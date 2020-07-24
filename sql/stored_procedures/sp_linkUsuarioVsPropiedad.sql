/*
 * Stored Procedure: csp_linkUsuarioVsPropiedad
 * Description: 
 * Author: Andres Cornejo
 * Modified by: Pablo Alpizar
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_linkUsuarioVsPropiedad @fechaInput DATE, @OperacionXML XML
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON

		DECLARE @UserRef NVARCHAR(100)
		DECLARE @PropiedadRef INT 
		DECLARE @idEntidad INT
		DECLARE @jsonDespues NVARCHAR(500)
		DECLARE @hdoc INT

		EXEC sp_xml_preparedocument @hdoc OUT,
			@OperacionXML

		DECLARE @tmpUSvsProp TABLE (
			NumFinca INT,
			nombreUsuario NVARCHAR(50),
			fechaxml DATE
			)

		INSERT @tmpUSvsProp (
			NumFinca,
			nombreUsuario,
			fechaxml
			)
		SELECT NumFinca,
			nombreUsuario,
			fecha
		FROM openxml(@hdoc, '/Operaciones_por_Dia/OperacionDia/UsuarioVersusPropiedad', 1) WITH (
				NumFinca INT,
				nombreUsuario NVARCHAR(50),
				fecha DATE '../@fecha'
				)
		WHERE @fechaInput = fecha


		EXEC sp_xml_removedocument @hdoc;
		--select * from @tmpUSvsProp
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

		BEGIN TRANSACTION

		INSERT UsuarioVsPropiedad (
			idUsuario,
			idPropiedad,
			activo
			)
		SELECT U.id,
			P.id,
			1
		FROM @tmpUSvsProp tmp
		INNER JOIN Usuario U ON U.username = tmp.nombreUsuario
		INNER JOIN Propiedad P ON P.NumFinca = tmp.NumFinca

		--insert register into bitacora
		WHILE (SELECT COUNT(*) FROM @tmpUSvsProp) > 0
		BEGIN
			SET @UserRef = (SELECT TOP 1 tmp.nombreUsuario FROM @tmpUSvsProp tmp)
			SET @PropiedadRef = (SELECT TOP 1 tmp.NumFinca FROM @tmpUSvsProp tmp)
			DELETE @tmpUSvsProp WHERE nombreUsuario = @UserRef AND NumFinca = @PropiedadRef

			SET @idEntidad = (SELECT UP.id FROM [dbo].[UsuarioVsPropiedad] UP
								INNER JOIN [dbo].[Usuario] U ON U.username = @UserRef
								INNER JOIN [dbo].[Propiedad] P ON P.NumFinca = @PropiedadRef
								WHERE UP.idPropiedad = P.id AND UP.idUsuario = U.id)

			SET @jsonDespues = (SELECT 
								@UserRef AS 'Nombre Usuario',
								@PropiedadRef AS 'Numero Finca',
								'activo' AS 'Estado'
								FOR JSON PATH, ROOT('Propiedad-Usuario'))

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
			WHERE T.Nombre = 'PropiedadVsUsuario'		
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


