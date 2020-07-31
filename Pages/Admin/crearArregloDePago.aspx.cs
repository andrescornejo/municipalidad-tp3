using Muni.Classes;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Caching;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Muni.Pages.Admin
{
    public partial class crearArregloDePago : System.Web.UI.Page
    {
        string currentUser;
        string currentProp;
        string montoTotal;

        #region PageLoadMethods
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Page.IsPostBack)
            {
                
            }
            if (!Page.IsPostBack)
            {
                lblDisplay.Text = "Crear un arreglo de pago.";
                masterLoad();
            }
        }

        protected void masterLoad()
        {
            ////User and property are selected.
            if (ViewState["user"] != null && ViewState["prop"] != null)
            {

            }
            //User is selected.
            else if (ViewState["user"] != null && ViewState["prop"] == null)
            {
                currentUser = ViewState["user"].ToString();
                loadUsers();
                setUser(currentUser);
                loadProperties(currentUser);
                setPageToPropetySelect();
                //System.Diagnostics.Debug.WriteLine("selected user: " + currentUser);
            }
            //Nothing is selected.
            else
            {
                loadUsers();
                setPageToUserSelect();
            }
        }

        #endregion

        #region LayoutChangingMethods

        protected void setPageToUserSelect()
        {
            lblInstruct.Text = "Seleccione un usuario.";
            btnAbort.Visible = false;
            btnCancel.Visible = false;
            btnSetProp.Visible = false;
            ddlProp.Visible = false;
            lblProperties.Visible = false;
            lblGrid.Visible = false;
            gridView.Visible = false;
            btnConsultRates.Visible = false;
        }

        protected void setPageToPropetySelect()
        {
            lblInstruct.Text = "Seleccione la propiedad del usuario.";
            btnSetUser.Visible = false;
            ddlUsers.Enabled = false;
            btnCancel.Visible = true;
            btnSetProp.Visible = true;
            ddlProp.Visible = true;
            lblProperties.Visible = true;
            lblGrid.Visible = false;
            gridView.Visible = false;
            btnConsultRates.Visible = false;
        }

        protected void setPageToDisplayGrid()
        {
            lblInstruct.Text = "Defina los términos del arreglo de pago.";
            btnSetUser.Visible = false;
            ddlUsers.Enabled = false;
            btnCancel.Visible = false;
            btnSetProp.Visible = false;
            ddlProp.Enabled = false;
            lblGrid.Text = "Recibos pendientes de la propiedad: " + currentProp;
            lblGrid.Visible = true;
            gridView.Visible = true;
            btnConsultRates.Visible = true;
        }

        #endregion

        #region DatabaseMethods

        protected void loadUsers()
        {
            ddlUsers.Enabled = true;

            DataTable dt = new DataTable();

            using (SqlConnection con = Globals.getConnection())
            {

                try
                {
                    SqlDataAdapter adapter = new SqlDataAdapter("SELECT username FROM dbo.Usuario", con);
                    adapter.Fill(dt);

                    ddlUsers.DataSource = dt;
                    ddlUsers.DataTextField = "username";
                    ddlUsers.DataBind();
                }
                catch (Exception ex)
                {
                    MessageBox.Show("Error al consultar usuarios.\n" + ex.Message);
                    ddlUsers.Enabled = false;
                }

            }

            ddlUsers.Items.Insert(0, new ListItem("<Seleccionar usuario>", "0"));

        }

        protected void loadProperties(string username)
        {
            ddlProp.Enabled = true;

            DataTable dt = new DataTable();

            using (SqlConnection con = Globals.getConnection())
            {

                try
                {
                    SqlDataAdapter sqlda = new SqlDataAdapter("csp_getPropiedadesDeUsuario", con);
                    sqlda.SelectCommand.CommandType = CommandType.StoredProcedure;
                    //Agregar los parametros
                    sqlda.SelectCommand.Parameters.AddWithValue("@usernameInput", username);
                    con.Open();
                    sqlda.Fill(dt);
                    con.Close();

                    ddlProp.DataSource = dt;
                    ddlProp.DataTextField = "# Propiedad";
                    ddlProp.DataBind();
                }
                catch (Exception ex)
                {
                    MessageBox.Show("Error al consultar propiedades del usuario.\n" + ex.Message);
                    ddlProp.Enabled = false;
                }

            }

            ddlProp.Items.Insert(0, new ListItem("<Seleccionar propiedad>", "0"));

        }

        protected void loadReceipts(int prop)
        {
            using (SqlConnection connection = Globals.getConnection())
            {
                using (SqlCommand cmd = connection.CreateCommand())
                {
                    SqlDataAdapter da = new SqlDataAdapter();
                    DataTable dt = new DataTable();

                    cmd.CommandText = "csp_adminRecibosPendientes";
                    cmd.CommandType = CommandType.StoredProcedure;

                    SqlParameter parameter = cmd.Parameters.AddWithValue("@inNumProp", prop);

                    cmd.Parameters.Add("@montoTotal", SqlDbType.Money).Direction = ParameterDirection.Output;
                    connection.Open();
                    da.SelectCommand = cmd;
                    da.Fill(dt);
                    ViewState["monto"] = cmd.Parameters["@montoTotal"].Value;
                    montoTotal = ViewState["monto"].ToString();

                    connection.Close();
                    gridView.DataSource = dt;
                    gridView.DataBind();
                }
            }
        }

        #endregion

        #region ButtonEvents

        protected void btnSetUser_Click(object sender, EventArgs e)
        {
            string user = ddlUsers.SelectedItem.Text;
            if (user == "<Seleccionar usuario>")
                MessageBox.Show("No ha seleccionado un usuario. Inténtelo de nuevo");
            else
            {
                setUser(user);
                loadProperties(user);
                setPageToPropetySelect();
            }

        }

        protected void btnSetProp_Click(object sender, EventArgs e)
        {
            string user = ddlUsers.SelectedItem.Text;
            string prop = ddlProp.SelectedItem.Text;
            int intProp;
            bool parseRes = Int32.TryParse(prop,out intProp);

            if (user == "<Seleccionar propiedad>")
                MessageBox.Show("No ha seleccionado un usuario. Inténtelo de nuevo");
            else if (!parseRes)
                MessageBox.Show("Error al guardar el número de propiedad.");
            else
            {
                setUser(user);
                setProperty(prop);
                loadReceipts(intProp);
                setPageToDisplayGrid();
            }
        }
        protected void btnConsultRates_Click(object sender, EventArgs e)
        {

        }
        protected void btnCancel_Click(object sender, EventArgs e)
        {
            reloadPage();
        }

        protected void btnAbort_Click(object sender, EventArgs e)
        {

        }

        #endregion

        #region MiscMethods

        private void reloadPage()
        {
            Response.Redirect(Request.RawUrl);
            //this.Response.Redirect(this.Request.Url.AbsoluteUri, false);
        }

        protected void setUser(string user)
        {
            ViewState["user"] = user;
            currentUser = ViewState["user"].ToString();
            ddlUsers.SelectedValue = currentUser;
        }

        protected void setProperty(string numProp)
        {
            ViewState["prop"] = numProp;
            currentProp = ViewState["prop"].ToString();
            ddlProp.SelectedValue = currentProp;
        }


        #endregion


    }
}