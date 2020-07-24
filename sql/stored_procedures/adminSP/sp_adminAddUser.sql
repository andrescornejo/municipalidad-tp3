/*
 * Stored Procedure: csp_adminAddUser
 * Description: 
 * Author: Andres Cornejo
 * Modified by: Pablo Alpizar
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_adminAddUser @inputUsername NVARCHAR(50),
	@inputPasswd NVARCHAR(100),
	@inputBit BIT,
	@inputInsertBy NVARCHAR(100),
	@inputInsertIn NVARCHAR(20)
AS
BEGIN
	BEGIN TRY
		DECLARE @jsonDespues NVARCHAR(500)
		DECLARE @idEntidad INT
		DECLARE @Admin NVARCHAR(20)

		SET NOCOUNT ON
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

		BEGIN TRANSACTION

		-- insert user
		INSERT Usuario (
			username,
			passwd,
			isAdmin,
			activo
			)
		SELECT @inputUsername,
			@inputPasswd,
			@inputBit,
			1

		-- save change of the table into bitácora
		SET @idEntidad = (SELECT U.id FROM [dbo].[Usuario] U WHERE U.username = @inputUsername)
		SET @Admin = (CASE WHEN @inputBit = 1
						THEN 'Administrador'
						ELSE 'Cliente'
					END)
		SET @jsonDespues = (SELECT
							@idEntidad AS 'ID',
							@inputUsername AS 'Nombre Usuario', 
							'*****' AS 'Contraseña', 
							@Admin AS 'Tipo Usuario', 
							'Activo' AS 'Estado'
							FOR JSON PATH, ROOT('Usuario'))
		
		INSERT INTO [dbo].[Bitacora] (
			idTipoEntidad,
			idEntidad, 
			jsonDespues,
			insertedAt,
			insertedBy,
			insertedIn
		) SELECT
		T.id,
		@idEntidad,
		@jsonDespues,
		GETDATE(),
		@inputInsertBy,
		@inputInsertIn
		FROM [dbo].[TipoEntidad] T
		WHERE T.Nombre = 'Usuario'
		
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

-- EXEC csp_adminAddUser 'puto', 'puto', 1
-- SELECT * FROM Usuario
