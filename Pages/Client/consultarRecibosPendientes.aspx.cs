using Muni.Classes;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Muni.Pages.Client
{
    public partial class consultarRecibosPendientes : System.Web.UI.Page
    {
        int currentProp;
        protected void Page_Load(object sender, EventArgs e)
        {
            currentProp = Cliente.CURRENTPROPERTY;
            welcomeLbl.Text = "Recibos pendientes de la propiedad: " + currentProp;
            reloadGridView();
        }

        protected void reloadGridView()
        {
            btnPay.Visible = false;
            DataTable table = Cliente.getRecibosPendientes(currentProp);
            if (table != null && table.Rows.Count > 0)
            {
                btnPay.Visible = true;
                lblLead.Text = "Seleccione los recibos que desea pagar";
                gridView.DataSource = table;
                gridView.DataBind();
            }
            else
                lblLead.Text = "Esta propiedad no tiene recibos pendientes.";
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            Cliente.clearCurrentProperty();
            Response.Redirect("ClientPanel.aspx");
        }

        protected void btnPay_Click(object sender, EventArgs e)
        {

        }
    }
}