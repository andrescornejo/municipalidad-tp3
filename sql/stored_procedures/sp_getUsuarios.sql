/*
 * Stored Procedure: csp_getUsuarios
 * Description: Gets all from Propietario by name
 * Author: Andres Cornejo
 */

USE municipalidad
GO

CREATE OR ALTER PROC csp_getUsuarios AS
BEGIN

    SELECT u.username AS 'Nombre de usuario',u.passwd AS 'Contraseña', u.isAdmin as 'Administrador'
    FROM Usuario u
    WHERE u.activo = 1
    order by u.username

END
GO

--exec csp_getUsuarios