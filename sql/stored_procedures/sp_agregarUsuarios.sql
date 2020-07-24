/*
 * Stored Procedure: csp_agregarUsuarios
 * Description: Agrega los usuarios de una fecha
 * Author: Andres Cornejo
 * Modified by: Pablo Alpizar
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_agregarUsuarios @fechaInput DATE, @OperacionXML XML
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON
		DECLARE @jsonDespues NVARCHAR(500)
		DECLARE @idEntidad INT
		DECLARE @Admin NVARCHAR(20)
		DECLARE @username NVARCHAR(100)

		DECLARE @hdoc INT

		EXEC sp_xml_preparedocument @hdoc OUT,
			@OperacionXML

		DECLARE @tmpUsuario TABLE (
			nombre NVARCHAR(50),
			passwd NVARCHAR(max),
			fechaxml DATE
			)

		INSERT @tmpUsuario (
			nombre,
			passwd,
			fechaxml
			)
		SELECT Nombre,
			password,
			fecha
		FROM openxml(@hdoc, '/Operaciones_por_Dia/OperacionDia/Usuario', 1) WITH (
				Nombre NVARCHAR(50),
				password NVARCHAR(max),
				fecha DATE '../@fecha'
				)
		WHERE @fechaInput = fecha


		EXEC sp_xml_removedocument @hdoc;
		--SELECT * FROM @tmpUsuario

		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

		BEGIN TRANSACTION

		INSERT Usuario (
			username,
			passwd,
			isAdmin,
			activo
			)
		SELECT t.nombre,
			t.passwd,
			0,
			1
		FROM @tmpUsuario t


		WHILE (SELECT COUNT(*) FROM @tmpUsuario) > 0
		BEGIN
			SET @username = (SELECT TOP 1 tmp.nombre FROM @tmpUsuario tmp)
			DELETE @tmpUsuario WHERE nombre = @username

			SET @idEntidad = (SELECT U.id FROM [dbo].[Usuario] U WHERE U.username = @username)

			SET @Admin = (CASE WHEN (SELECT U.isAdmin FROM [dbo].[Usuario] U WHERE U.id = @idEntidad) = 1
							THEN 'Administrador'
							ELSE 'Cliente'
						END)
			SET @jsonDespues = (SELECT
								@idEntidad AS 'ID',
								@username AS 'Nombre Usuario', 
								'*******' AS 'Contrasenna', 
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
				CONVERT(NVARCHAR(100), (SELECT @@SERVERNAME)),
				'192.168.1.7'
			FROM [dbo].[TipoEntidad] T
			WHERE T.Nombre = 'Usuario'
		END
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


