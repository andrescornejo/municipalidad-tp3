using Muni.Properties;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Web;
using System.Web.UI.WebControls;

namespace Muni.Classes
{
    public static class Globals
    {
        #region LoginMethods
        //TODO
        //Login info will be stored here. Not really safe, but safety doesn't matter in this case.
        private static string cURRENTUSER = "b"; //""
        private static bool iSADMIN = false;
        private static int uSERID = 2; //-1
        private static string cURRENTIP = "MOTHERRUSSIA";

        public static string CURRENTPANEL = "create"; //Can be set to create, update, or delete.

        public static string CURRENTUSER { get => cURRENTUSER; set => cURRENTUSER = value; }
        public static bool ISADMIN { get => iSADMIN; set => iSADMIN = value; }
        public static int USERID { get => uSERID; set => uSERID = value; }
        public static string CURRENTIP { get => cURRENTIP; set => cURRENTIP = value; }

        public static void setUser(string username, bool isAdmin)
        {
            CURRENTUSER = username;
            ISADMIN = isAdmin;
            getUserID();
            CURRENTIP = getLocalIPAddress();
        }

        //Metodo para el login
        public static int login(string username, string password)
        {
            //Pido conexion
            SqlConnection connection = getConnection();

            //Preparar el comando
            SqlCommand command = new SqlCommand("spLogin", connection);

            //Especificar que es un sp
            command.CommandType = CommandType.StoredProcedure;

            //Agregar los parametros
            command.Parameters.Add(new SqlParameter("@usernameInput", username));
            command.Parameters.Add(new SqlParameter("@passwordInput", password));

            var returnValue = command.Parameters.Add("@ReturnVal", SqlDbType.Int);
            returnValue.Direction = ParameterDirection.ReturnValue;

            //Abro la conexion
            connection.Open();
            //Ejecuto el comando
            command.ExecuteNonQuery();
            //Cierro la conexion
            connection.Close();

            return (int)returnValue.Value;
        }

        public static void logoutUser()
        {
            CURRENTUSER = "";
            ISADMIN = false;
            USERID = -1;
            CURRENTIP = "";
        }

        public static void getUserID()
        {
            //Prepare db connection.
            SqlConnection connection = getConnection();
            //Prepare the command.
            SqlCommand cmd = new SqlCommand("csp_getUserIDFromUsername", connection);
            cmd.CommandType = CommandType.StoredProcedure;
            //Declare the sp's return values.
            cmd.Parameters.Add(new SqlParameter("@inputUsername", CURRENTUSER));
            cmd.Parameters.Add("@outputID", SqlDbType.Int).Direction = ParameterDirection.Output;
            //Open the db connection.
            connection.Open();
            //Excecute the sp.
            cmd.ExecuteNonQuery();
            //Set the return value.
            int spOutput = Convert.ToInt32(cmd.Parameters["@outputID"].Value);
            //Close the connection to the db.
            connection.Close();
            //Set the return value as the session's user ID.
            USERID = spOutput;
        }

        public static string getLocalIPAddress()
        {
            string localIP;
            using (Socket socket = new Socket(AddressFamily.InterNetwork, SocketType.Dgram, 0))
            {
                socket.Connect("8.8.8.8", 65530);
                IPEndPoint endPoint = socket.LocalEndPoint as IPEndPoint;
                localIP = endPoint.Address.ToString();
            }
            return localIP;
        }



        #endregion

        #region DatabaseMethods
        //The connection string is stored here.

        public static string CONNECTIONSTRING = Properties.Resources.CONNECTIONSTRING;

        public static SqlConnection getConnection()
        {
            return new SqlConnection(CONNECTIONSTRING);
        }

        

        public static DataTable getPropietarios()
        {
            //Pido conexion
            SqlConnection connection = getConnection();

            //Variable que guarda la tabla resultante del sp
            DataTable datatable = new DataTable();

            //Preparo el SqlDataAdapter
            SqlDataAdapter sqlda = new SqlDataAdapter("csp_getPropietarios", connection);
            sqlda.SelectCommand.CommandType = CommandType.StoredProcedure;

            //Abro la conexion
            connection.Open();

            //Ejecuto y guardo la tabla en la variable
            sqlda.Fill(datatable);

            //Cierro la conexion
            connection.Close();

            return datatable;
        }

        public static DataTable getPropiedadesDePropietario(string id)
        {
            //Pido conexion
            SqlConnection connection = getConnection();

            //Variable que guarda la tabla resultante del sp
            DataTable datatable = new DataTable();
            
            //Preparo el SqlDataAdapter
            SqlDataAdapter sqlda = new SqlDataAdapter("csp_getPropiedadesDePropietario", connection);
            sqlda.SelectCommand.CommandType = CommandType.StoredProcedure;

            //Agregar los parametros
            sqlda.SelectCommand.Parameters.AddWithValue("@idInput", id);

            //Abro la conexion
            connection.Open();

            //Ejecuto y guardo la tabla en la variable
            sqlda.Fill(datatable);

            //Cierro la conexion
            connection.Close();

            return datatable;
        }

        public static DataTable getPropiedades()
        {
            //Pido conexion
            SqlConnection connection = getConnection();

            //Variable que guarda la tabla resultante del sp
            DataTable datatable = new DataTable();

            //Preparo el SqlDataAdapter
            SqlDataAdapter sqlda = new SqlDataAdapter("csp_getPropiedades", connection);
            sqlda.SelectCommand.CommandType = CommandType.StoredProcedure;

            //Abro la conexion
            connection.Open();

            //Ejecuto y guardo la tabla en la variable
            sqlda.Fill(datatable);

            //Cierro la conexion
            connection.Close();

            return datatable;
        }

        public static DataTable getUsuarios()
        {
            //Pido conexion
            SqlConnection connection = getConnection();

            //Variable que guarda la tabla resultante del sp
            DataTable datatable = new DataTable();

            //Preparo el SqlDataAdapter
            SqlDataAdapter sqlda = new SqlDataAdapter("csp_getUsuarios", connection);
            sqlda.SelectCommand.CommandType = CommandType.StoredProcedure;

            //Abro la conexion
            connection.Open();

            //Ejecuto y guardo la tabla en la variable
            sqlda.Fill(datatable);

            //Cierro la conexion
            connection.Close();

            return datatable;
        }

        public static DataTable getPropiedadesFromPropietarioDocID(string id)
        {
            //Pido conexion
            SqlConnection connection = getConnection();

            //Variable que guarda la tabla resultante del sp
            DataTable datatable = new DataTable();

            //Preparo el SqlDataAdapter
            SqlDataAdapter sqlda = new SqlDataAdapter("csp_getPropiedadesFromPropietarioDocID", connection);
            sqlda.SelectCommand.CommandType = CommandType.StoredProcedure;

            //Agregar los parametros
            sqlda.SelectCommand.Parameters.AddWithValue("@inputDocID", id);

            //Abro la conexion
            connection.Open();

            //Ejecuto y guardo la tabla en la variable
            sqlda.Fill(datatable);

            //Cierro la conexion
            connection.Close();

            return datatable;
        }

        public static DataTable getPropietariosFromNumFinca(string numFinca)
        {
            //Pido conexion
            SqlConnection connection = getConnection();

            //Variable que guarda la tabla resultante del sp
            DataTable datatable = new DataTable();

            //Preparo el SqlDataAdapter
            SqlDataAdapter sqlda = new SqlDataAdapter("csp_getPropietariosFromNumFinca", connection);
            sqlda.SelectCommand.CommandType = CommandType.StoredProcedure;

            //Agregar los parametros
            sqlda.SelectCommand.Parameters.AddWithValue("@inputNumFinca", numFinca);

            //Abro la conexion
            connection.Open();

            //Ejecuto y guardo la tabla en la variable
            sqlda.Fill(datatable);

            //Cierro la conexion
            connection.Close();

            return datatable;
        }

        public static DataTable getUsuarioFromNumFinca(string numFinca)
        {
            //Pido conexion
            SqlConnection connection = getConnection();

            //Variable que guarda la tabla resultante del sp
            DataTable datatable = new DataTable();

            //Preparo el SqlDataAdapter
            SqlDataAdapter sqlda = new SqlDataAdapter("csp_getUsuarioFromNumFinca", connection);
            sqlda.SelectCommand.CommandType = CommandType.StoredProcedure;

            //Agregar los parametros
            sqlda.SelectCommand.Parameters.AddWithValue("@inputNumFinca", numFinca);

            //Abro la conexion
            connection.Open();

            //Ejecuto y guardo la tabla en la variable
            sqlda.Fill(datatable);

            //Cierro la conexion
            connection.Close();

            return datatable;
        }

        public static DataTable getUsuariosDeLaPropiedad(string id)
        {
            //Pido conexion
            SqlConnection connection = getConnection();

            //Variable que guarda la tabla resultante del sp
            DataTable datatable = new DataTable();

            //Preparo el SqlDataAdapter
            SqlDataAdapter sqlda = new SqlDataAdapter("csp_getPropiedadesDeUsuario", connection);
            sqlda.SelectCommand.CommandType = CommandType.StoredProcedure;

            //Agregar los parametros
            sqlda.SelectCommand.Parameters.AddWithValue("@usernameInput", id);

            //Abro la conexion
            connection.Open();

            //Ejecuto y guardo la tabla en la variable
            sqlda.Fill(datatable);

            //Cierro la conexion
            connection.Close();

            return datatable;
        }

        public static DataTable getUsernames()
        {
            //Pido conexion
            SqlConnection connection = getConnection();

            //Variable que guarda la tabla resultante del sp
            DataTable datatable = new DataTable();

            //Preparo el SqlDataAdapter
            SqlDataAdapter sqlda = new SqlDataAdapter("csp_getUsernames", connection);
            sqlda.SelectCommand.CommandType = CommandType.StoredProcedure;

            //Abro la conexion
            connection.Open();

            //Ejecuto y guardo la tabla en la variable
            sqlda.Fill(datatable);

            //Cierro la conexion
            connection.Close();

            return datatable;
        }

        public static void addUser(string user, string pass, bool isadmin)
        {
            //Pido conexion
            SqlConnection connection = getConnection();

            //Preparo el comando
            SqlCommand cmd = new SqlCommand("csp_adminAddUser", connection);
            cmd.CommandType = CommandType.StoredProcedure;

            //Agregar los parametros
            cmd.Parameters.AddWithValue("@inputUsername", user);
            cmd.Parameters.AddWithValue("@inputPasswd", pass);
            cmd.Parameters.AddWithValue("@inputBit", isadmin);

            //Abro la conexion
            connection.Open();

            //Ejecuto el SP
            int rowAffected = cmd.ExecuteNonQuery();
       
            //Cierro la conexion
            connection.Close();
        }

        public static void addPropietario(string name, string docID, string docIDVal)
        {
            //Pido conexion
            SqlConnection connection = getConnection();

            //Preparo el comando
            SqlCommand cmd = new SqlCommand("csp_adminAddPropietario", connection);
            cmd.CommandType = CommandType.StoredProcedure;

            //Agregar los parametros
            cmd.Parameters.AddWithValue("@inputName", name);
            cmd.Parameters.AddWithValue("@inputDocIDVal", docID);
            cmd.Parameters.AddWithValue("@inputDocID", docIDVal);

            //Abro la conexion
            connection.Open();

            //Ejecuto el SP
            int rowAffected = cmd.ExecuteNonQuery();

            //Cierro la conexion
            connection.Close();
        }

        public static void deletePropietario(string docID)
        {
            //Pido conexion
            SqlConnection connection = getConnection();

            //Preparo el comando
            SqlCommand cmd = new SqlCommand("csp_adminDeletePropietario", connection);
            cmd.CommandType = CommandType.StoredProcedure;

            //Agregar los parametros
            cmd.Parameters.AddWithValue("@InputDocID", docID);

            //Abro la conexion
            connection.Open();

            //Ejecuto el SP
            int rowAffected = cmd.ExecuteNonQuery();

            //Cierro la conexion
            connection.Close();
        }

        public static void deleteUsuario(string username)
        {
            //Pido conexion
            SqlConnection connection = getConnection();

            //Preparo el comando
            SqlCommand cmd = new SqlCommand("csp_adminDeleteUsuario", connection);
            cmd.CommandType = CommandType.StoredProcedure;

            //Agregar los parametros
            cmd.Parameters.AddWithValue("@usuarioIDInput", username);

            //Abro la conexion
            connection.Open();

            //Ejecuto el SP
            int rowAffected = cmd.ExecuteNonQuery();

            //Cierro la conexion
            connection.Close();
        }

        public static void addPropiedad(int numFinca, int valor, string dir)
        {
            //Pido conexion
            SqlConnection connection = getConnection();

            //Preparo el comando
            SqlCommand cmd = new SqlCommand("csp_adminAddPropiedades", connection);
            cmd.CommandType = CommandType.StoredProcedure;

            //Agregar los parametros
            cmd.Parameters.AddWithValue("@inputNumFinca", numFinca);
            cmd.Parameters.AddWithValue("@inputValorFinca", valor);
            cmd.Parameters.AddWithValue("@inputDir", dir);

            //Abro la conexion
            connection.Open();

            //Ejecuto el SP
            int rowAffected = cmd.ExecuteNonQuery();

            //Cierro la conexion
            connection.Close();
        }
        public static void deletePropiedad(int numFinca)
        {
            //Pido conexion
            SqlConnection connection = getConnection();

            //Preparo el comando
            SqlCommand cmd = new SqlCommand("csp_adminDeletePropiedad", connection);
            cmd.CommandType = CommandType.StoredProcedure;

            //Agregar los parametros
            cmd.Parameters.AddWithValue("@numFincaInput", numFinca);

            //Abro la conexion
            connection.Open();

            //Ejecuto el SP
            int rowAffected = cmd.ExecuteNonQuery();

            //Cierro la conexion
            connection.Close();
        }

        #endregion
    }
}