/*
 * Stored Procedure: csp_agregarPagos
 * Description: sp que agrega los Pagos
 * Author: Pablo Alpizar
 */
USE municipalidad
GO

IF EXISTS (
		SELECT *
		FROM sysobjects
		WHERE id = object_id(N'[dbo].[csp_agregarPagos]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
BEGIN
	DROP PROCEDURE dbo.csp_agregarPagos
END
GO

CREATE PROC csp_agregarPagos @fechaInput DATE
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON
        DECLARE @idCC INT
        DECLARE @NumFinca INT
        DECLARE @idComprobante INT
		DECLARE @OperacionXML XML

		SELECT @OperacionXML = O
		FROM openrowset(BULK 'C:\xml\Operaciones.xml', single_blob) AS Operacion(O)

		DECLARE @hdoc INT
        
        DECLARE @tmpPago TABLE (
            idTipoRecibo INT,
            NumFinca INT
        )

        DECLARE @tmpPagoProp TABLE(
            idTipoRecibo INT
        )

		EXEC sp_xml_preparedocument @hdoc OUT,
		@OperacionXML
        
        INSERT INTO @tmpPago (
            idTipoRecibo,
            NumFinca
        ) SELECT 
            X.TipoRecibo,
            X.NumFinca
        FROM openXml(@hdoc, '/Operaciones_por_Dia/OperacionDia/Pago', 1) WITH(
            TipoRecibo INT,
            NumFinca INT,
            fecha DATE '../@fecha'
        ) AS X
        WHERE CONVERT(DATE, '2020-03-07') = fecha
        ORDER BY NumFinca 
        
        EXEC sp_xml_removedocument @hdoc;
        
        BEGIN TRANSACTION
            WHILE (SELECT COUNT(*) FROM @tmpPago) > 0
            BEGIN
                -- Tomo la primero Finca
                SET @NumFinca = (SELECT TOP 1 tmp.NumFinca FROM @tmpPago tmp)
                -- Inserto los pagos de una propiedad
                INSERT INTO @tmpPagoProp (idTipoRecibo)
                SELECT tmp.idTipoRecibo FROM @tmpPago tmp
                WHERE tmp.NumFinca = @NumFinca
                -- eliminio los Pagos de esa Finca tabla general
                DELETE FROM @tmpPago
                WHERE NumFinca = @NumFinca
                -- Creo un comprobante por los recibos ha pagar de esa propiedad
                INSERT INTO [dbo].[ComprobanteDePago] (fecha,MontoTotal,activo)
                SELECT @fechaInput, 0, 1

                SET @idComprobante = SCOPE_IDENTITY()

                WHILE (SELECT COUNT(*) FROM @tmpPagoProp) > 0
                BEGIN
                    SET @idCC = (SELECT TOP 1 tmpP.idTipoRecibo FROM @tmpPagoProp tmpP)
                    -- Elimino los Pago de se CC de la tabla PagosProp
                    DELETE @tmpPagoProp 
                    WHERE idTipoRecibo = @idCC

                    EXEC csp_RealizarPago @NumFinca, @idComprobante, @fechaInput, @idCC
                END
            END
        COMMIT
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