/*
 * Stored Procedure: csp_agregarCambioValorPropiedad
 * Description: 
 * Author: Pablo Alpizar
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_agregarCambioValorPropiedad (@inFecha DATE, @OperacionXML XML)
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON
		DECLARE @hdoc INT
		DECLARE @numFinca INT

		EXEC sp_xml_preparedocument @hdoc OUT,
			@OperacionXML

		DECLARE @tmpValorProp TABLE (
			NumFinca INT,
			Valor MONEY
			)

		INSERT INTO @tmpValorProp (
			NumFinca,
			Valor
			)
		SELECT NumFinca,
			NuevoValor
		FROM openxml(@hdoc, '/Operaciones_por_Dia/OperacionDia/CambioPropiedad ', 1) WITH (
				NumFinca INT,
				NuevoValor MONEY,
				fecha DATE '../@fecha'
				)
		WHERE @inFecha = fecha

		EXEC sp_xml_removedocument @hdoc;

		BEGIN TRANSACTION

		WHILE ( SELECT COUNT(*) FROM @tmpValorProp) > 0
		BEGIN
			--Seleccionamos la primera tabla
			SET  @numFinca = (SELECT TOP 1 tmp.NumFinca
			FROM @tmpValorProp tmp ORDER BY tmp.NumFinca DESC)

			UPDATE dbo.Propiedad
			SET Valor = (
					SELECT tmp.Valor
					FROM @tmpValorProp tmp
					WHERE @numFinca = tmp.NumFinca
					)
			WHERE NumFinca = @numFinca
				-- add change to bitacora table triggers

			-- Borramos el registro
			DELETE @tmpValorProp
			WHERE NumFinca = @numFinca
		END

		COMMIT
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


