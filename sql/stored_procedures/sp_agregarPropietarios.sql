/*
 * Stored Procedure: csp_agregarPropietarios
 * Description: 
 * Author: Andres Cornejo
 * Modified by: Pablo Alpizar
 */
USE municipalidad
GO

CREATE or alter PROC csp_agregarPropietarios @fechaInput DATE, @OperacionXML XML
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON
		DECLARE @jsonDespues NVARCHAR(500)
		DECLARE @valorDocID NVARCHAR(100)
		DECLARE @idEntidad INT

		DECLARE @hdoc INT

		EXEC sp_xml_preparedocument @hdoc OUT,
			@OperacionXML

		DECLARE @tmpPropiet TABLE (
			idTipoDocID INT,
			nombre NVARCHAR(50),
			valorDocID NVARCHAR(100),
			fechaxml DATE
			)

		INSERT @tmpPropiet (
			nombre,
			idTipoDocID,
			valorDocID,
			fechaxml
			)
		SELECT Nombre,
			TipoDocIdentidad,
			identificacion,
			fecha
		FROM openxml(@hdoc, '/Operaciones_por_Dia/OperacionDia/Propietario', 1) WITH (
				Nombre NVARCHAR(50),
				TipoDocIdentidad INT,
				identificacion NVARCHAR(100),
				fecha DATE '../@fecha'
				)
		WHERE @fechaInput = fecha

		EXEC sp_xml_removedocument @hdoc;

		--SELECT COUNT(*) FROM @tmpPropiet
		-- Proceso masivo
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		BEGIN TRANSACTION

		INSERT dbo.Propietario (
			nombre,
			idTipoDocID,
			valorDocID,
			activo
			)
		SELECT tp.nombre,
			tp.idTipoDocID,
			tp.valorDocID,
			1
		FROM @tmpPropiet tp
		
		-- insert into bitacora

		WHILE (SELECT COUNT(*) FROM @tmpPropiet) > 0
		BEGIN
			SET @valorDocID = (SELECT TOP 1 tmp.valorDocID FROM @tmpPropiet tmp)
			SET @idEntidad = (SELECT P.id FROM [dbo].[Propietario] P WHERE P.valorDocID = @valorDocID)
			DELETE @tmpPropiet WHERE valorDocID = @valorDocID

			SET @jsonDespues = (SELECT 
								P.id AS 'ID', 
								P.nombre AS 'Nombre', 
								T.nombre AS 'Tipo DocID' , 
								@valorDocID AS 'Valor ID', 
								'Activo' AS 'Estado'
							FROM [dbo].[Propietario] P
							JOIN [dbo].[TipoDocID] T ON T.id = P.idTipoDocID
							WHERE P.valorDocID = @valorDocID
							FOR JSON PATH,ROOT('Propietario'))

			INSERT INTO [dbo].[Bitacora] (
				idTipoEntidad,
				idEntidad, 
				jsonDespues,
				insertedAt,
				insertedBy,
				insertedIn
			) SELECT
				T.id,
				@idEntidad,
				@jsonDespues,
				GETDATE(),
				CONVERT(NVARCHAR(100), (SELECT @@SERVERNAME)),
				'192.168.1.7'
			FROM [dbo].[TipoEntidad] T
			WHERE T.Nombre = 'Propietario'

		END
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


