<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="verPropiedadesDeUsuario.aspx.cs" Inherits="Muni.Pages.VerPropiedadesPage" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Propiedades</title>
</head>
<body style="background-color:#2c3d63">
    <form id="form1" runat="server">
        <div>
            <asp:Button ID="backBtn" runat="server" Text="Back" Width="200px" BorderWidth="0px" Font-Bold="True" Font-Names="Bahnschrift" Font-Size="40px" ForeColor="White" style="margin-top:5px ;background-color:#ff6f5e" OnClick="backBtn_Click"/>
        </div>
        <div style="text-align:center">
            <asp:Label ID="catergoryLbl" runat="server" Font-Names="Bahnschrift" Font-Size="75px" ForeColor="White" Text="Propiedades que puede ver un usuario"></asp:Label>       
        </div>
        <div style="text-align:center;margin-top:50px">
            <asp:Label ID="nombreUsuarioLbl" runat="server" Text="Nombre de usuario" Font-Names="Bahnschrift" ForeColor="White"  Font-Size="30px"></asp:Label>
            <br/>
            <asp:TextBox ID="propiedadIdInput" runat="server" style="margin-top:10px;margin-bottom:10px" Font-Names="Bahnschrift" Width="250px" Font-Size="30px"></asp:TextBox>
            <br/>
            <asp:Button ID="verPropiedadesBtn" runat="server" Text="Ver propiedades" Width="500px" BorderWidth="0px" Font-Bold="True" Font-Names="Bahnschrift" Font-Size="40px" ForeColor="White" style="margin-top:10px ;background-color:#addcca" OnClick="verPropiedadesBtn_Click"/>
            <br/>
            <asp:GridView ID="gridView" runat="server" HorizontalAlign="Center" style="margin-top:30px;" Font-Names="Bahnschrift" Font-Size="20px" BackColor="White" BorderColor="#CCCCCC" BorderStyle="None" BorderWidth="1px" CellPadding="3">
                <FooterStyle BackColor="White" ForeColor="#000066" />
                <HeaderStyle BackColor="#006699" Font-Bold="True" ForeColor="White" />
                <PagerStyle BackColor="White" ForeColor="#000066" HorizontalAlign="Left" />
                <RowStyle ForeColor="#000066"/>
                <SelectedRowStyle BackColor="#669999" Font-Bold="True" ForeColor="White" />
                <SortedAscendingCellStyle BackColor="#F1F1F1" />
                <SortedAscendingHeaderStyle BackColor="#007DBB" />
                <SortedDescendingCellStyle BackColor="#CAC9C9" />
                <SortedDescendingHeaderStyle BackColor="#00547E" />
            </asp:GridView>
        </div>
    </form>
</body>
</html>
