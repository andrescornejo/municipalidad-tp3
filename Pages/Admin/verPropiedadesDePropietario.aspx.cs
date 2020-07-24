using Muni.Classes;
using System;
using System.Data;

namespace Muni.Pages
{
    public partial class VerPropietariosPage : System.Web.UI.Page
    {
        string usernameGot;
        protected void Page_Load(object sender, EventArgs e)
        {
            usernameGot = Request.QueryString["username"];
            this.gridView.DataSource = Globals.getPropietarios();
            this.gridView.DataBind();
        }

        protected void backBtn_Click(object sender, EventArgs e)
        {
            Response.Redirect("AdminPanel.aspx");
        }

        protected void verPropiedadesBtn_Click(object sender, EventArgs e)
        {
            string numeroFinca = this.propietarioIdInput.Text;
            if (numeroFinca.Length != 0)
            {

                DataTable dt = Globals.getPropiedadesFromPropietarioDocID(numeroFinca);
                this.gridView.DataSource = dt;
                this.gridView.DataBind();

            }
        }
    }
}