/*
 * Stored Procedure: csp_getJsonDespues
 * Description: Gets the jsonAntes from the log table.
 * Author: Andres Cornejo
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_getJsonDespues @inBitacoraID INT,
	@outJson VARCHAR(max) OUTPUT
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON
		SET @outJson = (
				SELECT b.jsonDespues
				FROM Bitacora b
				WHERE b.id = @inBitacoraID
				)

		RETURN 0
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


