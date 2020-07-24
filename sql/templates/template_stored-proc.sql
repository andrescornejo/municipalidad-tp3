/*
 * Stored Procedure: 
 * Description: 
 * Author: Andres Cornejo
 */

use municipalidad
go

create or alter proc spname /*@Input type*/ as
begin
	begin try
		set nocount on
	--sp code here

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
