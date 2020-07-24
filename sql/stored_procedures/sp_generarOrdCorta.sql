/*
 * Stored Procedure: csp_generarOrdCorta
 * Description: 
 * Author: Pablo Alpizar
 */

use municipalidad
go

create or alter proc csp_generarOrdCorta
as
begin
	begin try
		set nocount on
		
		DECLARE @tmpProp_CCAgua TABLE (idPropiedad INT)
		DECLARE @idPropiedad INT

		INSERT INTO @tmpPropiedadesCC_Agua (idPropiedad)
        SELECT CP.idPropiedad FROM [dbo].[CCenPropiedad] CP WHERE CP.idConceptoCobro = @idCCAgua

		WHILE (SELECT COUNT(*) FROM @tmpProp_CCAgua) > 0
		BEGIN
			-- tomar la primera propiedad
			SET @idPropiedad = (SELECT TOP 1 tmp.idPropiedad FROM @tmpProp_CCAgua)
			DELETE @tmpProp_CCAgua WHERE idPropiedad = @idPropiedad

		END
	end try
	begin catch
		IF @@TRANCOUNT > 0
			ROLLBACK

		DECLARE @errorMsg NVARCHAR(200) = (
				SELECT ERROR_MESSAGE()
				)

		PRINT ('ERROR:' + @errorMsg)

		RETURN - 1 * @@ERROR
	end catch
end

go