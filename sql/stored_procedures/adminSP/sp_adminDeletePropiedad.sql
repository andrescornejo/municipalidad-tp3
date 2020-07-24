/*
 * Stored Procedure: csp_adminDeletePropiedad
 * Description: Borrado logico de Objeto Entidad.
 * Author: Andres Cornejo
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_adminDeletePropiedad @inputNumFinca INT, @inputInsertedBy NVARCHAR(100), @inputInsertedIn NVARCHAR(100)
AS
BEGIN
	BEGIN TRY
		DECLARE @idPropiedad INT = (
				SELECT P.id
				FROM Propiedad P
				WHERE P.NumFinca = @inputNumFinca
				);

		declare @jsonAntes NVARCHAR(500)

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

		UPDATE UsuarioVsPropiedad
		SET activo = 0
		WHERE idPropiedad = @idPropiedad

		UPDATE CCenPropiedad
		SET activo = 0
		WHERE idPropiedad = @idPropiedad

		UPDATE TransaccionConsumo
		SET activo = 0
		WHERE idPropiedad = @idPropiedad

Insert Bitacora(idTipoEntidad, idEntidad, jsonAntes, jsonDespues, insertedAt, insertedBy, insertedIn)
		select t.id, @idPropiedad, @jsonAntes, null, GETDATE(),@inputInsertedBy, @inputInsertedIn
		from dbo.TipoEntidad T where T.Nombre = 'Propiedad'

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


