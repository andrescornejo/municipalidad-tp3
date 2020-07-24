/*
 * Stored Procedure: csp_linkPropiedadDelPropietario
 * Description: Links PropiedadDelPropietario table with Propiedad and Propietario
 * Author: Andres Cornejo
 */
USE municipalidad
GO

CREATE
	OR

ALTER PROC csp_linkPropiedadDelPropietario @fechaInput DATE
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON

		DECLARE @OperacionXML XML
		DECLARE @jsonDespues NVARCHAR(500)
		DECLARE @FincaRef INT
		DECLARE @PropRef INT
		DECLARE @idEntidad INT

		SELECT @OperacionXML = O
		FROM openrowset(BULK 'C:\xml\Operaciones.xml', single_blob) AS Operacion(O)

		DECLARE @hdoc INT

		EXEC sp_xml_preparedocument @hdoc OUT,
			@OperacionXML

		DECLARE @tmpProtxProp TABLE (
			NumFinca INT,
			identificacion NVARCHAR(100),
			fechaxml DATE
			)

		INSERT @tmpProtxProp (
			NumFinca,
			identificacion,
			fechaxml
			)
		SELECT NumFinca,
			identificacion,
			fecha
		FROM openxml(@hdoc, '/Operaciones_por_Dia/OperacionDia/PropiedadVersusPropietario', 1) WITH (
				NumFinca INT,
				identificacion NVARCHAR(100),
				fecha DATE '../@fecha'
				)
		WHERE @fechaInput = fecha

		--select * from @tmpProtxProp
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		BEGIN TRANSACTION

		INSERT dbo.PropiedadDelPropietario (
			idPropiedad,
			idPropietario,
			activo
			)
		SELECT PO.id,
			P.id,
			1
		FROM @tmpProtxProp AS pp
		JOIN Propietario P ON P.valorDocID = pp.identificacion
		JOIN Propiedad PO ON PO.NumFinca = pp.NumFinca
		
		--select * from PropiedadDelPropietario

		WHILE (SELECT COUNT(*) FROM @tmpProtxProp) > 0
		BEGIN
			SET @FincaRef = (SELECT TOP 1 tmp.NumFinca FROM @tmpProtxProp tmp)
			SET @PropRef = (SELECT TOP 1 tmp.identificacion FROM @tmpProtxProp tmp)
			DELETE @tmpProtxProp WHERE NumFinca = @FincaRef AND identificacion = @PropRef 

			SET @idEntidad = (SELECT pp.id FROM [dbo].[PropiedadDelPropietario] pp
							INNER JOIN Propietario P ON P.valorDocID = @PropRef
							INNER JOIN Propiedad PO ON PO.NumFinca = @FincaRef
							WHERE P.id = pp.idPropietario AND PO.id = idPropiedad)

			SET @jsonDespues = (SELECT 
								@FincaRef AS 'Numero Finca',
								P.nombre AS 'Propietario',
								@PropRef AS 'Identificacion',
								'activo' AS 'Estado'
								FROM [dbo].[Propietario] P
								WHERE P.valorDocID = @PropRef
								FOR JSON PATH, ROOT('Propiedad-Propietario'))

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
			WHERE T.Nombre = 'PropiedadVsPropietario'
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


