<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="consultaCambioEntidad.aspx.cs" Inherits="Muni.Pages.Admin.consultaCambioEntidad" %>

<%@ Register Src="~/Pages/Admin/AdminPanelUC.ascx" TagPrefix="uc1" TagName="AdminPanelUC" %>


<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no"/>
    <link href="../../Content/bootstrap-datepicker.standalone.css" rel="stylesheet" />
    <title>Consulta de cambios</title>
</head>
<body>
    <form id="consultaCambiosForm" runat="server">
        <uc1:AdminPanelUC runat="server" ID="AdminPanelUC" />
        <div class="container">
            <div class="jumbotron">
                <asp:Label ID="welcomeLbl" CssClass="display-4 mb-4" runat="server" Text="Placeholder text"></asp:Label>
                <br />
                <p class="lead">Por favor ingrese el tipo de entidad y el rango de fechas.</p>
                <div class="form-group row px-3 pb-4">
                    <div class="col-cs-2">
                        <p class="lead">Tipo de entidad</p>
                        <asp:DropDownList ID="dropTipoEntidad" CssClass="btn btn-secondary dropdown-toggle" runat="server">
                            <asp:ListItem>Propiedad</asp:ListItem>
                            <asp:ListItem>Propietario</asp:ListItem>
                            <asp:ListItem>Usuario</asp:ListItem>
                            <asp:ListItem>PropiedadVsPropietario</asp:ListItem>
                            <asp:ListItem>PropiedadVsUsuario</asp:ListItem>
                            <asp:ListItem>PropiedadJuridico</asp:ListItem>
                            <asp:ListItem>ConceptoCobro</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="col-xs-2 mx-3">
                        <p class="lead">Fecha inicio</p>
                        <asp:TextBox ID="tb_FormerDate" runat="server" CssClass="form-control" data-date-autoclose="true" data-date-format="yyyy-mm-dd" data-provide="datepicker" TextMode="DateTimeLocal"></asp:TextBox>
                    </div>
                    <div class="col-xs-2">
                        <p class="lead">Fecha fin</p>
                        <asp:TextBox ID="tb_LatterDate" runat="server" CssClass="form-control" data-date-autoclose="true" data-date-format="yyyy-mm-dd" data-provide="datepicker" TextMode="DateTimeLocal"></asp:TextBox>
                    </div>
                </div>
                <asp:Button ID="verCambiosBtn" runat="server" Text="Ver cambios realizados" CssClass="btn btn-primary btn-lg" OnClick="verCambiosBtn_Click"/>

                <hr class="my-4"/>
                <asp:GridView ID="gridTipoEntidad" runat="server" CssClass="table table-hover table-dark" AutoGenerateColumns="false" OnSelectedIndexChanged = "gridLink_Clicked">
                    <Columns>
                        <asp:ButtonField Text="Ver información" CommandName="Select" ItemStyle-Width="100"/>
                        <asp:BoundField DataField="id" HeaderText="id" />
                        <asp:BoundField DataField="TE" HeaderText="Tipo de entidad" />
                        <asp:BoundField DataField="inAt" HeaderText="Fecha de cambio" />
                        <asp:BoundField DataField="inBy" HeaderText="Insertado por" />
                        <asp:BoundField DataField="inIN" HeaderText="Dirección IP" />
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
                                <div runat="server" id="divJsonAntes" class="pb-4">
                                    <asp:Label ID="lblJsonAntes" runat="server" CssClass="lead" Text=""></asp:Label>
                                    <br class="mb-3"/>
                                    <asp:GridView ID="gridJsonAntes" runat="server" CssClass="table table-hover table-dark"></asp:GridView>
                                </div>
                                <div runat="server" id="divJsonDespues">
                                    <asp:Label ID="lblJsonDespues" runat="server" CssClass="lead" Text=""></asp:Label>
                                    <br class="mb-3"/>
                                    <asp:GridView ID="gridJsonDespues" runat="server" CssClass="table table-hover table-dark"></asp:GridView>
                                </div>
                                
                            </div>
                            <div class="modal-footer">
                                <button class="btn btn-info" data-dismiss="modal" aria-hidden="true">Cerrar</button>
                            </div>
                        </div>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </div>
        </div>
        <script src="../../Scripts/bootstrap-datepicker.min.js"></script>
    </form>
</body>
</html>
