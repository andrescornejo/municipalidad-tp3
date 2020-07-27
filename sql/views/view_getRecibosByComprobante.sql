/*
 * View: getRecibos 
 * Description: 
 * Author: Pablo Alpizar Monge
 */


USE municipalidad
GO


CREATE 
OR ALTER VIEW Recibos
AS 
SELECT R.idComprobantePago, 
    R.id,
    R.fecha,
    R.fechaVencimiento,
    C.nombre,
    R.monto
FROM [dbo].[Recibo] R
INNER JOIN [dbo].[ConceptoCobro] C ON R.idConceptoCobro = C.id