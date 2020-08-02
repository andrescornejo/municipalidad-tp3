/*
 * Stored Procedure: csp_consultaCuotaAP
 * Description: 
 * Author: Pablo Alpizar
 * Modified by: Andrés Cornejo
 *
 *
 * calcular la cuota de pago
 * R = P [(i (1 + i)^n) / ((1 + i)^n – 1)]    R = renta (cuota), P = principal (préstamo adquirido)
 * i = tasa de interés, n = número de periodos
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
        DECLARE @TasaInteres FLOAT, @Base float, @PoweredBase float, @finalExpression float
		set @TasaInteres = 0.1
		set @Base = 1 + @TasaInteres
		set @PoweredBase = POWER(@Base, @inPlazo)
		set @finalExpression = ((@TasaInteres * @PoweredBase)/(@PoweredBase - 1))
		set @finalExpression = @inMontoAP * @finalExpression
		set @outCuotaAP = @finalExpression

		--This wasn't working, so I did the same, but step by step.
        --SET @outCuotaAP = @inMontoAP * (@TasaInteres * POWER((1 + @TasaInteres),@inPlazo)/POWER((1 + @TasaInteres),@inPlazo) - 1)
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