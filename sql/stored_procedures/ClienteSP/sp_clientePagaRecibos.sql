/*
 * Stored Procedure: csp_clientePagaRecibos
 * Description: Stored procedure that handes the table a client sends when he/she pays bills. 
 * Author: Andres Cornejo
 */

use municipalidad
go

create or alter proc csp_clientePagaRecibos @inTablaRecibos udt_Recibo readonly as
begin
	begin try
		set nocount on

        declare @idTable table(ID int)

        Declare @ID int

        insert @idTable
        select i.id
        from @inTablaRecibos i
        /*Cree una tabla temporal para poder iterar, ya que no puedo
        * borrar de @inTablaRecibos, porque SQL me está forzando a 
        * declara @inTablaRecibos como readonly.
        */
        WHILE EXISTS(SELECT * FROM @idTable)
        BEGIN
        Select Top 1 @ID = ID From @idTable

        update Recibo
        set monto = 666,
        esPendiente = 0
        where Recibo.id = @ID

        delete @idTable
        where ID=@ID 

        end

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
