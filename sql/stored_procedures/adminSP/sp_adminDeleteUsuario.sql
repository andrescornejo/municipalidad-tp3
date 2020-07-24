/*
 * Stored Procedure: csp_adminAddUser
 * Description: Borrado logico de objeto usuario.
 * Author: Andres Cornejo
 * Modified by: Pablo Alpizar
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_adminDeleteUsuario @inUsr NVARCHAR(100),
	@inputInsertedBy NVARCHAR(100),
	@inputInsertedIn NVARCHAR(20)
AS
BEGIN
	DECLARE @jsonAntesUsuario NVARCHAR(500)
	DECLARE @jsonDespuesUsuario NVARCHAR(500)
	DECLARE @Admin NVARCHAR(20)
	DECLARE @isAdmin BIT
	declare @usrID int

	set @usrID = (select u.id from Usuario u where u.username = @inUsr)
	print(@usrID)

	BEGIN TRY
		SET @isAdmin = (
				SELECT U.isAdmin
				FROM [dbo].[Usuario] U
				WHERE U.id = @usrID
				)
		SET @Admin = (
				CASE 
					WHEN @isAdmin = 1
						THEN 'Administrador'
					ELSE 'Cliente'
					END
				)
		SET @jsonAntesUsuario = (
				SELECT U.id AS 'ID',
					U.username AS 'Nombre Usuario',
					'*****' AS 'Contraseña',
					@Admin AS 'Tipo Usuario',
					'Activo' AS 'Estado'
				FROM [dbo].[Usuario] U
				WHERE U.id = @usrID
				FOR JSON PATH,
					ROOT('Usuario')
				)
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

		BEGIN TRANSACTION

		UPDATE UsuarioVsPropiedad
		SET activo = 0
		WHERE idUsuario = @usrID

		-- Necesito iterar por cada relacion entre propiedad y usuario
		-- Falta agregar los cambios de las relaaciones Usuario Vs Propiedad
		UPDATE Usuario
		SET activo = 0
		WHERE id = @usrID

		-- insert into bitacora

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
			@usrID,
			@jsonAntesUsuario,
			null,
			GETDATE(),
			@inputInsertedBy,
			@inputInsertedIn
		FROM [dbo].[TipoEntidad] T
		WHERE T.Nombre = 'Usuario'

		COMMIT

		RETURN 0
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK

		RETURN - 1
	END CATCH
END
GO

--EXEC csp_adminDeleteUsuario 'lmaoxd'
