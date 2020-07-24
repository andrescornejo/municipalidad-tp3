/*
 * Stored Procedure: csp_adminDeletePropiedad
 * Description: Borrado logico de Objeto Entidad.
 * Author: Andres Cornejo
 * Modified by: Pablo Alpizar
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_adminDeletePropiedad @inputNumFinca INT,
	@inInsertedBy NVARCHAR(100),
	@inInsertedIn NVARCHAR(100)
AS
BEGIN
	BEGIN TRY
		DECLARE @jsonAntes NVARCHAR(500)
		DECLARE @idEntidad INT
		DECLARE @idPropiedad INT = (
				SELECT P.id
				FROM Propiedad P
				WHERE P.NumFinca = @inputNumFinca
				);
		DECLARE @tmpPropiedadDelPropietario TABLE (id INT)
		DECLARE @tmpUsuarioVsPropiedad TABLE (id INT)

		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

		BEGIN TRANSACTION

		UPDATE Propiedad
		SET activo = 0
		WHERE id = @idPropiedad

		UPDATE Reconteca
		SET activo = 0
		WHERE idPropiedad = @idPropiedad

		UPDATE Recibo
		SET activo = 0
		WHERE idPropiedad = @idPropiedad

		UPDATE PropiedadDelPropietario
		SET activo = 0
		WHERE idPropiedad = @idPropiedad

		INSERT INTO @tmpPropiedadDelPropietario (id)
		SELECT PP.id
		FROM [dbo].[PropiedadDelPropietario] PP
		WHERE PP.idPropiedad = @idPropiedad

		UPDATE UsuarioVsPropiedad
		SET activo = 0
		WHERE idPropiedad = @idPropiedad

		INSERT INTO @tmpUsuarioVsPropiedad (id)
		SELECT UP.id
		FROM [dbo].[UsuarioVsPropiedad] UP
		WHERE Up.idPropiedad = @idPropiedad

		UPDATE CCenPropiedad
		SET activo = 0
		WHERE idPropiedad = @idPropiedad

		UPDATE TransaccionConsumo
		SET activo = 0
		WHERE idPropiedad = @idPropiedad

		-- insert changes of PropiedadDelPropietario table into bitacora
		WHILE (
				SELECT COUNT(*)
				FROM @tmpPropiedadDelPropietario
				) > 0
		BEGIN
			SET @idEntidad = (
					SELECT TOP 1 tmpP.id
					FROM @tmpPropiedadDelPropietario tmpP
					)

			DELETE @tmpPropiedadDelPropietario
			WHERE id = @idEntidad

			SET @jsonAntes = (
					SELECT F.NumFinca AS 'Numero Finca',
						P.nombre AS 'Propietario',
						P.valorDocid AS 'Identificacion',
						'Activo' AS 'Estado'
					FROM [dbo].[PropiedadDelPropietario] PP
					INNER JOIN [dbo].[Propietario] P ON P.id = PP.idPropietario
					INNER JOIN [dbo].[Propiedad] F ON F.id = PP.idPropiedad
					WHERE PP.id = @idEntidad
					FOR JSON PATH,
						ROOT('Propiedad-Propietario')
					)

			INSERT INTO [dbo].[Bitacora] (
				idTipoEntidad,
				idEntidad,
				jsonAntes,
				jsonDespues,
				insertedAt,
				insertedBy,
				insertedIn
				)
			SELECT T.id,
				@idEntidad,
				@jsonAntes,
				NULL,
				GETDATE(),
				@inInsertedBy,
				@inInsertedIn
			FROM [dbo].[TipoEntidad] T
			WHERE T.Nombre = 'PropiedadVsPropietario'
		END

		-- insert changes of UsuarioVsPropiedad table into bitacora
		WHILE (
				SELECT COUNT(*)
				FROM @tmpUsuarioVsPropiedad
				) > 0
		BEGIN
			SET @idEntidad = (
					SELECT TOP 1 tmpU.id
					FROM @tmpUsuarioVsPropiedad tmpU
					)

			DELETE @tmpUsuarioVsPropiedad
			WHERE id = @idEntidad

			SET @jsonAntes = (
					SELECT U.username AS 'Nombre de Usuario',
						F.NumFinca AS 'Numero de Finca',
						'Activo' AS 'Estado'
					FROM [dbo].[UsuarioVsPropiedad] UP
					INNER JOIN [dbo].[Usuario] U ON U.id = UP.idUsuario
					INNER JOIN [dbo].[Propiedad] F ON F.id = UP.idPropiedad
					WHERE Up.id = @idEntidad
					FOR JSON PATH,
						ROOT('Propiedad-Usuario')
					)

			INSERT INTO [dbo].[Bitacora] (
				idTipoEntidad,
				idEntidad,
				jsonAntes,
				jsonDespues,
				insertedAt,
				insertedBy,
				insertedIn
				)
			SELECT T.id,
				@idEntidad,
				@jsonAntes,
				NULL,
				GETDATE(),
				@inInsertedBy,
				@inInsertedIn
			FROM [dbo].[TipoEntidad] T
			WHERE T.Nombre = 'PropiedadVsUsuario'
		END

		
		SET @jsonAntes = (
		SELECT @inputNumFinca AS 'Número de propiedad',
			p.Valor AS 'Valor monetario',
			p.Direccion AS 'Dirección',
			p.ConsumoAcumuladoM3 as 'Consumo acumulado m3',
			p.UltimoConsumoM3 as 'Ultimo consumo m3',
			'Activo' AS 'Estado'
		from Propiedad p where p.id = @idPropiedad
		FOR JSON PATH,
			ROOT('Propiedad')
		)
--Logging is disabled since the trigger takes care of this.
		-- INSERT Bitacora (
		-- 	idTipoEntidad,
		-- 	idEntidad,
		-- 	jsonAntes,
		-- 	jsonDespues,
		-- 	insertedAt,
		-- 	insertedBy,
		-- 	insertedIn
		-- 	)
		-- SELECT t.id,
		-- 	@idPropiedad,
		-- 	@jsonAntes,
		-- 	NULL,
		-- 	GETDATE(),
		-- 	@inInsertedBy,
		-- 	@inInsertedIn
		-- FROM dbo.TipoEntidad T
		-- WHERE T.Nombre = 'Propiedad'

		COMMIT

		RETURN 0
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK

		RETURN - 1
	END CATCH
END
GO


