/*
 * Stored Procedure: csp_getDocidIDFromName
 * Description: Retorna el id del la tabla tipoDocID, a partir del nombre.
 * Author: Andres Cornejo
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_getDocidIDFromName @inputName NVARCHAR(100)
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON

		DECLARE @outputID INT = (
				SELECT TOP 1 d.id
				FROM TipoDocID d
				WHERE d.nombre = @inputName
				AND d.activo = 1
				)

		RETURN @outputID
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

-- exec csp_getDocidIDFromName 'Cedula Nacional'
