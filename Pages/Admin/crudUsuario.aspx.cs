using Muni.Classes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Muni.Pages.Admin
{
    public partial class crudUsuario : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!this.IsPostBack)
            {
                clearTextBoxes();
                reloadGridView();
            }
            updatePanels();
        }

        #region CRUD

        protected void btnCreateUsr_Click(object sender, EventArgs e)
        {
            string usr = tbCusr.Text;
            string passwd = tbCpsswd.Text;

            if (tbCusr.Text!="" && tbCpsswd.Text!="")
            {
                AdminWeb.createUsuario(usr, passwd, cbCadmin.Checked, Globals.CURRENTUSER, Globals.CURRENTIP);
                clearTextBoxes();
                reloadGridView();
                MessageBox.Show("Usuario agregado: " + usr);
            }
            else
                MessageBox.Show("Error en las entradas");
        }

        protected void btnUpdateUsr_Click(object sender, EventArgs e)
        {
            string usr = tbUusr.Text;
            string psswd = tbUpsswd.Text;
            bool isAdm = cbUadmin.Checked;
            int id;
            bool idResult = Int32.TryParse(hf_id.Value, out id);

            if(tbUusr.Text!="" && tbUpsswd.Text!="" && idResult)
            {
                AdminWeb.updateUsuario(id, usr, psswd, isAdm, Globals.CURRENTUSER, Globals.CURRENTIP);
                clearTextBoxes();
                reloadGridView();
                MessageBox.Show("Usuario actualizado: " + usr);
            }
            else
                MessageBox.Show("Error en las entradas");
        }

        protected void btnDeleteUsr_Click(object sender, EventArgs e)
        {
            string usr = tbDusr.Text;
            if (tbDusr.Text != "")
            {
                AdminWeb.deleteUsuario(usr, Globals.CURRENTUSER, Globals.CURRENTIP);
                clearTextBoxes();
                reloadGridView();
                MessageBox.Show("Usuario borrado: " + usr);
            }
            else
                MessageBox.Show("Error en las entradas");
        }

        #endregion

        protected void gridUsr_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "Select")
            {
                //Determine the RowIndex of the Row whose Button was clicked.
                int rowIndex = Convert.ToInt32(e.CommandArgument);
                //Reference the GridView Row.
                GridViewRow row = gridUsr.Rows[rowIndex];
                //Get the values.

                string usr = row.Cells[1].Text;
                string passwd = row.Cells[2].Text;
                string isAdm = row.Cells[3].Text;
                string id = row.Cells[4].Text;

                fillTextBoxes(usr, passwd, isAdm, id);
            }
        }

        protected void fillTextBoxes(string usr, string passwd, string isAdm, string id)
        {
            if (jtCreate.Visible)
                return;
            else if (jtUpdate.Visible)
            {
                tbUusr.Text = usr;
                tbUpsswd.Text = passwd;
                cbUadmin.Checked = Convert.ToBoolean(isAdm); ;
                hf_id.Value = id;
            }
            else if (jtDelete.Visible)
            {
                tbDusr.Text = usr;
            }
        }

        protected void reloadGridView()
        {
            this.gridUsr.Columns[4].Visible = true;
            this.gridUsr.DataSource = AdminWeb.getUsuarios();
            this.gridUsr.DataBind();
            this.gridUsr.Columns[4].Visible = false;
        }

        protected void clearTextBoxes()
        {
            tbCusr.Text = "";
            tbCpsswd.Text = "";
            cbCadmin.Checked = false;
            tbUusr.Text = "";
            tbUpsswd.Text = "";
            cbUadmin.Checked = false;
            tbDusr.Text = "";
            hf_id.Value = "";
        }

        protected void updatePanels()
        {
            if (Globals.CURRENTPANEL == "create")
            {
                this.jtCreate.Visible = true;
                this.jtUpdate.Visible = false;
                this.jtDelete.Visible = false;
            }
            else if (Globals.CURRENTPANEL == "update")
            {
                this.jtCreate.Visible = false;
                this.jtUpdate.Visible = true;
                this.jtDelete.Visible = false;
            }
            else if (Globals.CURRENTPANEL == "delete")
            {
                this.jtCreate.Visible = false;
                this.jtUpdate.Visible = false;
                this.jtDelete.Visible = true;
            }
            else
            {
                Globals.CURRENTPANEL = "create";
            }
        }

        protected void dropCreate_Click(object sender, EventArgs e)
        {
            Globals.CURRENTPANEL = "create";
            updatePanels();
        }
        protected void dropUpdate_Click(object sender, EventArgs e)
        {
            Globals.CURRENTPANEL = "update";
            updatePanels();
        }
        protected void dropDelete_Click(object sender, EventArgs e)
        {
            Globals.CURRENTPANEL = "delete";
            updatePanels();
        }


    }
}