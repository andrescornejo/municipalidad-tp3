
using Muni.Classes;
using System;
using System.Collections.Generic;
using System.Data.SqlTypes;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Muni.Pages.Admin
{
    public partial class crudPropiedades : System.Web.UI.Page
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

        protected void btnCreateProp_Click(object sender, EventArgs e)
        {
            int numFinca, valorFinca;
            bool result1 = Int32.TryParse(tb_CnumProp.Text, out numFinca);
            bool result2 = Int32.TryParse(tb_Cvalor.Text, out valorFinca);
            string direccion = tb_Cdir.Text;

            if (result1 && result2 && tb_Cdir.Text != "")
            {
                AdminWeb.createPropiedad(numFinca, valorFinca, direccion, Globals.CURRENTUSER, Globals.CURRENTIP);
                clearTextBoxes();
                reloadGridView();
                MessageBox.Show("Propiedad agregada: " + numFinca);
            }
            else
                MessageBox.Show("Error en las entradas");
        }

        protected void btnDeleteProp_Click(object sender, EventArgs e)
        {
            bool result;
            int numFinca;  
            result = Int32.TryParse(tb_DnumProp.Text, out numFinca);

            if (tb_DnumProp.Text!= "" && result)
            {
                AdminWeb.deletePropiedad(numFinca, Globals.CURRENTUSER, Globals.CURRENTIP);
                clearTextBoxes();
                reloadGridView();
                MessageBox.Show("Propiedad borrada: " + numFinca);
            }
            else
                MessageBox.Show("Error en las entradas");    
        }

        protected void btnUpdateProp_Click(object sender, EventArgs e)
        {
            int numP, val, acum, ult, id;
            bool numPResult = Int32.TryParse(tb_UnumProp.Text, out numP);
            bool valResult = Int32.TryParse(tb_Uval.Text, out val);
            bool acumResult = Int32.TryParse(tb_Uacum.Text, out acum);
            bool ultResult = Int32.TryParse(tb_Uult.Text, out ult);
            bool idResult = Int32.TryParse(hf_Uid.Value, out id);
            string dir = tb_Udir.Text;

            if (tb_Udir.Text != "" && numPResult && valResult && acumResult
                && ultResult && idResult)
            {
                AdminWeb.updatePropiedad(id, numP, val, dir, acum, ult, Globals.CURRENTUSER, Globals.CURRENTIP);
                clearTextBoxes();
                reloadGridView();
                MessageBox.Show("Propiedad actualizada: " + numP);
            }
            else
                MessageBox.Show("Error en las entradas");
        }

        protected void gridProp_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "Select")
            {
                //Determine the RowIndex of the Row whose Button was clicked.
                int rowIndex = Convert.ToInt32(e.CommandArgument);
                //Reference the GridView Row.
                GridViewRow row = gridProp.Rows[rowIndex];
                //Get the values.

                string numProp = row.Cells[1].Text;
                string valor = row.Cells[2].Text;
                string dir = row.Cells[3].Text;
                string acumM3 = row.Cells[4].Text;
                string ultM3 = row.Cells[5].Text;
                string id = row.Cells[6].Text;

                fillTextBoxes(numProp, valor, dir, acumM3, ultM3, id);
            }
        }

        protected void fillTextBoxes(string numProp, string val, string dir, string acum, string ult, string id)
        {
            if (jtCreate.Visible)
                return;
            else if (jtUpdate.Visible)
            {
                tb_UnumProp.Text = numProp;
                tb_Uval.Text = val;
                tb_Udir.Text = dir;
                tb_Uacum.Text = acum;
                tb_Uult.Text = ult;
                hf_Uid.Value = id;
            }
            else if (jtDelete.Visible)
            {
                tb_DnumProp.Text = numProp;
                hf_Uid.Value = id;
            }
        }

        protected void reloadGridView()
        {
            this.gridProp.Columns[6].Visible = true;
            this.gridProp.DataSource = AdminWeb.getPropiedades();
            this.gridProp.DataBind();
            this.gridProp.Columns[6].Visible = false;
        }

        protected void clearTextBoxes()
        {
            tb_CnumProp.Text = "";
            tb_Cvalor.Text = "";
            tb_Cdir.Text = "";
            tb_DnumProp.Text = "";
            tb_UnumProp.Text = "";
            tb_Uval.Text = "";
            tb_Udir.Text = "";
            tb_Uacum.Text = "";
            tb_Uult.Text = "";
            hf_Uid.Value = "";
        }

        //Terrible method to circumvent postbacks created by the gridview.
        protected void updatePanels()
        {
            if(Globals.CURRENTPANEL == "create")
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