/*
 * Stored Procedure: csp_getUserIDFromUsername
 * Description: Retorna el id de un usuario, a partir de su nombre de usuario.
 * Author: Andres Cornejo
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_getUserIDFromUsername @inputUsername NVARCHAR(50),
	@outputID INT OUTPUT
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON
		SET @outputID = (
				SELECT TOP 1 u.id
				FROM Usuario u
				WHERE u.username = @inputUsername
					AND u.activo = 1
				)

		--PRINT (@outputID)
		RETURN @outputID
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

--EXEC csp_getUserIDFromUsername 'jpfeng'
