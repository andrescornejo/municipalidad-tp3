/*
 * Stored Procedure: csp_consultaRecibosSeleccionados
 * Description: 
 * Author: Pablo Alpizar Monge
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_consultaRecibosSeleccionados @inTableRecibos udt_Recibo READONLY,
	@montoTotal MONEY OUT
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON

		DECLARE @FechaVencimiento DATE,
			@MontoInteresMot MONEY,
			@TasaInteres FLOAT,
			@MontoRecibo MONEY,
			@idRecibo INT
		DECLARE @tmpRecibosInt TABLE (
			idPropiedad INT,
			idConceptoCobro INT,
			idEstado INT,
			fecha DATE,
			fechaVencimiento DATE,
			monto MONEY,
			activo BIT
			)
		DECLARE @tmpIdRecibos TABLE (id INT)

		INSERT INTO @tmpIdRecibos (id)
		SELECT TR.id
		FROM @inTableRecibos TR

		WHILE (
				SELECT COUNT(tmp.id)
				FROM @tmpIdRecibos tmp
				) > 0
		BEGIN
			SET @idRecibo = (
					SELECT TOP (1) tmp.id
					FROM @tmpIdRecibos tmp
					ORDER BY tmp.id
					)

			DELETE @tmpIdRecibos
			WHERE id = @idRecibo

			-- Agrego el monto del recibo al monto total
			SET @montoTotal = @montoTotal + (
					SELECT R.monto
					FROM [dbo].[Recibo] R
					WHERE R.id = @idRecibo
					)

			-- Revisa si el Recibo esta vencido
			-- Obtener los datos del recibo
			SELECT @FechaVencimiento = R.fechaVencimiento,
				@MontoRecibo = R.monto,
				@TasaInteres = C.TasaInteresesMoratorios
			FROM [dbo].[Recibo] R
			INNER JOIN [dbo].[ConceptoCobro] C ON C.id = R.idConceptoCobro
			WHERE R.id = @idRecibo

			-- Calcular los intereses
			SET @MontoInteresMot = CASE 
					WHEN GETDATE() <= @FechaVencimiento
						THEN 0
					ELSE (@MontoRecibo * @TasaInteres / 365) * ABS(DATEDIFF(DAY, @FechaVencimiento, GETDATE()))
					END

			-- Si el monto es mayor a cero generar un recibo de intereses temporal
			IF @MontoInteresMot > 0
			BEGIN
				INSERT INTO @tmpRecibosInt (
					idPropiedad,
					idConceptoCobro,
					idEstado,
					fecha,
					fechaVencimiento,
					monto,
					activo
					)
				SELECT R.idPropiedad,
					C.id,
					T.id,
					GETDATE(),
					GETDATE(),
					@MontoInteresMot,
					1
				FROM [dbo].[Recibo] R
				INNER JOIN [dbo].[ConceptoCobro] C ON C.nombre = 'Interes Moratorio'
				INNER JOIN [dbo].[TipoEstadoRecibo] T ON T.estado = 'Pendiente'
				WHERE R.id = @idRecibo

				-- Se agrega el monto del recibo de intereses al monto total
				SET @montoTotal = @montoTotal + @MontoInteresMot
			END
		END

		-- Insertar los recibos en la base
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		BEGIN TRANSACTION
			INSERT INTO [dbo].[Recibo] (
				idPropiedad,
				idConceptoCobro,
				idTipoEstado,
				fecha,
				fechaVencimiento,
				monto,
				activo
				)
			SELECT tmpR.idPropiedad,
				tmpR.idConceptoCobro,
				tmpR.idEstado,
				tmpR.fecha,
				tmpR.fechaVencimiento,
				tmpR.monto,
				tmpR.activo
			FROM @tmpRecibosInt tmpR
		COMMIT

		-- Select de todos los recibos de interes y los seleccionados
		SELECT TR.numPropiedad AS [Numero Finca],
			TR.conceptoCobro AS [Concepto Cobro],
			TR.fecha AS [Fecha],
			TR.fechaVence AS [Fecha Vencimiento],
			TR.montoTotal AS [Monto]
		FROM @inTableRecibos TR
		
		UNION
		
		SELECT P.NumFinca AS [Numero Finca],
			C.nombre AS [Concepto Cobro],
			tmpR.fecha AS [Fecha],
			tmpR.fechaVencimiento AS [Fecha Vencimiento],
			tmpR.monto AS [Monto]
		FROM @tmpRecibosInt tmpR
		INNER JOIN [dbo].[Propiedad] P ON tmpR.idPropiedad = P.id
		INNER JOIN [dbo].[ConceptoCobro] C ON tmpR.idConceptoCobro = C.id
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


