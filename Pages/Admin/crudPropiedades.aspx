<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="crudPropiedades.aspx.cs" Inherits="Muni.Pages.Admin.crudPropiedades" %>

<%@ Register Src="~/Pages/Admin/AdminPanelUC.ascx" TagPrefix="uc1" TagName="AdminPanelUC" %>


<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Manejo de propiedades</title>
</head>
<body>
    <form id="crudPropiedadesForm" runat="server">
        <uc1:AdminPanelUC runat="server" ID="AdminPanelUC" />
        <div class="container">

            <div class="dropdown show pb-3">
                <a class="btn btn-secondary dropdown-toggle" href="#" role="button" id="dropdownMenuLink" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                Tipo de gestión
                </a>
                
                <div class="dropdown-menu" aria-labelledby="dropdownMenuLink">
                    <asp:LinkButton ID="dropCreate" CssClass="dropdown-item" runat="server" OnClick="dropCreate_Click">Crear</asp:LinkButton>
                    <asp:LinkButton ID="dropUpdate" CssClass="dropdown-item" runat="server" OnClick="dropUpdate_Click">Actualizar</asp:LinkButton>
                    <asp:LinkButton ID="dropDelete" CssClass="dropdown-item" runat="server" OnClick="dropDelete_Click">Borrar</asp:LinkButton>
                </div>
            </div>

            <%-- Create section --%>
            <div id="jtCreate" class="jumbotron" runat="server">
                <h1 class="display-4">Crear de propiedades.</h1>
                <p class="lead">Ingrese los datos de la nueva propiedad.</p>
                <hr class="my-4"/>
                <div class="form-group row px-3 pb-4">
                    <div class="col-xs-2">
                        <p class="lead">Número de propiedad</p>
                        <asp:TextBox ID="tb_CnumProp" runat="server" CssClass="form-control" TextMode="Number"></asp:TextBox>
                    </div>
                    <div class="col-xs-2 px-3">
                        <p class="lead">Valor monetario</p>
                        <asp:TextBox ID="tb_Cvalor" runat="server" CssClass="form-control" TextMode="Number"></asp:TextBox>
                    </div>
                    <div class="col-xs-2">
                        <p class="lead">Dirección</p>
                        <asp:TextBox ID="tb_Cdir" runat="server" CssClass="form-control"></asp:TextBox>
                    </div>
                </div>
                <asp:Button ID="btnCreateProp" runat="server" Text="Crear propiedad" CssClass="btn btn-primary btn-lg" OnClick="btnCreateProp_Click"/>
            </div>

            <%-- Update section --%>
            <div id="jtUpdate" class="jumbotron" runat="server">
                <h1 class="display-4">Actualizar de propiedades.</h1>
                <p class="lead">Seleccione la propiedad que desea actualizar, y modifique los datos respectivos.</p>
                <hr class="my-4"/>
                <div class="form-group row px-3 pb-4">
                    <div class="col-xs-2">
                        <p class="lead">Número de propiedad</p>
                        <asp:TextBox ID="tb_UnumProp" runat="server" CssClass="form-control" TextMode="Number"></asp:TextBox>
                    </div>
                    <div class="col-xs-2 px-3">
                        <p class="lead">Valor monetario</p>
                        <asp:TextBox ID="tb_Uval" runat="server" CssClass="form-control" TextMode="Number"></asp:TextBox>
                    </div>
                    <div class="col-xs-2">
                        <p class="lead">Dirección</p>
                        <asp:TextBox ID="tb_Udir" runat="server" CssClass="form-control"></asp:TextBox>
                    </div>
                    <div class="col-xs-2  px-3">
                        <p class="lead">Consumo acumulado en m3</p>
                        <asp:TextBox ID="tb_Uacum" runat="server" CssClass="form-control" TextMode="Number"></asp:TextBox>
                    </div>
                    <div class="col-xs-2">
                        <p class="lead">Último consumo en m3</p>
                        <asp:TextBox ID="tb_Uult" runat="server" CssClass="form-control" TextMode="Number"></asp:TextBox>
                    </div>
                    <asp:HiddenField ID="hf_Uid" runat="server" />
                </div>
                <asp:Button ID="btnUpdateProp" runat="server" Text="Actualizar propiedad" CssClass="btn btn-primary btn-lg" OnClick="btnUpdateProp_Click"/>
            </div>

            <%-- Delete section --%>
            <div id="jtDelete" class="jumbotron" runat="server">
                <h1 class="display-4">Borrar de propiedades.</h1>
                <p class="lead">Seleccione la propiedad que desea borrar.</p>
                <hr class="my-4"/>
                <div class="form-group row px-3 pb-4">
                    <div class="col-xs-2">
                        <p class="lead">Número de propiedad</p>
                        <asp:TextBox ID="tb_DnumProp" runat="server" CssClass="form-control"></asp:TextBox>
                    </div>
                </div>
                <asp:Button ID="btnDeleteProp" runat="server" Text="Borrar propiedad" CssClass="btn btn-danger btn-lg" OnClick="btnDeleteProp_Click"/>
            </div>

            <%-- Grid section --%>
            <div id="jtGrid" class="jumbotron">
                <h1 class="h3">Propiedades registradas:</h1>
                <div class="my-4"></div>
                <asp:GridView ID="gridProp" runat="server" CssClass="table table-hover table-dark" AutoGenerateColumns="false" OnRowCommand="gridProp_RowCommand"  >
                    <Columns>
                        <asp:TemplateField>
                            <ItemTemplate>
                                <asp:Button ID="btnSelectRow" CssClass="btn btn-info" Text="Seleccionar propiedad" runat="server" CommandName="Select" CommandArgument="<%# Container.DataItemIndex %>"/>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="numFin" HeaderText="Número de propiedad" />
                        <asp:BoundField DataField="val" HeaderText="Valor monetario" />
                        <asp:BoundField DataField="dir" HeaderText="Dirección" />
                        <asp:BoundField DataField="cAm3" HeaderText="Consumo acumulado en m3" />
                        <asp:BoundField DataField="uCm3" HeaderText="Último consumo en m3" />
                        <asp:BoundField DataField="id"/>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </form>
</body>
</html>
