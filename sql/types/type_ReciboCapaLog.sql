/*
 * Type: ReciboCapaLogica
 * Description: Type used to recieve receipt data from the logical layer.
 * Author: Andres Cornejo
 */
USE municipalidad
GO

DROP type udt_Recibo
GO

CREATE TYPE [dbo].[udt_Recibo] AS TABLE (
	[id] [int],
	[numPropiedad] [int],
	[conceptoCobro] [varchar](50),
	[fecha] [date],
	[fechaVence] [date],
	[montoTotal] [money]
	)
GO


