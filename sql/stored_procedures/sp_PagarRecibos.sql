/*
 * Stored Procedure: csp_pagarRecibos
 * Description: 
 * Author: Pablo Alpizar
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_pagarRecibos @inTableIdRecibos INT
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON

		DECLARE @idComprobante INT,
			@idRecibo INT,
            @idPropiedad INT

		INSERT INTO [dbo].[ComprobanteDePago] (
			fecha,
			MontoTotal,
			activo
			)
		SELECT GETDATE(),
			0,
			1

		SET @idComprobante = (
				SELECT TOP (1) CP.id
				FROM [dbo].[ComprobanteDePago] CP
				ORDER BY CP.id DESC
				)

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

            UPDATE [dbo].[ComprobanteDePago]
            SET MontoTotal = MontoTotal + (
                SELECT R.monto FROM [dbo].[Recibo] R
                WHERE R.id = @idRecibo
            )
            WHERE id = @idComprobante

			IF EXISTS (SELECT RE.id FROM [dbo].[Reconexion] RE WHERE RE.id = @idRecibo)
			BEGIN
                SET @idPropiedad = (SELECT R.idPropiedad FROM [dbo].[Recibo] R WHERE R.id = @idRecibo)
				EXEC csp_generarOrdReconexion GETDATE(), @idPropiedad, @idRecibo
			END            
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


