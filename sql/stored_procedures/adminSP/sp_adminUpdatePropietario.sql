/*
 * Stored Procedure: csp_adminUpdatePropietario
 * Description: Actualizacion de informacion a Propietario por parte de un Admin.
 * Author: Andres Cornejo
 * Modified by: Pablo Alpizar
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_adminUpdatePropietario @inID int,
	@inputName NVARCHAR(50),
	@inputDocIDVal NVARCHAR(100),
	@inputDocID NVARCHAR(50),
	@inputInsertedBy NVARCHAR(100),
	@inputInsertedIn NVARCHAR(20)
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON

		DECLARE @idPropietario INT
		DECLARE @jsonAntes NVARCHAR(500)
		DECLARE @jsonDespues NVARCHAR(500)

		DECLARE @DocidID INT

		EXEC @DocidID = csp_getDocidIDFromName @inputDocID

		SET @jsonAntes = (
				SELECT P.nombre AS 'Nombre',
					P.valorDocID AS 'Valor del documento legal',
					T.nombre AS 'Tipo de documento legal',
					'Activo' AS 'Estado'
				FROM [dbo].[Propietario] P
				JOIN [dbo].[TipoDocID] T ON T.id = P.idTipoDocID
				WHERE P.id = @inID
				FOR JSON PATH,
					ROOT('Propietario')
				)
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

		BEGIN TRANSACTION

		UPDATE Propietario
		SET nombre = @inputName,
			valorDocID = @inputDocIDVal,
			idTipoDocID = @DocidID
		WHERE id = @inID
			AND activo = 1

		-- insert change into bitacora
		SET @jsonDespues = (
				SELECT P.nombre AS 'Nombre',
					P.valorDocID AS 'Valor del documento legal',
					T.nombre AS 'Tipo de documento legal',
					'Activo' AS 'Estado'
				FROM [dbo].[Propietario] P
				JOIN [dbo].[TipoDocID] T ON T.id = P.idTipoDocID
				WHERE P.id = @inID
				FOR JSON PATH,
					ROOT('Propietario')
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
		JOIN [dbo].[Propietario] P ON P.valorDocID = @inputDocIDVal
			AND P.activo = 1
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


