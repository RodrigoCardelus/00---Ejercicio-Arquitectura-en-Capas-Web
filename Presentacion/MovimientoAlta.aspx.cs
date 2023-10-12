using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class MovimientoAlta : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            if (!IsPostBack)
            {
                //primer acceso a la pagina
                this.LimpioControles();
                DDLCuenta.DataSource =

                //obtengo  col de cuentas / las guardo para reuso
                Session["Listacuentas"] = Logica.LogicaCuenta.CuentaListarActivo();

             DDLCuenta.DataSource = Session["Listacuentas"]; //cargo con los datos que mantengo en la memoria compartida
                DDLCuenta.DataTextField = "NumCta"; // propiedad publica - dato del objeto que se muestra en control
             DDLCuenta.DataValueField = "NumCta"; //prop publica . dato del objeto seleccionado que devuelven en seleccion
                //en la propiedad selected value
                DDLCuenta.DataBind(); //es el que lee y carga los controles
            }
        }
        catch (Exception ex)
        {
            LblError.Text = ex.Message;
        }
    }

    private void LimpioControles()
    {
        TxtMonto.Text = "";
        RbtnRetiro.Checked = true;
        LblError.Text = "";
    }


    protected void BtnRefresh_Click(object sender, EventArgs e)
    {
        this.LimpioControles();
    }

}