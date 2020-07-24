/*
 * Stored Procedure: csp_adminUpdatePropietario
 * Description: Actualizacion de informacion a Propietario por parte de un Admin.
 * Author: Andres Cornejo
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_adminUpdatePropietario @inputOLDDocID NVARCHAR(50),
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
		DECLARE @tmpJson NVARCHAR(500)
		DECLARE @jsonAntes NVARCHAR(500)
		DECLARE @jsonDespues NVARCHAR(500)

		EXEC @idPropietario = csp_getPropietarioIDFromDocID @inputOLDDocID

		DECLARE @DocidID INT

		EXEC @DocidID = csp_getDocidIDFromName @inputDocID

		SET @tmpJson = (
				SELECT P.nombre AS 'Nombre',
					T.nombre AS 'Tipo DocID',
					P.valorDocID AS 'Valor ID',
					'Activo' AS 'Estado'
				FROM [dbo].[Propietario] P
				JOIN [dbo].[TipoDocID] T ON T.id = P.idTipoDocID
				WHERE P.id = @idPropietario
				FOR JSON PATH,
					ROOT('Propietario')
				)
		SET @jsonAntes = @tmpJson
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

		BEGIN TRANSACTION

		UPDATE Propietario
		SET nombre = @inputName,
			valorDocID = @inputDocIDVal,
			idTipoDocID = @DocidID
		WHERE valorDocID = @inputOLDDocID
			AND activo = 1

		-- insert change into bitacora
		SET @jsonDespues = (
				SELECT @inputName AS 'Nombre',
					T.nombre AS 'Tipo DocID',
					@inputDocIDVal AS 'Valor ID',
					'Activo' AS 'Estado'
				FROM [dbo].[Propietario] P
				JOIN [dbo].[TipoDocID] T ON T.id = @DocidID
				WHERE P.valorDocID = @inputDocIDVal
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
			@idPropietario,
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


