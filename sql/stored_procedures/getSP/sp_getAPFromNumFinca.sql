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
            A.id AS [id],
            @inNumFinca AS [finca],
            A.plazoOriginal AS [plazo],
            A.plazoResta AS [plazoResta],
            A.idComprobante AS [cmp],
            A.montoOriginal AS [monto],
            A.saldo AS [saldo],
            A.cuota AS [cuota],
            (A.tasaInteresAnual * 100) AS [TasaI],
            A.insertedAt AS [fecha],
            A.updatedAt AS [fechaA]
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

