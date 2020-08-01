/*
 * Stored Procedure: 
 * Description: 
 * Author: Pablo Alpizar
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_generarReciboReconexiónAgua @inFecha DATE,
@inIdPropiedad INT
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON

		INSERT INTO [dbo].[Recibo] (
			idPropiedad,
			idConceptoCobro,
			idTipoEstado,
			fecha,
			fechaVencimiento,
			monto,
			activo
			)
		SELECT 
			@inIdPropiedad,
			C.id,
			T.id,
			@inFecha,
			@inFecha,
			CF.Monto,
			1
		FROM [dbo].[ConceptoCobro] C
		INNER JOIN [dbo].[CC_Fijo] CF ON C.id = CF.id
		INNER JOIN [dbo].[TipoEstadoRecibo] T ON T.estado = 'Pendiente'
		WHERE C.nombre = 'Reconexion de agua'
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


