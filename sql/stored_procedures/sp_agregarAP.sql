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
        
		DECLARE @APXML TABLE (numFinca INT, plazo INT, monto MONEY, cuota MONEY)
		
		DECLARE @tmpAPInfo TABLE (numFinca INT, plazo INT, monto MONEY, cuota MONEY)
        
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
			SELECT R.id 
			FROM [dbo].[Recibo] R
			INNER JOIN [dbo].[Propiedad] P ON P.NumFinca = @numFinca
			WHERE R.idTipoEstado = (SELECT T.id 
									FROM [dbo].[TipoEstadoRecibo] T
									WHERE T.estado = 'Pendiente')
			
			EXEC csp_clienteSeleccionaRecibos 
				@inRecibosIDTable = @tmpIdRecibos,
				@montoTotal = @montoAP OUTPUT;

			EXEC csp_consultaCuotaAP
				@inMontoAP = @montoAP,
				@inPlazo = @plazo,
				@outCuotaAP = @cuota OUTPUT;

			EXEC csp_adminCrearAP 
				@inMontoTotal = @montoAP,
				@inPlazo = @plazo,
				@inCuota = @cuota,
				@inUserName = 'SERVERNAME'
			
			--INSERT INTO @tmpAPInfo (numFinca, plazo, monto, cuota)
			--SELECT tmp.numFinca, tmp.plazo, @montoAP, @cuota
			--FROM @APXML tmp
			--WHERE tmp.numFinca = @numFinca

			DELETE TOP (1) @APXML
        END
		
		--insertar los AP desde la tabla temporal
		--SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		--BEGIN TRANSACTION

			--insertar los AP desde la tabla temporal
			--WHILE (EXISTS(SELECT 1 FROM @tmpAPInfo))
			--BEGIN

			--END

		--COMMIT


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


