using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Serilog;

namespace ConsoleProdCitas
{
    class Program
    {
        static void Main(string[] args)
        {
            string lstr_result="";
            sw_taskappoint.sw_taskappoint lsw_service = new sw_taskappoint.sw_taskappoint();

            Log.Logger = new LoggerConfiguration()
              .MinimumLevel.Debug()
              .WriteTo.Console()
              //.WriteTo.File("logs/myapp.txt", rollingInterval: RollingInterval.Day)
              .WriteTo.File("logg.txt", rollingInterval: RollingInterval.Day)
              .CreateLogger();

            
            try
            {
                Log.Information("inicio llamado servicio web");
                lstr_result = lsw_service.TaskAppoint();
                Log.Debug("Resultado llamado={A}", lstr_result);
                Log.Information("fin llamado servicio web");

            }
            catch (Exception ex)
            {
                lstr_result = ex.Message;
                Log.Error(ex, "Error en llamado");
            }
            finally
            {
                Log.CloseAndFlush();
            }
            Console.WriteLine("resultado=" + lstr_result);
            Thread.Sleep(1600);
        }
    }
}
