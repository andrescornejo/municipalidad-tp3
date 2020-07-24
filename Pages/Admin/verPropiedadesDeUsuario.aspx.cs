using Muni.Classes;
using System;
using System.Data;

namespace Muni.Pages
{
    public partial class VerPropiedadesPage : System.Web.UI.Page
    {
        string usernameGot;
        protected void Page_Load(object sender, EventArgs e)
        {
            usernameGot = Request.QueryString["username"];
            this.gridView.DataSource = Globals.getUsernames();
            this.gridView.DataBind();
        }

        protected void backBtn_Click(object sender, EventArgs e)
        {
            Response.Redirect("AdminPage.aspx?username=" + usernameGot);
        }

        protected void verPropiedadesBtn_Click(object sender, EventArgs e)
        {
            string idPropietario = this.propiedadIdInput.Text;
            if (idPropietario.Length != 0)
            {

                DataTable dt = Globals.getUsuariosDeLaPropiedad(idPropietario);
                this.gridView.DataSource = dt;
                this.gridView.DataBind();

            }
        }
    }
}