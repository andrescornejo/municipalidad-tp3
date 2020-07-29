using Muni.Classes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Muni.Pages.Client
{
    public partial class consultarComprobantes : System.Web.UI.Page
    {
        int currentProp;
        protected void Page_Load(object sender, EventArgs e)
        {
            //Maintain the current propery every time the page is loaded.
            currentProp = Cliente.CURRENTPROPERTY;
            //Only reload the labels and the gridview if the type off callback recieved is not postback.
            if (!Page.IsPostBack)
            {
                welcomeLbl.Text = "Comprobantes de recibos de la propiedad: " + currentProp;
                //reloadGridView();
            }
        }

        protected void btnBack_Click(object sender, EventArgs e)
        {
            Cliente.clearCurrentProperty();
            Response.Redirect("ClientPanel.aspx");
        }
    }
}