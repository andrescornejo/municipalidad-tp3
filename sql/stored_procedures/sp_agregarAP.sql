/*
 * Stored Procedure: csp_agregarAP
 * Description: 
 * Author: Pablo Alpizar
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_agregarAP @inFecha DATE,
@OperacionXML XML
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON
		DECLARE @hdoc INT, @tmpIdRecibos udt_idTable, @numFinca INT, @montoAP MONEY, @cuota MONEY, @plazo INT
        
		DECLARE @APXML TABLE (numFinca INT, plazo INT)
        
		EXEC sp_xml_preparedocument @hdoc OUT,
			@OperacionXML
        
		-- Tomar los AP del dia
        INSERT INTO @APXML(
            numFinca, 
            plazo
        )
        SELECT NumFinca,
            Plazo
		FROM openxml(@hdoc, '/Operaciones_por_Dia/OperacionDia/AP ', 1) WITH (
				NumFinca INT,
				Plazo INT,
				fecha DATE '../@fecha'
				)
		WHERE @inFecha = fecha

        EXEC sp_xml_removedocument @hdoc;
		-- Calcular el monto para cada AP
        WHILE (EXISTS(SELECT 1 FROM @APXML))
        BEGIN
            SELECT TOP (1) @numFinca = tmp.numFinca, @plazo = tmp.plazo FROM @APXML tmp
            INSERT @tmpIdRecibos 
			-- tomar los recibos pendientes
			SELECT R.id 
			FROM [dbo].[Recibo] R
			INNER JOIN [dbo].[Propiedad] P ON P.NumFinca = @numFinca
			WHERE R.idTipoEstado = (SELECT T.id 
									FROM [dbo].[TipoEstadoRecibo] T
									WHERE T.estado = 'Pendiente')
			
			EXEC csp_crearRecibosIntMoratorio 
				@inRecibosIDTable = @tmpIdRecibos,
				@inFecha = @inFecha,
				@montoTotal = @montoAP OUTPUT;

			EXEC csp_consultaCuotaAP
				@inMontoAP = @montoAP,
				@inPlazo = @plazo,
				@outCuotaAP = @cuota OUTPUT;

			EXEC csp_crearAP
				@inNumFinca = @numFinca,
				@inMontoTotal = @montoAP,
				@inPlazo = @plazo,
				@inCuota = @cuota,
				@inFecha = @inFecha

			DELETE TOP (1) @APXML
        END

	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK

		DECLARE @errorMsg NVARCHAR(200) = (
				SELECT ERROR_MESSAGE()
				)

		PRINT ('ERROR:' + @errorMsg)

		RETURN - 1 * @@ERROR
	END CATCH
END
GO


