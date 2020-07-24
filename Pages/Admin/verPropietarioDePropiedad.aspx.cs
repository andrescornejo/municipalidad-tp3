using Muni.Classes;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Muni.Pages
{
    public partial class verPropietarioDePropiedad : System.Web.UI.Page
    {
        string usernameGot;
        protected void Page_Load(object sender, EventArgs e)
        {
            usernameGot = Request.QueryString["username"];
            this.gridView.DataSource = Globals.getPropiedades();
            this.gridView.DataBind();
        }
        protected void verPropietariosBtn_Click(object sender, EventArgs e)
        {
            string numeroFinca = this.propiedadIdInput.Text;
            if (numeroFinca.Length != 0)
            {

                DataTable dt = Globals.getPropietariosFromNumFinca(numeroFinca);
                this.gridView.DataSource = dt;
                this.gridView.DataBind();

            }
        }
        protected void backBtn_Click(object sender, EventArgs e)
        {
            Response.Redirect("AdminPanel.aspx");
        }

    }
}