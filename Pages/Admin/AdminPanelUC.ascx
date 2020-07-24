<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="AdminPanelUC.ascx.cs" Inherits="Muni.Pages.Admin.AdminPanelUC" %>

<link href="../../Content/bootstrap.css" rel="stylesheet" />
<link href="../../Content/dashboard.css" rel="stylesheet" />



<%-- Enable js scripts from codebehind, and partial reloading to prevent gridview postback --%>
<asp:ScriptManager ID="ScriptManager1" runat="server" EnablePartialRendering="true"></asp:ScriptManager>

<div class="pos-f-t">
    <div class="collapse" id="navbarToggleExternalContent">
        <div class="bg-dark p-4">
            <asp:Label ID="lblUsername" CssClass="h3 text-white unselectable" runat="server" Text=""></asp:Label>
            <hr class="my-2">

            <ul class="nav navbar-nav">
                <li>
                    <a class="btn btn-dark btn-lg dropdown-toggle" href="#" role="button" id="dropdownMenuLink" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                    Gestión de entidades
                    </a>

                    <div class="dropdown-menu" aria-labelledby="dropdownMenuLink">
                        <a class="dropdown-item" href="#">Propietarios</a>
                        <a class="dropdown-item" href="crudPropiedades.aspx">Propiedades</a>
                        <a class="dropdown-item" href="crudUsuario.aspx">Usuarios</a>
                    </div>
                </li>
                <li class="my-1"><a href="#" class="btn btn-dark btn-lg">Propiedades de un propietario</a></li>
                <li class="my-1"><a href="#" class="btn btn-dark btn-lg">Propietarios de una propiedad</a></li>
                <li class="my-1"><a href="#" class="btn btn-dark btn-lg">Propiedades de un usuario</a></li>
                <li class="my-1"><a href="#" class="btn btn-dark btn-lg">Usuario de una propiedad</a></li>
                <li class="my-1"><a href="consultaCambioEntidad.aspx" class="btn btn-dark btn-lg">Cambios a entidades</a></li>
            </ul>
        </div> 
    </div>
  <nav class="navbar navbar-dark bg-dark">
    <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarToggleExternalContent" aria-controls="navbarToggleExternalContent" aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>
    <a class="navbar-brand unselectable" href="AdminPage.aspx">Panel de administrador</a>
    <ul class="navbar-nav px-3">
        <li class="nav-item text-nowrap">
            <asp:Button ID="logoutBtn" runat="server" Text="Cerrar sesión" OnClick="logoutBtn_Click" CssClass="btn btn-outline-danger my-2 my-sm-0" type="submit"/>
        </li>
    </ul>
  </nav>
</div>
<div class="container">
    <div id="alertDiv" class="alert alert-success mt-3 hidden" role="alert" runat="server">
        <asp:Label ID="lblAlert" runat="server" Text=""></asp:Label>
    </div>
    <div id="successDiv" class="alert alert-danger mt-3 hidden" role="alert" runat="server">
        <asp:Label ID="lblSucc" runat="server" Text=""></asp:Label>
    </div>
</div>

<div class="py-3"></div>

<script src="../../Scripts/jquery-3.5.1.min.js"></script>
<script src="../../Scripts/umd/popper.min.js"></script>
<script src="../../Scripts/bootstrap.min.js"></script>