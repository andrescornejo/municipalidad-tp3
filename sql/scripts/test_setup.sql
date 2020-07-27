use municipalidad
go 

set nocount on

insert Usuario(username, passwd, isAdmin, activo)
values ('a', '1', 1, 1),
('b', '1', 0, 1),
('test', 'lol', 1, 1)

INSERT Propiedad(NumFinca, Valor, Direccion, activo, ConsumoAcumuladoM3, UltimoConsumoM3)
values (1234, 1234, 'techa', 1, 2, 2),
(431, 12643, 'techa', 1, 2, 2),
(1111111, 123, 'techa', 1, 2, 2)

insert UsuarioVsPropiedad(idUsuario, idPropiedad, activo)
values (2, 1, 1),
(2, 2, 1),
(2, 3, 1)

insert ComprobanteDePago(fecha, MontoTotal, activo)
values ('2019-8-8', 50000, 1),
('2019-9-8', 50000, 1),
('2019-10-8', 50000, 1),
('2019-11-8', 50000, 1),
('2019-12-8', 50000, 1),
('2020-1-8', 50000, 1),
('2020-2-8', 50000, 1),
('2020-3-8', 50000, 1),
('2020-4-8', 50000, 1),
('2020-5-8', 50000, 1),
('2020-6-8', 50000, 1),
('2020-7-8', 50000, 1)

insert Recibo(idComprobantePago, idPropiedad, idConceptoCobro, fecha, fechaVencimiento, monto, esPendiente, activo)
values (1, 1, 1, '2019-8-8', '2019-8-17', 50000, 0, 1),
(2, 1, 1, '2019-9-8', '2019-9-17', 50000, 0, 1),
(3, 1, 1, '2019-10-10', '2019-10-17', 50000, 0, 1),
(4, 1, 1, '2019-11-8', '2019-11-17', 50000, 0, 1),
(5, 1, 1, '2019-12-8', '2019-12-17', 50000, 0, 1),
(6, 1, 1, '2020-1-10', '2020-1-17', 50000, 0, 1),
(7, 1, 1, '2020-2-8', '2020-2-17', 50000, 0, 1),
(8, 1, 1, '2020-3-8', '2020-3-17', 50000, 0, 1), 
(9, 1, 1, '2020-4-10', '2020-4-17', 50000, 0, 1),
(10, 1, 1, '2020-5-8', '2020-5-17', 50000, 0, 1),
(11, 1, 1, '2020-6-8', '2020-6-17', 50000, 0, 1),
(12, 1, 1, '2020-7-10', '2020-7-17', 50000, 1, 1),
(null, 1, 1, '2020-7-12', '2020-7-19', 50000, 1, 1),
(null, 1, 1, '2020-7-14', '2020-7-19', 50000, 1, 1),
(null, 1, 1, '2020-7-16', '2020-7-19', 50000, 1, 1),
(null, 1, 1, '2020-7-18', '2020-7-20', 50000, 1, 1),
(null, 1, 1, '2020-7-20', '2020-7-22', 50000, 1, 1)

insert Bitacora(idTipoEntidad, idEntidad, jsonAntes, jsonDespues, insertedAt, insertedBy, insertedIn)
values 
(1, 2, '{"Propietario":[{"ID":1,"Nombre":"Ferrer S.A.","Tipo DocID":"Cedula Juridica","Valor ID":"301659662","Estado":"Activo"}]}', '{"Propietario":[{"ID":1,"Nombre":"LMAOOOOOOOOOOO","Tipo DocID":"Cedula Juridica","Valor ID":"301659662","Estado":"Activo"}]}', '2020-07-07', 'LePerv', 'LePerv'),
(1, 2, '{"Propietario":[{"ID":1,"Nombre":"Ferrer S.A.","Tipo DocID":"Cedula Juridica","Valor ID":"301659662","Estado":"Activo"}]}', '{"Propietario":[{"ID":1,"Nombre":"Ferrer S.A.","Tipo DocID":"Cedula Juridica","Valor ID":"301659662","Estado":"Activo"}]}', '2020-07-07', 'LePerv', 'LePerv'),
(1, 3, null, '{"Propietario":[{"ID":1,"Nombre":"Ferrer S.A.","Tipo DocID":"Cedula Juridica","Valor ID":"301659662","Estado":"Activo"}]}', '2020-07-08', 'LePerv', 'LePerv'),
(1, 3, null, '{"Propietario":[{"ID":1,"Nombre":"Ferrer S.A.","Tipo DocID":"Cedula Juridica","Valor ID":"301659662","Estado":"Activo"}]}', '2020-07-09', 'LePerv', 'LePerv'),
(1, 2, '{"Propietario":[{"ID":1,"Nombre":"Ferrer S.A.","Tipo DocID":"Cedula Juridica","Valor ID":"301659662","Estado":"Activo"}]}', '{"Propietario":[{"ID":1,"Nombre":"Ferrer S.A.","Tipo DocID":"Cedula Juridica","Valor ID":"301659662","Estado":"Activo"}]}', '2020-07-10', 'LePerv', 'LePerv')

insert Propietario(idTipoDocID, nombre, valorDocID, activo)
values
(1, 'Rat Bastard', '1029384234', 1),
(1, 'wee wee breath', '112341234', 1),
(3, 'wee wee breff', '17547', 1)

