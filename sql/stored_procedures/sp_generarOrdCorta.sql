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
		WHERE R.idConceptoCobro = 1 AND R.idTipoEstado = (
			SELECT T.id 
			FROM [dbo].[TipoEstadoRecibo] T
			WHERE T.estado = 'Pediente' 
		)
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
				AND (SELECT COUNT(R.id) FROM [dbo].[Recibo] R WHERE R.idConceptoCobro = 10 AND 
					R.idPropiedad = @idPropiedad AND 
						R.idTipoEstado = (
						SELECT T.id 
						FROM [dbo].[TipoEstadoRecibo] T
						WHERE T.estado = 'Pediente' )
					) = 0)
			BEGIN
				-- Recibo de reconexion
				INSERT INTO [dbo].[Recibo] (
					idPropiedad, 
					idConceptoCobro,
					idTipoEstado,
					fecha,
					fechaVencimiento,
					monto,
					activo)
				SELECT 
					@idPropiedad,
					C.id,
					T.id,
					@inFecha,
					DATEADD(DAY,C.QDiasVencimiento,@inFecha),
					CF.monto,
					1
				FROM [dbo].[ConceptoCobro] C 
				INNER JOIN [dbo].[CC_Fijo] CF ON C.id = CF.id
				INNER JOIN [dbo].[TipoEstadoRecibo] T ON T.estado = 'Pediente'
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


