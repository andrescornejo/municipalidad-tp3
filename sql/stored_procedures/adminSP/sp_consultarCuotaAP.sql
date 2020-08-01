/*
 * Stored Procedure: csp_consultaCuotaAP
 * Description: 
 * Author: Pablo Alpizar
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_consultaCuotaAP @inMontoAP MONEY, @inPlazo INT, @outCuotaAP MONEY OUT
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON
        DECLARE @TasaInteres FLOAT

        -- calcular la cuota de pago
        -- R = P [(i (1 + i)n) / ((1 + i)n – 1)]    R = renta (cuota), P = principal (préstamo adquirido)
        -- i = tasa de interés, n = número de periodos
        SET @outCuotaAP = @inMontoAP * (@TasaInteres * POWER((1 + @TasaInteres),@inPlazo)/POWER((1 + @TasaInteres),@inPlazo) - 1)
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