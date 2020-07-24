using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Muni.Pages
{
    public partial class crudTables : System.Web.UI.Page
    {
        string usernameGot;
        protected void Page_Load(object sender, EventArgs e)
        {
            usernameGot = Request.QueryString["username"];
        }
        protected void backBtn_Click(object sender, EventArgs e)
        {
            Response.Redirect("AdminPage.aspx?username=" + usernameGot);
        }
        protected void crudPropietariosBtn_Click(object sender, EventArgs e)
        {
            Response.Redirect("propietariosCRUD.aspx?username=" + usernameGot);
        }
        protected void crudPropiedadesBtn_Click(object sender, EventArgs e)
        {
            Response.Redirect("propiedadesCRUD.aspx?username=" + usernameGot);
        }
        protected void crudUsuariosBtn_Click(object sender, EventArgs e)
        {
            Response.Redirect("usuariosCRUD.aspx?username=" + usernameGot);
        }
    }
}