/*
 * Stored Procedure: sp_AnularPagoRecibos
 * Description: 
 * Author: Pablo Alpizar
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC sp_AnularPagoRecibos @inTableInfoRecibos INT
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON
        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		BEGIN TRANSACTION

		WHILE (
				SELECT COUNT(IR.id)
				FROM @inTableIdRecibos
				) > 0
		BEGIN
			SET @idRecibo = (
					SELECT TOP (1) IR.id
					FROM @inTableIdRecibos
					)

			DELETE TOP (1)
			FROM @inTableIdRecibos

			UPDATE [dbo].[Recibo]
			SET esPendiente = 0,
				idComprobantePago = @idComprobante
			WHERE id = @idRecibo          
		END
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


