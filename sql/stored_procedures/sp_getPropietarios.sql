/*
 * Stored Procedure: csp_getPropietarios
 * Description: Gets all from Propietario by name
 * Author: Andres Cornejo
 */

USE municipalidad
GO

CREATE OR ALTER PROC csp_getPropietarios AS
BEGIN

    SELECT P.valorDocID AS Identificacion,
    P.nombre AS Nombre, 
    TD.nombre AS [Tipo de documento]
    FROM Propietario P 
    JOIN TipoDocID TD ON P.idTipoDocID = TD.id
    WHERE p.activo = 1
    order by p.nombre

END
GO

--exec csp_getPropietarios
