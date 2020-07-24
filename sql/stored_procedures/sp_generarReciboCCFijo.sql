/*
 * Stored Procedure: csp_generarReciboCCFijo
 * Description: 
 * Author: Pablo Alpizar
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_generarReciboCCFijo @inFecha DATE
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON
		DECLARE @tmpCCFijo TABLE(id INT)
		DECLARE @idCC INT
		INSERT INTO @tmpCCFijo (id)
		SELECT C.id FROM [dbo].[CC_Fijo] C

		WHILE (SELECT COUNT(*) FROM @tmpCCFijo) > 0
		BEGIN
			-- iteramos por todos los conceptos de cobro fijos
			SET @idCC = (SELECT TOP 1 tmp.id FROM @tmpCCFijo tmp)
			DELETE @tmpCCFijo WHERE id = @idCC
			
			DECLARE @DiaCobro INT = (
					SELECT C.DiaEmisionRecibo
					FROM [dbo].[ConceptoCobro] C
					WHERE C.id = @idCC
			)
			IF @DiaCobro = (
					SELECT DAY(@inFecha)
					)
			BEGIN
				DECLARE @tmpPropiedadesTipoCC TABLE (idPropiedad INT)

				INSERT INTO @tmpPropiedadesTipoCC (idPropiedad)
				SELECT CP.idPropiedad
				FROM [dbo].[CCenPropiedad] CP
				WHERE CP.idConceptoCobro = @idCC

				INSERT INTO [dbo].[Recibo] (
					idPropiedad,
					idConceptoCobro,
					fecha,
					fechaVencimiento,
					monto,
					esPendiente,
					Activo
					)
				SELECT tmp.idPropiedad,
					@idCC,
					@inFecha,
					DATEADD(DAY, CC.QDiasVencimiento, @inFecha),
					CF.Monto,
					1,
					1
				FROM @tmpPropiedadesTipoCC tmp
				INNER JOIN [dbo].[ConceptoCobro] CC ON @idCC = CC.id
				INNER JOIN [dbo].[CC_Fijo] CF ON @idCC = CF.id
			END
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


