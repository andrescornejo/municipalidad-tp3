using Muni.Classes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Muni.Pages
{
    public partial class usuariosDelete : System.Web.UI.Page
    {
        string usernameGot;
        protected void Page_Load(object sender, EventArgs e)
        {
            usernameGot = Request.QueryString["username"];
            this.gridView.DataSource = Globals.getUsuarios();
            this.gridView.DataBind();
        }
        protected void backBtn_Click(object sender, EventArgs e)
        {
            Response.Redirect("usuariosCRUD.aspx?username=" + usernameGot);
        }

        protected void deletePropietarioBtn_Click(object sender, EventArgs e)
        {
            string docID = textBoxUsername.Text;
            if (docID.Length != 0)
            {
                Globals.deletePropietario(docID);
                this.textBoxUsername.Text = "";
                this.gridView.DataSource = Globals.getUsuarios();
                this.gridView.DataBind();
                MessageBox.Show("Usuario borrado");
            }
            else
                MessageBox.Show("Error en las entradas");
        }
    }
}