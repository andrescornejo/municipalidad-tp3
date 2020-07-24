/*
 * Stored Procedure: csp_getUsernames
 * Description: Gets a table with all the usernames from the 'Usuario' table
 * Author: Andres Cornejo
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_getUsernames
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON

		SELECT u.username AS 'Nombre de usuario'
		FROM Usuario u
		WHERE u.activo = 1
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


