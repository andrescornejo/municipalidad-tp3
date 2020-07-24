--Script that simulates the operation of the database from an xml
--Author: Andres Cornejo
USE municipalidad
GO

SET NOCOUNT ON;

DECLARE @FechasOperacionXML XML

SELECT @FechasOperacionXML = F
FROM openrowset(BULK 'C:\xml\Operaciones.xml', single_blob) AS FechasOperacion(F)

DECLARE @hdoc INT

EXEC sp_xml_preparedocument @hdoc OUT,
	@FechasOperacionXML

DECLARE @fechas TABLE (fechaOperacion DATE)

INSERT @fechas (fechaOperacion)
SELECT fecha
FROM openxml(@hdoc, '/Operaciones_por_Dia/OperacionDia', 1) WITH (fecha DATE)

EXEC sp_xml_removedocument @hdoc;

--select * from @fechas
DECLARE @firstDate DATE;
DECLARE @lastDate DATE;

SET @firstDate = (
		SELECT min(T.fechaOperacion)
		FROM @fechas T
		)
SET @lastDate = (
		SELECT max(T.fechaOperacion)
		FROM @fechas T
		)

WHILE (@firstDate <= @lastDate)
BEGIN
	PRINT ('Fecha actual: ' + convert(VARCHAR(30), @firstDate))

	--Execute every day
	EXEC csp_agregarPropiedades @firstDate, @FechasOperacionXML
	EXEC csp_agregarPropietarios @firstDate, @FechasOperacionXML
	EXEC csp_agregarPersonaJuridica @firstDate, @FechasOperacionXML
	EXEC csp_linkPropiedadDelPropietario @firstDate, @FechasOperacionXML
	EXEC csp_linkCCenPropiedad @firstDate, @FechasOperacionXML
	EXEC csp_agregarUsuarios @firstDate, @FechasOperacionXML
	EXEC csp_linkUsuarioVsPropiedad @firstDate, @FechasOperacionXML
	EXEC csp_agregarCambioValorPropiedad @firstDate, @FechasOperacionXML 
	EXEC csp_agregarTransConsumo @firstDate, @FechasOperacionXML
	EXEC csp_generarReciboCCFijo @firstDate
	EXEC csp_generarReciboCCPorcentaje @firstDate
	EXEC csp_generarRecibosAgua @firstDate
	EXEC csp_agregarPagos @firstDate, @FechasOperacionXML
	exec csp_generarOrdCorta @firstDate
	SET @firstDate = dateadd(day, 1, @firstDate);
END