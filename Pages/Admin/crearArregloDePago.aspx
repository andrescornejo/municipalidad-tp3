<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="crearArregloDePago.aspx.cs" Inherits="Muni.Pages.Admin.crearArregloDePago" %>

<%@ Register Src="~/Pages/Admin/AdminPanelUC.ascx" TagPrefix="uc1" TagName="AdminPanelUC" %>


<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Crear arreglos de pago</title>
</head>
<body>
    <form id="apForm" runat="server">
        <uc1:AdminPanelUC runat="server" ID="AdminPanelUC" />
        <div class="container">
            <div class="jumbotron">
                <asp:Label ID="welcomeLbl" CssClass="display-4 mb-4" runat="server" Text="Placeholder text"></asp:Label>
                <br />
                <p class="lead">Por favor ingrese el tipo de entidad y el rango de fechas.</p>
                <div class="form-group row px-3 pb-4">
                    <div class="col-cs-2">
                        <p class="lead">Tipo de entidad</p>
                        <asp:DropDownList ID="ddlUsers" CssClass="btn btn-secondary dropdown-toggle" runat="server"></asp:DropDownList>
                    </div>
                    <div class="col-xs-2 mx-3">
                        <p class="lead">Fecha inicio</p>
                        <asp:TextBox ID="tb_FormerDate" runat="server" CssClass="form-control" data-date-autoclose="true" data-date-format="yyyy-mm-dd" data-provide="datepicker" TextMode="DateTimeLocal"></asp:TextBox>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
