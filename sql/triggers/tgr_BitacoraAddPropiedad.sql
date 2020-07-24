/*
 * trigger: trgBitacoraAddProperty 
 * Description: 
 * Author: Pablo Alpizar
 */

USE municipalidad
GO

CREATE OR ALTER TRIGGER dbo.trgBitacoraAddPropiedad
ON [dbo].[Propiedad]
AFTER  INSERT
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @jsonDespues NVARCHAR(500)
    DECLARE @idEntidad INT

        set @idEntidad = (select p.id from inserted P)
        SET @jsonDespues = (SELECT 
                                P.NumFinca AS 'Numero Finca',
                                P.valor AS 'Valor',
                                P.Direccion AS 'Direccion',
                                'Activo' AS 'Estado',
                                P.ConsumoAcumuladoM3 AS 'Consumo Acumuluado M3',
                                P.UltimoConsumoM3 AS 'Consumo Acumulado M3 ultimo recibo'
                            FROM inserted P
                            FOR JSON PATH, ROOT('Propiedad'))

        INSERT INTO [dbo].[Bitacora] (
            idTipoEntidad,
            idEntidad,
            jsonAntes,
            jsonDespues,
            insertedAt,
            insertedBy,
            insertedIn
        ) 
        SELECT
            T.id,
            @idEntidad,
            null,
            @jsonDespues,
            GETDATE(),
            CONVERT(NVARCHAR(100), (SELECT @@SERVERNAME)),
	    	'SERVER IP'
        FROM [dbo].[TipoEntidad] T WHERE T.Nombre = 'Propiedad'

END