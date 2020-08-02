/*
 * Stored Procedure: csp_RealizarPago
 * Description: Realiza el pago de todos los recibos pendientes de una finca
 * Author: Pablo Alpizar
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_RealizarPago @inNumFinca INT,
	@inIdComprobante INT,
	@inFecha DATE,
	@idTipoCC INT
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON

		DECLARE @idRecibo INT
		DECLARE @FechaVenc DATE
		DECLARE @InterestMot MONEY
		DECLARE @MontoRecibo MONEY
		DECLARE @TasaInterest FLOAT
		DECLARE @tmpReciboPediente TABLE (id INT)

		-- tomo todos los recibos del Tipo CC pedientes
		INSERT INTO @tmpReciboPediente
		SELECT R.id
		FROM [dbo].[Recibo] R
		INNER JOIN [dbo].[Propiedad] P ON P.NumFinca = @inNumFinca
		WHERE R.idTipoEstado = (
			SELECT T.id 
			FROM [dbo].[TipoEstadoRecibo] T
			WHERE T.estado = 'Pendiente'
		)
			AND R.idPropiedad = P.id
			AND R.activo = 1
			AND idConceptoCobro = @idTipoCC
		ORDER BY R.fecha ASC

		SET @TasaInterest = (
				SELECT CC.TasaInteresesMoratorios
				FROM [dbo].[ConceptoCobro] CC
				WHERE CC.id = @idTipoCC
				)

		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		BEGIN TRANSACTION

		WHILE (
				SELECT COUNT(*)
				FROM @tmpReciboPediente
				) > 0
		BEGIN
			SET @idRecibo = (
					SELECT TOP 1 tmp.id
					FROM @tmpReciboPediente tmp
					)

			DELETE @tmpReciboPediente
			WHERE id = @idRecibo

			SET @FechaVenc = (
					SELECT R.fechaVencimiento
					FROM [dbo].[Recibo] R
					WHERE R.id = @idRecibo
					)
			SET @MontoRecibo = (
					SELECT R.monto
					FROM [dbo].[Recibo] R
					WHERE R.id = @idRecibo
					)
			SET @InterestMot = CASE 
					WHEN @inFecha <= @FechaVenc
						THEN 0
					ELSE (@MontoRecibo * @TasaInterest / 365) * ABS(DATEDIFF(DAY, @FechaVenc, @inFecha))
					END

			-- Si existen intereses moratorios entonces generamos un recibo por el monto
			IF @InterestMot > 0
			BEGIN
				INSERT INTO [dbo].[Recibo] (
					idComprobantePago,
					idPropiedad,
					idConceptoCobro,
					idTipoEstado,
					fecha,
					fechaVencimiento,
					monto,
					Activo
					)
				SELECT @inIdComprobante,
					P.id,
					CC.id,
					T.id,
					@inFecha,
					@inFecha,
					@InterestMot,
					1
				FROM [dbo].[Propiedad] P
				INNER JOIN [dbo].[ConceptoCobro] CC ON CC.nombre = 'Interes Moratorio'
				INNER JOIN [dbo].[TipoEstadoRecibo] T ON T.estado = 'Pagado'
				WHERE P.NumFinca = @inNumFinca

				-- incluimos en monto del recibo en el comprobante
				UPDATE [dbo].[ComprobanteDePago]
				SET MontoTotal = MontoTotal + @InterestMot
				WHERE id = @inIdComprobante
			END

			-- Actualizo los valores del recibo
			UPDATE [dbo].[Recibo]
			SET idTipoEstado = (
					SELECT T.id
					FROM [dbo].[TipoEstadoRecibo] T
					WHERE T.estado = 'Pagado'
					),
				idComprobantePago = @inIdComprobante
			WHERE id = @idRecibo

			-- Actualizo el monto total del comprobante
			UPDATE [dbo].[ComprobanteDePago]
			SET MontoTotal = MontoTotal + (
					SELECT R.monto
					FROM [dbo].[Recibo] R
					WHERE R.id = @idRecibo
					)
			WHERE id = @inIdComprobante

			IF EXISTS (
					SELECT RE.id
					FROM [dbo].[Reconexion] RE
					WHERE RE.id = @idRecibo
					)
			BEGIN
				EXEC csp_RealizarPago @inNumFinca,
					@inIdComprobante,
					@inFecha,
					1

				DECLARE @idPropiedad INT = (
						SELECT P.id
						FROM [dbo].[Propiedad] P
						WHERE P.NumFinca = @inNumFinca
						)

				EXEC csp_generarOrdReconexion @inFecha,
					@idPropiedad,
					@idRecibo
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


