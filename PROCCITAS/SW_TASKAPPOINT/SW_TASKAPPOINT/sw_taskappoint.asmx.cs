using System;
using System.Collections.Generic;
using System.Data;
using System.Data.OleDb;
using System.Linq;
using System.Web;
using System.Web.Configuration;
using System.Web.Services;

namespace SW_TASKAPPOINT
{
    /// <summary>
    /// Descripción breve de sw_taskappoint
    /// </summary>
    [WebService(Namespace = "http://jalcom.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [System.ComponentModel.ToolboxItem(false)]
    // Para permitir que se llame a este servicio web desde un script, usando ASP.NET AJAX, quite la marca de comentario de la línea siguiente. 
    // [System.Web.Script.Services.ScriptService]
    public class sw_taskappoint : System.Web.Services.WebService
    {


        [WebMethod]
        public string TaskAppoint()
        {
            DataTable ldtb_Result = new DataTable();// ' la tabla que obtiene el resultado
            OleDbDataAdapter iAdapt_comand = new OleDbDataAdapter();
            OleDbCommand iolecmd_comand = new OleDbCommand();
            OleDbConnection ioleconx_conexion = new OleDbConnection();// '' objeto de conexion que se usara para conectar
                                                                      //ADODB.conection obj = new ADODB.conection();


            string istr_conx = "";// ' cadena de conexion
            string strSQL = "";
            string lstrNow = DateTime.Now.ToString("yyyyMMdd HHmmss"); // case sensitive
            string lstrDateparam = "";
            string lstr_tempstring = "";
            int lint_tempint = 0;
            int lint_qtyPerHour = 0;
            int lint_qtyCrane = 0;




            #region leerwebconfig

             //> fecha

                 lstr_tempstring = WebConfigurationManager.AppSettings["datetest"].ToString();
                if (lstr_tempstring.Length > 3)
                    lstrDateparam = lstr_tempstring;
                else
                    lstrDateparam = lstrNow;
            //< fecha

            //> por hora
            /// leer cantidad por hora

            lstr_tempstring = "";
            lstr_tempstring = WebConfigurationManager.AppSettings["intQtyPerHour"].ToString();

            if (int.TryParse(lstr_tempstring, out lint_tempint) == false)
            {
                lint_tempint = 0;
            }

            if (lint_tempint > 0)
            {
                lint_qtyPerHour = lint_tempint;

            }
            //< por hora 

            //> cantidad grua

            /// leer cantidad de gruas 
            lstr_tempstring = "";
            lstr_tempstring = WebConfigurationManager.AppSettings["intQtyCrane"].ToString(); 

            if (int.TryParse(lstr_tempstring, out lint_tempint) == false)
            {
                lint_tempint = 0;
            }

            if (lint_tempint > 0)
            {
                lint_qtyCrane = lint_tempint;

            }

            /// <<<
            //< cantidad grua
            #endregion

             istr_conx = System.Configuration.ConfigurationManager.ConnectionStrings["dbCalathus"].ToString();
            ioleconx_conexion.ConnectionString = istr_conx;
            iolecmd_comand = ioleconx_conexion.CreateCommand();

            ldtb_Result = new DataTable("User");
            strSQL = "spSetAppointOnTime";

            iolecmd_comand.Parameters.Add("intMode", OleDbType.Numeric);
            iolecmd_comand.Parameters.Add("dtmDate", OleDbType.VarChar);
            iolecmd_comand.Parameters.Add("intQtyPerHour", OleDbType.Numeric);
            iolecmd_comand.Parameters.Add("intQtyCrane", OleDbType.Numeric);



            iolecmd_comand.Parameters["intMode"].Value = 1;
            iolecmd_comand.Parameters["dtmDate"].Value = lstrDateparam;
            iolecmd_comand.Parameters["intQtyPerHour"].Value = lint_qtyPerHour;
            iolecmd_comand.Parameters["intQtyCrane"].Value = lint_qtyCrane;



            iolecmd_comand.CommandText = strSQL;
            iolecmd_comand.CommandType = CommandType.StoredProcedure;
            iolecmd_comand.CommandTimeout = 99999;

            try
            {
                iAdapt_comand.SelectCommand = iolecmd_comand;
                iAdapt_comand.Fill(ldtb_Result);

                if (ldtb_Result.Rows.Count>0 && ldtb_Result.Columns.Count > 0 )
                { // cantidad de registros
                    lstr_tempstring = ldtb_Result.Rows[ldtb_Result.Rows.Count - 1][0].ToString();
                    return lstr_tempstring;
                } // fin --cantidad de informacion 

            }
            catch (Exception ex)
            {
                string strError = ex.Message;
                strError = ex.Message;
                return "db="+strError;
            }
            finally
            {
                ioleconx_conexion.Close();
            }
            // return ldtb_Result;
            return "";
        }

        public string ObtenerError(String cad, int ex)
        {

            if ((cad.Contains(ex.ToString()) == true) && (cad.Contains("Sybase Provider]") == true))
            {

                int idx = cad.LastIndexOf("]");
                idx = idx + 1;

                if ((idx > 0) && (idx <= cad.Length))
                    return cad.Substring(idx);
                else
                    return "";

            }
            else
            {
                if (cad.Contains("SSybase Provider]") == true)
                {
                    int idx;
                    idx = cad.LastIndexOf("]");
                    idx = idx + 1;

                    if (idx > 0 && idx <= cad.Length)
                        return cad.Substring(idx);
                    else
                        return "";
                }

            } // else if((cad.Contains(ex.ToString()) == True) &&(cad.Contains("Sybase Provider]") == True))

            return "";

        }

        public DataTable Dt_RetrieveErrorTable(string astr_Message)
        {
            DataTable ldt_ErrorTable;
            DataRow lrw_Error;

            ldt_ErrorTable = new DataTable("ErrorTable");
            ldt_ErrorTable.Columns.Add("Error", typeof(string));
            lrw_Error = ldt_ErrorTable.NewRow();

            lrw_Error["Error"] = astr_Message;
            ldt_ErrorTable.Rows.Add(lrw_Error);

            return ldt_ErrorTable;

        } //public DataTable dt_RetrieveErrorTable(string astr_Message)


    }
}
