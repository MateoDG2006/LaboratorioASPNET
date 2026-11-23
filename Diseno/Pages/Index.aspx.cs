using System;
using System.Linq;
using System.Web.UI.WebControls;
using LaboratorioCrud.Web.Infraestructura;

namespace LaboratorioCrud.Web.Pages
{
    public partial class Indice : PaginaBase
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;
            if (Session["MensajeCrud"] != null) {
                Mensaje.Text = Server.HtmlEncode((string)Session["MensajeCrud"]);
                Mensaje.CssClass = "notice notice-success";
                Mensaje.Visible = true;
                Session.Remove("MensajeCrud");
            }
            Cargar();
        }
        private void Cargar()
        {
            try {
                var registros = Servicio().Listar(Busqueda.Text, IncluirAnulados.Checked);
                Usuarios.DataSource = registros;
                Usuarios.DataBind();
                if (Usuarios.HeaderRow != null) Usuarios.HeaderRow.TableSection = TableRowSection.TableHeader;
                Total.Text = registros.Count.ToString();
                Activos.Text = registros.Count(u => u.Activo).ToString();
                Anulados.Text = registros.Count(u => !u.Activo).ToString();
                Conteo.Text = registros.Count + (registros.Count == 1 ? " usuario encontrado" : " usuarios encontrados");
            } catch (Exception error) { MostrarError(Mensaje, error); }
        }
        protected void Buscar_Click(object sender, EventArgs e) { Mensaje.Visible = false; Cargar(); }
        protected void Filtro_Changed(object sender, EventArgs e) { Mensaje.Visible = false; Cargar(); }
        protected void Limpiar_Click(object sender, EventArgs e) { Busqueda.Text = ""; IncluirAnulados.Checked = false; Mensaje.Visible = false; Cargar(); }
        protected void Usuarios_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            string accion;
            switch (e.CommandName) {
                case "ConsultarUsuario": accion = "ver"; break;
                case "EditarUsuario": accion = "editar"; break;
                case "AnularUsuario": accion = "eliminar"; break;
                default: return;
            }
            int id;
            if (!int.TryParse(Convert.ToString(e.CommandArgument), out id) || id <= 0) {
                MostrarError(Mensaje, new ArgumentException("El identificador no es valido.")); return;
            }
            Response.Redirect("Crud.aspx?accion=" + accion + "&id=" + id, false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}
