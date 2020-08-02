/*
 * View: getRecibos 
 * Description: 
 * Author: Pablo Alpizar Monge
 */
USE municipalidad
GO

CREATE
	OR

ALTER VIEW view_Recibos
AS
SELECT R.idComprobantePago AS [numCom],
	R.id AS [numRecibo],
	p.NumFinca AS [numProp],
	R.fecha,
	R.fechaVencimiento AS [vence],
	C.nombre AS [cc],
	R.monto
FROM [dbo].[Recibo] R
INNER JOIN [dbo].[ConceptoCobro] C ON R.idConceptoCobro = C.id
INNER JOIN [dbo].[Propiedad] P ON R.idPropiedad = P.id
Inner join [dbo].[TipoEstadoRecibo] T on T.id = R.idTipoEstado
WHERE R.activo = 1 and t.estado = 'Pagado'
