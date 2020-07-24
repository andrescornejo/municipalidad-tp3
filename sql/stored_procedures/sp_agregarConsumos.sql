/*
 * Stored Procedure: 
 * Description: 
 * Author: Andres Cornejo
 */

use municipalidad
go

IF EXISTS (
		SELECT *
		FROM sysobjects
		WHERE id = object_id(N'[dbo].[csp_agregarTransConsumo]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
BEGIN
	DROP PROCEDURE dbo.csp_agregarTransConsumo
END
GO

create or alter proc csp_agregarTransConsumo @fechaInput DATE
as
begin
	begin try
		set nocount on

        DECLARE @MontoM3 MONEY
        DECLARE @OperacionXML XML

        SELECT @OperacionXML = O
		FROM openrowset(BULK 'C:\xml\Operaciones.xml', single_blob) AS Operacion(O)

        DECLARE @hdoc INT

        DECLARE @tmpConsumo TABLE (
            idTipoTransConsumo INT,
            FechaXml DATE,
            LecturaM3 INT,
            Descripcion NVARCHAR(100),
            NumFinca INT
        )
        
                
        SET @MontoM3 = (SELECT CC.ValorM3
        FROM dbo.CC_ConsumoAgua CC 
        INNER JOIN dbo.ConceptoCobro C ON C.nombre = 'Agua'
        WHERE C.id = CC.id)

        EXEC sp_xml_preparedocument @hdoc OUT,
	    @OperacionXML
        INSERT INTO @tmpConsumo(
            idTipoTransConsumo,
            FechaXml,
            Descripcion,
            NumFinca,
            LecturaM3
        ) 
        SELECT 
            X.id,
            X.fecha,
            X.descripcion,
            X.NumFinca,
            X.LecturaM3      
        FROM openxml(@hdoc, '/Operaciones_por_Dia/OperacionDia/TransConsumo', 1) WITH ( 
            id INT,
            fecha DATE '../@fecha',
            descripcion NVARCHAR(100),
            NumFinca INT,
            LecturaM3 INT
        ) AS X
        WHERE CONVERT(DATE,'2020-04-07') = fecha

        EXEC sp_xml_removedocument @hdoc;

        INSERT dbo.TransaccionConsumo (
            idPropiedad,
            fecha,
            montoM3,
            LecturaConsumoM3,
            NuevoAcumulado,
            activo,
            idTipoTransConsumo
        )
        SELECT 
            P.id,
            tmp.FechaXml,
            @MontoM3,
            tmp.LecturaM3,
            P.ConsumoAcumuladoM3,
            1,
            idTipoTransConsumo
        FROM @tmpConsumo tmp    
        INNER JOIN dbo.Propiedad P ON tmp.NumFinca = P.NumFinca
        
	end try
	begin catch
		IF @@TRANCOUNT > 0
			ROLLBACK

		DECLARE @errorMsg NVARCHAR(200) = (
				SELECT ERROR_MESSAGE()
				)

		PRINT ('ERROR:' + @errorMsg)

		RETURN - 1 * @@ERROR
	end catch
end
go