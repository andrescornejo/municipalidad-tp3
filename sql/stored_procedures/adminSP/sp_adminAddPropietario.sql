/*
 * Stored Procedure: csp_adminAddPropietario
 * Description: 
 * Author: Andres Cornejo
 * Modified by: Pablo Alpizar
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_adminAddPropietario @inputName NVARCHAR(50),
	@inputDocIDVal NVARCHAR(100),
	@inputDocID NVARCHAR(50),
	@inputInsertBy NVARCHAR(100),
	@inputInsertIn NVARCHAR(20)
AS
BEGIN
	BEGIN TRY
		DECLARE @DocidID INT
		DECLARE @jsonDespues NVARCHAR(500)
		DECLARE @idEntidad INT

		EXEC @DocidID = csp_getDocidIDFromName @inputDocID

		--PRINT (@DocidID)
		SET NOCOUNT ON
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

		BEGIN TRANSACTION

		-- insert new owner
		
		INSERT Propietario (
			nombre,
			valorDocID,
			idTipoDocID,
			activo
			)
		SELECT @inputName,
			@inputDocIDVal,
			@DocidID,
			1

		--insert into bitacora
		SET @jsonDespues = (SELECT
								@inputName AS 'Nombre', 
								T.nombre AS 'Tipo DocID', 
								@inputDocIDVal AS 'Valor ID', 
								'Activo' AS 'Estado'
							FROM [dbo].[Propietario] P
							JOIN [dbo].[TipoDocID] T ON T.id = @DocidID
							WHERE P.valorDocID = @inputDocIDVal
							FOR JSON PATH,ROOT('Propietario'))

		INSERT INTO [dbo].[Bitacora] (
			idTipoEntidad,
			idEntidad, 
			jsonDespues,
			insertedAt,
			insertedBy,
			insertedIn
		) SELECT
		T.id,
		SCOPE_IDENTITY(),
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

--exec csp_adminAddPropietario 'andres', '12315', 'Cedula Juridica', 'flamingo', 'hannibal'

