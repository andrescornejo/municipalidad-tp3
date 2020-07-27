/*	Script para llenar el tipo de estado de un recibo
	Autor: Pablo Alpizar
*/
USE municipalidad
GO

DECLARE @hdoc INT;
SET IDENTITY_INSERT TipoEstadoRecibo ON

DECLARE @TipoEstadoXML XML;

SELECT @TipoEstadoXML = T
FROM openrowset(BULK 'C:\xml\TipoEstado.xml', single_blob) AS TipoEstado(T)

EXEC sp_xml_preparedocument @hdoc OUT,
	@TipoEstadoXML

INSERT [dbo].[TipoEstadoRecibo] (
    id,
	Estado,
	activo
	)
SELECT X.id,
	X.Nombre,
	1
FROM openxml(@hdoc, '/TipoEstado/Estado', 1) WITH (
		id INT,
		Nombre NVARCHAR(25)
		) AS X

SELECT *
FROM TipoEstadoRecibo

EXEC sp_xml_removedocument @hdoc

SET IDENTITY_INSERT TipoEstadoRecibo OFF
GO