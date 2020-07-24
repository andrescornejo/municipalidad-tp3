/*
 * Stored Procedure: csp_agregarPersonaJuridica
 * Description: sp que agrega las personas juridicas por medio de joins
 * Author: Andres Cornejo
 */
USE municipalidad
GO

IF EXISTS (
		SELECT *
		FROM sysobjects
		WHERE id = object_id(N'[dbo].[csp_agregarPersonaJuridica]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
BEGIN
	DROP PROCEDURE dbo.csp_agregarPersonaJuridica
END
GO

CREATE PROC csp_agregarPersonaJuridica @fechaInput DATE
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON

		DECLARE @OperacionXML XML

		SELECT @OperacionXML = O
		FROM openrowset(BULK 'C:\xml\Operaciones.xml', single_blob) AS Operacion(O)

		DECLARE @hdoc INT

		EXEC sp_xml_preparedocument @hdoc OUT,
			@OperacionXML

		DECLARE @tmpPersonaJuridica TABLE (
			docidPersonaJuridica NVARCHAR(100),
			TipDocIdPJ INT,
			DocidRepresentante NVARCHAR(100),
			Nombre NVARCHAR(50),
			TipDocIdRepresentante INT,
			fechaxml DATE
			)

		INSERT @tmpPersonaJuridica (
			docidPersonaJuridica,
			TipDocIdPJ,
			DocidRepresentante,
			Nombre,
			TipDocIdRepresentante,
			fechaxml
			)
		SELECT docidPersonaJuridica,
			TipDocIdPJ,
			DocidRepresentante,
			Nombre,
			TipDocIdRepresentante,
			fecha
		FROM openxml(@hdoc, '/Operaciones_por_Dia/OperacionDia/PersonaJuridica', 1) WITH (
				docidPersonaJuridica NVARCHAR(100),
				TipDocIdPJ INT,
				DocidRepresentante NVARCHAR(100),
				Nombre NVARCHAR(50),
				TipDocIdRepresentante INT,
				fecha DATE '../@fecha'
				)
		WHERE @fechaInput = fecha

		EXEC sp_xml_removedocument @hdoc;

		--select * from @tmpPersonaJuridica
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

		BEGIN TRANSACTION

		INSERT INTO dbo.PropietarioJuridico (
			id,
			idTipoDocID,
			representante,
			RepDocID,
			TipoDocIdRepresentante,
			activo
			)
		SELECT P.id,
			tpj.TipDocIdPJ,
			tpj.Nombre,
			tpj.DocidRepresentante,
			tpj.TipDocIdRepresentante,
			1
		FROM @tmpPersonaJuridica AS tpj
		JOIN Propietario P ON P.valorDocID = tpj.docidPersonaJuridica

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


