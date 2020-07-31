/*
 * Stored Procedure: csp_adminRecibosPendientes
 * Description: 
 * Author: Andres Cornejo
 */

use municipalidad
go

create or alter proc csp_adminRecibosPendientes @inNumProp int, @montoTotal MONEY OUT
as
begin
	begin try
		set nocount on
        DECLARE @FechaVencimiento DATE,
			@MontoInteresMot MONEY,
			@TasaInteres FLOAT,
			@MontoRecibo MONEY,
			@idRecibo INT

declare @idTable table (storedID int)
declare @finalReceiptIDTable table (storedID int)
declare @idProp INT, @idEstadoPendiente INT
set @idEstadoPendiente = (select top 1 e.id from TipoEstadoRecibo e where e.estado = 'Pendiente')
set @idProp = (select top 1 p.id from Propiedad p where p.NumFinca = @inNumProp)

        --Insert into the temporary table where the loop will excecute.
		INSERT INTO @idTable
		SELECT r.id
		FROM Recibo r 
        where r.idPropiedad = @idProp
        and r.idTipoEstado = @idEstadoPendiente 

        --Insert into the temporary table that contains all final ids.
        insert into @finalReceiptIDTable
        select i.storedID
        from @idTable i

		set @montoTotal = 0
		set @MontoInteresMot = 0
		set @MontoRecibo = 0		

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
					WHEN GETDATE() < @FechaVencimiento
						THEN 0
					ELSE ((@MontoRecibo * (@TasaInteres / 365)) * ABS(DATEDIFF(DAY, @FechaVencimiento, GETDATE())))
					END

			-- Si el monto es mayor a cero generar un recibo de intereses temporal
			IF @MontoInteresMot > 0
			BEGIN
				-- Se agrega el monto del recibo de intereses al monto total
				SET @montoTotal = @montoTotal + @MontoInteresMot
                SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
				BEGIN TRANSACTION
				INSERT INTO dbo.Recibo(idPropiedad, idConceptoCobro
				, idTipoEstado, fecha, fechaVencimiento, monto, activo)
				SELECT  
					R.idPropiedad,
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
				COMMIT
				--insertar el id del recibo recien creado a la lista final
				insert @finalReceiptIDTable select SCOPE_IDENTITY()

			END

		END
        	select i.id as [id],
            p.NumFinca [numP],
            c.nombre as [cc],
            i.fecha as [fecha],
            i.fechaVencimiento as [fv],
            i.monto as [monto]
            from Recibo i
            INNER Join @finalReceiptIDTable t on t.storedID = i.id
            inner join dbo.ConceptoCobro C on C.id = i.idConceptoCobro
            inner join dbo.Propiedad P on P.id = i.idPropiedad
        return 0

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
