--Master script, that fills the database with the data provided in the xmls, in their respective tables.
--Author: Andres Cornejo
USE municipalidad
GO

--Tabla Usuario
SET IDENTITY_INSERT dbo.Usuario OFF

DECLARE @hdoc INT;
DECLARE @UsuarioXML XML;

SELECT @UsuarioXML = U
FROM openrowset(BULK 'C:\xml\Admin.xml', single_blob) AS Usuario(U)

EXEC sp_xml_preparedocument @hdoc OUT,
	@UsuarioXML

INSERT dbo.Usuario (
	username,
	passwd,
	isAdmin
	)
SELECT username,
	passwd,
	tipoUsuario
FROM openxml(@hdoc, '/Administrador/UsuarioAdmi', 1) WITH (
		username NVARCHAR(50),
		passwd NVARCHAR(MAX),
		tipoUsuario BIT
		)

-- SELECT *
-- FROM Usuario

EXEC sp_xml_removedocument @hdoc
GO

--Tabla TipoDocID
SET IDENTITY_INSERT dbo.TipoDocID ON

DECLARE @hdoc INT;
DECLARE @TipoDocIDXML XML;

SELECT @TipoDocIDXML = T
FROM openrowset(BULK 'C:\xml\TipoDocumentoIdentidad.xml', single_blob) AS TipoDocID(T)

EXEC sp_xml_preparedocument @hdoc OUT,
	@TipoDocIDXML

INSERT dbo.TipoDocID (
	id,
	nombre
	)
SELECT codigoDoc,
	descripcion
FROM openxml(@hdoc, '/TipoDocIdentidad/TipoDocId', 1) WITH (
		codigoDoc INT,
		descripcion NVARCHAR(MAX)
		)

SET IDENTITY_INSERT dbo.TipoDocID OFF

-- SELECT *
-- FROM TipoDocID

EXEC sp_xml_removedocument @hdoc
GO

--Tablas de Concepto Cobro
SET IDENTITY_INSERT dbo.ConceptoCobro ON

DECLARE @hdoc INT;
DECLARE @ConceptoCobroXML XML;

SELECT @ConceptoCobroXML = C
FROM openrowset(BULK 'C:\xml\concepto_cobro.xml', single_blob) AS ConceptoCobro(C)

EXEC sp_xml_preparedocument @hdoc OUT,
	@ConceptoCobroXML

INSERT dbo.ConceptoCobro (
	id,
	nombre,
	TasaInteresesMoratorios,
	DiaEmisionRecibo,
	QDiasVencimiento,
	EsRecurrente,
	EsImpuesto
	)
SELECT id,
	Nombre,
	TasaInteresMoratoria,
	DiaCobro,
	QDiasVencimiento,
	EsRecurrente,
	EsImpuesto
FROM openxml(@hdoc, '/Conceptos_de_Cobro/conceptocobro', 1) WITH (
		id INT,
		Nombre NVARCHAR(MAX),
		TasaInteresMoratoria REAL,
		DiaCobro INT,
		QDiasVencimiento INT,
		EsRecurrente BIT,
		EsImpuesto BIT
		)

INSERT dbo.CC_ConsumoAgua (
	id,
	ConsumoM3
	)
SELECT id,
	ConsumoM3
FROM openxml(@hdoc, '/Conceptos_de_Cobro/ccagua', 1) WITH (
		id INT,
		ConsumoM3 INT
		)

INSERT dbo.CC_Porcentaje (
	id,
	ValorPorcentaje
	)
SELECT id,
	ValorPorcentaje
FROM openxml(@hdoc, '/Conceptos_de_Cobro/ccporcentual', 1) WITH (
		id INT,
		ValorPorcentaje FLOAT
		)

INSERT dbo.CC_Fijo (
	id,
	MontoFijo
	)
SELECT id,
	Monto
FROM openxml(@hdoc, '/Conceptos_de_Cobro/ccfijo', 1) WITH (
		id INT,
		Monto MONEY
		)

SET IDENTITY_INSERT dbo.ConceptoCobro OFF

-- SELECT *
-- FROM ConceptoCobro

-- SELECT *
-- FROM CC_ConsumoAgua

-- SELECT *
-- FROM CC_Porcentaje

-- SELECT *
-- FROM CC_Fijo

EXEC sp_xml_removedocument @hdoc
GO


