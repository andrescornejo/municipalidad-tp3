/*
 * trigger: trgBitacoraUpdateProperty 
 * Description: 
 * Author: Pablo Alpizar
 */



CREATE TRIGGER dbo.trgBitacoraUpdateProperty
ON dbo.Propiedad
AFTER  INSERT
AS
BEGIN
    SET NOCOUNT ON

    INSERT INTO dbo.Bitacora (

    )
    SELECT 
    
    FROM insert P

END