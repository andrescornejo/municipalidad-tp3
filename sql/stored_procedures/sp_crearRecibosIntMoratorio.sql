/*
 * Stored Procedure: csp_crearRecibosIntMoratorio
 * Description: 
 * Author: Pablo Alpizar
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_crearRecibosIntMoratorio @inRecibosIDTable udt_idTable READONLY,
    @inFecha DATE,
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
		DECLARE @idTable TABLE (storedID INT)
		DECLARE @finalReceiptIDTable TABLE (storedID INT)

		--Insert into the temporary table where the loop will excecute.
		INSERT INTO @idTable
		SELECT i.storedID
		FROM @inRecibosIDTable i

		--Insert into the temporary table that contains all final ids.
		INSERT INTO @finalReceiptIDTable
		SELECT i.storedID
		FROM @inRecibosIDTable i

		SET @montoTotal = 0
		SET @MontoInteresMot = 0
		SET @MontoRecibo = 0

		WHILE (
				SELECT COUNT(tmp.storedID)
				FROM @idTable tmp
				) > 0
		BEGIN
			SET @idRecibo = (
					SELECT TOP (1) tmp.storedID
					FROM @idTable tmp
					ORDER BY tmp.storedID
					)

			DELETE @idTable
			WHERE storedID = @idRecibo

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
					WHEN @inFecha < @FechaVencimiento
						THEN 0
					ELSE ((@MontoRecibo * (@TasaInteres / 365)) * ABS(DATEDIFF(DAY, @FechaVencimiento, @inFecha)))
					END

			-- Si el monto es mayor a cero generar un recibo de intereses temporal
			IF @MontoInteresMot > 0
			BEGIN
				-- Se agrega el monto del recibo de intereses al monto total
				SET @montoTotal = @montoTotal + @MontoInteresMot
				SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

				BEGIN TRANSACTION

				INSERT INTO dbo.Recibo (
					idPropiedad,
					idConceptoCobro,
					idTipoEstado,
					fecha,
					fechaVencimiento,
					monto,
					activo
					)
				SELECT R.idPropiedad,
					C.id,
					T.id,
					@inFecha,
					@inFecha,
					@MontoInteresMot,
					1
				FROM [dbo].[Recibo] R
				INNER JOIN [dbo].[ConceptoCobro] C ON C.nombre = 'Interes Moratorio'
				INNER JOIN [dbo].[TipoEstadoRecibo] T ON T.estado = 'Pendiente'
				WHERE R.id = @idRecibo

				COMMIT

				--insertar el id del recibo recien creado a la lista final
				INSERT @finalReceiptIDTable
				SELECT SCOPE_IDENTITY()
			END
		END

		SELECT i.id AS [id],
			p.NumFinca [numP],
			c.nombre AS [cc],
			i.fecha AS [fecha],
			i.fechaVencimiento AS [fv],
			i.monto AS [monto]
		FROM Recibo i
		INNER JOIN @finalReceiptIDTable t ON t.storedID = i.id
		INNER JOIN dbo.ConceptoCobro C ON C.id = i.idConceptoCobro
		INNER JOIN dbo.Propiedad P ON P.id = i.idPropiedad

		RETURN 0
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