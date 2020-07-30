<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="consultarRecibosPendientes.aspx.cs" Inherits="Muni.Pages.Client.consultarRecibosPendientes" %>

<%@ Register Src="~/Pages/Client/ClientPanelUC.ascx" TagPrefix="uc1" TagName="ClientPanelUC" %>


<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Recibos Pendientes</title>
</head>
<body>
    <form id="consultaReciboPenForm" runat="server">
        <uc1:ClientPanelUC runat="server" ID="ClientPanelUC" />
        <div class="container">
            <div class="jumbotron">
                <asp:Label ID="welcomeLbl" CssClass="display-4" runat="server" Text="Placeholder text"></asp:Label>
                <div class="py-3">
                    <asp:Label ID="lblLead" CssClass="lead" runat="server" >Placeholder text</asp:Label>
                </div>
                    <asp:Button ID="btnBack" CssClass="btn btn-secondary btn-lg" OnClick="btnBack_Click" Text="Volver" runat="server" />
                    <asp:Button ID="btnConsult" CssClass="btn btn-primary btn-lg" OnClick="btnConsult_Click" Text="Consultar recibos" runat="server"/>
                <br/>

                <hr class="my-4"/>
                <asp:GridView ID="gridView" runat="server" CssClass="table table-hover table-dark" AutoGenerateColumns="false">
                    <Columns>
                        <asp:TemplateField HeaderText="">  
                            <EditItemTemplate>  
                                <asp:CheckBox ID="cbGv" runat="server" />  
                            </EditItemTemplate>  
                            <ItemTemplate>  
                                <asp:CheckBox ID="cbGv" runat="server" />  
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
                <asp:GridView ID="dg1" runat="server" AutoGenerateColumns="true"></asp:GridView>
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
                        </div>
                        <div class="modal-body">
                            <asp:Label ID="lblModalBody" runat="server" CssClass="lead" Text=""></asp:Label>
                            <br class="mb-3"/>
                            <asp:GridView ID="gridModal" runat="server" CssClass="table table-hover table-dark" AutoGenerateColumns="false">
                                <Columns>
                                    <asp:BoundField DataField="id" HeaderText="id" />
                                    <asp:BoundField DataField="numP" HeaderText="# Propiedad" />
                                    <asp:BoundField DataField="cc" HeaderText="Concepto de cobro" />
                                    <asp:BoundField DataField="fecha" HeaderText="Fecha de emisión" />
                                    <asp:BoundField DataField="fv" HeaderText="Fecha de vencimiento" />
                                    <asp:BoundField DataField="monto" HeaderText="Monto total" />
                                </Columns>
                            </asp:GridView>
                            <asp:GridView ID="dg2" runat="server" AutoGenerateColumns="true"></asp:GridView>
                            <div class ="mb-1"></div>
                            <asp:Label ID="lblModalTotal" runat="server" CssClass="h3" Text=""></asp:Label>
                        </div>
                        <div class="modal-footer">
                            <asp:Button ID="btnCancel" CssClass="btn btn-danger btn-lg" OnClick="btnCancel_Click" Text="Cancelar" runat="server" />
                            <asp:Button ID="btnPay" CssClass="btn btn-primary btn-lg" OnClick="btnPay_Click" Text="Pagar recibos" runat="server" />

                        </div>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
    </div>
    </form>
</body>
</html>
