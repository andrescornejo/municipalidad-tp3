/*
 * Stored Procedure: csp_adminPagoConAP
 * Description: 
 * Author: Pablo Alpizar
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_adminCrearAP @inNumFinca udt_Recibo READONLY,
@inMontoTotal MONEY,
@inPlazo INT, 
@inCuota MONEY
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON
		DECLARE @comprobante INT, @tasaInteres FLOAT

		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		BEGIN TRANSACTION

			INSERT INTO [dbo].[ComprobanteDePago] (fecha,MontoTotal,activo)
			SELECT GETDATE(),0,1

			INSERT INTO [dbo].[AP](idPropiedad,
				idComprobante,
				montoOriginal,
				saldo,
				tasaInteresAnual,
				plazoOriginal,
				plazoResta,
				cuota,
				insertedAt,
				updatedAt)
			SELECT P.id,
				@comprobante,
				@inMontoTotal,
				0,
				@tasaInteres,
				@inPlazo,
				@inPlazo,
				@inCuota,
				GETDATE(),
				GETDATE()
			FROM @inTableRecibos P


		COMMIT

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


