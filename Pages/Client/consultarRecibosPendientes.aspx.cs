using Microsoft.SqlServer.Server;
using Muni.Classes;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using System.Drawing.Printing;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Muni.Pages.Client
{

    public partial class consultarRecibosPendientes : System.Web.UI.Page
    {
        int currentProp;
        double montoTotal;
        protected void Page_Load(object sender, EventArgs e)
        {
            if (ViewState["Monto"] != null)
                montoTotal = Convert.ToDouble(ViewState["Monto"].ToString());
            else
                ViewState["Monto"] = -1;
            //This is needed to make the buttons inside the modal excecute server side code and close the modal.
            ScriptManager scriptManager = ScriptManager.GetCurrent(this.Page);
            scriptManager.RegisterPostBackControl(this.btnPay);
            scriptManager.RegisterPostBackControl(this.btnCancel);
            //Maintain the current propery every time the page is loaded.
            currentProp = Cliente.CURRENTPROPERTY;
            //Only reload the labels and the gridview if the type off callback recieved is not postback.
            if (!Page.IsPostBack)
            {
                welcomeLbl.Text = "Recibos pendientes de la propiedad: " + currentProp;
                reloadGridView();
            }

        }

        #region ButtonEvents

        protected void btnBack_Click(object sender, EventArgs e)
        {
            Cliente.clearCurrentProperty();
            Response.Redirect("ClientPanel.aspx");
        }

        protected void btnConsult_Click(object sender, EventArgs e)
        {
            DataTable rawTable = getGridViewIDs();
            verifyConsultData(rawTable);

            //debugGridView(rawTable);
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            setIDVisibility(true, true);
            DataTable dt = getModalGridIDs();
            abortPayment(dt);
            setModalVisibility("myModal", false);
            MessageBox.Show("Pago de recibos abortado.");
            reloadGridView();

            //debugGridView(dt);
        }

        protected void btnPay_Click(object sender, EventArgs e)
        {
            setIDVisibility(true, true);
            DataTable dt = getModalGridIDs();
            excecutePayment(dt);          
            setModalVisibility("myModal", false);
            MessageBox.Show("Pago de recibos realizado con éxito.");
            reloadGridView();

            //debugGridView(dt);
        }

        #endregion

        #region PaymentLogic

        protected void showPendingReceipts(DataTable inputTable)
        {
            DataTable processedTable = consultPendingReceipts(inputTable);

            clearModal();
            this.gridModal.DataSource = processedTable;
            this.gridModal.DataBind();
            lblModalTitle.Text = "Pago de recibos pendientes";
            lblModalBody.Text = "Recibos pendientes de la propiedad: " + currentProp;
            lblModalTotal.Text = "Monto total a pagar: " + montoTotal;
            setIDVisibility(false, true);
            setModalVisibility("myModal", true);
        }

        protected DataTable consultPendingReceipts(DataTable inputTable)
        {
            using (SqlConnection connection = Globals.getConnection())
            {
                using (SqlCommand cmd = connection.CreateCommand())
                {
                    connection.Open();
                    SqlDataAdapter da = new SqlDataAdapter();
                    DataTable dt = new DataTable();

                    cmd.CommandText = "csp_clienteSeleccionaRecibos";
                    cmd.CommandType = CommandType.StoredProcedure;

                    SqlParameter parameter = cmd.Parameters.AddWithValue("@inRecibosIDTable", inputTable);
                    parameter.SqlDbType = SqlDbType.Structured;
                    parameter.TypeName = "dbo.udt_idTable";

                    cmd.Parameters.Add("@montoTotal", SqlDbType.Money).Direction = ParameterDirection.Output;

                    da.SelectCommand = cmd;
                    da.Fill(dt);
                    ViewState["Monto"] = cmd.Parameters["@montoTotal"].Value;
                    montoTotal = Convert.ToDouble(ViewState["Monto"].ToString());
                    
                    connection.Close();
                    return dt;
                }
            }
        }
        protected void abortPayment(DataTable input)
        {
            using (SqlConnection connection = Globals.getConnection())
            {
                connection.Open();
                using (SqlCommand command = connection.CreateCommand())
                {
                    command.CommandText = "dbo.csp_clienteCancelaPago";
                    command.CommandType = CommandType.StoredProcedure;

                    SqlParameter parameter;
                    parameter = command.Parameters.AddWithValue("@inTablaRecibos", input);

                    parameter.SqlDbType = SqlDbType.Structured;
                    parameter.TypeName = "dbo.udt_idTable";

                    command.ExecuteNonQuery();
                }
                connection.Close();
            }
        }
        protected void excecutePayment(DataTable input)
        {
            using (SqlConnection connection = Globals.getConnection())
            {
                connection.Open();
                using (SqlCommand command = connection.CreateCommand())
                {
                    command.CommandText = "dbo.csp_clientePagaRecibos";
                    command.CommandType = CommandType.StoredProcedure;

                    SqlParameter parameter;
                    parameter = command.Parameters.AddWithValue("@inTablaRecibos", input);

                    parameter.SqlDbType = SqlDbType.Structured;
                    parameter.TypeName = "dbo.udt_idTable";

                    command.ExecuteNonQuery();
                }
                connection.Close();
            }
        }

        #endregion

        #region DataManagingFunctions

        protected DataTable getGridViewIDs()
        {
            setIDVisibility(true, false);
            DataTable dt = new DataTable();

            dt.Columns.Add("column1");
            foreach (GridViewRow row in gridView.Rows)
            {
                var checkbox = row.FindControl("cbGv") as CheckBox;
                if (checkbox.Checked)
                {
                    DataRow dr = dt.NewRow();
                    dr["column1"] = row.Cells[1].Text;

                    dt.Rows.Add(dr);
                }
            }
            prepareTable(dt);
            setIDVisibility(false, false);
            return dt;
        }

        protected DataTable getModalGridIDs()
        {
            DataTable dt = new DataTable();

            dt.Columns.Add("column1");
            foreach (GridViewRow row in gridModal.Rows)
            {
                DataRow dr = dt.NewRow();
                dr["column1"] = row.Cells[0].Text;

                dt.Rows.Add(dr);
            }
            prepareTable(dt);
            return dt;
        }

        //Renames the columns of the table so they can be sent and understood by the database.
        protected void prepareTable(DataTable input)
        {
            input.Columns["column1"].ColumnName = "storedID";
        }

        #endregion

        #region LayoutChangingFunctions

        protected void reloadGridView()
        {
            btnConsult.Visible = false;
            DataTable table = Cliente.getRecibosPendientes(currentProp);
            setIDVisibility(true, false);
            if (table != null && table.Rows.Count > 0)
            {
                gridView.Visible = true;
                btnConsult.Visible = true;
                lblLead.Text = "Seleccione los recibos que desea pagar";
                gridView.DataSource = table;
                gridView.DataBind();
                setIDVisibility(false, false);
            }
            else
            {
                lblLead.Text = "Esta propiedad no tiene recibos pendientes.";
                gridView.Visible = false;
            }
        }

        protected void setIDVisibility(bool val, bool isModalGrid)
        {
            if (isModalGrid)
                gridModal.Columns[0].Visible = val;
            else
                gridView.Columns[1].Visible = val;
        }

        protected void setModalVisibility(string modalName, bool input)
        {   if(input)
                ScriptManager.RegisterStartupScript(Page, Page.GetType(), modalName, "$('#" + modalName + "').modal({ backdrop: 'static', keyboard: false});", true);
            else
                ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(), "Pop", "$('#"+modalName+"').modal('hide');", true);
        }

        protected void clearModal()
        {
            gridModal.DataSource = null;
            gridModal.DataBind();
            lblModalTitle.Text = "";
            lblModalBody.Text = "";
        }

        private void clearTable(DataTable table)
        {
            try
            {
                table.Clear();
            }
            catch (DataException e)
            {
                // Process exception and return.
                Console.WriteLine("Exception of type {0} occurred.",
                    e.GetType());
            }
        }
        #endregion

        #region ValidationFunctions
        //
        protected void verifyConsultData(DataTable inputTable)
        {
            bool validationStatus = validateReceiptOrder(inputTable);
            if (checkIfAllCB_Empty())
            {
                MessageBox.Show("No puede pagar si no ha seleccionado recibos.");
                return;
            }
            else if (validationStatus)
            {
                showPendingReceipts(inputTable);
            }
            else if (!validationStatus)
            {
                MessageBox.Show("No puede pagar recibos más recientes, sin pagar los recibos viejos primero.");
                return;
            }
            else
            {
                MessageBox.Show("Error desconocido.");
                return;
            }
        }


        //This function ensures that you cant pay newer receipts if old ones arent payed yet.
        protected bool validateReceiptOrder(DataTable newDT)
        {
            DataTable oldDT = Cliente.getRecibosPendientes(currentProp);
            for (int i = 0; i < newDT.Rows.Count; i++)
            {
                if (oldDT.Rows[i][0].ToString() != newDT.Rows[i][0].ToString())
                    return false;
            }
            return true;
        }

        //Function that returns true if all checkboxes are empty.
        protected bool checkIfAllCB_Empty()
        {

            foreach (GridViewRow row in gridView.Rows)
            {
                var checkbox = row.FindControl("cbGv") as CheckBox;
                if (checkbox.Checked)
                {
                    return false;
                }
            }
            return true;
        }

        protected void debugGridView(DataTable input)
        {

            //For debugging purposes.
            dg1.DataSource = input;
            dg1.DataBind();
        }

        #endregion
    }
}