/*
 * Stored Procedure: csp_generarRecibosAP
 * Description: 
 * Author: Pablo Alpizar
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_generarRecibosAP @inFecha DATE
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON
		DECLARE @tmpAP TABLE (id INT)

        INSERT INTO @tmpAP (id)
        

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


