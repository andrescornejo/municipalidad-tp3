/*
 * Stored Procedure: 
 * Description: 
 * Author: Andres Cornejo
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_cleanComprobantes
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON

		DELETE
		FROM ComprobanteDePago
		WHERE MontoTotal = 0.00
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


