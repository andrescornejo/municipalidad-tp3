using Muni.Classes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Muni.Pages
{
    public partial class propietariosCRUD : System.Web.UI.Page
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
            Response.Redirect("crudTables.aspx?username=" + usernameGot);
        }

        protected void createPropietariosBtn_Click(object sender, EventArgs e)
        {
            Response.Redirect("propietariosCreate.aspx?username=" + usernameGot);
        }
        protected void updatePropietariosBtn_Click(object sender, EventArgs e)
        {
            Response.Redirect("propietariosUpdate.aspx?username=" + usernameGot);
        }
        protected void deletePropietariosBtn_Click(object sender, EventArgs e)
        {
            Response.Redirect("propietariosDelete.aspx?username=" + usernameGot);
        }

    }
}