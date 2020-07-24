<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="crudTables.aspx.cs" Inherits="Muni.Pages.crudTables" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Edición de entidades</title>
</head>
<body style="background-color:#2c3d63">
    <form id="form1" runat="server">
        <div>
            <asp:Button ID="backBtn" runat="server" Text="Back" Width="200px" BorderWidth="0px" Font-Bold="True" Font-Names="Bahnschrift" Font-Size="40px" ForeColor="White" style="margin-top:5px ;background-color:#ff6f5e" OnClick="backBtn_Click"/>
        </div>
        <div style="text-align:center">
            <asp:Label ID="catergoryLbl" runat="server" Font-Names="Bahnschrift" Font-Size="75px" ForeColor="White" Text="Edición de entidades"></asp:Label>       
        </div>
        <div style="text-align:center;margin-top:50px">
            <asp:Button ID="crudPropietariosBtn" runat="server" Text="Editar Propietarios" Width="500px" BorderWidth="0px" Font-Bold="True" Font-Names="Bahnschrift" Font-Size="40px" ForeColor="White" style="margin-top:10px ;background-color:#addcca" OnClick="crudPropietariosBtn_Click"/>
            <br/>
            <asp:Button ID="crudPropiedadesBtn" runat="server" Text="Editar Propiedades" Width="500px" BorderWidth="0px" Font-Bold="True" Font-Names="Bahnschrift" Font-Size="40px" ForeColor="White" style="margin-top:10px ;background-color:#addcca" OnClick="crudPropiedadesBtn_Click"/>
            <br/>
            <asp:Button ID="crudUsuariosBtn" runat="server" Text="Editar Usuarios" Width="500px" BorderWidth="0px" Font-Bold="True" Font-Names="Bahnschrift" Font-Size="40px" ForeColor="White" style="margin-top:10px ;background-color:#addcca" OnClick="crudUsuariosBtn_Click"/>
            <br/>
        </div>
    </form>
</body>
</html>
