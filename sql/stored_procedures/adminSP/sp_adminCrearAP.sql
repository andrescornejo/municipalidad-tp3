/*
 * Stored Procedure: csp_adminPagoConAP
 * Description: 
 * Author: Pablo Alpizar
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_adminCrearAP @inNumFinca INT,
	@inMontoTotal MONEY,
	@inPlazo INT,
	@inCuota MONEY,
	@inUserName NVARCHAR(50)
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON

		DECLARE @comprobante INT,
			@tasaInteres FLOAT
		DECLARE @tmpRecibos udt_idTable

		INSERT INTO @tmpRecibos (id)
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
				updatedAt
				)
			SELECT P.id,
				@comprobante,
				@inMontoTotal,
				0,
				@tasaInteres,
				@inPlazo,
				@inPlazo,
				@inCuota,
				GETDATE(),
				GETDATE()
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
				(SELECT TOP(1) AP.id),
				TM.id,
				@inMontoTotal,
				@0,
				@inPlazo,
				@inMontoTotal,
				GETDATE(),
				@inUserName,
				1
			FROM [dbo].[AP] AP
			INNER JOIN [dbo].[idTipoMovAP] TM ON TM.Nombre = 'Debito'
			ORDER BY AP.id DESC
			
			-- actualizar el AP
			UPDATE [dbo].[AP]
			SET saldo = (SELECT TOP (1) M.saldo FROM [MovimientoAP] M ORDER BY M.id DESC ),
				updateAt = GETDATE()

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
			SET idConceptoCobro = @comprobante,
				idTipoEstado = (
					SELECT T.id
					FROM [dbo].[TipoEstadoRecibo] T
					WHERE T.estado = 'Pagado'
				)
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


