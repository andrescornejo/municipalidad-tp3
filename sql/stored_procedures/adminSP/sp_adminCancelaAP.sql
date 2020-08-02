/*
 * Stored Procedure: csp_adminCancelaAP
 * Description: 
 * Author: Pablo Alpizar Monge
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_adminCancelaAP @inNumFinca INT
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON
        DECLARE @tmpRecibos udt_idTable

        INSERT INTO @tmpRecibos (storedID)
        SELECT R.id
        FROM [dbo].[Recibo] R
        INNER JOIN [dbo].[Propiedad] P ON P.NumFinca = @inNumFinca
        WHERE R.idPropiedad = P.id
            AND R.idTipoEstado = (
				SELECT T.id
				FROM [TipoEstadoRecibo] T
				WHERE T.estado = 'Pendiente'
				)
            AND R.idConceptoCobro = (SELECT C.id FROM [dbo].[ConceptoCobro] C WHERE C.nombre = 'Interes Moratorio')
	
        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		BEGIN TRANSACTION
            -- Actualizar el estado de los recibos creados de interes moratorio
			UPDATE [dbo].[Recibo]
            SET idTipoEstado = (
                SELECT T.id
				FROM [TipoEstadoRecibo] T
				WHERE T.estado = 'Anulado')
			FROM [dbo].[Recibo] R
			INNER JOIN [dbo].[Propiedad] P ON P.NumFinca = @inNumFinca
			WHERE R.idPropiedad = P.id
				AND R.idTipoEstado = (
					SELECT T.id
					FROM [TipoEstadoRecibo] T
					WHERE T.estado = 'Pendiente' 
					)
				AND R.idConceptoCobro = (SELECT C.id FROM [dbo].[ConceptoCobro] C WHERE C.nombre = 'Interes Moratorio')
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
