/*
 * Stored Procedure: csp_getRecibosPendientes
 * Description: 
 * Author: Pablo Alpizar
 * Modified by: Andrés Cornejo
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_getRecibosPendientes @inNumFinca INT
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON

		SELECT
			R.id as [id],
			@inNumFinca AS [Numero Finca],
			C.nombre AS [Concepto Cobro],
			R.fecha AS [Fecha de Emision],
			R.fechaVencimiento AS [Fecha Vencimiento],
			R.monto AS [Monto Total]
		FROM [dbo].[Recibo] R
		INNER JOIN [dbo].[ConceptoCobro] C ON R.idConceptoCobro = C.id
		INNER JOIN [dbo].[Propiedad] P ON P.NumFinca = @inNumFinca
		WHERE R.esPendiente = 1
			AND R.activo = 1
			AND R.idPropiedad = P.id
		Order by R.fecha asc
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


