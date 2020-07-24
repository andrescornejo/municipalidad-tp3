/*
 * Stored Procedure: csp_agregarUsuarios
 * Description: Agrega los usuarios de una fecha
 * Author: Andres Cornejo
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_agregarUsuarios @fechaInput DATE
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON
		DECLARE @jsonDespues NVARCHAR(500)
		DECLARE @OperacionXML XML
		DECLARE @idEntidad INT
		DECLARE @Admin NVARCHAR(20)

		SELECT @OperacionXML = O
		FROM openrowset(BULK 'C:\xml\Operaciones.xml', single_blob) AS Operacion(O)

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
			passwd,
			fecha
		FROM openxml(@hdoc, '/Operaciones_por_Dia/OperacionDia/Usuario', 1) WITH (
				Nombre NVARCHAR(50),
				passwd NVARCHAR(max),
				fecha DATE '../@fecha'
				)
		WHERE @fechaInput = fecha

		-- SELECT * FROM @tmpUsuario

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
			

			SET @Admin = (CASE WHEN @inputBit = 1
							THEN 'Administrador'
							ELSE 'Cliente'
						END)
			SET @jsonDespues = (SELECT
								@idEntidad AS 'ID',
								@inputUsername AS 'Nombre Usuario', 
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


