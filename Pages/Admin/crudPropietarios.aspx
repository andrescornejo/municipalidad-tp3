<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="crudPropietarios.aspx.cs" Inherits="Muni.Pages.Admin.crudPropietarios" %>

<%@ Register Src="~/Pages/Admin/AdminPanelUC.ascx" TagPrefix="uc1" TagName="AdminPanelUC" %>


<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="crudPropietariosForm" runat="server">
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
                <h1 class="display-4">Crear propietarios.</h1>
                <p class="lead">Ingrese los datos de la nueva propiedad.</p>
                <hr class="my-4"/>
                <div class="form-group row px-3 pb-4">
                    <div class="col-xs-2">
                        <p class="lead">Nombre del propietario</p>
                        <asp:TextBox ID="tbCnombre" runat="server" CssClass="form-control"></asp:TextBox>
                    </div>
                    <div class="col-xs-2 px-3">
                        <p class="lead">Valor del documento legal</p>
                        <asp:TextBox ID="tbCdocID" runat="server" CssClass="form-control" TextMode="Number"></asp:TextBox>
                    </div>
                    <div class="col-xs-2">
                        <p class="lead">Tipo del documento legal</p>
                        <asp:DropDownList ID="ddCTDocID" CssClass="btn btn-secondary dropdown-toggle" runat="server">
                            <asp:ListItem>Cedula Nacional</asp:ListItem>
                            <asp:ListItem>Cedula Residente</asp:ListItem>
                            <asp:ListItem>Pasaporte</asp:ListItem>
                            <asp:ListItem>Cedula Juridica</asp:ListItem>
                            <asp:ListItem>Registro Civil</asp:ListItem>
                            <asp:ListItem>Cedula Extranjera</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
                <asp:Button ID="btnCreatePropiet" runat="server" Text="Crear propietario" CssClass="btn btn-primary btn-lg" OnClick="btnCreatePropiet_Click"/>
            </div>

            <%-- Update section --%>
            <div id="jtUpdate" class="jumbotron" runat="server">
                <h1 class="display-4">Actualizar propietarios.</h1>
                <p class="lead">Seleccione el propietario que desea actualizar, y modifique los datos necesarios.</p>
                <hr class="my-4"/>
                <div class="form-group row px-3 pb-4">
                    <div class="col-xs-2">
                        <p class="lead">Nombre del propietario</p>
                        <asp:TextBox ID="tbUnombre" runat="server" CssClass="form-control"></asp:TextBox>
                    </div>
                    <div class="col-xs-2 px-3">
                        <p class="lead">Valor del documento legal</p>
                        <asp:TextBox ID="tbUdocID" runat="server" CssClass="form-control" TextMode="Number"></asp:TextBox>
                    </div>
                    <div class="col-xs-2">
                        <p class="lead">Tipo del documento legal</p>
                        <asp:DropDownList ID="ddUTDocID" CssClass="btn btn-secondary dropdown-toggle" runat="server">
                            <asp:ListItem>Cedula Nacional</asp:ListItem>
                            <asp:ListItem>Cedula Residente</asp:ListItem>
                            <asp:ListItem>Pasaporte</asp:ListItem>
                            <asp:ListItem>Cedula Juridica</asp:ListItem>
                            <asp:ListItem>Registro Civil</asp:ListItem>
                            <asp:ListItem>Cedula Extranjera</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
                <asp:Button ID="btnUpdatePropiet" runat="server" Text="Actualizar propietario" CssClass="btn btn-primary btn-lg" OnClick="btnUpdatePropiet_Click"/>
            </div>

            <%-- Delete section --%>
            <div id="jtDelete" class="jumbotron" runat="server">
                <h1 class="display-4">Borrar propietarios.</h1>
                <p class="lead">Seleccione la propiedad que desea borrar.</p>
                <hr class="my-4"/>
                <div class="form-group row px-3 pb-4">
                    <div class="col-xs-2">
                        <p class="lead">Número de propiedad</p>
                        <asp:TextBox ID="tbDdocID" runat="server" CssClass="form-control" TextMode="Number"></asp:TextBox>
                    </div>
                </div>
                <asp:Button ID="btnDeletePropiet" runat="server" Text="Borrar propietario" CssClass="btn btn-danger btn-lg" OnClick="btnDeletePropiet_Click"/>
            </div>

            <%-- Grid section --%>
            <div id="jtGrid" class="jumbotron">
                <h1 class="h3">Propietarios registrados:</h1>
                <div class="my-4"></div>
                <asp:GridView ID="gridPropiet" runat="server" CssClass="table table-hover table-dark" AutoGenerateColumns="false" OnRowCommand="gridPropiet_RowCommand"  >
                    <Columns>
                        <asp:TemplateField>
                            <ItemTemplate>
                                <asp:Button ID="btnSelectRow" CssClass="btn btn-info" Text="Seleccionar propietario" runat="server" CommandName="Select" CommandArgument="<%# Container.DataItemIndex %>"/>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="name" HeaderText="Nombre" />
                        <asp:BoundField DataField="docid" HeaderText="Valor del documento legal" />
                        <asp:BoundField DataField="tid" HeaderText="Tipo de documento legal" />
                        <asp:BoundField DataField="id"/>
                    </Columns>
                </asp:GridView>
            </div>
            <asp:HiddenField ID="hf_id" runat="server" />
        </div>
    </form>
</body>
</html>
