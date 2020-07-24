using Muni.Classes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Muni.Pages
{
    public partial class usuariosUpdate : System.Web.UI.Page
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

        protected void updateUsuarioBtn_Click(object sender, EventArgs e)
        {
            string OLDUsername = textBoxOLDUsername.Text;
            string NEWUsername = textBoxNewName.Text;
            string NEWPassword = textBoxNewPassword.Text;
            bool isAdmin = isAdminCheckbox.Checked;

            if (OLDUsername.Length != 0 && NEWUsername.Length != 0 && NEWPassword.Length != 0)
            {
                AdminWeb.updateUsuario(OLDUsername, NEWUsername, NEWPassword, isAdmin, Globals.CURRENTUSER, Globals.CURRENTIP);
                clearTextBoxes();
                this.gridView.DataSource = Globals.getUsuarios();
                this.gridView.DataBind();
                MessageBox.Show("Usuario actualizado: " + NEWUsername);
            }
            else
                MessageBox.Show("Error en las entradas");
        }

        protected void clearTextBoxes()
        {
            this.textBoxOLDUsername.Text = "";
            this.textBoxNewName.Text = "";
            this.textBoxNewPassword.Text = "";
        }
    }
}