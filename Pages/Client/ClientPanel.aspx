<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ClientPanel.aspx.cs" Inherits="Muni.Pages.Client.ClientPanel" %>

<%@ Register Src="~/Pages/Client/ClientPanelUC.ascx" TagPrefix="uc1" TagName="ClientPanelUC" %>


<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no"/>
    <link href="../../Content/bootstrap.css" rel="stylesheet" />
    <link href="../../Content/dashboard.css" rel="stylesheet" />

    <title>Panel de cliente</title>
</head>
<body>
    <form id="clientPanelForm" runat="server">
    <uc1:ClientPanelUC runat="server" id="ClientPanelUC" />
    <div class="container">
        <div class="jumbotron">
            <asp:Label ID="welcomeLbl" CssClass="display-4" runat="server" Text="Placeholder text"></asp:Label>
            <br />
            <p class="lead">Por favor ingrese un número de propiedad.</p>
            <asp:TextBox ID="propidTB" runat="server" CssClass="form-control input-sm" TextMode="Number"></asp:TextBox>
            <br/>

            <asp:Button ID="verRecPenBtn" runat="server" Text="Ver recibos pendientes" CssClass="btn btn-primary btn-lg" OnClick="verRecPenBtn_Click"/>
            <asp:Button ID="btnVerRecPagados" runat="server" Text="Ver recibos pagados" CssClass="btn btn-primary btn-lg" OnClick="btnVerRecPagados_Click"/>
            <asp:Button ID="btnVerCompobantes" runat="server" Text="Ver comprobantes de pago" CssClass="btn btn-primary btn-lg" OnClick="btnVerComprobantes_Click"/>
            <asp:Button ID="btnVerAP" runat="server" Text="Ver arreglo de pago" CssClass="btn btn-primary btn-lg" OnClick="btnVerAP_Click"/>

            <hr class="my-4"/>
            <asp:GridView ID="gridView" runat="server" CssClass="table table-hover table-dark h5" AutoGenerateColumns="false" OnRowCommand="gridView_RowCommand">
                <Columns>
                    <asp:TemplateField ShowHeader="False" ItemStyle-Width="130">
                        <ItemTemplate>
                            <asp:Button ID="Button1" runat="server" CausesValidation="false" CommandName="Select"
                                Text="Seleccionar" CommandArgument='<%# Eval("# Propiedad") %>' CssClass="btn btn-info btn-lg"/>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="# Propiedad" HeaderText="# Propiedad"/>
                    <asp:BoundField DataField="Valor" HeaderText="Valor" />
                    <asp:BoundField DataField="Direccion" HeaderText="Dirección" />
                </Columns>
            </asp:GridView>
        </div>
    </div>


    <!-- Modal code -->
    <div class="modal fade" id="myModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg" role="document">
            <asp:UpdatePanel ID="upModal" runat="server" ChildrenAsTriggers="false" UpdateMode="Conditional">
                <ContentTemplate>
                    <div class="modal-content">
                        <div class="modal-header">
                            <h4 class="modal-title"><asp:Label ID="lblModalTitle" runat="server" Text=""></asp:Label></h4>
                            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                <span aria-hidden="true">&times;</span>
                            </button>
                        </div>
                        <div class="modal-body">
                            <asp:Label ID="lblModalBody" runat="server" CssClass="lead" Text=""></asp:Label>
                            <br class="mb-3"/>
                            <asp:GridView ID="gridModal" runat="server" CssClass="table table-hover table-dark"></asp:GridView>
                        </div>
                        <div class="modal-footer">
                            <button class="btn btn-danger" data-dismiss="modal" aria-hidden="true">Cancelar</button>
                        </div>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
    </div>


    </form>
    
</body>
</html>
