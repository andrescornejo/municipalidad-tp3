/*
 * Stored Procedure: csp_generarReciboCCPorcentaje
 * Description: 
 * Author: Pablo Alpizar
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_generarReciboCCPorcentaje @inFecha DATE
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON

		DECLARE @tmpCCPorcentaje TABLE (id INT)
		DECLARE @idCC INT

		INSERT INTO @tmpCCPorcentaje(id)
		SELECT CP.id FROM [dbo].[CC_Porcentaje] CP

		WHILE (SELECT COUNT(*) FROM @tmpCCPorcentaje) > 0
		BEGIN
			-- iteramos por cada concepto cobro porcentual
			SET @idCC = (SELECT TOP 1 tmp.id FROM @tmpCCPorcentaje tmp ORDER BY tmp.id DESC)
			DELETE @tmpCCPorcentaje WHERE id = @idCC

			DECLARE @Monto MONEY
			DECLARE @Porcentaje FLOAT
			DECLARE @idPropiedad INT
			DECLARE @QDias INT
			DECLARE @DiaCobro INT = (
					SELECT C.DiaEmisionRecibo
					FROM [dbo].[ConceptoCobro] C
					WHERE C.id = @idCC
					)

			IF @DiaCobro = (
					SELECT DAY(@inFecha)
					)
			BEGIN

				DECLARE @tmpPropiedadesTipoCC TABLE (
					idPropiedad INT,
					valor MONEY
					)
				DECLARE @tmpRecibos TABLE (
					idPropiedad INT,
					idConceptoCobro INT,
					Monto MONEY
					)

				SET @Porcentaje = (
						SELECT CC.ValorPorcentaje
						FROM [dbo].[CC_Porcentaje] CC
						WHERE CC.id = @idCC
						)
				SET @QDias = (
						SELECT C.QDiasVencimiento
						FROM [dbo].[ConceptoCobro] C
						WHERE C.id = @idCC
						)

				INSERT INTO @tmpPropiedadesTipoCC (
					idPropiedad,
					valor
					)
				SELECT CP.idPropiedad,
					P.Valor
				FROM [dbo].[CCenPropiedad] CP
				INNER JOIN [dbo].[Propiedad] P ON CP.idPropiedad = P.id
				WHERE CP.idConceptoCobro = @idCC

				WHILE (
						SELECT COUNT(*)
						FROM @tmpPropiedadesTipoCC
						) > 0
				BEGIN
					-- seleccionamos la primera propiedad
					SET @idPropiedad = (SELECT TOP 1 tmp.idPropiedad
					FROM @tmpPropiedadesTipoCC tmp ORDER BY tmp.idPropiedad DESC)

					SET @Monto = (
							(SELECT tmp.valor
							FROM @tmpPropiedadesTipoCC tmp
							WHERE tmp.idPropiedad = @idPropiedad) 
							* (@Porcentaje / 100)
							)

					-- Quitamos esta propiedad de la tabla
					DELETE @tmpPropiedadesTipoCC
					WHERE @idPropiedad = idPropiedad

					INSERT INTO @tmpRecibos (
						idPropiedad,
						idConceptoCobro,
						Monto
						)
					SELECT @idPropiedad,
						@idCC,	
						@Monto
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
				esPendiente,
				activo
				)
			SELECT tmpR.idPropiedad,
				tmpR.idConceptoCobro,
				@inFecha,
				DATEADD(DAY, @QDias, @inFecha),
				tmpR.Monto,
				1,
				1
			FROM @tmpRecibos tmpR

			COMMIT
			RETURN 1
		END
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


