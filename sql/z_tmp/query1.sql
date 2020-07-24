use municipalidad
go 

declare @fechaInput DATE
set @fechaInput = '2020-02-19'

DECLARE @OperacionXML XML

		SELECT @OperacionXML = O
		FROM openrowset(BULK 'C:\xml\Operaciones.xml', single_blob) AS Operacion(O)

		DECLARE @hdoc INT

		EXEC sp_xml_preparedocument @hdoc OUT,
			@OperacionXML

		DECLARE @tmpUSvsProp TABLE (
			NumFinca INT,
			nombreUsuario nvarchar(50),
			fechaxml DATE
			)

		INSERT @tmpUSvsProp (
			NumFinca,
			nombreUsuario,
			fechaxml
			)
		SELECT NumFinca,
			nombreUsuario,
			fecha
		FROM openxml(@hdoc, '/Operaciones_por_Dia/OperacionDia/UsuarioVersusPropiedad', 1) WITH (
				NumFinca INT,
				nombreUsuario nvarchar(50),
				fecha DATE '../@fecha'
				)
		WHERE @fechaInput = fecha

		--select * from @tmpUSvsProp
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

		BEGIN TRANSACTION
		insert UsuarioVsPropiedad(idUsuario, idPropiedad)
		select U.id, P.id
		from @tmpUSvsProp tmp
		join Usuario U on U.username = tmp.nombreUsuario
		join Propiedad P on P.NumFinca = tmp.NumFinca 
commit 
return 1
		--select * from UsuarioVsPropiedad

        -- INSERT dbo.CCenPropiedad(idConceptoCobro, idPropiedad, fechaInicio)
		-- SELECT cp.idcobro, P.id, @fechaInput
		-- FROM @tmpUsuario AS cp
		-- JOIN Propiedad P ON P.NumFinca = cp.NumFinca
        
        -- --select * from CCenPropiedad