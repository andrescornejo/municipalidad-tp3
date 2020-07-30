using Muni.Classes;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Muni.Pages.Client
{
    public partial class ClientPanel : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            this.welcomeLbl.Text = "Bienvenido, " + Globals.CURRENTUSER + ".";
            if (!Page.IsPostBack)
            {
                //Button inside grid triggers full postback, hence why this code is checked for !IsPostBack.
                this.gridView.DataSource = Cliente.getClientProperties(Globals.CURRENTUSER);
                this.gridView.DataBind();
            }
        }

        private void setPropID(int propID)
        {
            Cliente.CURRENTPROPERTY = propID;
        }

        protected void clearModal()
        {
            gridModal.DataSource = null;
            gridModal.DataBind();
            lblModalTitle.Text = "";
            lblModalBody.Text = "";
        }

        protected void gridView_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "Select")
            {
                //Determine the RowIndex of the Row whose Button was clicked.
                //int rowIndex = Convert.ToInt32(e.CommandArgument);
                ////Reference the GridView Row.
                //GridViewRow row = gridView.Rows[rowIndex];
                ////Get the values.

                //string name = row.Cells[1].Text;
                this.propidTB.Text = e.CommandArgument.ToString();
            }
        }

        protected void verRecPenBtn_Click(object sender, EventArgs e)
        {
            int propID;
            bool parseRes = Int32.TryParse(propidTB.Text, out propID);

            if (propidTB.Text.Length != 0 && parseRes)
            {
                setPropID(propID);
                Response.Redirect("consultarRecibosPendientes.aspx");
            }
            else
                MessageBox.Show("Entrada invalida.");

            //Code before proyecto 3.
            //clearModal();
            //lblModalTitle.Text = "Recibos pendientes";
            //lblModalBody.Text = "Recibos pendientes de la propiedad: " + prop;

            //this.gridModal.DataSource = Cliente.getRecibosPendientes(Cliente.CURRENTPROPERTY);
            //this.gridModal.DataBind();

            //ScriptManager.RegisterStartupScript(Page, Page.GetType(), "myModal", "$('#myModal').modal();", true);
            //upModal.Update();
        }

        protected void btnVerRecPagados_Click(object sender, EventArgs e)
        {
            if (propidTB.Text.Length == 0)
            {
                MessageBox.Show("Entrada invalida.");
                return;
            }
                
            string prop = propidTB.Text;

            clearModal();
            setPropID(Convert.ToInt32(prop));
            lblModalTitle.Text = "Recibos pagados";
            lblModalBody.Text = "Recibos pagados de la propiedad: " + prop;

            this.gridModal.DataSource = Cliente.getRecibosPagados(Cliente.CURRENTPROPERTY);
            this.gridModal.DataBind();

            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "myModal", "$('#myModal').modal();", true);
            upModal.Update();
        }

        protected void btnVerCompobantes_Click(object sender, EventArgs e)
        {
            int propID;
            bool parseRes = Int32.TryParse(propidTB.Text, out propID);

            if (propidTB.Text.Length != 0 && parseRes)
            {
                setPropID(propID);
                Response.Redirect("consultarComprobantes.aspx");
            }
            else
                MessageBox.Show("Entrada invalida.");

            //string prop = propidTB.Text;

            //clearModal();
            //setPropID(Convert.ToInt32(prop));
            //lblModalTitle.Text = "Recibos pendientes";
            //lblModalBody.Text = "Recibos pendientes de la propiedad: " + prop;

            //this.gridModal.DataSource = Cliente.getComprobantes(Cliente.CURRENTPROPERTY);
            //this.gridModal.DataBind();

            //ScriptManager.RegisterStartupScript(Page, Page.GetType(), "myModal", "$('#myModal').modal();", true);
            //upModal.Update();
        }

    }
}