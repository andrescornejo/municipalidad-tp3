--code to delete the database
USE [master];

DECLARE @kill VARCHAR(8000) = '';

SELECT @kill = @kill + 'kill ' + CONVERT(VARCHAR(5), session_id) + ';'
FROM sys.dm_exec_sessions
WHERE database_id = db_id('municipalidad')

EXEC (@kill);
GO

DROP DATABASE municipalidad;
GO