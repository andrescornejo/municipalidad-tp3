/*	Script para llenar la tabla de usuario con datos de prueba
	Autor: Andres Cornejo
*/
USE municipalidad
GO

--SET IDENTITY_INSERT Usuario ON
--Disabled cuz xml team...
DECLARE @hdoc INT;
DECLARE @UsuarioXML XML;

SELECT @UsuarioXML = U
FROM openrowset(BULK 'C:\xml\Usuarios.xml', single_blob) AS Usuario(U)

EXEC sp_xml_preparedocument @hdoc OUT,
	@UsuarioXML

SELECT @UsuarioXML
INSERT dbo.Usuario (
	username,
	passwd,
	isAdmin,
	activo
	)
SELECT 
	X.username,
	X.password,
	IsAdmin = 	(case when (X.tipo = 'admin') 
					then 1
					else 0
				end),

	1
FROM openxml(@hdoc, '/Usuarios/Usuario', 1) 
	WITH (
		username NVARCHAR(50),
		password NVARCHAR(MAX),
		tipo NVARCHAR(20)
	) X
SELECT *
FROM Usuario

EXEC sp_xml_removedocument @hdoc
GO


