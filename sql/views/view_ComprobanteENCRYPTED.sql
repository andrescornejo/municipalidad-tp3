USE municipalidad
GO

CREATE
	OR

ALTER VIEW view_ComprobanteENCRYPTED
AS
SELECT cmp.id AS [numCom],
	cmp.fecha AS [fecha],
	cmp.MontoTotal AS [monto]
FROM ComprobanteDePago cmp
WHERE cmp.activo = 1
