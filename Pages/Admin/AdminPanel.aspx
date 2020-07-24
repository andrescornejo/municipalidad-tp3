<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminPanel.aspx.cs" Inherits="Muni.Pages.Admin.AdminPanel" %>

<%@ Register Src="~/Pages/Admin/AdminPanelUC.ascx" TagPrefix="uc1" TagName="AdminPanelUC" %>


<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="adminPanelForm" runat="server">
        <uc1:AdminPanelUC runat="server" ID="AdminPanelUC" />
    </form>

    <div class="container">
        <div class="card-deck my-2">
            <div class="card text-center" style="width: 18rem;">
                <div class="card-body">
                    <h3 class="card-title">Gestión y manipulación de entidades.</h3>
                    <p class="card-text">Crear, actualizar y borrar entidades.</p>
                    <div class="btn-group"> 
                        <a href="crudPropiedades.aspx" class="btn btn-primary ">Propiedades</a>
                        <a href="crudPropietarios.aspx" class="btn btn-primary ">Propietarios</a>
                        <a href="crudUsuario.aspx" class="btn btn-primary ">Usuarios</a>
                    </div>

                </div>
            </div>

            <div class="card text-center" style="width: 18rem;">
                <div class="card-body">
                    <h3 class="card-title">Propiedades de un propietario</h3>
                    <p class="card-text">Ver las propiedades que le pertenecen a un propietario.</p>
                    <a href="verPropiedadesDePropietario.aspx" class="btn btn-primary">Ver</a>
                </div>
            </div>

            <div class="card text-center" style="width: 18rem;">
                <div class="card-body">
                    <h3 class="card-title">Propietarios de una propiedad</h3>
                    <p class="card-text">Ver los distintos propietarios de una propiedad.</p>
                    <a href="verPropietarioDePropiedad.aspx" class="btn btn-primary">Ver</a>
                </div>
            </div>
        </div>


        <div class="card-deck my-5">

            <div class="card text-center" style="width: 18rem;">
                <div class="card-body">
                    <h3 class="card-title">Propiedades de un usuario</h3>
                    <p class="card-text">Ver las propiedades que le pertenecen a un usuario.</p>
                    <a href="verPropiedadesDeUsuario.aspx" class="btn btn-primary">Ver</a>
                </div>
            </div>

            <div class="card text-center" style="width: 18rem;">
                <div class="card-body">
                    <h3 class="card-title">Usuario de una propiedad</h3>
                    <p class="card-text">Ver el usuario al que le pertenece una propiedad.</p>
                    <a href="verUsuarioDePropiedad.aspx" class="btn btn-primary">Ver</a>
                </div>
            </div>

            <div class="card text-center" style="width: 18rem;">
                <div class="card-body">
                    <h3 class="card-title">Cambios realizados a entidades</h3>
                    <p class="card-text">Ver los cambios que se le han realizado a las entidades en el pasado.</p>
                    <a href="consultaCambioEntidad.aspx" class="btn btn-primary">Ver</a>
                </div>
            </div>

        </div>
    </div>





</body>
</html>
