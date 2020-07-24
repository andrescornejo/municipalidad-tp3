/*
 * Stored Procedure: csp_getComprobantes
 * Description: 
 * Author: Andres Cornejo
 */

use municipalidad
go

create or alter proc csp_getComprobantes @inNumFinca INT
as
begin
	begin try
		set nocount on

		DECLARE @idRef INT
		DECLARE @tmpIdComprob TABLE (idComprobante INT)
		DECLARE @tmpComprobantes TABLE (
			idComprobante INT,
			fecha DATE,
			Monto MONEY
		)

		INSERT INTO @tmpIdComprob (idComprobante)
		SELECT DISTINCT R.idComprobantePago 
		FROM [dbo].[Recibo] R
		INNER JOIN [dbo].[Propiedad] P ON @inNumFinca = P.NumFinca
		WHERE R.idPropiedad = P.id AND R.activo = 1 AND R.esPendiente = 0


		WHILE (SELECT COUNT(*) FROM @tmpIdComprob) > 0
		BEGIN
			SET @idRef = (SELECT TOP 1 tmp.idComprobante FROM @tmpIdComprob tmp)
			DELETE @tmpIdComprob WHERE idComprobante = @idRef

			INSERT @tmpComprobantes (
				idComprobante,
				fecha,
				Monto
			)
			SELECT 
				@idRef,
				cmp.fecha,
				cmp.MontoTotal
			FROM [dbo].[ComprobanteDePago] cmp
			WHERE cmp.id = @idRef
		END

		SELECT 
			cmp.idComprobante AS [Numero Comprobante], 
			cmp.fecha AS [Fecha],
			cmp.Monto AS [Monto Total]
			FROM @tmpComprobantes cmp
			ORDER BY cmp.fecha ASC
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