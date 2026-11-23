using System;
using System.Globalization;
using LaboratorioCrud.Logica.Modelos;
using LaboratorioCrud.Web.Infraestructura;

namespace LaboratorioCrud.Web.Pages
{
    public partial class FormularioUsuario : PaginaBase
    {
        private int IdActual { get { return (int)(ViewState["IdActual"] ?? 0); } }
        private string Modo { get { return (string)(ViewState["Modo"] ?? ""); } }
        private DateTime Version { get { return (DateTime)ViewState["Version"]; } }
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;
            try {
                var accion = (Request.QueryString["accion"] ?? "crear").ToLowerInvariant();
                if (accion != "crear" && accion != "ver" && accion != "editar" && accion != "eliminar")
                    throw new ArgumentException("La accion solicitada no existe.");
                ViewState["Modo"] = accion;
                FechaNacimiento.Attributes["max"] = DateTime.Today.ToString("yyyy-MM-dd");
                FechaNacimiento.Attributes["min"] = DateTime.Today.AddYears(-120).ToString("yyyy-MM-dd");
                Titulo.Text = accion == "crear" ? "Nuevo usuario" : accion == "editar" ? "Editar usuario" : accion == "eliminar" ? "Anular usuario" : "Detalle del usuario";
                RutaActual.Text = Titulo.Text;
                Descripcion.Text = accion == "crear" ? "Agrega una persona al directorio con sus datos de contacto." : "Consulta la información y el historial de este registro.";
                Guardar.Text = accion == "crear" ? "Crear usuario" : "Guardar cambios";
                Guardar.Visible = accion == "crear" || accion == "editar";
                if (accion == "crear") return;
                int id;
                if (!int.TryParse(Request.QueryString["id"], out id) || id <= 0)
                    throw new ArgumentException("Falta un identificador de usuario valido.");
                var usuario = Servicio().Obtener(id);
                if (usuario == null) throw new ArgumentException("No se encontro el usuario solicitado.");
                if (!usuario.Activo && accion != "ver") throw new ArgumentException("El usuario esta anulado. Solo se puede consultar su historial.");
                ViewState["IdActual"] = id;
                ViewState["Version"] = usuario.FechaModificacion;
                Nombre.Text = usuario.Nombre; Apellido.Text = usuario.Apellido;
                Correo.Text = usuario.Correo; Telefono.Text = usuario.Telefono;
                FechaNacimiento.Text = usuario.FechaNacimiento.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);
                bool lectura = accion == "ver" || accion == "eliminar";
                Nombre.ReadOnly = lectura; Apellido.ReadOnly = lectura; Correo.ReadOnly = lectura;
                Telefono.ReadOnly = lectura; FechaNacimiento.ReadOnly = lectura;
                Identificador.Text = "ID " + id;
                Auditoria.Visible = true;
                Estado.Text = usuario.Activo ? "Activo" : "Anulado";
                FechaRegistro.Text = usuario.FechaDeInsercion.ToString("dd/MM/yyyy HH:mm:ss");
                FechaEdicion.Text = usuario.FechaModificacion.ToString("dd/MM/yyyy HH:mm:ss");
                FechaAnulacion.Text = usuario.FechaEliminacion.HasValue ? usuario.FechaEliminacion.Value.ToString("dd/MM/yyyy HH:mm:ss") : "Sin anulación";
                AvisoAnulacion.Visible = accion == "eliminar";
                ConfirmarAnulacion.Visible = accion == "eliminar";
            } catch (Exception error) { Formulario.Visible = false; AvisoAnulacion.Visible = false; MostrarError(Mensaje, error); }
        }
        protected void Guardar_Click(object sender, EventArgs e)
        {
            try {
                if (!Formulario.Visible || (Modo != "crear" && Modo != "editar")) throw new ArgumentException("Esta accion no esta disponible.");
                DateTime fecha;
                if (!DateTime.TryParseExact(FechaNacimiento.Text, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out fecha))
                    throw new ArgumentException("Seleccione una fecha de nacimiento valida.");
                var usuario = new Usuario { IdUsuario = IdActual, Nombre = Nombre.Text, Apellido = Apellido.Text,
                    Correo = Correo.Text, Telefono = Telefono.Text, FechaNacimiento = fecha };
                if (Modo == "crear") {
                    var id = Servicio().Crear(usuario);
                    // Invalida una segunda pulsacion dentro de la misma instancia de pagina.
                    Guardar.Enabled = false;
                    Volver("Usuario #" + id + " creado correctamente.");
                } else {
                    Servicio().Actualizar(usuario, Version);
                    Volver("Usuario actualizado correctamente.");
                }
            } catch (Exception error) { MostrarError(Mensaje, error); }
        }
        protected void ConfirmarAnulacion_Click(object sender, EventArgs e)
        {
            try {
                if (!Formulario.Visible || Modo != "eliminar") throw new ArgumentException("Esta accion no esta disponible.");
                Servicio().Anular(IdActual, Version);
                Volver("Usuario anulado. Su historial se conserva.");
            } catch (Exception error) { MostrarError(Mensaje, error); }
        }
    }
}
