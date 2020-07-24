/*
 * Stored Procedure: csp_getPropiedades
 * Description: 
 * Author: Andres Cornejo
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_getPropiedades
AS
BEGIN
	SELECT P.numFinca AS [numFin],
		CAST(P.valor  AS int) AS [val],
		P.Direccion AS [dir],
		P.ConsumoAcumuladoM3 as [cAm3],
		P.UltimoConsumoM3 as [uCm3],
		P.id as [id]
	FROM Propiedad P
	WHERE P.activo = 1
END
	--EXEC csp_getPropiedades
