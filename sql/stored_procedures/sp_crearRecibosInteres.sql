/*
 * Stored Procedure: csp_crearRecibosInteres
 * Description: 
 * Author: Pablo Alpizar
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_crearRecibosInteres @inTableIdRecibos INT, @outMontoTotal money OUTPUT
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON

		DECLARE @FechaVencimiento DATE
		DECLARE @idRecibo INT
		DECLARE @MontoInteresMot MONEY
		DECLARE @TasaInteres FLOAT
		DECLARE @tmpInfoRecibos TABLE (
			id INT,
			FechaVencimiento DATE
			)
        DECLARE @tmpRecibosInt TABLE (
            idPropiedad INT,
            idConceptoCobro INT,
            fecha DATE,
            fechaVencimiento DATE,
            monto MONEY,
			idTipoEstado int,
            activo BIT
        )
		DECLARE @MontoRecibo MONEY

		-- Revisar cuales Recibos estan vencidos
		WHILE (
				SELECT COUNT(IR.id)
				FROM @inTableIdRecibos IR
				) > 0
		BEGIN
			SET @idRecibo = (
					SELECT TOP 1 IR.id
					FROM @inTableIdRecibos IR
					)

			DELETE TOP (1)
			FROM @inTableIdRecibos

			SET @FechaVencimiento = (
					SELECT R.fechaVencimiento
					FROM [dbo].[Recibo] R
					WHERE R.id = @idRecibo
					)
			SET @MontoRecibo = (
					SELECT R.monto
					FROM [dbo].[Recibo] R
					WHERE R.id = @idRecibo
					)
			SET @TasaInteres = (
					SELECT C.TasaInteresesMoratorios
					FROM [dbo].[ConceptoCobro] C
					INNER JOIN [dbo].[Recibo] R ON R.id = @idRecibo
					WHERE C.id = R.id
					)
			SET @MontoInteresMot = CASE 
					WHEN GETDATE() <= @FechaVencimiento
						THEN 0
					ELSE (@MontoRecibo * @TasaInteres / 365) * ABS(DATEDIFF(DAY, @FechaVencimiento, GETDATE()))
					END

            IF @MontoInteresMot > 0
            BEGIN
                INSERT INTO @tmpRecibosInt (
                    idPropiedad,
                    idConceptoCobro,
                    fecha,
                    fechaVencimiento,
                    monto,
					idTipoEstado,
                    activo
                )
                SELECT R.id,
                    C.id,
                    GETDATE(),
                    GETDATE(),
                    @MontoInteresMot,
                    1,
                    1
                FROM [dbo].[Recibo] R
                INNER JOIN [dbo].[ConceptoCobro] C ON C.nombre = 'Interes Moratorio' 
                WHERE R.id = @idRecibo
			
			INSERT INTO @outTableRecibosInteres (id)
			SELECT TOP (1) R.id FROM [dbo].[Recibo] R ORDER BY R.id DESC
            END
		END
        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		BEGIN TRANSACTION
            INSERT INTO [dbo].[Recibo] (
                idPropiedad,
                idConceptoCobro,
                fecha,
                fechaVencimiento,
                monto,
				idTipoEstado,
                activo    
            )
            SELECT tmp.idPropiedad,
                tmp.idConceptoCobro,
                tmp.fecha,
                tmp.fechaVencimiento,
                tmp.monto,
				tmp.idTipoEstado,
                tmp.activo
            FROM @tmpRecibosInt tmp
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


