using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Drawing;

public partial class ClienteListado : System.Web.UI.Page
{

    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {

            lblMensaje.Text = "";

            if (!IsPostBack)
            {
                CargoCliente();
            }
        }
        catch (Exception ex)
        {
            lblMensaje.ForeColor = Color.Red;
            lblMensaje.Text = ex.Message;
        }
    }

    private void CargoCliente()
    {
       
        try
        {
            List<EntidadesCompartidas.Cliente> listaCliente = Logica.LogicaCliente.ClienteListar();

            if(listaCliente.Count > 0)
            {
                DGVListado.DataSource = listaCliente;
                DGVListado.DataBind();
            }
            else
            {
                throw new Exception("No existen cliente aun en el sistema");
            }
        }
        catch (Exception ex)
        {
            lblMensaje.ForeColor = Color.Red;
            lblMensaje.Text = ex.Message;
        }
    }
 
}