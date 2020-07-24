/*
 * Stored Procedure: csp_getPropiedadesDePropietario
 * Description: 
 * Author: Andres Cornejo
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_getPropiedadesDePropietario @idInput NVARCHAR(100)
AS
BEGIN
	DECLARE @idPropietario INT = (
			SELECT P.id
			FROM Propietario P
			WHERE @idInput = P.valorDocId
			);

	SELECT P.NumFinca AS [# Propiedad],
		P.Valor AS [Valor],
		P.Direccion AS [Direccion]
	FROM Propiedad P
	JOIN PropiedadDelPropietario PP ON P.id = PP.idPropietario
		AND PP.activo = 1
	WHERE @idPropietario = PP.idPropietario
		AND P.activo = 1
END
	--EXEC csp_getPropiedadesDePropietario 301410305
