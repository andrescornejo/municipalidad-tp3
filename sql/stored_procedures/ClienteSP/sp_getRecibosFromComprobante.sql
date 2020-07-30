/*
 * Stored Procedure: csp_getRecibosFromComprobante
 * Description: 
 * Author: Andres Cornejo
 */

use municipalidad
go

create or alter proc csp_getRecibosFromComprobante @inID int as
begin
	begin try
		set nocount on
		
		SELECT R.id AS [id],
			P.NumFinca AS [numP],
			C.nombre AS [cc],
			R.fecha AS [fecha],
			R.fechaVencimiento AS [vence],
			R.monto AS [monto]
			--DESCRIPCION
		FROM [dbo].[Recibo] R
		Inner join [dbo].[ComprobanteDePago] CP ON CP.id = R.idComprobantePago
		INNER JOIN [dbo].[ConceptoCobro] C ON R.idConceptoCobro = C.id
		INNER JOIN [dbo].[Propiedad] P ON P.id = R.idPropiedad
		WHERE R.idTipoEstado = (
				SELECT T.id
				FROM [dbo].[TipoEstadoRecibo] T
				WHERE T.estado = 'Pagado'
				)
			AND R.activo = 1
			and @inID = CP.id
		ORDER BY R.fecha ASC

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
