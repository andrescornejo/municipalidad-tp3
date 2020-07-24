/*	Script para llenar la tabla de TipoTransaccionConsumo con datos de prueba
	Autor: Pablo Alpizar
*/

USE municipalidad
GO

DECLARE @hdoc INT;

SET IDENTITY_INSERT TipoTransaccionConsumo ON

DECLARE @TipoTransaccionConsumoXML XML;

SELECT @TipoTransaccionConsumoXML = T
FROM openrowset(BULK 'C:\xml\TipoTransConsumo.xml', single_blob) AS TipoTransaccionConsumo(T)

EXEC sp_xml_preparedocument @hdoc OUT,
	@TipoTransaccionConsumoXML

INSERT dbo.TipoTransaccionConsumo (
	id,
	nombre,
	activo
	)
SELECT X.id,
	X.Nombre,
	1
FROM openxml(@hdoc, '/TipoTransConsumo/TransConsumo', 1) WITH (
		id INT,
		Nombre NVARCHAR(50)
		) AS X
SELECT *
FROM TipoTransaccionConsumo

EXEC sp_xml_removedocument @hdoc

SET IDENTITY_INSERT TipoTransaccionConsumo OFF
GO