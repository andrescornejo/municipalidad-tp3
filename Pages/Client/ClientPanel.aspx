<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ClientPanel.aspx.cs" Inherits="Muni.Pages.Client.ClientPanel" %>

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
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <div class="container">
        <nav class="navbar navbar-dark bg-dark fixed-top flex-md-nowrap p-2 shadow" >
            <a class="navbar-brand col-sm-3 col-md-2 mr-0" href="#">Panel de cliente</a>
            <ul class="navbar-nav px-3">
                <li class="nav-item text-nowrap">
                    <asp:Button ID="logoutBtn" runat="server" Text="Cerrar sesión" OnClick="logoutBtn_Click" CssClass="btn btn-outline-danger my-2 my-sm-0" type="submit"/>
                </li>
            </ul>
        </nav>
    </div>
    <hr class="my-5"/>
    <div class="container">
        <div class="jumbotron">
            <asp:Label ID="welcomeLbl" CssClass="display-4" runat="server" Text="Placeholder text"></asp:Label>
            <br />
            <p class="lead">Por favor ingrese un número de propiedad.</p>
            <asp:TextBox ID="propidTB" runat="server" CssClass="form-control input-sm" TextMode="Number"></asp:TextBox>
            <br/>

            <asp:Button ID="verRecPenBtn" runat="server" Text="Ver recibos pendientes" CssClass="btn btn-primary btn-lg" OnClick="verRecPenBtn_Click"/>
            <asp:Button ID="btnVerRecPagados" runat="server" Text="Ver recibos pagados" CssClass="btn btn-primary btn-lg" OnClick="btnVerRecPagados_Click"/>
            <asp:Button ID="btnVerCompobantes" runat="server" Text="Ver comprobantes de pago" CssClass="btn btn-primary btn-lg" OnClick="btnVerCompobantes_Click"/>

            <hr class="my-4"/>
            <asp:GridView ID="gridView" runat="server" CssClass="table table-hover table-dark" AutoGenerateColumns="false" OnSelectedIndexChanged = "OnSelectedIndexChanged">
                <Columns>
                    <asp:ButtonField Text="Seleccionar Propiedad" CommandName="Select" ItemStyle-Width="100"/>
                    <asp:BoundField DataField="# Propiedad" HeaderText="# Propiedad" />
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
                            <button class="btn btn-info" data-dismiss="modal" aria-hidden="true">Cerrar</button>
                        </div>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
    </div>

    <%-- jQuery ,popper.js ,bootstrap.js --%>
    <script src="../../Scripts/jquery-3.5.1.min.js"></script>
    <script src="../../Scripts/popper.min.js"></script>
    <script src="../../Scripts/bootstrap.min.js"></script>
    </form>
    
</body>
</html>
