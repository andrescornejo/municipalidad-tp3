/*
 * Stored Procedure: csp_getRecibosPagados 
 * Description: 
 * Author: Andres Cornejo
 */

use municipalidad
go

create or alter proc csp_getRecibosPagados @inNumFinca INT 
as
begin
	begin try
		set nocount on
		
		SELECT 
			@inNumFinca AS [Numero Finca],
			R.idComprobantePago AS [Comprobante de Pago],
			C.nombre AS [Concepto Cobro],
			R.fecha AS [Fecha de Emision],
			R.fechaVencimiento AS [Fecha Vencimiento],
			R.monto AS [Monto Total]
		FROM [dbo].[Recibo] R
		INNER JOIN [dbo].[ConceptoCobro] C ON R.idConceptoCobro = C.id 
		INNER JOIN [dbo].[Propiedad] P ON P.NumFinca = @inNumFinca
		WHERE R.esPendiente = 0 AND R.activo = 1
			AND R.idPropiedad = P.id

	end try
	begin catch
		IF @@TRANCOUNT > 0
			ROLLBACK

		DECLARE @errorMsg NVARCHAR(200) = (
				SELECT ERROR_MESSAGE()
				)

		PRINT ('ERROR:' + @errorMsg)

		RETURN - 1 * @@ERROR
	end catch
end

go