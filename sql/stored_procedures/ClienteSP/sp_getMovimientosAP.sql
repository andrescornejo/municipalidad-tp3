/*
 * Stored Procedure: csp_getMovimientosAP
 * Description: 
 * Author: Pablo Alpizar
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_getMovimientosAP @inIdAP INT
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON

			SELECT 
				M.id AS [ID],
				T.Nombre AS [TipoMovAP],
				M.monto AS [Monto],
				M.interesDelMes AS [MontoInt],
				M.PlazoResta AS [PlazoResta],
				M.nuevoSaldo AS [SaldoRestante],
				M.fecha AS [Fecha]
			FROM [dbo].[MovimientoAP] M
			INNER JOIN [dbo].[TipoMovAP] T ON T.id = M.idTipoMovAp
			WHERE M.idAP = @inIdAP
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


