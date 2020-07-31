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
                <asp:Label ID="lblDisplay" CssClass="display-4" runat="server" Text="Placeholder text"></asp:Label>
                <div class="py-5">
                    <asp:Label ID="lblInstruct" CssClass="h4" runat="server" Text="Placeholder text"></asp:Label>
                </div>
                <div class="form-group row mx-auto">
                    <div class="col-cs-2">
                        <asp:Label ID="lblUsernames" CssClass="lead" runat="server" Text="Usuario"></asp:Label>
                        <asp:DropDownList ID="ddlUsers" CssClass="btn btn-secondary dropdown-toggle" runat="server"></asp:DropDownList>
                    </div>
                    <div class="col-cs-2 mx-2">
                        <asp:Label ID="lblProperties" CssClass="lead" runat="server" Text="Propiedades"></asp:Label>
                        <asp:DropDownList ID="ddlProp" CssClass="btn btn-secondary dropdown-toggle" runat="server"></asp:DropDownList>
                    </div>
                </div>
                <div>
                    <asp:Button ID="btnCancel" CssClass="btn btn-danger btn-lg" OnClick="btnCancel_Click" Text="Cancelar" runat="server"/>
                    <asp:Button ID="btnAbort" CssClass="btn btn-danger btn-lg" OnClick="btnAbort_Click" Text="Abortar AP" runat="server"/>
                    <asp:Button ID="btnSetUser" CssClass="btn btn-primary btn-lg" OnClick="btnSetUser_Click" Text="Confirmar usuario" runat="server"/>
                    <asp:Button ID="btnSetProp" CssClass="btn btn-primary btn-lg" OnClick="btnSetProp_Click" Text="Confirmar propiedad" runat="server"/>
                    <asp:Button ID="btnConsultRates" CssClass="btn btn-primary btn-lg" OnClick="btnConsultRates_Click" Text="Consultar cuotas" runat="server"/>
                </div>
                <div class="py-3">
                    <div class="pb-3">
                        <asp:Label ID="lblGrid" CssClass="h4" runat="server" Text="Placeholder text"></asp:Label>
                    </div>
                    <asp:GridView ID="gridView" runat="server" CssClass="table table-hover table-dark" AutoGenerateColumns="false">
                        <Columns>
                            <asp:BoundField DataField="id" HeaderText="id" />
                            <asp:BoundField DataField="numP" HeaderText="# Propiedad" />
                            <asp:BoundField DataField="cc" HeaderText="Concepto de cobro" />
                            <asp:BoundField DataField="fecha" HeaderText="Fecha de emisión" />
                            <asp:BoundField DataField="fv" HeaderText="Fecha de vencimiento" />
                            <asp:BoundField DataField="monto" HeaderText="Monto total" />
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
