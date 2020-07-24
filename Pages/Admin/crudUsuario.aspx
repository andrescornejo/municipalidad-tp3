<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="crudUsuario.aspx.cs" Inherits="Muni.Pages.Admin.crudUsuario" %>

<%@ Register Src="~/Pages/Admin/AdminPanelUC.ascx" TagPrefix="uc1" TagName="AdminPanelUC" %>


<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Manejo de usuarios</title>
</head>
<body>
    <form id="crudUsuariosForm" runat="server">
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
                <h1 class="display-4">Crear usuarios.</h1>
                <p class="lead">Ingrese los datos del nuevo usuario.</p>
                <hr class="my-4"/>
                <div class="form-group row px-3 pb-4">
                    <div class="col-xs-2">
                        <p class="lead">Nombre de usuario</p>
                        <asp:TextBox ID="tbCusr" runat="server" CssClass="form-control" ></asp:TextBox>
                    </div>
                    <div class="col-xs-2 px-3">
                        <p class="lead">Contraseña</p>
                        <asp:TextBox ID="tbCpsswd" runat="server" CssClass="form-control" ></asp:TextBox>
                    </div>
                    <div class="col-xs-2">
                        <p class="lead">Estado de administrador</p>
                        <asp:CheckBox ID="cbCadmin" runat="server" Text=" " TextAlign="Left"/>
                    </div>
                </div>
                <asp:Button ID="btnCreateUsr" runat="server" Text="Crear usuario" CssClass="btn btn-primary btn-lg" OnClick="btnCreateUsr_Click"/>
            </div>

            <%-- Update section --%>
            <div id="jtUpdate" class="jumbotron" runat="server">
                <h1 class="display-4">Actualizar usuarios.</h1>
                <p class="lead">Seleccione el usuario que desea actualizar, y modifique los datos necesarios.</p>
                <hr class="my-4"/>
                <div class="form-group row px-3 pb-4">
                    <div class="col-xs-2">
                        <p class="lead">Nombre de usuario</p>
                        <asp:TextBox ID="tbUusr" runat="server" CssClass="form-control" ></asp:TextBox>
                    </div>
                    <div class="col-xs-2 px-3">
                        <p class="lead">Contraseña</p>
                        <asp:TextBox ID="tbUpsswd" runat="server" CssClass="form-control" ></asp:TextBox>
                    </div>
                    <div class="col-xs-2">
                        <p class="lead">Estado de administrador</p>
                        <asp:CheckBox ID="cbUadmin" runat="server" Text=" " TextAlign="Left"/>
                    </div>
                </div>
                <asp:Button ID="btnUpdateUsr" runat="server" Text="Actualizar usuario" CssClass="btn btn-primary btn-lg" OnClick="btnUpdateUsr_Click"/>
            </div>

            <%-- Delete section --%>
            <div id="jtDelete" class="jumbotron" runat="server">
                <h1 class="display-4">Borrar usuarios.</h1>
                <p class="lead">Seleccione el usuario que desea borrar.</p>
                <hr class="my-4"/>
                <div class="form-group row px-3 pb-4">
                    <div class="col-xs-2">
                        <p class="lead">Nombre de usuario</p>
                        <asp:TextBox ID="tbDusr" runat="server" CssClass="form-control" ></asp:TextBox>
                    </div>
                </div>
                <asp:Button ID="btnDeleteUsr" runat="server" Text="Borrar usuario" CssClass="btn btn-danger btn-lg" OnClick="btnDeleteUsr_Click"/>
            </div>

            <%-- Grid section --%>
            <div id="jtGrid" class="jumbotron">
                <h1 class="h3">Propiedades registradas:</h1>
                <div class="my-4"></div>
                <asp:GridView ID="gridUsr" runat="server" CssClass="table table-hover table-dark" AutoGenerateColumns="false" OnRowCommand="gridUsr_RowCommand"  >
                    <Columns>
                        <asp:TemplateField>
                            <ItemTemplate>
                                <asp:Button ID="btnSelectRow" CssClass="btn btn-info" Text="Seleccionar usuario" runat="server" CommandName="Select" CommandArgument="<%# Container.DataItemIndex %>"/>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="usr" HeaderText="Nombre de usuario" />
                        <asp:BoundField DataField="psswd" HeaderText="Contraseña" />
                        <asp:BoundField DataField="isAdmin" HeaderText="Rol administrador" />
                        <asp:BoundField DataField="id"/>
                    </Columns>
                </asp:GridView>
            </div>
            <asp:HiddenField ID="hf_id" runat="server" />
        </div>
    </form>
</body>
</html>
