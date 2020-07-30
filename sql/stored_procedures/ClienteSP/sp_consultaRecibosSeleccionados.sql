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
		DECLARE @tmpRecibosConsulta TABLE (id INT)
		-- Tomar todos los id de los recibos seleccionados
		INSERT INTO @tmpIdRecibos (id)
		SELECT TR.id
		FROM @inTableRecibos TR

		-- insertarlos en los recibos a consultar
		INSERT @tmpRecibosConsulta
		SELECT id FROM @tmpIdRecibos

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
			WHILE (SELECT COUNT(*) FROM @tmpRecibosInt tmp) > 0
			BEGIN
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

				-- Guardar el id del recibo creado en los Recibos consulta
				INSERT INTO @tmpRecibosConsulta (id)
				SELECT TOP (1) R.id FROM [dbo].[Recibo] R ORDER BY R.id DESC 
			END
		COMMIT

		-- Select de todos los recibos de interes y los seleccionados
		SELECT R.id AS [id],
			P.numFinca AS [Numero Finca],
			C.nombre AS [Concepto Cobro],
			R.fecha AS [Fecha de Emision],
			R.fechaVencimiento AS [Fecha Vencimiento],
			R.monto AS [Monto Total]
		FROM [dbo].[Recibo] R
		INNER JOIN @tmpRecibosConsulta tmp ON R.id = tmp.id
		INNER JOIN [dbo].[Propiedad] P ON R.idPropiedad = P.id
		INNER JOIN [dbo].[ConceptoCobro] C ON R.idConceptoCobro = C.id
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


