/*
 * Stored Procedure: csp_crearAP
 * Description: 
 * Author: Pablo Alpizar
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_crearAP @inNumFinca INT,
	@inMontoTotal MONEY,
	@inPlazo INT,
	@inCuota MONEY,
    @inFecha DATE
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON

		DECLARE @comprobante INT,
			@tasaInteres FLOAT = 0.1
		DECLARE @tmpRecibos udt_idTable

		INSERT INTO @tmpRecibos (storedID)
		SELECT R.id
		FROM [dbo].[Recibo] R
		INNER JOIN [dbo].[Propiedad] P ON P.NumFinca = @inNumFinca
		WHERE R.idPropiedad = P.id
			AND R.idTipoEstado = (
				SELECT T.id
				FROM [TipoEstadoRecibo] T
				WHERE T.estado = 'Pendiente'
				)

		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		BEGIN TRANSACTION

			-- crear un comprobante nuevo
			INSERT INTO [dbo].[ComprobanteDePago] (
				fecha,
				MontoTotal,
				activo
				)
			SELECT GETDATE(),
				0,
				1

			-- obtener el numero de comprobante
			SET @comprobante = (
					SELECT TOP (1) C.id
					FROM [dbo].[ComprobanteDePago] C
					ORDER BY C.id DESC
					)

			-- crear el AP con monto cero
			INSERT INTO [dbo].[AP] (
				idPropiedad,
				idComprobante,
				montoOriginal,
				saldo,
				tasaInteresAnual,
				plazoOriginal,
				plazoResta,
				cuota,
				insertedAt,
				updatedAt,
				activo
				)
			SELECT P.id,
				@comprobante,
				@inMontoTotal,
				0,
				@tasaInteres,
				@inPlazo,
				@inPlazo,
				@inCuota,
				@inFecha,
				@inFecha,
				1
			FROM [dbo].[Propiedad] P
			WHERE P.NumFinca = @inNumFinca

			-- insertar el primer movimiento del AP en la tabla de movimientoAP
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
			SELECT 
				SCOPE_IDENTITY(),
				TM.id,
				@inMontoTotal,
				0,
				@inPlazo,
				@inMontoTotal,
				@inFecha,
                'OPERACIONES',
				1
			FROM [dbo].[TipoMovAP] TM
            WHERE TM.Nombre = 'Debito'
			
			-- actualizar el AP
			UPDATE [dbo].[AP]
			SET saldo = (SELECT TOP (1) M.nuevoSaldo FROM [dbo].[MovimientoAP] M ORDER BY M.id DESC ),
				updatedAt = @inFecha

			-- Actulizar el comprobante
			UPDATE [dbo].[ComprobanteDePago]
			SET MontoTotal = @inMontoTotal,
				descripcion = (
					SELECT CONCAT (
							'AP',(
								SELECT CONVERT(NVARCHAR(10), (SELECT TOP(1) AP.id FROM [dbo].[AP] AP
								ORDER BY AP.id DESC))
							))
					)
			WHERE id = @comprobante


			-- Actualizar los recibos que se pagan con ese AP
			UPDATE [dbo].[Recibo]
			SET idComprobantePago = @comprobante,
				idTipoEstado = (
					SELECT T.id
					FROM [dbo].[TipoEstadoRecibo] T
					WHERE T.estado = 'Pagado'
				)
            FROM [dbo].[Recibo] R
            INNER JOIN @tmpRecibos tmp ON tmp.storedID = R.id
            
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