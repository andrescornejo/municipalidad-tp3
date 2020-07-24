/*
 * Stored Procedure: csp_linkCCenPropiedad
 * Description: Links the CCenPropiedad table with the ConceptoCobro and Propiedad tables.
 * Author: Andres Cornejo
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_linkCCenPropiedad @fechaInput DATE
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON

		DECLARE @OperacionXML XML

		SELECT @OperacionXML = O
		FROM openrowset(BULK 'C:\xml\Operaciones.xml', single_blob) AS Operacion(O)

		DECLARE @hdoc INT

		EXEC sp_xml_preparedocument @hdoc OUT,
			@OperacionXML

		DECLARE @tmpCCenProp TABLE (
			idcobro INT,
			NumFinca INT,
			fechaxml DATE
			)

		INSERT @tmpCCenProp (
			idcobro,
			NumFinca,
			fechaxml
			)
		SELECT idcobro,
			NumFinca,
			fecha
		FROM openxml(@hdoc, '/Operaciones_por_Dia/OperacionDia/ConceptoCobroVersusPropiedad', 1) WITH (
				idcobro INT,
				NumFinca INT,
				fecha DATE '../@fecha'
				)
		WHERE @fechaInput = fecha

		--select * from @tmpCCenProp
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

		BEGIN TRANSACTION

		INSERT dbo.CCenPropiedad (
			idConceptoCobro,
			idPropiedad,
			fechaInicio,
			activo
			)
		SELECT cp.idcobro,
			P.id,
			@fechaInput,
			1
		FROM @tmpCCenProp AS cp
		JOIN Propiedad P ON P.NumFinca = cp.NumFinca

		--select * from CCenPropiedad
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


