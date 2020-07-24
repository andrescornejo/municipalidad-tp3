/*
 * Stored Procedure: csp_agregarPropiedades
 * Description: 
 * Author: Andres Cornejo
 */
USE municipalidad
GO

IF EXISTS (
		SELECT *
		FROM sysobjects
		WHERE id = object_id(N'[dbo].[csp_agregarPropiedades]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
BEGIN
	DROP PROCEDURE dbo.csp_agregarPropiedades
END
GO

CREATE PROC csp_agregarPropiedades @fechaInput DATE, @OperacionXML XML
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON

		DECLARE @hdoc INT
		DECLARE @PropiedadRef INT

		EXEC sp_xml_preparedocument @hdoc OUT,
			@OperacionXML

		DECLARE @tmpProp TABLE (
			NumFinca INT,
			Valor MONEY,
			Direccion NVARCHAR(max),
			fechaxml DATE
			)

		INSERT INTO @tmpProp (
			NumFinca,
			Valor,
			Direccion,
			fechaxml
			)
		SELECT NumFinca,
			Valor,
			Direccion,
			fecha
		FROM openxml(@hdoc, '/Operaciones_por_Dia/OperacionDia/Propiedad', 1) WITH (
				NumFinca INT,
				Valor MONEY,
				Direccion NVARCHAR(MAX),
				fecha DATE '../@fecha'
				)
		WHERE @fechaInput = fecha

		EXEC sp_xml_removedocument @hdoc;
		--select * from @tmpProp

		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		BEGIN TRANSACTION

		WHILE (SELECT COUNT(*) FROM @tmpProp) > 0
		BEGIN
			SET @PropiedadRef = (SELECT TOP 1 tmp.NumFinca FROM @tmpProp tmp)

			INSERT dbo.Propiedad (
				NumFinca,
				Valor,
				Direccion,
				activo,
				ConsumoAcumuladoM3,
				UltimoConsumoM3
				)
			SELECT tp.NumFinca,
				tp.Valor,
				tp.Direccion,
				1,
				0,
				0
			FROM @tmpProp tp
			WHERE tp.NumFinca = @PropiedadRef

			DELETE @tmpProp WHERE NumFinca = @PropiedadRef
		END
		COMMIT

		RETURN 1
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK

		DECLARE @errorMsg NVARCHAR(200) = (
				SELECT ERROR_MESSAGE()
				)

		PRINT ('ERROR:' + @errorMsg)

		RETURN - 1 * @@ERROR
	END CATCH
END
GO


