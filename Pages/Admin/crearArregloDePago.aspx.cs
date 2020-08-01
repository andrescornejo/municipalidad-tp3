using Muni.Classes;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
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
        string cuotaMensual;

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
            btnCancel.Visible = false;
            btnAbort.Visible = false;

            btnSetProp.Visible = false;
            ddlProp.Visible = false;
            lblProperties.Visible = false;
            lblGrid.Visible = false;
            gridView.Visible = false;
            btnConsultRates.Visible = false;

            lblPlazo.Visible = false;
            tbPlazo.Visible = false;
            lblMontoDesc.Visible = false;
            lblMontoTotal.Visible = false;
            lblCuotaDesc.Visible = false;
            lblCuotaTotal.Visible = false;
            btnCreateAP.Visible = false;
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

            btnAbort.Visible = true;
            lblPlazo.Visible = true;
            tbPlazo.Visible = true;
            lblMontoDesc.Visible = true;
            lblMontoTotal.Visible = true;
            lblMontoTotal.Text = "CRC " + ViewState["monto"].ToString();
        }

        protected void setPageToFinalStep()
        {
            lblInstruct.Text = "Cree el arreglo de pago, o edite la cantidad de cuotas.";
            lblCuotaDesc.Visible = true;
            lblCuotaTotal.Text = "CRC " + ViewState["cuota"].ToString();
            lblCuotaTotal.Visible = true;
            btnCreateAP.Visible = true;
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
                    cuotaMensual = ViewState["monto"].ToString();

                    connection.Close();
                    gridView.DataSource = dt;
                    gridView.DataBind();
                }
            }
        }

        protected void calculateFees(string monto, string plazo)
        {
            using (SqlConnection connection = Globals.getConnection())
            {
                SqlCommand command = new SqlCommand("csp_consultaCuotaAP", connection);
                command.CommandType = CommandType.StoredProcedure;

                command.Parameters.Add(new SqlParameter("@inMontoAP", monto));
                command.Parameters.Add(new SqlParameter("@inPlazo", plazo));

                command.Parameters.Add("@outCuotaAP", SqlDbType.Money).Direction = ParameterDirection.Output;

                connection.Open();
                command.ExecuteNonQuery();
                ViewState["cuota"] = command.Parameters["@outCuotaAP"].Value;
                cuotaMensual = ViewState["cuota"].ToString();
                connection.Close();
            }
        }

        protected void createAP(string monto, string plazo, string cuota, string admin, string numProp)
        {
            using (SqlConnection connection = Globals.getConnection())
            {
                SqlCommand command = new SqlCommand("csp_adminCrearAP", connection);
                command.CommandType = CommandType.StoredProcedure;

                command.Parameters.Add(new SqlParameter("@inNumFinca", numProp));
                command.Parameters.Add(new SqlParameter("@inMontoTotal", monto));
                command.Parameters.Add(new SqlParameter("@inPlazo", plazo));
                command.Parameters.Add(new SqlParameter("@inCuota", cuota));
                command.Parameters.Add(new SqlParameter("@inUserName", admin));

                connection.Open();
                command.ExecuteNonQuery();
                connection.Close();
            }
        }

        protected void abortAP()
        {
            DataTable dt = getGridViewIDs();
            using (SqlConnection connection = Globals.getConnection())
            {
                connection.Open();
                using (SqlCommand command = connection.CreateCommand())
                {
                    command.CommandText = "dbo.csp_clienteCancelaPago";
                    command.CommandType = CommandType.StoredProcedure;

                    SqlParameter parameter;
                    parameter = command.Parameters.AddWithValue("@inTablaRecibos", dt);

                    parameter.SqlDbType = SqlDbType.Structured;
                    parameter.TypeName = "dbo.udt_idTable";

                    command.ExecuteNonQuery();
                }
                connection.Close();
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

            if (prop == "<Seleccionar propiedad>")
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
            string monto = ViewState["monto"].ToString();
            string plazo = tbPlazo.Text;
            bool validInputs = calculateFeesValidator(monto, plazo);

            if (validInputs)
            {
                calculateFees(monto, plazo);
                setPageToFinalStep();
            }
            else
                MessageBox.Show("Entradas inválidas.");

        }

        protected void btnCreateAP_Click(object sender, EventArgs e)
        {
            string prop = ViewState["prop"].ToString();
            string monto = ViewState["monto"].ToString();
            string cuota = ViewState["cuota"].ToString();
            string plazo = tbPlazo.Text;
            bool validInputs = createAPValidator(monto, plazo, cuota, prop);

            if (validInputs)
            {
                createAP(monto, plazo, cuota, Globals.CURRENTUSER, prop);
                MessageBox.Show("Arreglo de pago creado exitosamente");
                setPageToUserSelect();
            }
            else
                MessageBox.Show("Entradas inválidas.");
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            reloadPage();
        }

        protected void btnAbort_Click(object sender, EventArgs e)
        {
            abortAP();
            reloadPage();
        }

        #endregion

        #region MiscMethods

        private void reloadPage()
        {
            Response.Redirect(Request.RawUrl);
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

        protected DataTable getGridViewIDs()
        {
            DataTable dt = new DataTable();

            dt.Columns.Add("storedID");
            foreach (GridViewRow row in gridView.Rows)
            {
                DataRow dr = dt.NewRow();
                dr["storedID"] = row.Cells[0].Text;
                dt.Rows.Add(dr);
            }
            return dt;
        }

        protected bool calculateFeesValidator(string inMonto, string inPlazo)
        {
            double monto;
            int plazo;
            bool resMonto = Double.TryParse(inMonto, out monto);
            bool resPlazo = Int32.TryParse(inPlazo, out plazo);
            if(!resMonto || !resPlazo) 
                return false;

            if(monto < 0)
                return false;
            if (plazo <= 0)
                return false;
            else
                return true;
        }

        protected bool createAPValidator(string inMonto, string inPlazo, string inCuota, string inProp)
        {
            double monto, cuota;
            int plazo, prop;
            bool resMonto = Double.TryParse(inMonto, out monto);
            bool resCuota = Double.TryParse(inCuota, out cuota);
            bool resPlazo = Int32.TryParse(inPlazo, out plazo);
            bool resProp = Int32.TryParse(inProp, out prop);
            if (!resMonto || !resPlazo || !resCuota || !resProp)
                return false;

            if (monto < 0)
                return false;
            if (plazo <= 0)
                return false;
            if (cuota < 0)
                return false;
            else
                return true;
        }

        #endregion
    }
}