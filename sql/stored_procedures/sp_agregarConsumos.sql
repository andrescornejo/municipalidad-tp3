/*
 * Stored Procedure: csp_agregarTransConsumo
 * Description: 
 * Author: Pablo Alpizar
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_agregarTransConsumo @inFecha DATE,  @OperacionXML XML
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON
		DECLARE @MontoM3 MONEY
		DECLARE @NumFincaRef INT
		DECLARE @hdoc INT
		DECLARE @idTipoTrans INT
		DECLARE @tmpConsumo TABLE (
			idTipoTransConsumo INT,
			FechaXml DATE,
			LecturaM3 INT,
			Descripcion NVARCHAR(100),
			NumFinca INT
			)

		SET @MontoM3 = (
				SELECT CC.ValorM3
				FROM dbo.CC_ConsumoAgua CC
				INNER JOIN dbo.ConceptoCobro C ON C.nombre = 'Agua'
				WHERE C.id = CC.id
				)

		EXEC sp_xml_preparedocument @hdoc OUT,
			@OperacionXML

		INSERT INTO @tmpConsumo (
			idTipoTransConsumo,
			FechaXml,
			Descripcion,
			NumFinca,
			LecturaM3
			)
		SELECT X.id,
			X.fecha,
			X.descripcion,
			X.NumFinca,
			X.LecturaM3
		FROM openxml(@hdoc, '/Operaciones_por_Dia/OperacionDia/TransConsumo', 1) WITH (
				id INT,
				fecha DATE '../@fecha',
				descripcion NVARCHAR(100),
				NumFinca INT,
				LecturaM3 INT
				) AS X
		WHERE @inFecha = fecha

		EXEC sp_xml_removedocument @hdoc;

		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		BEGIN TRANSACTION

		WHILE (SELECT COUNT(*) FROM @tmpConsumo) > 0
		BEGIN
			-- Seleccionamos la primera propiedad
			SET @NumFincaRef = (SELECT TOP 1 tmp.NumFinca FROM @tmpConsumo tmp ORDER BY tmp.NumFinca DESC)
			SET @idTipoTrans = (SELECT TOP 1 tmp.idTipoTransConsumo FROM @tmpConsumo tmp ORDER BY tmp.NumFinca DESC)

			INSERT dbo.TransaccionConsumo (
				idPropiedad,
				fecha,
				montoM3,
				LecturaConsumoM3,
				NuevoAcumuladoM3,
				activo,
				idTipoTransacCons
				)
			SELECT P.id,
				tmp.FechaXml,
				@MontoM3,
				tmp.LecturaM3,
				(CASE WHEN @idTipoTrans = 1 THEN tmp.LecturaM3
					WHEN @idTipoTrans = 2 then P.ConsumoAcumuladoM3 - tmp.LecturaM3
					ELSE P.ConsumoAcumuladoM3 + tmp.LecturaM3
				END),
				1,
				@idTipoTrans
			FROM @tmpConsumo tmp
			INNER JOIN dbo.Propiedad P ON @NumFincaRef = P.NumFinca
			WHERE tmp.NumFinca = @NumFincaRef AND tmp.idTipoTransConsumo = @idTipoTrans
	
	
			UPDATE [dbo].[Propiedad]
			SET ConsumoAcumuladoM3 = (SELECT TC.NuevoAcumuladoM3 
										FROM [dbo].[TransaccionConsumo] TC
										INNER JOIN [dbo].[Propiedad] P ON P.NumFinca = @NumFincaRef 
										WHERE TC.idPropiedad = P.id AND TC.fecha = @inFecha
												AND TC.idTipoTransacCons = @idTipoTrans)
			WHERE NumFinca = @NumFincaRef

			DELETE @tmpConsumo WHERE NumFinca = @NumFincaRef AND idTipoTransConsumo = @idTipoTrans
		END
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


