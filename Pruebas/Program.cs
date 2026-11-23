using System;
using System.Collections.Generic;
using System.IO;
using LaboratorioCrud.Logica.Datos;
using LaboratorioCrud.Logica.Modelos;
using LaboratorioCrud.Logica.Servicios;
using MySql.Data.MySqlClient;

namespace LaboratorioCrud.Pruebas
{
    internal static class Program
    {
        private static int aprobadas;
        private static void Afirmar(bool condicion, string descripcion)
        {
            if (!condicion) throw new Exception("FALLO: " + descripcion);
            aprobadas++;
            Console.WriteLine("OK " + descripcion);
        }
        private static void Rechaza<T>(Action accion, string descripcion) where T : Exception
        {
            try { accion(); } catch (T) { Afirmar(true, descripcion); return; }
            throw new Exception("FALLO: " + descripcion);
        }
        private static Usuario Ejemplo()
        {
            return new Usuario { Nombre = " Ana ", Apellido = " Torres ", Correo = " ANA@EXAMPLE.TEST ", Telefono = "6000-0000", FechaNacimiento = new DateTime(2001, 1, 2) };
        }
        private static int Main(string[] args)
        {
            try {
                Reglas();
                if (Array.IndexOf(args, "--mysql") >= 0) IntegracionMySql();
                Console.WriteLine("APROBADAS: " + aprobadas);
                return 0;
            } catch (Exception error) { Console.Error.WriteLine(error.GetType().Name + ": " + error.Message); return 1; }
        }
        private static void Reglas()
        {
            var falso = new RepositorioSimulado();
            var servicio = new UsuarioServicio(falso);
            var usuario = Ejemplo();
            Afirmar(servicio.Crear(usuario) == 7, "Crear devuelve el ID del repositorio");
            Afirmar(usuario.Nombre == "Ana" && usuario.Apellido == "Torres" && usuario.Correo == "ana@example.test", "Normaliza nombres y correo");
            Rechaza<ArgumentException>(() => servicio.Obtener(0), "Rechaza ID cero");
            Rechaza<ArgumentException>(() => servicio.Anular(-4, DateTime.Now), "Rechaza ID negativo antes de acceder a datos");
            usuario = Ejemplo(); usuario.Nombre = "  ";
            Rechaza<ArgumentException>(() => servicio.Crear(usuario), "Rechaza nombre vacio");
            usuario = Ejemplo(); usuario.Apellido = new string('x', 81);
            Rechaza<ArgumentException>(() => servicio.Crear(usuario), "Rechaza apellido demasiado largo");
            usuario = Ejemplo(); usuario.Correo = "sin-correo";
            Rechaza<ArgumentException>(() => servicio.Crear(usuario), "Rechaza correo invalido");
            usuario = Ejemplo(); usuario.Correo = "Persona <ana@example.test>";
            Rechaza<ArgumentException>(() => servicio.Crear(usuario), "Rechaza display name como direccion");
            usuario = Ejemplo(); usuario.FechaNacimiento = DateTime.Today.AddDays(1);
            Rechaza<ArgumentException>(() => servicio.Crear(usuario), "Rechaza fecha futura");
            usuario = Ejemplo(); usuario.FechaNacimiento = DateTime.Today.AddYears(-121);
            Rechaza<ArgumentException>(() => servicio.Crear(usuario), "Rechaza fecha fuera de rango");
            usuario = Ejemplo(); usuario.Telefono = "telefono";
            Rechaza<ArgumentException>(() => servicio.Crear(usuario), "Rechaza telefono invalido");
            Afirmar(falso.Creaciones == 1, "La validacion impide escrituras invalidas");
            usuario = Ejemplo(); usuario.Telefono = ""; usuario.Nombre = "O'Connor";
            Afirmar(servicio.Crear(usuario) == 7, "Permite apostrofe y telefono opcional");
            Rechaza<ArgumentException>(() => servicio.Listar(new string('x', 161), false), "Limita la busqueda");
            servicio.Listar(" Ana ", true);
            Afirmar(falso.Busqueda == "Ana" && falso.IncluirAnulados, "Transmite busqueda y filtro correctamente");
            usuario = Ejemplo(); usuario.IdUsuario = 7;
            falso.OperacionCorrecta = false;
            Rechaza<InvalidOperationException>(() => servicio.Actualizar(usuario, DateTime.Now), "Detecta conflicto de edicion");
            Rechaza<InvalidOperationException>(() => servicio.Anular(7, DateTime.Now), "Detecta conflicto de anulacion");
        }

        private static void IntegracionMySql()
        {
            var cadena = Environment.GetEnvironmentVariable("CRUD_TEST_CONNECTION");
            if (string.IsNullOrEmpty(cadena)) throw new Exception("Defina CRUD_TEST_CONNECTION apuntando a una base que termine en _test.");
            var builder = new MySqlConnectionStringBuilder(cadena);
            if (!builder.Database.EndsWith("_test", StringComparison.OrdinalIgnoreCase))
                throw new Exception("Las pruebas de integracion requieren una base terminada en _test.");
            var repo = new MySqlUsuarioRepositorio(cadena);
            var servicio = new UsuarioServicio(repo);
            int id = 0;
            try {
                var usuario = Ejemplo();
                usuario.Correo = "prueba." + Guid.NewGuid().ToString("N") + "@example.test";
                id = servicio.Crear(usuario);
                Afirmar(id > 0, "MySQL CREATE genera ID");
                var creado = servicio.Obtener(id);
                Afirmar(creado != null && creado.Nombre == "Ana" && creado.Activo, "MySQL READ recupera datos reales");
                Afirmar(creado.FechaDeInsercion != default(DateTime) && creado.FechaEliminacion == null, "Auditoria inicial correcta");
                usuario.IdUsuario = id; usuario.Nombre = "Ana editada";
                servicio.Actualizar(usuario, creado.FechaModificacion);
                var actualizado = servicio.Obtener(id);
                Afirmar(actualizado.Nombre == "Ana editada", "MySQL UPDATE persiste valores");
                Afirmar(actualizado.FechaDeInsercion == creado.FechaDeInsercion && actualizado.FechaModificacion > creado.FechaModificacion, "UPDATE conserva insercion y cambia version");
                Rechaza<InvalidOperationException>(() => servicio.Actualizar(usuario, creado.FechaModificacion), "MySQL impide escritura concurrente obsoleta");
                var duplicado = Ejemplo(); duplicado.Correo = usuario.Correo;
                Rechaza<ArgumentException>(() => servicio.Crear(duplicado), "MySQL impide correo duplicado");
                var lista = servicio.Listar(usuario.Correo, false);
                Afirmar(lista.Count == 1 && lista[0].IdUsuario == id, "sp_load filtra por correo sin mezclar filas");
                servicio.Anular(id, actualizado.FechaModificacion);
                var anulado = servicio.Obtener(id);
                Afirmar(!anulado.Activo && anulado.FechaEliminacion.HasValue, "DELETE es logico y registra fecha");
                Afirmar(servicio.Listar(usuario.Correo, false).Count == 0, "El listado activo excluye anulados");
                Afirmar(servicio.Listar(usuario.Correo, true).Count == 1, "El historial conserva el registro anulado");
                Rechaza<InvalidOperationException>(() => servicio.Actualizar(usuario, anulado.FechaModificacion), "No edita usuarios anulados");
                Rechaza<InvalidOperationException>(() => servicio.Anular(id, anulado.FechaModificacion), "No anula dos veces");
                Rechaza<ArgumentException>(() => servicio.Crear(duplicado), "El correo sigue reservado al anular");
                Afirmar(servicio.Obtener(int.MaxValue) == null, "ID inexistente devuelve ausencia");
            } finally {
                // Limpia exclusivamente la fila creada por esta prueba en una base _test.
                if (id > 0) using (var conexion = new MySqlConnection(cadena))
                using (var cmd = new MySqlCommand("DELETE FROM usuarios WHERE IdUsuario = @id", conexion)) {
                    cmd.Parameters.Add("@id", MySqlDbType.Int32).Value = id;
                    conexion.Open(); cmd.ExecuteNonQuery();
                }
            }
        }

        private sealed class RepositorioSimulado : IUsuarioRepositorio
        {
            public int Creaciones; public bool OperacionCorrecta = true; public string Busqueda; public bool IncluirAnulados;
            public int Crear(Usuario usuario) { Creaciones++; return 7; }
            public Usuario Obtener(int id) { return null; }
            public IList<Usuario> Listar(string busqueda, bool incluirAnulados) { Busqueda = busqueda; IncluirAnulados = incluirAnulados; return new List<Usuario>(); }
            public bool Actualizar(Usuario usuario, DateTime version) { return OperacionCorrecta; }
            public bool Anular(int id, DateTime version) { return OperacionCorrecta; }
        }
    }
}
