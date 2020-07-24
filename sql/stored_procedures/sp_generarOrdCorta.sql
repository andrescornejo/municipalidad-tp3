/*
 * Stored Procedure: csp_generarOrdCorta
 * Description: 
 * Author: Pablo Alpizar
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_generarOrdCorta @inFecha DATE
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON

		DECLARE @tmpRecibosPedientes TABLE (idPropiedad INT)
		DECLARE @idPropiedad INT

		INSERT INTO @tmpRecibosPedientes (idPropiedad)
		SELECT R.idPropiedad
		FROM [dbo].[Recibo] R
		WHERE R.idConceptoCobro = 1 AND R.esPendiente = 1

		WHILE (
				SELECT COUNT(*)
				FROM @tmpRecibosPedientes
				) > 0
		BEGIN
			-- tomar la primera propiedad
			SET @idPropiedad = (
					SELECT TOP 1 tmp.idPropiedad
					FROM @tmpRecibosPedientes tmp
			)
			IF ((SELECT COUNT(tmp.idPropiedad) FROM @tmpRecibosPedientes tmp WHERE tmp.idPropiedad = @idPropiedad) > 1
				AND (SELECT COUNT(R.id) FROM [dbo].[Recibo] R WHERE R.idConceptoCobro = 10 AND R.idPropiedad = @idPropiedad AND R.esPendiente = 1) = 0)
			BEGIN
				-- Recibo de reconexion
				INSERT INTO [dbo].[Recibo] (
					idPropiedad, 
					idConceptoCobro, 
					fecha,
					fechaVencimiento,
					monto,
					esPendiente,
					activo)
				SELECT 
					@idPropiedad,
					C.id,
					@inFecha,
					DATEADD(DAY,C.QDiasVencimiento,@inFecha),
					CF.monto,
					1,
					1
				FROM [dbo].[ConceptoCobro] C 
				INNER JOIN [dbo].[CC_Fijo] CF ON C.id = CF.id
				WHERE C.nombre = 'Reconexion de agua'

				INSERT INTO [dbo].[Reconexion] (id,activo)
				SELECT R.id,1
				FROM [dbo].[Recibo] R 
				WHERE R.idPropiedad = @idPropiedad AND idConceptoCobro = 10 AND fecha = @inFecha

				-- Generar la orden de corta
				INSERT INTO [dbo].[Corte] (idReconexion, fecha, idPropiedad, activo)
				SELECT R.id, @inFecha, @idPropiedad, 1
				FROM [dbo].[Recibo] R 
				WHERE R.idPropiedad = @idPropiedad AND idConceptoCobro = 10 AND fecha = @inFecha

			END
			DELETE @tmpRecibosPedientes
			WHERE idPropiedad = @idPropiedad
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


