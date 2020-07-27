using Muni.Classes;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
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
        protected void Page_Load(object sender, EventArgs e)
        {
            currentProp = Cliente.CURRENTPROPERTY;
            if (!Page.IsPostBack)
            {
                welcomeLbl.Text = "Recibos pendientes de la propiedad: " + currentProp;
                reloadGridView();
            }

        }

        protected void reloadGridView()
        {
            btnPay.Visible = false;
            DataTable table = Cliente.getRecibosPendientes(currentProp);
            if (table != null && table.Rows.Count > 0)
            {
                gridView.Visible = true;
                btnPay.Visible = true;
                lblLead.Text = "Seleccione los recibos que desea pagar";
                gridView.DataSource = table;
                gridView.DataBind();
                setIDVisibility(false);
            }
            else {
                lblLead.Text = "Esta propiedad no tiene recibos pendientes.";
                gridView.Visible = false;
            }
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            Cliente.clearCurrentProperty();
            Response.Redirect("ClientPanel.aspx");
        }

        protected void btnPay_Click(object sender, EventArgs e)
        {
            DataTable selectedData = getGridData();
            processPayment(selectedData);

            //For debugging purposes.
            //g2.DataSource = selectedData;
            //g2.DataBind();
        }

        protected DataTable getGridData()
        {
            setIDVisibility(true);
            DataTable dt = new DataTable();
            //i starts in 1 to omit the checkbox column
            for (int i = 1; i < gridView.Columns.Count; i++)
            {
                dt.Columns.Add("column" + i.ToString());
            }
            foreach (GridViewRow row in gridView.Rows)
            {
                var checkbox = row.FindControl("cbGv") as CheckBox;
                if (checkbox.Checked)
                {
                    DataRow dr = dt.NewRow();
                    for (int j = 1; j < gridView.Columns.Count; j++)
                    {
                        dr["column" + j.ToString()] = row.Cells[j].Text;
                    }

                    dt.Rows.Add(dr);
                }
            }
            prepareTable(dt);
            return dt;
        }

        //This function ensured that you cant pay newer receipts if old ones arent payed yet.
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

        protected void processPayment(DataTable inputTable)
        {
            bool validationStatus = validateReceiptOrder(inputTable);
            if (checkIfAllCB_Empty())
            {
                MessageBox.Show("No puede pagar si no ha seleccionado recibos.");
                return;
            }
            else if (validationStatus)
            {
                excecutePayment(inputTable);
                reloadGridView();
                MessageBox.Show("Recibos pagados exitosamente.");
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
                    parameter.TypeName = "dbo.udt_Recibo";

                    command.ExecuteNonQuery();
                }
                connection.Close();
            }
        }


        protected void setIDVisibility(bool val)
        {
            gridView.Columns[1].Visible = val;
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

        //Renames the columns of the table so they can be sent and understood by the database.
        protected void prepareTable(DataTable input)
        {
            input.Columns["column1"].ColumnName = "id";
            input.Columns["column2"].ColumnName = "numPropiedad";
            input.Columns["column3"].ColumnName = "conceptoCobro";
            input.Columns["column4"].ColumnName = "fecha";
            input.Columns["column5"].ColumnName = "fechaVence";
            input.Columns["column6"].ColumnName = "montoTotal";
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
    }
}