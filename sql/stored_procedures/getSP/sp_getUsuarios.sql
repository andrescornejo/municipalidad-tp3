/*
 * Stored Procedure: csp_getUsuarios
 * Description: Gets all from Propietario by name
 * Author: Andres Cornejo
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_getUsuarios
AS
BEGIN
	SELECT u.username AS [usr],
		'*****' AS [psswd],
		u.isAdmin AS [isAdmin],
		u.id AS [id]
	FROM Usuario u
	WHERE u.activo = 1
	ORDER BY u.username
END
GO

--exec csp_getUsuarios
