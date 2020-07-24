/*	Script para llenar la tabla de TipoEntidad con datos de prueba
	Autor: Pablo Alpizar
*/
USE municipalidad
GO

DECLARE @hdoc INT;
SET IDENTITY_INSERT TipoEntidad ON

DECLARE @TipoEntidadXML XML;

SELECT @TipoEntidadXML = T
FROM openrowset(BULK 'C:\xml\TipoEntidad.xml', single_blob) AS TipoEntidad(T)

EXEC sp_xml_preparedocument @hdoc OUT,
	@TipoEntidadXML

INSERT dbo.TipoEntidad (
	id,
	nombre,
	activo
	)
SELECT X.id,
	X.Nombre,
	1
FROM openxml(@hdoc, '/TipoEntidades/Entidad', 1) WITH (
		id INT,
		Nombre NVARCHAR(50)
		) AS X
SELECT *
FROM TipoEntidad

EXEC sp_xml_removedocument @hdoc

SET IDENTITY_INSERT TipoEntidad OFF
GO