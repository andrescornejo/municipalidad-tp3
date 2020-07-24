--Script that simulates the operation of the database from an xml
--Author: Andres Cornejo
USE municipalidad
GO

set nocount on;

declare @FechasOperacionXML xml
select @FechasOperacionXML = F
from openrowset(bulk 'C:\xml\Operaciones.xml', single_blob) as FechasOperacion(F)

declare @hdoc int
exec sp_xml_preparedocument @hdoc out, @FechasOperacionXML

declare @fechas table(fechaOperacion date)

insert @fechas(fechaOperacion)
select fecha from openxml(@hdoc,'/Operaciones_por_Dia/OperacionDia',1)
with (fecha date)

--select * from @fechas

declare @firstDate date;
declare @lastDate date;

set @firstDate = (select min(T.fechaOperacion) from @fechas T)
set @lastDate = (select max(T.fechaOperacion) from @fechas T)

while(@firstDate <= @lastDate)
    begin
        print('Fecha actual: '+ convert(varchar(30),@firstDate))
        --Execute every day
        exec csp_agregarPropiedades @firstDate
        exec csp_agregarPropietarios @firstDate
        exec csp_agregarPersonaJuridica @firstDate
        exec csp_linkPropiedadDelPropietario @firstDate
        exec csp_linkCCenPropiedad @firstDate
        exec csp_agregarUsuarios @firstDate
        exec csp_linkUsuarioVsPropiedad @firstDate

        set @firstDate = dateadd(day,1,@firstDate);
    end
