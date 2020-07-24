<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminPage.aspx.cs" Inherits="Muni.Pages.AdminPage" %>

<%@ Register Src="~/Pages/Admin/AdminPanelUC.ascx" TagPrefix="uc1" TagName="AdminPanelUC" %>


<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">

<head runat="server">
    <title>WELCOME [PLACEHOLDER FOR USERNAME XD]</title>
</head>
<body style="background-color:#2c3d63">
    <form id="AdminPage" runat="server">
        <uc1:AdminPanelUC runat="server" ID="AdminPanelUC" />
        <div style="text-align:center">
            <asp:Label ID="welcomeLbl" runat="server" Font-Names="Bahnschrift" Font-Size="70px" ForeColor="White" Text="Panel de administrador"></asp:Label>
            <br />
            <asp:Label ID="userLbl" runat="server" Font-Names="Bahnschrift" Font-Size="70px" ForeColor="White" Text="[Placeholder for username XD]"></asp:Label>       
        </div>
        <div style="text-align:center;margin-top:20px">
        </div>
        <div style="text-align:center">
            <asp:Button ID="crudTablesBtn" runat="server" Text="Edición de entidades" Width="700px" BorderWidth="0px" Font-Bold="True" Font-Names="Bahnschrift" Font-Size="40px" ForeColor="White" style="margin-top:30px ;background-color:#ff6f5e" OnClick="crudBtn_Click"/>
            <br />
            <asp:Button ID="verPropiedadesDePropietarioBtn" runat="server" Text="Ver propiedades de un propietario" Width="700px" BorderWidth="0px" Font-Bold="True" Font-Names="Bahnschrift" Font-Size="40px" ForeColor="White" style="margin-top:30px ;background-color:#ff6f5e" OnClick="verPropiedadesDePropietarioBtn_Click"/>
            <br />
            <asp:Button ID="verPropietarioDePropiedadBtn" runat="server" Text="Ver propietarios de una propiedad" Width="700px" BorderWidth="0px" Font-Bold="True" Font-Names="Bahnschrift" Font-Size="40px" ForeColor="White" style="margin-top:30px ;background-color:#ff6f5e" OnClick="verPropietarioDePropiedadBtn_Click"/>
            <br />
            <asp:Button ID="verPropiedadesDeUsuario" runat="server" Text="Propiedades que puede ver un usuario" Width="700px" BorderWidth="0px" Font-Bold="True" Font-Names="Bahnschrift" Font-Size="40px" ForeColor="White" style="margin-top:30px ;background-color:#ff6f5e" OnClick="verPropiedadesDeUsuarioBtn_Click"/>
            <br />
            <asp:Button ID="verServiciosBtn" runat="server" Text="Ver usuario de una propiedad" Width="700px" BorderWidth="0px" Font-Bold="True" Font-Names="Bahnschrift" Font-Size="40px" ForeColor="White" style="margin-top:30px ;background-color:#ff6f5e" OnClick="verServiciosBtn_Click"/>
            <br />
            <asp:Button ID="btnCambioEntidad" runat="server" Text="Ver cambios a entidades" Width="700px" BorderWidth="0px" Font-Bold="True" Font-Names="Bahnschrift" Font-Size="40px" ForeColor="White" style="margin-top:30px ;background-color:#ff6f5e" OnClick="cambioEntidadBtn_Click"/>
        </div>
    </form>
</body>
</html>
