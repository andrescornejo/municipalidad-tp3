/*
 * Stored Procedure: csp_getUsuarioFromNumFinca
 * Description: 
 * Author: Andres Cornejo
 */

use municipalidad
go

create or alter proc csp_getUsuarioFromNumFinca @inputNumFinca int as
begin
	begin try
		set nocount on
	DECLARE @idPropiedad INT

		EXEC @idPropiedad = csp_getPropiedadIDFromNumFinca @inputNumFinca

		PRINT (@idPropiedad)

		SELECT u.username as 'Nombre de usuario', u.isAdmin 'Estado Administrador'
		FROM Usuario u
		JOIN UsuarioVsPropiedad uvp ON uvp.idUsuario = u.id
		AND uvp.activo = 1
		WHERE @idPropiedad = uvp.idPropiedad
		AND u.activo = 1

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
