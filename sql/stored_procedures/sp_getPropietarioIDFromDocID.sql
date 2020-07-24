/*
 * Stored Procedure: csp_getPropietarioIDFromDocID
 * Description: Retorna el id de un Propietario, a partir de su numero de DocID
 * Author: Andres Cornejo
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_getPropietarioIDFromDocID @inputDocID NVARCHAR(100)
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON

		DECLARE @outputID INT

		SET @outputID = (
				SELECT TOP 1 p.id
				FROM Propietario p
				WHERE p.valorDocID = @inputDocID
				AND p.activo = 1
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

-- EXEC csp_getPropietarioIDFromDocID '303581304'
