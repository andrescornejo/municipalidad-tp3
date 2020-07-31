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
		DECLARE @hdoc INT, @tmpIdRecibos udt_idTable, @numFinca INT
        DECLARE @tmpAP TABLE (numFinca INT, plazo INT)
        EXEC sp_xml_preparedocument @hdoc OUT,
			@OperacionXML
        
        INSERT INTO @tmpAP(
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

        WHILE (EXISTS(SELECT 1 FROM @tmpAP))
        BEGIN
            SET @numFinca = (SELECT TOP (1) tmp.numFinca FROM @tmpAP tmp)

            


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


