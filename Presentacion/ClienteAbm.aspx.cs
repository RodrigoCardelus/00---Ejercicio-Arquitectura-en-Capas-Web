using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
//using EntidadesCompartidas;
//using Logica;
using System.Drawing;

public partial class ClienteAbm : System.Web.UI.Page
{

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        { 
            //primer acceso a la pagina
            Session["Cliente"] = null;
            this.DesActivoBotones();
            this.LimpioControles();
        }
    }

    private void DesActivoBotones()
    {
        BtnAlta.Enabled = false;
        BtnBaja.Enabled = false;
        BtnModificar.Enabled = false;
    }

    private void LimpioControles()
    {
        TxtCedula.Text = "";
        TxtNombre.Text = "";
        TxtDireccion.Text = "";
        LblError.Text = "";
    }
 
    protected void BtnBusco_Click(object sender, EventArgs e)
    {
        try
        {
            
            EntidadesCompartidas.Cliente _unCliente = null;
            _unCliente = Logica.LogicaCliente.ClienteBuscar(Convert.ToInt32(TxtCedula.Text));
            //this.LimpioControles();
            TxtCedula.Enabled = false;
            if (_unCliente == null)
            {
                BtnAlta.Enabled = true;
            }
            else
            {
                BtnModificar.Enabled = true;
                BtnBaja.Enabled = true;
                Session["Cliente"] = _unCliente;
                TxtCedula.Text = _unCliente.CICli.ToString();
                TxtNombre.Text = _unCliente.NomCli;
                TxtDireccion.Text = _unCliente.DirCli;
            }
        }
        catch (Exception ex)
        {
            LblError.Text = ex.Message;
        }
    }

    protected void BtnAlta_Click(object sender, EventArgs e)
    {
        try
        {
            int cedula;

            try
            {
                cedula = Convert.ToInt32(TxtCedula.Text);
            }
            catch 
            {

                throw new Exception("Formmato incorrecto");
            }

            string nombre = TxtNombre.Text.Trim();
            string direccion = TxtNombre.Text.Trim();

            EntidadesCompartidas.Cliente _unCliente = null;
            _unCliente = new EntidadesCompartidas.Cliente(cedula,nombre,direccion);
            Logica.LogicaCliente.ClienteAlta(_unCliente);
            this.DesActivoBotones();
            this.LimpioControles();
            LblError.ForeColor = Color.Green;
            LblError.Text = "Alta con Exito";
        }
        catch (Exception ex)
        {
            LblError.Text = ex.Message;
        }
    }

    protected void BtnBaja_Click(object sender, EventArgs e)
    {
        try
        {
            EntidadesCompartidas.Cliente _unCliente = (EntidadesCompartidas.Cliente)Session["Cliente"];
            Logica.LogicaCliente.ClienteBaja(_unCliente);
            this.DesActivoBotones();
            this.LimpioControles();
            LblError.Text = "Baja con Exito";
        }
        catch (Exception ex)
        {
            LblError.Text = ex.Message;
        }
    }

    protected void BtnModificar_Click(object sender, EventArgs e)
    {
        try
        {
            EntidadesCompartidas.Cliente _unCliente = (EntidadesCompartidas.Cliente)Session["Cliente"];
            _unCliente.NomCli = TxtNombre.Text.Trim();
            _unCliente.DirCli = TxtDireccion.Text.Trim();
            Logica.LogicaCliente.ClienteModificar(_unCliente);
            this.DesActivoBotones();
            this.LimpioControles();
            LblError.Text = "Modificacion con Exito";
        }
        catch (Exception ex)
        {
            LblError.Text = ex.Message;
        }
    }

    protected void BtnRefresh_Click(object sender, EventArgs e)
    {
        DesActivoBotones();
        LimpioControles();
    }
}