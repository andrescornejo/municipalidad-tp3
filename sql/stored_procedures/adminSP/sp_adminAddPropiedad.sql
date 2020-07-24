/*
 * Stored Procedure: csp_adminAddPropiedades
 * Description: 
 * Author: Andres Cornejo
 * Modified by: Pablo Alpizar
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_adminAddPropiedades @inputNumFinca INT,
	@inputValorFinca MONEY,
	@inputDir NVARCHAR(max),
	@inputInsertedBy NVARCHAR(100),
	@inputInsertedIn NVARCHAR(20)
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

		DECLARE @jsonDespues NVARCHAR(500)

		SET @jsonDespues = (
				SELECT @inputNumFinca AS 'Número de propiedad',
					@inputValorFinca AS 'Valor monetario',
					@inputDir AS 'Dirección',
					0 AS 'Consumo acumulado m3',
					0 AS 'Ultimo consumo m3',
					'Activo' AS 'Estado'
				FOR JSON PATH,
					ROOT('Propiedad')
				)

		BEGIN TRANSACTION

		INSERT Propiedad (
			NumFinca,
			Valor,
			Direccion,
			activo,
			ConsumoAcumuladoM3,
			UltimoConsumoM3
			)
		SELECT @inputNumFinca,
			@inputValorFinca,
			@inputDir,
			1,
			0,
			0

		INSERT Bitacora (
			idTipoEntidad,
			idEntidad,
			jsonAntes,
			jsonDespues,
			insertedAt,
			insertedBy,
			insertedIn
			)
		SELECT t.id,
			(
				SELECT SCOPE_IDENTITY()
				),
			NULL,
			@jsonDespues,
			GETDATE(),
			@inputInsertedBy,
			@inputInsertedIn
		FROM dbo.TipoEntidad T
		WHERE T.Nombre = 'Propiedad'

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

--EXEC csp_adminAddPropiedades 420, 420, 'tencha'
