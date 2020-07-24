using Muni.Classes;
using Muni.Pages;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services.Description;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Muni
{
    public partial class MainPage : System.Web.UI.Page
    {
        protected void loginBtn_Click(object sender, EventArgs e)
        {
            string usernameGot, passwordGot;

            usernameGot = this.usernameTb.Text;
            passwordGot = this.passwordTb.Text;

            if (usernameGot.Length == 0 || passwordGot.Length ==0){
                MessageBox.Show("Username or password can't be empty.");
            }
            //Invoke SP to check if user is admin or not.
            
            switch (Globals.login(usernameGot, passwordGot))
            {
                case 0:
                    Globals.setUser(usernameGot, false);
                    Response.Redirect("Client/ClientPanel.aspx");
                    break;
                    //throw new NotImplementedException("No se ha implementado el cliente");
                case 1:
                    Globals.setUser(usernameGot, true);
                    Response.Redirect("Admin/AdminPanel.aspx");
                    break;
                default:
                    MessageBox.Show("Failed to log in.");
                    break;
            }
        }
 
    }
}