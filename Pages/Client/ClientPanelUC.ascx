<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ClientPanelUC.ascx.cs" Inherits="Muni.Pages.Client.ClientPanelUC" %>

<link href="../../Content/bootstrap.css" rel="stylesheet" />
<link href="../../Content/dashboard.css" rel="stylesheet" />

<asp:ScriptManager ID="ScriptManager1" runat="server" EnablePartialRendering="true"></asp:ScriptManager>

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

<div class="container">
    <div id="alertDiv" class="alert alert-success mt-3 hidden" role="alert" runat="server">
        <asp:Label ID="lblAlert" runat="server" Text=""></asp:Label>
    </div>
    <div id="successDiv" class="alert alert-danger mt-3 hidden" role="alert" runat="server">
        <asp:Label ID="lblSucc" runat="server" Text=""></asp:Label>
    </div>
</div>

<div class="py-5"></div>

<%-- jQuery ,popper.js ,bootstrap.js --%>
<script src="../../Scripts/jquery-3.5.1.min.js"></script>
<script src="../../Scripts/umd/popper.min.js"></script>
<script src="../../Scripts/bootstrap.min.js"></script>