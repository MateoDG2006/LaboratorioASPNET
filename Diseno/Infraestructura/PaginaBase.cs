using System;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;
using LaboratorioCrud.Logica.Datos;
using LaboratorioCrud.Logica.Servicios;

namespace LaboratorioCrud.Web.Infraestructura
{
    public abstract class PaginaBase : Page
    {
        protected override void OnInit(EventArgs e)
        {
            if (Session["ClaveFormulario"] == null) Session["ClaveFormulario"] = Guid.NewGuid().ToString("N");
            ViewStateUserKey = (string)Session["ClaveFormulario"];
            base.OnInit(e);
        }
        protected UsuarioServicio Servicio()
        {
            var configuracion = ConfigurationManager.ConnectionStrings["conexion"];
            if (configuracion == null || string.IsNullOrWhiteSpace(configuracion.ConnectionString))
                throw new ConfigurationErrorsException("Configure la conexion local antes de continuar.");
            return new UsuarioServicio(new MySqlUsuarioRepositorio(configuracion.ConnectionString));
        }
        protected void MostrarError(Label destino, Exception error)
        {
            string mensaje;
            if (error is ArgumentException || error is InvalidOperationException)
                mensaje = error.Message;
            else {
                var referencia = Guid.NewGuid().ToString("N").Substring(0, 8);
                Trace.Warn("CRUD " + referencia, "Error al acceder a los datos.", error);
                var sql = error as MySqlException;
                if (sql != null) {
                    mensaje = "MySQL " + sql.Number + ": " + DescribirErrorMySql(sql.Number);
                    // El detalle del motor solo se muestra al ejecutar localmente.
                    if (Request.IsLocal) mensaje += " Detalle: " + sql.Message;
                } else if (error is ConfigurationErrorsException) {
                    mensaje = "No se pudo leer la conexion. Revise Web.config y App_Data/Conexion.local.config; debe existir una entrada llamada conexion.";
                } else {
                    mensaje = "No se pudo completar la operacion. Tipo de error: " + error.GetType().Name + ". Ejecute Diagnosticar_conexion.cmd para identificar la causa.";
                }
                mensaje += " Referencia: " + referencia;
            }
            destino.Text = Server.HtmlEncode(mensaje);
            destino.CssClass = "notice notice-error";
            destino.Visible = true;
        }
        private static string DescribirErrorMySql(int numero)
        {
            switch (numero) {
                case 1045: return "MySQL rechazo la cuenta o su autenticacion. Crear la base no crea el usuario crud_app. Use una cuenta existente; omitir Pwd solo funciona si esa cuenta permite acceso sin contrasena.";
                case 1044: return "La cuenta no tiene permiso para acceder a la base de datos indicada.";
                case 1049: return "La base indicada en la cadena de conexion no existe en esta instancia de MySQL.";
                case 1146: return "Falta una tabla. Ejecute los scripts de tablas y seed en la misma base configurada en la aplicacion.";
                case 1054: return "La tabla tiene columnas diferentes de las que espera el proyecto. Revise Database/02_tablas.sql y el esquema existente.";
                case 1305: return "Falta un procedimiento almacenado. Ejecute Database/03_procedimientos.sql en la base configurada.";
                case 1318: return "El procedimiento tiene parametros diferentes. Vuelva a ejecutar Database/03_procedimientos.sql para actualizar sus firmas.";
                case 1370: return "La cuenta no tiene permiso EXECUTE sobre el procedimiento almacenado.";
                case 0: case 1042: case 2002: case 2003: case 2005:
                    return "No se pudo abrir la conexion. Revise que MySQL este iniciado y que el servidor y el puerto sean correctos.";
                default: return "La operacion fue rechazada por MySQL. El numero identifica el error del motor.";
            }
        }
        protected void Volver(string mensaje)
        {
            Session["MensajeCrud"] = mensaje;
            Response.Redirect(ResolveUrl("~/Pages/Index.aspx"), false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}
