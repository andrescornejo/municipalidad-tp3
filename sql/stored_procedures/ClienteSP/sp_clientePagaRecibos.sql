/*
 * Stored Procedure: csp_clientePagaRecibos
 * Description: Stored procedure that handes the table a client sends when he/she pays bills. 
 * Author: Andres Cornejo
 * Modified by: Pablo Alpizar
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_clientePagaRecibos @inTablaRecibos udt_idTable readonly
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON

		DECLARE @idTable TABLE (storedID INT)
		DECLARE @ID INT,
			@idComprobante INT,
			@idPropiedad INT,
			@date DATE

		-- Insertar los id de los recibos a pagar en una tabla para iterar
		INSERT @idTable
		SELECT i.storedID
		FROM @inTablaRecibos i

		-- Crear el comprobante de pago
		INSERT INTO [dbo].[ComprobanteDePago] (
			fecha,
			MontoTotal,
			descripcion,
			activo
			)
		SELECT GETDATE(),
			0,
			'Pago en línea.',
			1

		-- Guardar el id del comprobante
		SET @idComprobante = (
				SELECT TOP (1) CP.id
				FROM [dbo].[ComprobanteDePago] CP
				ORDER BY CP.id DESC
				)
				
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
				SELECT TOP 1 @ID = storedID
				FROM @idTable

				DELETE @idTable
				WHERE storedID = @ID

				-- Actualizar los de estado y idComprobante del recibo 
				UPDATE [dbo].[Recibo]
				SET idTipoEstado = (
						SELECT T.id
						FROM [dbo].[TipoEstadoRecibo] T
						WHERE T.estado = 'Pagado'
						),
					idComprobantePago = @idComprobante
				WHERE id = @ID

				-- Actualizar el valor del comprobante
				UPDATE [dbo].[ComprobanteDePago]
				SET MontoTotal = MontoTotal + (
						SELECT R.monto
						FROM [dbo].[Recibo] R
						WHERE R.id = @ID
						)
				WHERE id = @idComprobante

				-- Si el recibo es de reconexión entonces se genera la orden de reconexión a la propiedad
				IF EXISTS (
						SELECT RE.id
						FROM [dbo].[Reconexion] RE
						WHERE RE.id = @ID
						)
				BEGIN
					SET @idPropiedad = (
							SELECT R.idPropiedad
							FROM [dbo].[Recibo] R
							WHERE R.id = @ID
							)
					SET @date = GETDATE()

					EXEC csp_generarOrdReconexion @date,
						@idPropiedad,
						@ID
				END
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