using Muni.Classes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Muni.Pages
{
    public partial class propiedadesDelete : System.Web.UI.Page
    {
        string usernameGot;
        protected void Page_Load(object sender, EventArgs e)
        {
            usernameGot = Request.QueryString["username"];
            this.gridView.DataSource = Globals.getPropiedades();
            this.gridView.DataBind();
        }
        protected void backBtn_Click(object sender, EventArgs e)
        {
            Response.Redirect("propiedadesCRUD.aspx?username=" + usernameGot);
        }

        protected void deletePropietarioBtn_Click(object sender, EventArgs e)
        {
            int numFinca = Int32.Parse(textNumFincaInput.Text);

            if (numFinca != 0)
            {
                Globals.deletePropiedad(numFinca);
                this.textNumFincaInput.Text = "";
                this.gridView.DataSource = Globals.getPropiedades();
                this.gridView.DataBind();
                MessageBox.Show("Propiedad borrada");
            }
            else
                MessageBox.Show("Error en las entradas");
        }
    }
}