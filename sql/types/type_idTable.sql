/*
 * Type: idTable
 * Description: Type that serves as a table for db IDs
 * Author: Andres Cornejo
 */
USE municipalidad
GO

DROP type udt_idTable
GO

CREATE TYPE [dbo].[udt_idTable] AS TABLE (
	[storedID] [int]
	)
GO