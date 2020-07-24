/*
 * Stored Procedure: csp_adminUpdateUsuario
 * Description: Actualizacion de un Usuario por un Admin.
 * Author: Andres Cornejo
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_adminUpdateUsuario @inID int,
	@inputNewUsername NVARCHAR(50),
	@inputNewPassword NVARCHAR(100),
	@inputAdminStatus BIT,
	@inputInsertedBy NVARCHAR(100),
	@inputInsertedIn NVARCHAR(20)
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON

		DECLARE @jsonAntes NVARCHAR(500)
		DECLARE @jsonDespues NVARCHAR(500)
		DECLARE @adminBefore NVARCHAR(500)
		DECLARE @adminAfter NVARCHAR(500)
		DECLARE @oldAdminStatus BIT
		DECLARE @newPasswd NVARCHAR(500)

		IF @inputNewPassword = '*****'
			set @newPasswd = (select u.passwd from Usuario u where u.id = @inID)
		ELSE
			set @newPasswd = @inputNewPassword

		SET @oldAdminStatus = (
				SELECT u.isAdmin
				FROM Usuario u
				WHERE u.id = @inID
				)
		SET @adminBefore = (
				CASE 
					WHEN @oldAdminStatus = 1
						THEN 'Administrador'
					ELSE 'Cliente'
					END
				)
		SET @adminAfter = (
				CASE 
					WHEN @inputAdminStatus = 1
						THEN 'Administrador'
					ELSE 'Cliente'
					END
				)
		SET @jsonAntes = (
				SELECT u.username AS 'Nombre Usuario',
					'*****' AS 'Contraseña',
					u.isAdmin AS 'Tipo Usuario',
					'Activo' AS 'Estado'
					from Usuario u where u.id = @inID
				FOR JSON PATH,
					ROOT('Usuario')
				)
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

		BEGIN TRANSACTION

		UPDATE Usuario
		SET username = @inputNewUsername,
			passwd = @newPasswd,
			isAdmin = @inputAdminStatus
		WHERE id = @inID
			AND activo = 1

		-- inset into bitacora
		SET @jsonDespues = (
				SELECT u.username AS 'Nombre Usuario',
					'*****' AS 'Contraseña',
					u.isAdmin AS 'Tipo Usuario',
					'Activo' AS 'Estado'
					from Usuario u where u.id = @inID
				FOR JSON PATH,
					ROOT('Usuario')
				)

		INSERT INTO [dbo].[Bitacora] (
			idTipoEntidad,
			idEntidad,
			jsonAntes,
			jsonDespues,
			insertedAt,
			insertedBy,
			insertedIn
			)
		SELECT T.id,
			@inID,
			@jsonAntes,
			@jsonDespues,
			GETDATE(),
			@inputInsertedBy,
			@inputInsertedIn
		FROM [dbo].[TipoEntidad] T
		JOIN [dbo].[Usuario] U ON @inputNewUsername = U.username
			AND U.activo = 1
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

-- EXEC csp_adminUpdateUsuario 'lol', 'fengJP', 'yeet', 0, 'lskdjf', 'asldkfj';
