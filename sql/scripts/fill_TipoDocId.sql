/*	Script para llenar la tabla de TipoDocID con datos de prueba
	Autor: Andres Cornejo
*/
USE municipalidad
GO

DECLARE @hdoc INT;

SET IDENTITY_INSERT TipoDocID ON

DECLARE @TipoDocIDXML XML;

SELECT @TipoDocIDXML = T
FROM openrowset(BULK 'C:\xml\TipoDocumentoIdentidad.xml', single_blob) AS TipoDocID(T)

EXEC sp_xml_preparedocument @hdoc OUT,
	@TipoDocIDXML

INSERT dbo.TipoDocID (
	id,
	nombre,
	activo
	)
SELECT codigoDoc,
	descripcion,
	1
FROM openxml(@hdoc, '/TipoDocIdentidad/TipoDocId', 1) WITH (
		codigoDoc INT,
		descripcion NVARCHAR(MAX)
		)
SELECT *
FROM TipoDocID

EXEC sp_xml_removedocument @hdoc
GO


