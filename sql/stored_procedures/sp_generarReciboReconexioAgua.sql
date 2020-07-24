/*
 * Stored Procedure: 
 * Description: 
 * Author: Pablo Alpizar
 */

use municipalidad
go

create or alter proc csp_generarReciboReconexiónAgua @inFecha DATE 
as
begin
	begin try
		set nocount on
		

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