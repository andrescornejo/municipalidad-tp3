<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="consultarAP_DeProp.aspx.cs" Inherits="Muni.Pages.Client.consultarAP_DeProp" %>

<%@ Register Src="~/Pages/Client/ClientPanelUC.ascx" TagPrefix="uc1" TagName="ClientPanelUC" %>


<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="consultarAPForm" runat="server">
        <uc1:ClientPanelUC runat="server" ID="ClientPanelUC" />
        <div class="mb-3 mx-5">
            <asp:Button ID="btnBack" CssClass="btn btn-outline-secondary btn-lg" OnClick="btnBack_Click" Text="Volver" runat="server" />
        </div>
        <div class="container">
            <div class="jumbotron">
                <asp:Label ID="lblDisplay" CssClass="display-4" runat="server" Text="Placeholder text"></asp:Label>
                <div class="py-3">
                    <asp:Label ID="lblLead" CssClass="lead" runat="server" >Placeholder text</asp:Label>
                </div>
                <br/>

                <hr class="my-4"/>
                <asp:GridView ID="gridAP" runat="server" CssClass="table table-hover table-dark" AutoGenerateColumns="false">
                    <Columns>
                        <asp:BoundField DataField="id" HeaderText="id" />
                        <asp:BoundField DataField="finca" HeaderText="Número de propiedad" />
                        <asp:BoundField DataField="plazo" HeaderText="Plazo en meses" />
                        <asp:BoundField DataField="plazoResta" HeaderText="Meses faltantes" />
                        <asp:BoundField DataField="cmp" HeaderText="Número de comprobante" />
                        <asp:BoundField DataField="monto" HeaderText="Monto total" />
                        <asp:BoundField DataField="saldo" HeaderText="Saldo" />
                        <asp:BoundField DataField="cuota" HeaderText="Cuota" />
                        <asp:BoundField DataField="TasaI" HeaderText="Tasa de interes" />
                        <asp:BoundField DataField="fecha" HeaderText="Fecha de creación" />
                        <asp:BoundField DataField="fechaA" HeaderText="Último pago" />
                    </Columns>
                </asp:GridView>
            </div>
            <div class="jumbotron py-auto">
                <div class="pb-3">
                    <asp:Label ID="lblMovAP" CssClass="h4" runat="server" Text="Placeholder text"></asp:Label>
                </div>
                <asp:GridView ID="gridMovAP" runat="server" CssClass="table table-hover table-dark" AutoGenerateColumns="false">
                    <Columns>
                        <asp:BoundField DataField="id" HeaderText="id" />
                        <asp:BoundField DataField="fecha" HeaderText="Fecha de pago" />
                        <asp:BoundField DataField="TipoMov" HeaderText="Tipo de movimiento" />
                        <asp:BoundField DataField="monto" HeaderText="Monto" />
                        <asp:BoundField DataField="saldo" HeaderText="Saldo" />
                        <asp:BoundField DataField="interes" HeaderText="Tasa de interés" />
                        <asp:BoundField DataField="plazoResta" HeaderText="Meses faltantes" />
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </form>
</body>
</html>
