/*
 * Stored Procedure: csp_generarRecibosAP
 * Description: 
 * Author: Pablo Alpizar
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_generarRecibosAP @inFecha DATE
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON
		DECLARE @id INT
		DECLARE @tmpAP udt_idTable

        INSERT INTO @tmpAP (storedID)
        SELECT AP.id
        FROM [dbo].[AP] AP 
		WHERE (SELECT CONVERT(DATE, AP.insertedAt)) = @inFecha


		IF(EXISTS(SELECT 1 FROM @tmpAP))
		BEGIN
  			SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			BEGIN TRANSACTION
				-- insertar los recibos 
				INSERT INTO [Recibo] (
					idPropiedad,
					idConceptoCobro,
					idTipoEstado,
					fecha,
					fechaVencimiento,
					monto,
					activo
				)
				SELECT 
					AP.idPropiedad,
					C.id,
					T.id,
					@inFecha,
					DATEADD(DAY,C.QDiasVencimiento,@inFecha),
					AP.cuota,
					1
				FROM @tmpAP tmp
				INNER JOIN [dbo].[ConceptoCobro] C ON C.nombre = 'AP'
				INNER JOIN [dbo].[TipoEstadoRecibo] T ON T.estado = 'Pendiente'
				INNER JOIN [dbo].[AP] AP ON tmp.storedID = AP.id 

			COMMIT
		END;


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


