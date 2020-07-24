/*
 * Stored Procedure: csp_getPropiedadesDeUsuario
 * Description: 
 * Author: Andres Cornejo
 */

USE municipalidad
GO

CREATE OR ALTER PROC csp_getPropiedadesDeUsuario @usernameInput NVARCHAR(100)
AS
BEGIN

    DECLARE @idUser INT = (SELECT U.id FROM Usuario U WHERE @usernameInput = U.username);

    SELECT P.NumFinca AS [# Propiedad],P.Valor AS [Valor], P.Direccion AS [Direccion]
    FROM Propiedad P JOIN UsuarioVsPropiedad UVP ON P.id = UVP.idPropiedad
    WHERE @idUser = UVP.idUsuario AND UVP.activo = 1

END
