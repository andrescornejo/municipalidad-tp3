<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LoginPage.aspx.cs" Inherits="Muni.MainPage" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">

<head runat="server">
    <title>Login</title>
    <%-- add bootstrap --%>
    <link href="../Content/bootstrap.css" rel="stylesheet" />
    <link href="../Content/login-page.css" rel="stylesheet" />
</head>
<body>
    <div class="container">
        <div class="row">
            <div class="col-sm-9 col-md-7 col-lg-5 mx-auto">
                <div class="card card-signin my-5">
                    <div class="card-body">
                        <h5 class="card-title text-center">Municipalidad - Login</h5>
                        <form id="loginForm" runat="server">
                            <div class="form-label-group">
                                <asp:TextBox ID="usernameTb" runat="server" CssClass="form-control"></asp:TextBox>
                                <label for="inputEmail">Nombre de usuario</label>
                            </div>
                            <div class="form-label-group">
                                <asp:TextBox ID="passwordTb" runat="server" CssClass="form-control" TextMode="Password"></asp:TextBox>
                                <label for="inputPassword">Contraseña</label>
                          </div>
                            <asp:Button ID="loginBtn" runat="server" Text="Login" OnClick="loginBtn_Click" CssClass="btn btn-lg btn-primary btn-block text-uppercase" type="submit"/>
                            <hr class="my-4"/>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <%-- jQuery ,popper.js ,bootstrap.js --%>
    <script src="../Scripts/jquery-3.5.1.min.js"></script>
    <script src="../Scripts/popper.min.js"></script>
    <script src="../Scripts/bootstrap.min.js"></script>
</body>
</html>
