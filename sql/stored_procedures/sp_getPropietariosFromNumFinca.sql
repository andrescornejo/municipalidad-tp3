/*
 * Stored Procedure: csp_getPropietariosFromNumFinca
 * Description: 
 * Author: Andres Cornejo
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_getPropietariosFromNumFinca @inputNumFinca INT
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON

		DECLARE @idPropiedad INT

		EXEC @idPropiedad = csp_getPropiedadIDFromNumFinca @inputNumFinca

		PRINT (@idPropiedad)

		SELECT p.nombre AS 'Nombre',
			p.valorDocID AS 'Documento Legal'
		FROM Propietario p
		JOIN PropiedadDelPropietario pdp ON pdp.idPropietario = p.id
			AND pdp.activo = 1
		WHERE @idPropiedad = pdp.idPropiedad
		AND p.activo = 1
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

--EXEC csp_getPropietariosFromNumFinca 9782331
