using Muni.Classes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Muni.Pages
{
    public partial class propiedadesCreate : System.Web.UI.Page
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

        protected void addPropietarioBtn_Click(object sender, EventArgs e)
        {
            int numFinca = Int32.Parse(textBoxNumFincaInput.Text);
            int valorFinca = Int32.Parse(textBoxValorMonetario.Text);
            string direccion = textBoxDireccion.Text;


            if (numFinca != 0 && direccion.Length != 0)
            {
                Globals.addPropiedad(numFinca, valorFinca, direccion);
                this.textBoxNumFincaInput.Text = "";
                this.textBoxValorMonetario.Text = "";
                this.textBoxDireccion.Text = "";
                this.gridView.DataSource = Globals.getPropiedades();
                this.gridView.DataBind();
                MessageBox.Show("Propiedad agregada: " + numFinca);
            }
            else
                MessageBox.Show("Error en las entradas");
        }
    }
}