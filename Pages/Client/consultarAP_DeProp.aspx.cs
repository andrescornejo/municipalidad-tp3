using Muni.Classes;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Muni.Pages.Client
{
    public partial class consultarAP_DeProp : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                lblDisplay.Text = "Consulta de arreglo de pago para la propiedad: " + Cliente.CURRENTPROPERTY;
                loadData();
            }
        }

        protected void loadData()
        {
            DataTable dt = loadAPData();
            
            if (dt != null)
            {
                if (dt.Rows.Count == 0)
                {
                    lblLead.Text = "Esta propiedad no tiene un arreglo de pago asociado.";
                    lblMovAP.Visible = false;
                    gridAP.Visible = false;
                    gridMovAP.Visible = false;
                    divMovAP.Visible = false;
                }
                else
                {
                    lblLead.Text = "Último arreglo de pago de la propiedad.";
                    lblMovAP.Text = "Movimientos de este arreglo de pago: ";

                    gridAP.DataSource = dt;
                    gridAP.DataBind();

                    DataTable mov = loadAPMovements(getAPID());
                    gridMovAP.DataSource = mov;
                    gridMovAP.DataBind();
                    gridMovAP.Columns[0].Visible = false;
                }
            }
        }

        protected DataTable loadAPData()
        {
            SqlConnection connection = Globals.getConnection();
            DataTable datatable = new DataTable();

            SqlDataAdapter sqlda = new SqlDataAdapter("csp_getAPFromNumFinca", connection);
            sqlda.SelectCommand.CommandType = CommandType.StoredProcedure;
            sqlda.SelectCommand.Parameters.AddWithValue("@inNumFinca", Cliente.CURRENTPROPERTY);

            connection.Open();
            sqlda.Fill(datatable);
            connection.Close();

            return datatable;
        }

        protected string getAPID()
        {
            gridAP.Columns[0].Visible = true;
            GridViewRow row = gridAP.Rows[0];
            string val = row.Cells[0].Text;
            gridAP.Columns[0].Visible = false;

            return val;
        }

        protected DataTable loadAPMovements(string apid)
        {
            SqlConnection connection = Globals.getConnection();
            DataTable datatable = new DataTable();

            SqlDataAdapter sqlda = new SqlDataAdapter("csp_getMovAPFromAP", connection);
            sqlda.SelectCommand.CommandType = CommandType.StoredProcedure;
            sqlda.SelectCommand.Parameters.AddWithValue("@inIdAP", apid);

            connection.Open();
            sqlda.Fill(datatable);
            connection.Close();

            return datatable;
        }

        protected void btnBack_Click(object sender, EventArgs e)
        {
            Cliente.clearCurrentProperty();
            Response.Redirect("ClientPanel.aspx");
        }
    }
}