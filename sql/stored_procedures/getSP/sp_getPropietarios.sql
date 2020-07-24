/*
 * Stored Procedure: csp_getPropietarios
 * Description: Gets all from Propietario by name
 * Author: Andres Cornejo
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_getPropietarios
AS
BEGIN
	SELECT p.nombre AS [name],
		p.valorDocID AS [docid],
		t.nombre AS [tid],
		p.id AS [id]
	FROM Propietario p
	JOIN TipoDocID t ON t.id = p.idTipoDocID
	WHERE p.activo = 1
	ORDER BY p.nombre
END
GO

--exec csp_getPropietarios
