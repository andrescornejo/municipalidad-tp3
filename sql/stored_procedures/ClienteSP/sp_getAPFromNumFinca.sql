/*
 * Stored Procedure: csp_getAPFromNumFinca
 * Description: 
 * Author: Pablo Alpizar Monge
 */
USE municipalidad
GO

CREATE
	OR
ALTER PROC csp_getAPFromNumFinca @inNumFinca INT
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON

        SELECT 
            A.id AS [ID],
            P.NumFinca AS [Numero Finca],
            A.idComprobante AS [Comprobante de pago],
            A.montoOriginal AS [Monto Total],
            A.saldo AS [Monto Restante],
            A.tasaInteresAnual AS [Tasa Interes],
            A.plazoOriginal AS [Plazo],
            A.plazoResta AS [Plazo Restante],
            A.cuota AS [Cuota],
            A.insertedAt AS [Fecha Creacion]
        FROM [dbo].[AP] A
        INNER JOIN [dbo].[Propiedad] P ON P.NumFinca = @inNumFinca
        WHERE A.activo = 1 AND A.idPropiedad = P.id
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


