using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace Muni.Classes
{
    public static class Cliente
    {
        #region ClientData
        private static int cURRENTPROPERTY = -1;

        public static int CURRENTPROPERTY { get => cURRENTPROPERTY; set => cURRENTPROPERTY = value; }

        public static void clearCurrentPropery() { CURRENTPROPERTY = -1; }

        #endregion

        #region ClientMethods
        public static DataTable getClientProperties(string username)
        {
            //Pido conexion
            SqlConnection connection = Globals.getConnection();

            //Variable que guarda la tabla resultante del sp
            DataTable datatable = new DataTable();

            //Preparo el SqlDataAdapter
            SqlDataAdapter sqlda = new SqlDataAdapter("csp_getPropiedadesDeUsuario", connection);
            sqlda.SelectCommand.CommandType = CommandType.StoredProcedure;

            //Agregar los parametros
            sqlda.SelectCommand.Parameters.AddWithValue("@usernameInput", username);

            //Abro la conexion
            connection.Open();

            //Ejecuto y guardo la tabla en la variable
            sqlda.Fill(datatable);

            //Cierro la conexion
            connection.Close();

            return datatable;
        }

        public static DataTable getRecibosPendientes(int propNum)
        {
            SqlConnection connection = Globals.getConnection();
            DataTable datatable = new DataTable();

            SqlDataAdapter sqlda = new SqlDataAdapter("csp_getRecibosPendientes", connection);
            sqlda.SelectCommand.CommandType = CommandType.StoredProcedure;
            sqlda.SelectCommand.Parameters.AddWithValue("@inNumFinca", propNum);

            connection.Open();
            sqlda.Fill(datatable);
            connection.Close();

            return datatable;
        }

        public static DataTable getRecibosPagados(int propNum)
        {
            SqlConnection connection = Globals.getConnection();
            DataTable datatable = new DataTable();

            SqlDataAdapter sqlda = new SqlDataAdapter("csp_getRecibosPagados", connection);
            sqlda.SelectCommand.CommandType = CommandType.StoredProcedure;
            sqlda.SelectCommand.Parameters.AddWithValue("@inNumFinca", propNum);

            connection.Open();
            sqlda.Fill(datatable);
            connection.Close();

            return datatable;
        }

        public static DataTable getComprobantes(int propNum)
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

        #endregion
    }
}