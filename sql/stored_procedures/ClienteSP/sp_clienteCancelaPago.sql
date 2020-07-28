/*
 * Stored Procedure: csp_clienteCancelaPago
 * Description: Stored procedure that handes the table a client sends when he/she cancels pay. 
 * Author: Pablo Alpizar 
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_clienteCancelaPago @inTablaRecibos udt_Recibo readonly
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON

		DECLARE @idTable TABLE (ID INT)
		DECLARE @ID INT,
			@idComprobante INT,
			@idPropiedad INT,
			@date DATE

		-- Insertar los id de los recibos a pagar en una tabla para iterar
		INSERT @idTable
		SELECT i.id
		FROM @inTablaRecibos i
        WHERE ConceptoCobro = 'Interes Moratorio'

		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		BEGIN TRANSACTION
		    /*Cree una tabla temporal para poder iterar, ya que no puedo
            * borrar de @inTablaRecibos, porque SQL me está forzando a 
            * declara @inTablaRecibos como readonly.
            */
		    WHILE EXISTS (
		    		SELECT *
		    		FROM @idTable
		    		)
		    BEGIN
		    	SELECT TOP 1 @ID = ID
		    	FROM @idTable
    
		    	DELETE @idTable
		    	WHERE ID = @ID
    
		    	-- Actualizar los de estado del recibo 
		    	UPDATE [dbo].[Recibo]
		    	SET idTipoEstado = (
		    			SELECT T.id
		    			FROM [dbo].[TipoEstadoRecibo] T
		    			WHERE T.estado = 'Anulado'
		    			)
		    	WHERE id = @ID
		    END
        COMMIT
		RETURN 1
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