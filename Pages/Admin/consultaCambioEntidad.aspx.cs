using Muni.Classes;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Muni.Pages.Admin
{
    public partial class consultaCambioEntidad : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            this.welcomeLbl.Text = "Ver cambios a entidades.";
        }

        protected void verCambiosBtn_Click(object sender, EventArgs e)
        {
            if(tb_FormerDate.Text.Length!=0 && tb_LatterDate.Text.Length != 0) {
                clearGridTipoEntidad();
                string te = dropTipoEntidad.SelectedValue;
                string fa = tb_FormerDate.Text;
                string fd = tb_LatterDate.Text;

                this.gridTipoEntidad.DataSource = AdminWeb.getBitacoraEntidad(te, fa, fd);
                
                this.gridTipoEntidad.DataBind();
                this.gridTipoEntidad.Columns[1].Visible = false;
            }
        }

        //gridLink_Clicked opens up a modal to view more specific information about the selected entity.
        protected void gridLink_Clicked(object sender, EventArgs e)
        {
            
            //Setting needed data for the modal.
            string spJsonA = "csp_getJsonAntes";
            string spJsonD = "csp_getJsonDespues";
            string tmpString = gridTipoEntidad.SelectedRow.Cells[1].Text;
            string modalTitle = gridTipoEntidad.SelectedRow.Cells[2].Text;
            int idBitacora = Convert.ToInt32(tmpString);
            //Getting the JSON from the database.
            string jsonAntes = AdminWeb.getJsonBitacora(idBitacora, spJsonA);
            string jsonDespues = AdminWeb.getJsonBitacora(idBitacora, spJsonD);

            setupModal(jsonAntes, jsonDespues, modalTitle);

            //Display the modal.
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "myModal", "$('#myModal').modal();", true);
            upModal.Update();

        }

        public void setupModal(string jsonAntes, string jsonDespues, string modalTitle)
        {
            //Clear the modal in case of existing previous data.
            clearModal();
            //Setting up the labels and the gridviews for the modal.
            this.lblModalTitle.Text = "Cambio a entidad tipo: " + modalTitle + ".";
            //Getting the data tables from the json.
            DataTable dataTableAntes = DerializeDataTable(jsonAntes);
            DataTable dataTableDespues = DerializeDataTable(jsonDespues);

            if (dataTableAntes != null)
            {
                this.lblJsonAntes.Text = "Entidad antes:";
                this.gridJsonAntes.DataSource = dataTableAntes;
                this.gridJsonAntes.DataBind();
            }
            else
                this.lblJsonAntes.Text = "Entidad antes: No existe."; //divJsonAntes.Visible = false;
            if (dataTableDespues != null)
            {
                this.lblJsonDespues.Text = "Entidad después:";
                this.gridJsonDespues.DataSource = dataTableDespues;
                this.gridJsonDespues.DataBind();
            }
            else
                this.lblJsonDespues.Text = "Entidad después: Borrada.";
                

        }

        public DataTable DerializeDataTable(string json)
        {
            dynamic dataSet = JsonConvert.DeserializeObject<DataSet>(json);
            if(dataSet == null) { 
                return null;
            }
            else
            {
                var table = dataSet.Tables[0];
                return table;
            }
        }

        protected void clearGridTipoEntidad()
        {
            this.gridTipoEntidad.Columns[1].Visible = true;
            gridTipoEntidad.DataSource = null;
            gridTipoEntidad.DataBind();
        }

        protected void clearModal()
        {
            lblJsonAntes.Text = "";
            lblJsonDespues.Text = "";
            gridJsonAntes.DataSource = null;
            gridJsonAntes.DataBind();
            gridJsonDespues.DataSource = null;
            gridJsonDespues.DataBind();
        }
    }
}