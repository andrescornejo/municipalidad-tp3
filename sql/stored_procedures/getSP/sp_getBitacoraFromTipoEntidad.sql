/*
 * Stored Procedure: csp_getBitacoraFromTipoEntidad
 * Description: Gets a dataset with a log entry from an entity name.
 * Author: Andres Cornejo
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_getBitacoraFromTipoEntidad @inTipoEntidad NVARCHAR(50),
	@inFechaInicio DATE,
	@inFechaFin DATE
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON

		DECLARE @idTipoEnt INT

		SET @idTipoEnt = (
				SELECT T.id
				FROM dbo.TipoEntidad T
				WHERE t.Nombre = @inTipoEntidad
				)

		PRINT (@idTipoEnt)

		SELECT B.id AS [id],
			@inTipoEntidad AS [TE],
			B.insertedAt AS [inAt],
			B.insertedBy AS [inBy],
			B.insertedIn AS [inIN]
		FROM Bitacora B
		WHERE B.idTipoEntidad = @idTipoEnt
			AND B.insertedAt BETWEEN @inFechaInicio
				AND @inFechaFin
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

-- exec csp_getBitacoraFromTipoEntidad 'Propiedad', '2020-07-06', '2020-07-08'
