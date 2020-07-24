USE municipalidad
GO

CREATE
	OR

ALTER PROCEDURE spLogin @usernameInput NVARCHAR(100),
	@passwordInput NVARCHAR(100)
AS
BEGIN
	DECLARE @isAdmin INT = (
			SELECT U.isAdmin
			FROM Usuario U
			WHERE @usernameInput = U.username
				AND @passwordInput = U.passwd
				AND U.activo = 1
			);

	IF @isAdmin = 1
		RETURN @isAdmin
	ELSE IF @isAdmin = 0
		RETURN 0;
	ELSE
		RETURN - 1
END
GO

-- DECLARE @isAdmin INT;
-- EXEC @isAdmin = spLogin 'Jquiros', '123hola'
-- print(@isAdmin)
