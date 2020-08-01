/*	Script para llenar el tipo de estado de un recibo
	Autor: Pablo Alpizar
*/
USE municipalidad
GO


SET IDENTITY_INSERT TipoMovAP ON
DECLARE @hdoc INT;

DECLARE @TipoMovAPXML XML;

SELECT @TipoMovAPXML = T
FROM openrowset(BULK 'C:\xml\TipoMovAP.xml', single_blob) AS TipoMovAP(T)

EXEC sp_xml_preparedocument @hdoc OUT,
	@TipoMovAPXML

INSERT [dbo].[TipoMovAP] (
    id,
	Nombre,
	activo
	)
SELECT X.id,
	X.Nombre,
	1
FROM openxml(@hdoc, '/TipoMovAP/MovAP', 1) WITH (
		id INT,
		Nombre NVARCHAR(25)
		) AS X

SELECT *
FROM TipoMovAP

EXEC sp_xml_removedocument @hdoc

SET IDENTITY_INSERT TipoMovAP OFF
GO