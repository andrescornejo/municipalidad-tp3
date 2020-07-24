/*
 * trigger: trgBitacoraAddProperty 
 * Description: 
 * Author: Pablo Alpizar
 */



CREATE TRIGGER dbo.trgBitacoraAddProperty
ON dbo.Propiedad
AFTER  INSERT
AS
BEGIN
    SET NOCOUNT ON

    INSERT INTO dbo.Bitacora (

    )
    SELECT 
    *
    FROM [dbo].[Propiedad] P

END