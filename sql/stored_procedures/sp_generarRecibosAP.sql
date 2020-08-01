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

		DECLARE @id INT, @descripcion NVARCHAR(100), @idM INT
		DECLARE @tmpAP udt_idTable

		INSERT INTO @tmpAP (storedID)
		SELECT AP.id
		FROM [dbo].[AP] AP
		WHERE NOT (
				SELECT CONVERT(DATE, AP.insertedAt)
				) = @inFecha
			AND (
				SELECT DAY(AP.insertedAt)
				) = (
				SELECT DAY(@inFecha)
				)

		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

		BEGIN TRANSACTION

		WHILE (
				EXISTS (
					SELECT 1
					FROM @tmpAP
					)
				)
		BEGIN
			SET @id = (
					SELECT TOP (1) tmp.storedID
					FROM @tmpAP tmp
					)

			DELETE TOP (1) @tmpAP

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
			SELECT AP.idPropiedad,
				C.id,
				T.id,
				@inFecha,
				DATEADD(DAY, C.QDiasVencimiento, @inFecha),
				AP.cuota,
				1
			FROM [dbo].[AP] AP
			INNER JOIN [dbo].[ConceptoCobro] C ON C.nombre = 'AP'
			INNER JOIN [dbo].[TipoEstadoRecibo] T ON T.estado = 'Pendiente'
			WHERE @id = AP.id

			-- insertar el movimiento del  AP
			INSERT INTO [dbo].[movimientoAP] (
				idAP,
				idTipoMovAP,
				monto,
				interesDelMes,
				PlazoResta,
				nuevoSaldo,
				fecha,
				insertedBy,
				activo
				)
			SELECT @id,
				TM.id,
				AP.cuota - AP.saldo * AP.tasaInteresAnual / 12,
				AP.saldo * AP.tasaInteresAnual / 12,
				AP.plazoResta - 1,
				AP.saldo - (AP.cuota - AP.saldo * AP.tasaInteresAnual / 12),
				@inFecha,
				'USERNAME',
				1
			FROM [dbo].[AP] AP
			INNER JOIN [dbo].[TipoMovAP] TM ON TM.Nombre = 'Credito'
			WHERE AP.id = @id

			SET @idM = SCOPE_IDENTITY()

			SELECT @descripcion = 
			'Interés mensual:' + CONVERT(NVARCHAR(20), M.interesDelMes) + ', ' 
			+ 'Amortización:' + CONVERT(NVARCHAR(20), M.monto) + ', '
			 + 'Plazo Resta:' + CONVERT(NVARCHAR(20), M.PlazoResta)
			FROM [dbo].[movimientoAP] M 
			WHERE M.id = @idM

			-- insertar el ReciboAP
			INSERT INTO [dbo].[RecibosAP] (
				id,
				idMovimientoAP,
				descripcion
				)
			SELECT
				@id,
				@idM,
				@descripcion

			-- update AP
			UPDATE [dbo].[AP]
			SET AP.saldo = M.nuevoSaldo,
				AP.plazoResta = M.PlazoResta,
				AP.updatedAt = @inFecha
			FROM [dbo].[AP] AP
			INNER JOIN [dbo].[MovimientoAP] M ON M.id = @idM
			WHERE AP.id = @id
		END;

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


