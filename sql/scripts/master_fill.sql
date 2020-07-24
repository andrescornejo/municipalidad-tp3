--Master script, that fills the database with the data provided in the xmls, in their respective tables.
--Author: Andres Cornejo
USE municipalidad
GO

--TRIGGERS
CREATE
	OR

ALTER TRIGGER dbo.trgBitacoraAddPropiedad ON [dbo].[Propiedad]
AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @jsonDespues NVARCHAR(500)
	DECLARE @idEntidad INT

	SET @idEntidad = (
			SELECT p.id
			FROM inserted P
			)
	SET @jsonDespues = (
			SELECT P.NumFinca AS 'Numero Finca',
				P.valor AS 'Valor',
				P.Direccion AS 'Direccion',
				'Activo' AS 'Estado',
				P.ConsumoAcumuladoM3 AS 'Consumo Acumuluado M3',
				P.UltimoConsumoM3 AS 'Consumo Acumulado M3 ultimo recibo'
			FROM inserted P
			FOR JSON PATH,
				ROOT('Propiedad')
			)

	INSERT INTO [dbo].[Bitacora] (
		idTipoEntidad,
		idEntidad,
		jsonAntes,
		jsonDespues,
		insertedAt,
		insertedBy,
		insertedIn
		)
	SELECT T.id,
		@idEntidad,
		NULL,
		@jsonDespues,
		GETDATE(),
		CONVERT(NVARCHAR(100), (
				SELECT @@SERVERNAME
				)),
		'SERVER IP'
	FROM [dbo].[TipoEntidad] T
	WHERE T.Nombre = 'Propiedad'
END
GO

CREATE
	OR

ALTER TRIGGER dbo.trgBitacoraUpdatePropiedad ON dbo.Propiedad
AFTER UPDATE
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @jsonDespues NVARCHAR(500)
	DECLARE @idEntidad INT
	DECLARE @jsonAntes NVARCHAR(500)
	DECLARE @Estado NVARCHAR(15)

	SET @idEntidad = (
			SELECT P.id
			FROM inserted P
			)
	SET @Estado = (
			SELECT CASE 
					WHEN (
							SELECT D.activo
							FROM deleted D
							) = 1
						THEN 'Activo'
					ELSE 'Inactivo'
					END
			)
	SET @jsonAntes = (
			SELECT TOP 1 D.NumFinca AS 'Número de propiedad',
				D.valor AS 'Valor monetario',
				D.Direccion AS 'Dirección',
				@Estado AS 'Estado',
				D.ConsumoAcumuladoM3 AS 'Consumo Acumuluado m3',
				D.UltimoConsumoM3 AS 'Último consumo m3'
			FROM DELETED D
			FOR JSON PATH,
				ROOT('Propiedad')
			)
	SET @Estado = (
			SELECT CASE 
					WHEN (
							SELECT P.activo
							FROM INSERTED P
							) = 1
						THEN 'Activo'
					ELSE 'Inactivo'
					END
			)
	SET @jsonDespues = (
			SELECT P.NumFinca AS 'Número de propiedad',
				P.valor AS 'Valor monetario',
				P.Direccion AS 'Dirección',
				@Estado AS 'Estado',
				P.ConsumoAcumuladoM3 AS 'Consumo Acumuluado m3',
				P.UltimoConsumoM3 AS 'Último consumo m3'
			FROM INSERTED P
			FOR JSON PATH,
				ROOT('Propiedad')
			)

	INSERT INTO [dbo].[Bitacora] (
		idTipoEntidad,
		idEntidad,
		jsonAntes,
		jsonDespues,
		insertedAt,
		insertedBy,
		insertedIn
		)
	SELECT T.id,
		@idEntidad,
		@jsonAntes,
		@jsonDespues,
		GETDATE(),
		CONVERT(NVARCHAR(100), (
				SELECT @@SERVERNAME
				)),
		'SERVER IP'
	FROM [dbo].[TipoEntidad] T
	WHERE T.Nombre = 'Propiedad'
END
GO

--Tabla Usuario
SET IDENTITY_INSERT dbo.Usuario OFF

DECLARE @hdoc INT;
DECLARE @UsuarioXML XML;

SELECT @UsuarioXML = U
FROM openrowset(BULK 'C:\xml\Usuarios.xml', single_blob) AS Usuario(U)

EXEC sp_xml_preparedocument @hdoc OUT,
	@UsuarioXML

--SELECT @UsuarioXML
INSERT dbo.Usuario (
	username,
	passwd,
	isAdmin,
	activo
	)
SELECT X.username,
	X.password,
	IsAdmin = (
		CASE 
			WHEN (X.tipo = 'admin')
				THEN 1
			ELSE 0
			END
		),
	1
FROM openxml(@hdoc, '/Usuarios/Usuario', 1) WITH (
		username NVARCHAR(50),
		password NVARCHAR(MAX),
		tipo NVARCHAR(20)
		) X

SELECT *
FROM Usuario

SET IDENTITY_INSERT dbo.Usuario OFF

EXEC sp_xml_removedocument @hdoc
GO

--Tabla TipoDocID
SET IDENTITY_INSERT dbo.TipoDocID ON

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

SET IDENTITY_INSERT dbo.TipoDocID OFF

EXEC sp_xml_removedocument @hdoc
GO

--Tablas de Concepto Cobro
SET IDENTITY_INSERT ConceptoCobro ON

DECLARE @hdoc INT;
DECLARE @ConceptoCobroXML XML;

SELECT @ConceptoCobroXML = C
FROM openrowset(BULK 'C:\xml\ConceptoDeCobro.xml', single_blob) AS ConceptoCobro(C)

EXEC sp_xml_preparedocument @hdoc OUT,
	@ConceptoCobroXML

INSERT dbo.ConceptoCobro (
	id,
	nombre,
	TasaInteresesMoratorios,
	DiaEmisionRecibo,
	QDiasVencimiento,
	EsRecurrente,
	EsFijo,
	EsImpuesto,
	activo
	)
SELECT X.id,
	X.Nombre,
	X.TasaInteresMoratoria,
	X.DiaCobro,
	X.QDiasVencimiento,
	X.EsRecurrente,
	X.EsFijo,
	X.EsImpuesto,
	1
FROM openxml(@hdoc, '/Conceptos_de_Cobro/conceptocobro', 1) WITH (
		id INT,
		Nombre NVARCHAR(MAX),
		TasaInteresMoratoria REAL,
		DiaCobro INT,
		QDiasVencimiento INT,
		EsRecurrente BIT,
		EsFijo BIT,
		EsImpuesto BIT
		) AS X

INSERT dbo.CC_ConsumoAgua (
	id,
	ValorM3,
	MontoMinimo,
	activo
	)
SELECT X.id,
	X.ValorM3,
	X.MontoMinRecibo,
	1
FROM openxml(@hdoc, '/Conceptos_de_Cobro/conceptocobro', 1) WITH (
		id INT,
		ValorM3 MONEY,
		MontoMinRecibo MONEY,
		TipoCC NVARCHAR(10)
		) AS X
WHERE X.TipoCC = 'CC Consumo'

INSERT dbo.CC_Porcentaje (
	id,
	ValorPorcentaje,
	activo
	)
SELECT X.id,
	X.ValorPorcentaje,
	1
FROM openxml(@hdoc, '/Conceptos_de_Cobro/conceptocobro', 1) WITH (
		id INT,
		ValorPorcentaje FLOAT,
		TipoCC NVARCHAR(13)
		) AS X
WHERE X.TipoCC = 'CC Porcentaje'

INSERT dbo.CC_Fijo (
	id,
	Monto,
	activo
	)
SELECT X.id,
	X.Monto,
	1
FROM openxml(@hdoc, '/Conceptos_de_Cobro/conceptocobro', 1) WITH (
		id INT,
		Monto MONEY,
		TipoCC NVARCHAR(7)
		) AS X
WHERE X.TipoCC = 'CC Fijo'

/*SELECT *
FROM ConceptoCobro

SELECT *
FROM CC_ConsumoAgua

SELECT *
FROM CC_Porcentaje

SELECT *
FROM CC_Fijo*/
SET IDENTITY_INSERT ConceptoCobro OFF

EXEC sp_xml_removedocument @hdoc
GO

--Tabla TipoEntidad
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

SET IDENTITY_INSERT TipoEntidad OFF

EXEC sp_xml_removedocument @hdoc
GO

--Tabla TipoTransConsumo
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

SET IDENTITY_INSERT TipoTransaccionConsumo OFF

EXEC sp_xml_removedocument @hdoc
GO


