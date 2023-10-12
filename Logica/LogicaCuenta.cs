using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using EntidadesCompartidas;
using Persistencia;

namespace Logica
{
    public class LogicaCuenta
    {
        public static void CuentaAlta(Cuenta unaCuenta)
        {
            if (unaCuenta is CuentaCorriente)
                PersistenciaCuentaCorriente.Alta((CuentaCorriente)unaCuenta);
            else
                PersistenciaCuentaCAhorro.Alta((CuentaCAhorro)unaCuenta);
        }

        public static void CuentaBaja(Cuenta unaCuenta)
        {
            if (unaCuenta is CuentaCorriente)
                PersistenciaCuentaCorriente.Baja((CuentaCorriente)unaCuenta);
            else
                PersistenciaCuentaCAhorro.Baja((CuentaCAhorro)unaCuenta);
        }

        public static Cuenta CuentaBuscarActivos(int pNumCta)
        {
            Cuenta _unaCuenta = null;
            _unaCuenta = PersistenciaCuentaCorriente.BuscarActivos(pNumCta);
            if (_unaCuenta == null)
                _unaCuenta = PersistenciaCuentaCAhorro.BuscarActivos(pNumCta);
            return _unaCuenta;
        }

        public static List<Cuenta> CuentaListarActivo()
        {
            List<Cuenta> _lista = new List<Cuenta>();
            _lista.AddRange(PersistenciaCuentaCorriente.CuentaCorrienteListadoActivos());
            _lista.AddRange(PersistenciaCuentaCAhorro.CuentaCAhorroListado());
            return _lista;
        }

        public static List<CuentaCorriente> CuentaCorrienteListar()
        {
            return(PersistenciaCuentaCorriente.CuentaCorrienteListadoActivos());
        }
    }
}
