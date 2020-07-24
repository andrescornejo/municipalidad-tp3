/*
 * Stored Procedure: 
 * Description: 
 * Author: Pablo Alpizar
 */

use municipalidad
go

create or alter proc csp_generarReciboCCPorcentaje @inFecha DATE,
@inIdCC INT 
as
begin
	begin try
		set nocount on
		DECLARE @DiaCobro INT = (SELECT C.DiaEmisionRecibo 
                            FROM [dbo].[ConceptoCobro] C 
                            WHERE C.id = @inIdCC)

        IF @DiaCobro != (SELECT EXTRACT (DAY FROM @inFecha))
        BEGIN
            RETURN
        END

		DECLARE @tmpPropiedadesTipoCC TABLE(
            idPropiedad INT
        )

		DECLARE @tmpRecibos TABLE (
			
		)

		INSERT INTO @tmpPropiedadesTipoCC (idPropiedad)
		SELECT CP.idPropiedad FROM [dbo].[CCenPropiedad] CP 
		WHERE CP.idConceptoCobro = @inIdCC

		INSERT INTO [dbo].[Recibo] (

		)


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