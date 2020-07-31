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
    public partial class consultarComprobantes : System.Web.UI.Page
    {
        int currentProp;
        int currentID;
        protected void Page_Load(object sender, EventArgs e)
        {
            if (ViewState["idComprobante"] != null)
                currentID = Convert.ToInt32(ViewState["idComprobante"].ToString());
            else
                ViewState["idComprobante"] = -1;
            //Maintain the current propery every time the page is loaded.
            currentProp = Cliente.CURRENTPROPERTY;
            //Only reload the labels and the gridview if the type off callback recieved is not postback.
            if (!Page.IsPostBack)
            {
                welcomeLbl.Text = "Comprobantes de pago de la propiedad: " + currentProp;
                reloadGridView();
            }
        }

        protected void btnBack_Click(object sender, EventArgs e)
        {
            Cliente.clearCurrentProperty();
            Response.Redirect("ClientPanel.aspx");
        }

        protected void reloadGridView()
        {
            DataTable table = getComprobantes(currentProp);
            if (table != null && table.Rows.Count > 0)
            {
                gridView.Visible = true;
                lblLead.Text = "Seleccione un comprobante, para ver sus recibos asociados.";
                gridView.DataSource = table;
                gridView.DataBind();
            }
            else
            {
                lblLead.Text = "Esta propiedad no tiene comprobantes.";
                gridView.Visible = false;
            }
        }

        protected void gridView_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "Select")
            {
                ViewState["idComprobante"] = e.CommandArgument.ToString();
                currentID = Convert.ToInt32(ViewState["idComprobante"].ToString());
                showReceipts(currentID);
            }
        }

        protected void showReceipts(int id)
        {
            DataTable processedTable = getRecibosAsociados(id);

            clearModal();
            this.gridModal.DataSource = processedTable;
            this.gridModal.DataBind();
            lblModalTitle.Text = "Consulta de recibos asociados a un comprobante.";
            lblModalBody.Text = "Recibos asociados al comprobante: " + currentID;
            setModalVisibility("myModal", true);
        }

        protected static DataTable getComprobantes(int propNum)
        {
            SqlConnection connection = Globals.getConnection();
            DataTable datatable = new DataTable();

            SqlDataAdapter sqlda = new SqlDataAdapter("csp_getComprobantes", connection);
            sqlda.SelectCommand.CommandType = CommandType.StoredProcedure;
            sqlda.SelectCommand.Parameters.AddWithValue("@inNumFinca", propNum);

            connection.Open();
            sqlda.Fill(datatable);
            connection.Close();

            return datatable;
        }

        protected static DataTable getRecibosAsociados(int id)
        {
            SqlConnection connection = Globals.getConnection();
            DataTable datatable = new DataTable();

            SqlDataAdapter sqlda = new SqlDataAdapter("csp_getRecibosFromComprobante", connection);
            sqlda.SelectCommand.CommandType = CommandType.StoredProcedure;
            sqlda.SelectCommand.Parameters.AddWithValue("@inID", id);

            connection.Open();
            sqlda.Fill(datatable);
            connection.Close();

            return datatable;
        }

        protected void clearModal()
        {
            gridModal.DataSource = null;
            gridModal.DataBind();
            lblModalTitle.Text = "";
            lblModalBody.Text = "";
        }

        protected void setModalVisibility(string modalName, bool input)
        {
            if (input)
                ScriptManager.RegisterStartupScript(Page, Page.GetType(), modalName, "$('#" + modalName + "').modal({ backdrop: 'static', keyboard: false});", true);
            else
                ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(), "Pop", "$('#" + modalName + "').modal('hide');", true);
        }
    }
}