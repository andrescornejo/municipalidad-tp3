/*
 * Stored Procedure: csp_generarReciboCCFijo
 * Description: 
 * Author: Pablo Alpizar
 */

use municipalidad
go

create or alter proc csp_generarReciboCCFijo @inFecha DATE, 
@inIdCC INT
as
begin
	begin try
		set nocount on        
		DECLARE @DiaCobro INT = (SELECT C.DiaEmisionRecibo 
                            FROM [dbo].[ConceptoCobro] C 
                            WHERE C.id = @inIdCC)

        IF @DiaCobro != (SELECT DAY (@inFecha))
        BEGIN
            RETURN
        END

		DECLARE @tmpPropiedadesTipoCC TABLE(
            idPropiedad INT
        )
	
		INSERT INTO @tmpPropiedadesTipoCC (idPropiedad)
        SELECT CP.idPropiedad FROM [dbo].[CCenPropiedad] CP 
		WHERE CP.idConceptoCobro = @inIdCC

        INSERT INTO [dbo].[Recibo](
            idPropiedad,
            idConceptoCobro, 
            fecha, 
            fechaVencimiento, 
            monto,
            esPendiente,
            Activo
        )
		SELECT
			tmp.idPropiedad,
			@inIdCC,
			@inFecha,
			DATEADD(DAY,CC.QDiasVencimiento, @inFecha),
			CF.Monto,
			1,
			1
		FROM @tmpPropiedadesTipoCC tmp
		INNER JOIN [dbo].[ConceptoCobro] CC ON @inIdCC = CC.id
		INNER JOIN [dbo].[CC_Fijo] CF ON @inIdCC = CF.id
		
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