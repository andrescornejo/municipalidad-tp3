using Muni.Classes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Muni.Pages
{
    public partial class propietariosDelete : System.Web.UI.Page
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
            Response.Redirect("propietariosCRUD.aspx?username=" + usernameGot);
        }

        protected void deletePropietarioBtn_Click(object sender, EventArgs e)
        {
            string docID = textBoxDocIDInput.Text;
            if (docID.Length != 0)
            {
                Globals.deletePropietario(docID);
                this.textBoxDocIDInput.Text = "";
                this.gridView.DataSource = Globals.getPropietarios();
                this.gridView.DataBind();
                MessageBox.Show("Propietario borrado");
            }
            else
                MessageBox.Show("Error en las entradas");
        }
    }
}