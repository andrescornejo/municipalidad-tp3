/*
 * Stored Procedure: csp_getMovAPFromAP
 * Description: get all movement from one AP
 * Author: Pablo Alpizar
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_getMovAPFromAP @inIdAP INT
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON

        SELECT
            M.id,
            M.fecha AS [fecha],
            T.Nombre AS [TipoMov],
            M.monto AS [monto],
            M.nuevoSaldo AS [saldo],
            M.interesDelMes AS [interes],
            M.PlazoResta AS [plazoResta]
        FROM [MovimientoAP] M
        INNER JOIN [TipoMovAP] T ON M.idTipoMovAp = T.id
        WHERE idAP = @inIdAP AND  M.activo = 1
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

