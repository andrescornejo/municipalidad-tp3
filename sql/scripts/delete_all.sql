--Script to reset contents of a database
--Inspired by: https://stackoverflow.com/questions/3687575/delete-all-data-in-sql-server-database

use municipalidad
go

-- disable referential integrity
EXEC sp_MSForEachTable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL' 
GO 

EXEC sp_MSForEachTable 'DELETE FROM ?' 
GO 

 EXEC sp_MSForEachTable 'DBCC CHECKIDENT(''?'', RESEED, 0)'
 GO

-- enable referential integrity again 
EXEC sp_MSForEachTable 'ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL' 
GO