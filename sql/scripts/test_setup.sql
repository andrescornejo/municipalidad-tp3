use municipalidad
go 

set nocount on
--DELETE ALL TABLES
-- disable referential integrity
EXEC sp_MSForEachTable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL' 
GO 

EXEC sp_MSForEachTable 'DELETE FROM ?' 
GO 

EXEC sp_MSForEachTable 'DBCC CHECKIDENT(''?'', RESEED, 0)'
GO

-- enable referential integrity again 
EXEC sp_MSForEachTable 'ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL' 
GO

--TRIGGERS
CREATE OR ALTER TRIGGER dbo.trgBitacoraUpdatePropiedad
ON dbo.Propiedad
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @jsonDespues NVARCHAR(500)
    DECLARE @idEntidad INT
    DECLARE @jsonAntes NVARCHAR(500)
    DECLARE @Estado NVARCHAR(15)

    set @idEntidad = (select P.id from inserted P)

    SET @Estado = (SELECT CASE WHEN (SELECT D.activo FROM deleted D) = 1
                    THEN 'Activo'
                    ELSE 'Inactivo'
                    END)
 
    SET @jsonAntes = (SELECT TOP 1
            D.NumFinca AS 'N�mero de propiedad',
            D.valor AS 'Valor monetario',
            D.Direccion AS 'Direcci�n',
            @Estado AS 'Estado',
            D.ConsumoAcumuladoM3 AS 'Consumo Acumuluado m3',
            D.UltimoConsumoM3 AS '�ltimo consumo m3'
        FROM DELETED D
        FOR JSON PATH, ROOT('Propiedad'))

    SET @Estado = (SELECT CASE WHEN (SELECT P.activo FROM INSERTED P) = 1
                    THEN 'Activo'
                    ELSE 'Inactivo'
                    END)

    SET @jsonDespues = (SELECT 
            P.NumFinca AS 'N�mero de propiedad',
            P.valor AS 'Valor monetario',
            P.Direccion AS 'Direcci�n',
            @Estado AS 'Estado',
            P.ConsumoAcumuladoM3 AS 'Consumo Acumuluado m3',
            P.UltimoConsumoM3 AS '�ltimo consumo m3'
        FROM INSERTED P
        FOR JSON PATH, ROOT('Propiedad'))
    
    INSERT INTO [dbo].[Bitacora] (
        idTipoEntidad,
        idEntidad,
        jsonAntes,
        jsonDespues,
        insertedAt,
        insertedBy,
        insertedIn
    )
    SELECT 
        T.id,
        @idEntidad,
        @jsonAntes,
        @jsonDespues,
        GETDATE(),
        CONVERT(NVARCHAR(100), (SELECT @@SERVERNAME)),
		'SERVER IP'
    FROM [dbo].[TipoEntidad] T WHERE T.Nombre = 'Propiedad'

END
GO

CREATE OR ALTER TRIGGER dbo.trgBitacoraAddPropiedad
ON [dbo].[Propiedad]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @jsonDespues NVARCHAR(500)
    DECLARE @idEntidad INT

        set @idEntidad = (select p.id from inserted P)
        SET @jsonDespues = (SELECT 
                                P.NumFinca AS 'Numero Finca',
                                P.valor AS 'Valor',
                                P.Direccion AS 'Direccion',
                                'Activo' AS 'Estado',
                                P.ConsumoAcumuladoM3 AS 'Consumo Acumuluado M3',
                                P.UltimoConsumoM3 AS 'Consumo Acumulado M3 ultimo recibo'
                            FROM inserted P
                            FOR JSON PATH, ROOT('Propiedad'))

        INSERT INTO [dbo].[Bitacora] (
            idTipoEntidad,
            idEntidad,
            jsonAntes,
            jsonDespues,
            insertedAt,
            insertedBy,
            insertedIn
        ) 
        SELECT
            T.id,
            @idEntidad,
            null,
            @jsonDespues,
            GETDATE(),
            CONVERT(NVARCHAR(100), (SELECT @@SERVERNAME)),
	    	'SERVER IP'
        FROM [dbo].[TipoEntidad] T WHERE T.Nombre = 'Propiedad'

END
GO

--INSERT TIPODOCID CATALOG TABLE
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
SET IDENTITY_INSERT dbo.TipoDocID OFF
EXEC sp_xml_removedocument @hdoc
GO

--INSERT TIPO ESTADO CATALOG TABLE
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

EXEC sp_xml_removedocument @hdoc

SET IDENTITY_INSERT TipoEstadoRecibo OFF
GO

--INSERT CONCEPTO COBRO CATALOG TABLE
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
	activo)
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

Set IDENTITY_INSERT ConceptoCobro off
EXEC sp_xml_removedocument @hdoc
GO

--INSERT TIPO ENTIDAD CATALOG TABLE
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

EXEC sp_xml_removedocument @hdoc

SET IDENTITY_INSERT TipoEntidad OFF
GO

--INSERT TIPOTRANSCONSUMO CATALOG TABLE
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

EXEC sp_xml_removedocument @hdoc

SET IDENTITY_INSERT TipoTransaccionConsumo OFF
GO

--INSERT SAMPLE DATA
insert Usuario(username, passwd, isAdmin, activo)
values ('a', '1', 1, 1),
('b', '1', 0, 1),
('test', 'lol', 1, 1)

--multiple inserts used to prevent problems with the trigger.
INSERT Propiedad(NumFinca, Valor, Direccion, activo, ConsumoAcumuladoM3, UltimoConsumoM3)
select 1234, 1234, 'techa', 1, 2, 2

INSERT Propiedad(NumFinca, Valor, Direccion, activo, ConsumoAcumuladoM3, UltimoConsumoM3)
select 431, 12643, 'techa', 1, 2, 2

INSERT Propiedad(NumFinca, Valor, Direccion, activo, ConsumoAcumuladoM3, UltimoConsumoM3)
select 1111111, 123, 'techa', 1, 2, 2

insert UsuarioVsPropiedad(idUsuario, idPropiedad, activo)
values (2, 1, 1),
(2, 2, 1),
(2, 3, 1)

insert ComprobanteDePago(fecha, MontoTotal, activo)
values ('2019-8-8', 50000, 1),
('2019-9-8', 50000, 1),
('2019-10-8', 50000, 1),
('2019-11-8', 50000, 1),
('2019-12-8', 50000, 1),
('2020-1-8', 50000, 1),
('2020-2-8', 50000, 1),
('2020-3-8', 50000, 1),
('2020-4-8', 50000, 1),
('2020-5-8', 50000, 1),
('2020-6-8', 50000, 1),
('2020-7-8', 50000, 1)

insert Recibo(idComprobantePago, idPropiedad, idConceptoCobro, fecha, fechaVencimiento, monto, idTipoEstado, activo)
values (1, 1, 1, '2019-8-8', '2019-8-17', 50000, 2, 1),
(2, 1, 1, '2019-9-8', '2019-9-17', 50000, 2, 1),
(3, 1, 1, '2019-10-10', '2019-10-17', 50000, 2, 1),
(4, 1, 1, '2019-11-8', '2019-11-17', 50000, 2, 1),
(5, 1, 1, '2019-12-8', '2019-12-17', 50000, 2, 1),
(6, 1, 1, '2020-1-10', '2020-1-17', 50000, 2, 1),
(7, 1, 1, '2020-2-8', '2020-2-17', 50000, 2, 1),
(8, 1, 1, '2020-3-8', '2020-3-17', 50000, 2, 1), 
(9, 1, 1, '2020-4-10', '2020-4-17', 50000, 2, 1),
(10, 1, 1, '2020-5-8', '2020-5-17', 50000, 2, 1),
(11, 1, 1, '2020-6-8', '2020-6-17', 50000, 2, 1),
(null, 1, 1, '2020-7-10', '2020-7-17', 50000, 1, 1),
(null, 1, 1, '2020-7-12', '2020-7-19', 50000, 1, 1),
(null, 1, 1, '2020-7-14', '2020-7-19', 50000, 1, 1),
(null, 1, 1, '2020-7-16', '2020-7-19', 50000, 1, 1),
(null, 1, 1, '2020-7-18', '2020-7-20', 50000, 1, 1),
(null, 1, 1, '2020-7-20', '2020-7-22', 50000, 1, 1)

insert Bitacora(idTipoEntidad, idEntidad, jsonAntes, jsonDespues, insertedAt, insertedBy, insertedIn)
values 
(1, 2, '{"Propietario":[{"ID":1,"Nombre":"Ferrer S.A.","Tipo DocID":"Cedula Juridica","Valor ID":"301659662","Estado":"Activo"}]}', '{"Propietario":[{"ID":1,"Nombre":"LMAOOOOOOOOOOO","Tipo DocID":"Cedula Juridica","Valor ID":"301659662","Estado":"Activo"}]}', '2020-07-07', 'LePerv', 'LePerv'),
(1, 2, '{"Propietario":[{"ID":1,"Nombre":"Ferrer S.A.","Tipo DocID":"Cedula Juridica","Valor ID":"301659662","Estado":"Activo"}]}', '{"Propietario":[{"ID":1,"Nombre":"Ferrer S.A.","Tipo DocID":"Cedula Juridica","Valor ID":"301659662","Estado":"Activo"}]}', '2020-07-07', 'LePerv', 'LePerv'),
(1, 3, null, '{"Propietario":[{"ID":1,"Nombre":"Ferrer S.A.","Tipo DocID":"Cedula Juridica","Valor ID":"301659662","Estado":"Activo"}]}', '2020-07-08', 'LePerv', 'LePerv'),
(1, 3, null, '{"Propietario":[{"ID":1,"Nombre":"Ferrer S.A.","Tipo DocID":"Cedula Juridica","Valor ID":"301659662","Estado":"Activo"}]}', '2020-07-09', 'LePerv', 'LePerv'),
(1, 2, '{"Propietario":[{"ID":1,"Nombre":"Ferrer S.A.","Tipo DocID":"Cedula Juridica","Valor ID":"301659662","Estado":"Activo"}]}', '{"Propietario":[{"ID":1,"Nombre":"Ferrer S.A.","Tipo DocID":"Cedula Juridica","Valor ID":"301659662","Estado":"Activo"}]}', '2020-07-10', 'LePerv', 'LePerv')

insert Propietario(idTipoDocID, nombre, valorDocID, activo)
values
(1, 'Rat Bastard', '1029384234', 1),
(1, 'wee wee breath', '112341234', 1),
(3, 'wee wee breff', '17547', 1)

