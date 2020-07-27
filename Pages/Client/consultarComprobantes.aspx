<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="consultarComprobantes.aspx.cs" Inherits="Muni.Pages.Client.consultarComprobantes" %>

<%@ Register Src="~/Pages/Client/ClientPanelUC.ascx" TagPrefix="uc1" TagName="ClientPanelUC" %>


<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Consulta de Comprobantes</title>
</head>
<body>
    <form id="consultarComprobantesForm" runat="server">
        <uc1:ClientPanelUC runat="server" ID="ClientPanelUC" />
        
        <div>
            <asp:Button ID="btnBack" CssClass="btn btn-secondary btn-lg" OnClick="btnBack_Click" Text="Volver" runat="server" />
        </div>
        <div class="container">
            <div class="jumbotron">
                <asp:Label ID="welcomeLbl" CssClass="display-4" runat="server" Text="Placeholder text"></asp:Label>
                <div class="py-3">
                    <asp:Label ID="lblLead" CssClass="lead" runat="server" >Placeholder text</asp:Label>
                </div>
                <br/>

                <hr class="my-4"/>
                <asp:GridView ID="gridView" runat="server" CssClass="table table-hover table-dark" AutoGenerateColumns="false">
                    <Columns>
                        <asp:TemplateField ShowHeader="False" ItemStyle-Width="130">
                            <ItemTemplate>
                                <asp:Button ID="Button1" runat="server" CausesValidation="false" CommandName="Select"
                                    Text="Seleccionar" CommandArgument='' CssClass="btn btn-info btn-lg"/>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="id" HeaderText="id" />
                        <asp:BoundField DataField="Numero Finca" HeaderText="# Propiedad" />
                        <asp:BoundField DataField="Concepto Cobro" HeaderText="Concepto de cobro" />
                        <asp:BoundField DataField="Fecha de Emision" HeaderText="Fecha de emisión" />
                        <asp:BoundField DataField="Fecha Vencimiento" HeaderText="Fecha de vencimiento" />
                        <asp:BoundField DataField="Monto Total" HeaderText="Monto total" />
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
                            <br class="mb-3"/>
                            <asp:Label ID="lblModalTotal" runat="server" CssClass="lead" Text=""></asp:Label>
                        </div>
                        <div class="modal-footer">
                            <asp:Button ID="btnCancel" CssClass="btn btn-danger btn-lg" OnClick="btnCancel_Click" Text="Volver" runat="server" />
                        </div>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
    </div>
    </form>
</body>
</html>
