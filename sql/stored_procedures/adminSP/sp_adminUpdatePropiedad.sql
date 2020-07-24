/*
 * Stored Procedure: csp_adminUpdatePropiedad
 * Description: Actualizacion a una Propiedad por un Admin.
 * Author: Andres Cornejo
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_adminUpdatePropiedad @inID INT,
	@inNumProp INT,
	@inValor MONEY,
	@inDir NVARCHAR(max),
	@inAcumM3 INT,
	@inUltM3 INT,
	@inUsername NVARCHAR(500),
	@inIP NVARCHAR(500)
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON

--Logging to table Bitacora is disabled because a trigger does it 
		-- DECLARE @jsonAntes NVARCHAR(500),
		-- 	@jsonDespues NVARCHAR(500)

		-- SET @jsonAntes = (
		-- 		SELECT p.NumFinca AS 'Número de propiedad',
		-- 			p.Valor AS 'Valor monetario',
		-- 			p.Direccion AS 'Dirección',
		-- 			p.ConsumoAcumuladoM3 AS 'Consumo acumulado m3',
		-- 			p.UltimoConsumoM3 AS 'Ultimo consumo m3',
		-- 			'Activo' AS 'Estado'
		-- 		FROM Propiedad p
		-- 		WHERE p.id = @inID
		-- 		FOR JSON PATH,
		-- 			ROOT('Propiedad')
		-- 		)
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

		BEGIN TRAN

		UPDATE Propiedad
		SET NumFinca = @inNumProp,
			Valor = @inValor,
			Direccion = @inDir,
			ConsumoAcumuladoM3 = @inAcumM3,
			UltimoConsumoM3 = @inUltM3
		WHERE id = @inID
			AND activo = 1

		-- SET @jsonDespues = (
		-- 		SELECT p.NumFinca AS 'Número de propiedad',
		-- 			p.Valor AS 'Valor monetario',
		-- 			p.Direccion AS 'Dirección',
		-- 			p.ConsumoAcumuladoM3 AS 'Consumo acumulado m3',
		-- 			p.UltimoConsumoM3 AS 'Ultimo consumo m3',
		-- 			'Activo' AS 'Estado'
		-- 		FROM Propiedad p
		-- 		WHERE p.id = @inID
		-- 		FOR JSON PATH,
		-- 			ROOT('Propiedad')
		-- 		)

		-- INSERT Bitacora (
		-- 	idTipoEntidad,
		-- 	idEntidad,
		-- 	jsonAntes,
		-- 	jsonDespues,
		-- 	insertedAt,
		-- 	insertedBy,
		-- 	insertedIn
		-- 	)
		-- SELECT te.id,
		-- 	@inID,
		-- 	@jsonAntes,
		-- 	@jsonDespues,
		-- 	GETDATE(),
		-- 	@inUsername,
		-- 	@inIP
		-- FROM TipoEntidad te
		-- WHERE te.Nombre = 'Propiedad'

		COMMIT

		RETURN 1
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


