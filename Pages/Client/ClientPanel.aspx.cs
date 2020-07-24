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
            this.gridView.DataSource = Cliente.getClientProperties(Globals.CURRENTUSER);
            this.gridView.DataBind();
        }

        protected void logoutBtn_Click(object sender, EventArgs e)
        {
            Globals.logoutUser();
            Cliente.clearCurrentPropery();
            Response.Redirect("../LoginPage.aspx");
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

        protected void OnSelectedIndexChanged(object sender, EventArgs e)
        {
            //Accessing BoundField Column.
            string name = gridView.SelectedRow.Cells[1].Text;

            this.propidTB.Text = name;
        }
        protected void verRecPenBtn_Click(object sender, EventArgs e)
        {
            if (propidTB.Text.Length == 0)
                return;

            string prop = propidTB.Text;

            clearModal();
            setPropID(Convert.ToInt32(prop));
            lblModalTitle.Text = "Recibos pendientes";
            lblModalBody.Text = "Recibos pendientes de la propiedad: " + prop;

            this.gridModal.DataSource = Cliente.getRecibosPendientes(Cliente.CURRENTPROPERTY);
            this.gridModal.DataBind();

            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "myModal", "$('#myModal').modal();", true);
            upModal.Update();
        }

        protected void btnVerRecPagados_Click(object sender, EventArgs e)
        {
            if (propidTB.Text.Length == 0)
                return;

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
            if (propidTB.Text.Length == 0)
                return;

            string prop = propidTB.Text;

            clearModal();
            setPropID(Convert.ToInt32(prop));
            lblModalTitle.Text = "Recibos pendientes";
            lblModalBody.Text = "Recibos pendientes de la propiedad: " + prop;

            this.gridModal.DataSource = Cliente.getComprobantes(Cliente.CURRENTPROPERTY);
            this.gridModal.DataBind();

            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "myModal", "$('#myModal').modal();", true);
            upModal.Update();
        }
    }
}