/*
 * Stored Procedure: csp_getRecibosPagados 
 * Description: 
 * Author: Pablo Alpizar
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_getRecibosPagados @inNumFinca INT
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON

		SELECT @inNumFinca AS [Numero Finca],
			R.idComprobantePago AS [Comprobante de Pago],
			C.nombre AS [Concepto Cobro],
			R.fecha AS [Fecha de Emision],
			R.fechaVencimiento AS [Fecha Vencimiento],
			R.monto AS [Monto Total]
		FROM [dbo].[Recibo] R
		INNER JOIN [dbo].[ConceptoCobro] C ON R.idConceptoCobro = C.id
		INNER JOIN [dbo].[Propiedad] P ON P.NumFinca = @inNumFinca
		WHERE R.esPendiente = 0
			AND R.activo = 1
			AND R.idPropiedad = P.id
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


