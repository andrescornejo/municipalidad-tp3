/*
 * Stored Procedure: csp_getPropiedadesFromPropietarioDocID
 * Description: SP que devuelve las propiedades de un propietario a partir de su numero de identificacion.
 * Author: Andres Cornejo
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_getPropiedadesFromPropietarioDocID @inputDocID NVARCHAR(100)
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON

		DECLARE @idPropietario INT

		EXEC @idPropietario = csp_getPropietarioIDFromDocID @inputDocID

		PRINT (@idPropietario)

		SELECT p.NumFinca AS 'Número de propiedad',
			p.Valor AS 'Valor monetario',
			p.Direccion AS 'Dirección'
		FROM Propiedad p
		JOIN PropiedadDelPropietario pdp ON pdp.idPropiedad = p.id
			AND pdp.activo = 1
		WHERE @idPropietario = pdp.idPropietario 
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

--EXEC csp_getPropiedadesFromPropietarioDocID '303581304'