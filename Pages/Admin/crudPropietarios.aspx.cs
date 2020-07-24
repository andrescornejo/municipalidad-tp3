using Muni.Classes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Muni.Pages.Admin
{
    public partial class crudPropietarios : System.Web.UI.Page
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

        protected void btnCreatePropiet_Click(object sender, EventArgs e)
        {
            string name = tbCnombre.Text;
            string docid = tbCdocID.Text;
            string tid = ddCTDocID.SelectedValue;

            if (tbCnombre.Text != "" && tbCdocID.Text != "")
            {
                AdminWeb.createPropietario(name, docid, tid, Globals.CURRENTUSER, Globals.CURRENTIP);
                clearTextBoxes();
                reloadGridView();
                MessageBox.Show("Usuario agregado: " + name);
            }
            else
                MessageBox.Show("Error en las entradas");
        }

        protected void btnUpdatePropiet_Click(object sender, EventArgs e)
        {
            string name = tbUnombre.Text;
            string docid = tbUdocID.Text;
            string tid = ddUTDocID.SelectedValue;
            int inID;
            bool idResult = Int32.TryParse(hf_id.Value, out inID);

            if (tbUnombre.Text != "" && tbUdocID.Text != "" && idResult)
            {
                AdminWeb.updatePropietario(inID, name, docid, tid, Globals.CURRENTUSER, Globals.CURRENTIP);
                clearTextBoxes();
                reloadGridView();
                MessageBox.Show("Usuario actualizado: " + name);
            }
            else
                MessageBox.Show("Error en las entradas");
        }

        protected void btnDeletePropiet_Click(object sender, EventArgs e)
        {
            string docid = tbDdocID.Text;

            if (tbDdocID.Text != "")
            {
                AdminWeb.deletePropietario(docid, Globals.CURRENTUSER, Globals.CURRENTIP);
                clearTextBoxes();
                reloadGridView();
                MessageBox.Show("Usuario borrado.");
            }
            else
                MessageBox.Show("Error en las entradas");
        }

        #endregion

        protected void gridPropiet_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "Select")
            {
                //Determine the RowIndex of the Row whose Button was clicked.
                int rowIndex = Convert.ToInt32(e.CommandArgument);
                //Reference the GridView Row.
                GridViewRow row = gridPropiet.Rows[rowIndex];
                //Get the values.

                string name = row.Cells[1].Text;
                string docid = row.Cells[2].Text;
                string tid = row.Cells[3].Text;
                string id = row.Cells[4].Text;

                fillTextBoxes(name, docid, tid, id);
            }
        }

        protected void fillTextBoxes(string name, string docid, string tid, string id)
        {
            if (jtCreate.Visible)
                return;
            else if (jtUpdate.Visible)
            {
                tbUnombre.Text = name;
                tbUdocID.Text = docid;
                ddUTDocID.SelectedValue = tid;
                hf_id.Value = id;
            }
            else if (jtDelete.Visible)
            {
                tbDdocID.Text = docid;
                hf_id.Value = id;
            }
        }

        protected void reloadGridView()
        {
            this.gridPropiet.Columns[4].Visible = true;
            this.gridPropiet.DataSource = AdminWeb.getPropietarios();
            this.gridPropiet.DataBind();
            this.gridPropiet.Columns[4].Visible = false;
        }

        protected void clearTextBoxes()
        {
            tbCnombre.Text = "";
            tbCdocID.Text = "";
            ddCTDocID.SelectedValue = "Cedula Nacional";
            tbUnombre.Text = "";
            tbUdocID.Text = "";
            ddUTDocID.SelectedValue = "Cedula Nacional";
            tbDdocID.Text = "";
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