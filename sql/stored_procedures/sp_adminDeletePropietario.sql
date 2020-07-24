/*
 * Stored Procedure: csp_adminDeletePropietario
 * Description: Borrado logico de Objeto Propietario
 * Author: Andres Cornejo
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_adminDeletePropietario @InputDocID NVARCHAR(20),
@inputInsertBy NVARCHAR(100),
@inputInsertIn NVARCHAR(20)
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON

		DECLARE @idPropietario INT
		DECLARE @jsonAntes NVARCHAR(500)
		DECLARE @jsonDespues NVARCHAR(500)
		DECLARE @idEntidad INT
		
		EXEC @idPropietario = csp_getPropietarioIDFromDocID @InputDocID

		SET @jsonAntes = (SELECT 
						P.id AS 'ID', 
						P.nombre AS 'Nombre', 
						T.nombre AS 'Tipo DocID' , 
						@inputDocID AS 'Valor ID', 
						'Activo' AS 'Estado'
					FROM [dbo].[Propietario] P
					JOIN [dbo].[TipoDocID] T ON T.id = P.idTipoDocID
					WHERE P.valorDocID = @inputDocID
					FOR JSON PATH,ROOT('Propietario'))

		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		BEGIN TRANSACTION

		update PropietarioJuridico
		set activo = 0
		WHERE id = @idPropietario

		update PropiedadDelPropietario
		set activo = 0
		WHERE idPropietario = @idPropietario

		update Propietario
		set activo = 0
		WHERE id = @idPropietario
		
		SET @jsonDespues = (SELECT 
						P.id AS 'ID', 
						P.nombre AS 'Nombre', 
						T.nombre AS 'Tipo DocID' , 
						@inputDocID AS 'Valor ID', 
						'Activo' AS 'Estado'
					FROM [dbo].[Propietario] P
					JOIN [dbo].[TipoDocID] T ON T.id = P.idTipoDocID
					WHERE P.valorDocID = @inputDocID
					FOR JSON PATH,ROOT('Propietario'))

		INSERT INTO [dbo].[Bitacora] (
			idTipoEntidad,
			idEntidad,
			jsonAntes, 
			jsonDespues,
			insertedAt,
			insertedBy,
			insertedIn
		) SELECT
			T.id,
			@idEntidad,
			@jsonAntes,
			@jsonDespues,
			GETDATE(),
			@inputInsertBy,
			@inputInsertIn
		FROM [dbo].[TipoEntidad] T
		WHERE T.Nombre = 'Propietario'
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

--EXEC csp_adminDeletePropietario '301777068'
