using Muni.Classes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Muni.Pages.Client
{
    public partial class ClientPanelUC : System.Web.UI.UserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void logoutBtn_Click(object sender, EventArgs e)
        {
            Globals.logoutUser();
            Cliente.clearCurrentProperty();
            Response.Redirect("../LoginPage.aspx");
        }

        public void alertMsg(string msg)
        {
            lblAlert.Text = msg;
            this.alertDiv.Visible = true;
        }

        public void successMsg(string msg)
        {
            lblSucc.Text = msg;
            this.successDiv.Visible = true;
        }
    }
}