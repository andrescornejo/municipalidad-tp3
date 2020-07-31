/*
 * Stored Procedure: csp_getRecibosFromComprobante
 * Description: 
 * Author: Andres Cornejo
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_getRecibosFromComprobante @inID INT
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON

		SELECT v.numRecibo,
			v.numProp,
			v.cc,
			v.fecha,
			v.vence,
			v.monto
		FROM view_Recibos v
		WHERE v.numCom = @inID
		ORDER BY v.fecha ASC
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


