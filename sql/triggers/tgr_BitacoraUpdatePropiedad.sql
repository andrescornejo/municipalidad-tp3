/*
 * trigger: trgBitacoraUpdateProperty 
 * Description: 
 * Author: Pablo Alpizar
 */

USE municipalidad
GO

CREATE OR ALTER TRIGGER dbo.trgBitacoraUpdatePropiedad
ON dbo.Propiedad
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @jsonDespues NVARCHAR(500)
    DECLARE @idEntidad INT
    DECLARE @jsonAntes NVARCHAR(500)
    DECLARE @Estado NVARCHAR(15)

    set @idEntidad = (select P.id from inserted P)

    SET @Estado = (SELECT CASE WHEN (SELECT D.activo FROM deleted D) = 1
                    THEN 'Activo'
                    ELSE 'Inactivo'
                    END)
 
    SET @jsonAntes = (SELECT TOP 1
            D.NumFinca AS 'Número de propiedad',
            D.valor AS 'Valor monetario',
            D.Direccion AS 'Dirección',
            @Estado AS 'Estado',
            D.ConsumoAcumuladoM3 AS 'Consumo Acumuluado m3',
            D.UltimoConsumoM3 AS 'Último consumo m3'
        FROM DELETED D
        FOR JSON PATH, ROOT('Propiedad'))

    SET @Estado = (SELECT CASE WHEN (SELECT P.activo FROM INSERTED P) = 1
                    THEN 'Activo'
                    ELSE 'Inactivo'
                    END)

    SET @jsonDespues = (SELECT 
            P.NumFinca AS 'Número de propiedad',
            P.valor AS 'Valor monetario',
            P.Direccion AS 'Dirección',
            @Estado AS 'Estado',
            P.ConsumoAcumuladoM3 AS 'Consumo Acumuluado m3',
            P.UltimoConsumoM3 AS 'Último consumo m3'
        FROM INSERTED P
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
        @jsonAntes,
        @jsonDespues,
        GETDATE(),
        CONVERT(NVARCHAR(100), (SELECT @@SERVERNAME)),
		'SERVER IP'
    FROM [dbo].[TipoEntidad] T WHERE T.Nombre = 'Propiedad'

END