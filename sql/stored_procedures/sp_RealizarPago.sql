/*
 * Stored Procedure: csp_PagoAgua
 * Description: 
 * Author: Pablo Alpizar
 */

use municipalidad
go

create or alter proc csp_RealizarPago @inNumFinca INT, 
@inIdComprobante INT, 
@inFecha DATE,
@idTipoCC INT
as
begin
	begin try
		set nocount on
		DECLARE @idRecibo INT
		DECLARE @FechaVenc DATE
		DECLARE @InterestMot MONEY
		DECLARE @MontoRecibo MONEY
		DECLARE @TasaInterest FLOAT
		DECLARE @tmpReciboPediente TABLE (id INT)

		-- tomo todos los recibos del Tipo CC pedientes
		INSERT INTO @tmpReciboPediente
		SELECT R.id FROM [dbo].[Recibo] R
		INNER JOIN [dbo].[Propiedad] P ON P.NumFinca = @inNumFinca
		WHERE R.esPendiente = 1 AND R.idPropiedad = P.id 
			AND R.activo = 1 AND idConceptoCobro = @idTipoCC
		ORDER BY R.fecha ASC
		
		SET @TasaInterest = (SELECT CC.TasaInteresesMoratorios FROM [dbo].[ConceptoCobro] CC WHERE CC.id = @idTipoCC)

		BEGIN TRANSACTION
		WHILE (SELECT COUNT(*) FROM @tmpReciboPediente) > 0
		BEGIN
			SET @idRecibo = (SELECT TOP 1 tmp.id FROM @tmpReciboPediente tmp)
			DELETE @tmpReciboPediente WHERE id = @idRecibo

			SET @FechaVenc = (SELECT R.fechaVencimiento FROM [dbo].[Recibo] R WHERE R.id = @idRecibo)

			SET @MontoRecibo = (SELECT R.monto FROM [dbo].[Recibo] R WHERE R.id = @idRecibo)

			SET @InterestMot = CASE 
			WHEN @inFecha <= @FechaVenc THEN 0
			ELSE (@MontoRecibo * @TasaInterest / 365) * ABS(DATEDIFF(DAY,@FechaVenc, @inFecha))
			END
			-- Si existen intereses moratorios entonces generamos un recibo por el monto
			IF @InterestMot > 0 
			BEGIN
				INSERT INTO [dbo].[Recibo](
					idComprobantePago,
            		idPropiedad,
            		idConceptoCobro, 
            		fecha, 
            		fechaVencimiento, 
            		monto,
            		esPendiente,
            		Activo
        			)
				SELECT 
					@inIdComprobante,
					P.id,
					CC.id,
					@inFecha,
					@inFecha,
					@InterestMot,
					0,
					1
				FROM [dbo].[Propiedad] P
				JOIN [dbo].[ConceptoCobro] CC ON CC.nombre = 'Interes Moratorio'
				-- incluimos en valor del recibo en el comprobante
				UPDATE [dbo].[ComprobanteDePago]
				SET MontoTotal = MontoTotal + @InterestMot
				WHERE id = @inIdComprobante	
			END

			-- Actualizo los valores del recibo
			UPDATE [dbo].[Recibo]
			SET esPendiente = 0
			WHERE id = @idRecibo
			-- Actualizo el idComprobante
			UPDATE [dbo].[Recibo]
			SET idComprobantePago = @inIdComprobante
			WHERE id = @idRecibo

			-- Actualizo el monto total del comprobante
			UPDATE [dbo].[ComprobanteDePago]
			SET MontoTotal = MontoTotal + (SELECT R.monto FROM [dbo].[Recibo] R WHERE R.id = @idRecibo)
			WHERE id = @inIdComprobante
		END

		COMMIT

	end try
	begin catch
		IF @@TRANCOUNT > 0
			ROLLBACK

		DECLARE @errorMsg NVARCHAR(200) = (
				SELECT ERROR_MESSAGE()
				)

		PRINT ('ERROR:' + @errorMsg)

		RETURN - 1 * @@ERROR
	end catch
end

go