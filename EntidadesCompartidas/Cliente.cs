using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace EntidadesCompartidas
{
    public class Cliente : IComparable
    {

        //atributos
        private int _CICli;
        private string _NomCli;
        private string _DirCli;


        //Propiedades
        public int CICli
        {
            get { return _CICli; }
            set { _CICli = value; }
        }

        public string NomCli
        {
            get { return _NomCli; }
            set
            {
                if ((value.Trim().Length > 30) || (value.Trim().Length <= 0))
                    throw new Exception("Error en Nombre cliente");
                else
                    _NomCli = value;
            }
        }

        public string DirCli
        {
            get { return _DirCli; }
            set
            {
                if ((value.Trim().Length > 30) || (value.Trim().Length <= 0))
                    throw new Exception("Error en Direccion cliente");
                else
                    _DirCli = value;
            }
        }


        //Constructor Completo
        public Cliente(int pCICli, string pNomCli, string pDirCli)
        {
            CICli = pCICli;
            NomCli = pNomCli;
            DirCli = pDirCli;
        }


        //operaciones
        public int CompareTo(Object obj)
        {
            Cliente _parametro = (Cliente)obj;
            if (this == null)
                return 1;
            else if (_parametro == null)
                return -1;
            else 
                return (this.NomCli.CompareTo(_parametro.NomCli));
        }

    }
}
