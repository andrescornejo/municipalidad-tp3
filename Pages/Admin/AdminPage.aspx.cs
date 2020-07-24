using Muni.Classes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Muni.Pages
{
    public partial class AdminPage : System.Web.UI.Page
    {
        
        protected void Page_Load(object sender, EventArgs e)
        {
            string usernameGot = Globals.CURRENTUSER;
            this.Title = this.userLbl.Text = usernameGot;
        }
        protected void logoutBtn_Click(object sender, EventArgs e)
        {
            Globals.logoutUser();
            Response.Redirect("../LoginPage.aspx");
        }

        protected void addUsuarioBtn_Click(object sender, EventArgs e)
        {
            Response.Redirect("addUsersFromAdmin.aspx");
        }

        protected void crudBtn_Click(object sender, EventArgs e)
        {
            Response.Redirect("crudTables.aspx");
        }
        protected void verPropiedadesDePropietarioBtn_Click(object sender, EventArgs e)
        {
            Response.Redirect("verPropiedadesDePropietario.aspx");
        }

        protected void verPropietarioDePropiedadBtn_Click(object sender, EventArgs e)
        {
            Response.Redirect("verPropietarioDePropiedad.aspx");
        }

        protected void verPropiedadesDeUsuarioBtn_Click(object sender, EventArgs e)
        {
            Response.Redirect("verPropiedadesDeUsuario.aspx");
        }

        protected void verServiciosBtn_Click(object sender, EventArgs e)
        {
            Response.Redirect("verUsuarioDePropiedad.aspx");
        }

        protected void cambioEntidadBtn_Click(object sender, EventArgs e)
        {
            Response.Redirect("consultaCambioEntidad.aspx");
        }
    }
}