using System;
using System.Collections.Generic;
using System.Data;
using MySql.Data.MySqlClient;
using LaboratorioCrud.Logica.Modelos;

namespace LaboratorioCrud.Logica.Datos
{
    public sealed class MySqlUsuarioRepositorio : IUsuarioRepositorio
    {
        private readonly string cadena;
        public MySqlUsuarioRepositorio(string cadenaConexion)
        {
            if (string.IsNullOrWhiteSpace(cadenaConexion)) throw new ArgumentException("Falta la cadena de conexion.");
            cadena = cadenaConexion;
        }

        private static MySqlCommand Comando(string procedimiento, MySqlConnection conexion)
        {
            return new MySqlCommand(procedimiento, conexion) { CommandType = CommandType.StoredProcedure, CommandTimeout = 15 };
        }

        public IList<Usuario> Listar(string busqueda, bool incluirAnulados)
        {
            var resultado = new List<Usuario>();
            using (var conexion = new MySqlConnection(cadena))
            using (var cmd = Comando("sp_load", conexion))
            {
                cmd.Parameters.Add("_busqueda", MySqlDbType.VarChar, 160).Value = busqueda ?? "";
                cmd.Parameters.Add("_incluirAnulados", MySqlDbType.Byte).Value = incluirAnulados;
                conexion.Open();
                using (var lector = cmd.ExecuteReader())
                    while (lector.Read()) resultado.Add(Mapear(lector));
            }
            return resultado;
        }

        public Usuario Obtener(int id)
        {
            using (var conexion = new MySqlConnection(cadena))
            using (var cmd = Comando("sp_read", conexion))
            {
                cmd.Parameters.Add("_idUsuario", MySqlDbType.Int32).Value = id;
                conexion.Open();
                using (var lector = cmd.ExecuteReader()) return lector.Read() ? Mapear(lector) : null;
            }
        }

        public int Crear(Usuario usuario)
        {
            using (var conexion = new MySqlConnection(cadena))
            using (var cmd = Comando("sp_create", conexion))
            {
                AgregarCampos(cmd, usuario);
                var salida = cmd.Parameters.Add("_nuevoId", MySqlDbType.Int32);
                salida.Direction = ParameterDirection.Output;
                conexion.Open();
                Ejecutar(cmd);
                return Convert.ToInt32(salida.Value);
            }
        }

        public bool Actualizar(Usuario usuario, DateTime version)
        {
            using (var conexion = new MySqlConnection(cadena))
            using (var cmd = Comando("sp_update", conexion))
            {
                AgregarCampos(cmd, usuario);
                cmd.Parameters.Add("_idUsuario", MySqlDbType.Int32).Value = usuario.IdUsuario;
                cmd.Parameters.Add("_version", MySqlDbType.DateTime).Value = version;
                var salida = cmd.Parameters.Add("_afectados", MySqlDbType.Int32);
                salida.Direction = ParameterDirection.Output;
                conexion.Open();
                Ejecutar(cmd);
                return Convert.ToInt32(salida.Value) == 1;
            }
        }

        public bool Anular(int id, DateTime version)
        {
            using (var conexion = new MySqlConnection(cadena))
            using (var cmd = Comando("sp_delete", conexion))
            {
                cmd.Parameters.Add("_idUsuario", MySqlDbType.Int32).Value = id;
                cmd.Parameters.Add("_version", MySqlDbType.DateTime).Value = version;
                var salida = cmd.Parameters.Add("_afectados", MySqlDbType.Int32);
                salida.Direction = ParameterDirection.Output;
                conexion.Open();
                Ejecutar(cmd);
                return Convert.ToInt32(salida.Value) == 1;
            }
        }

        private static void Ejecutar(MySqlCommand cmd)
        {
            try { cmd.ExecuteNonQuery(); }
            catch (MySqlException ex) when (ex.Number == 1062)
            {
                throw new ArgumentException("Este correo ya pertenece a un usuario, incluso si fue anulado.", ex);
            }
        }

        private static void AgregarCampos(MySqlCommand cmd, Usuario usuario)
        {
            cmd.Parameters.Add("_nombre", MySqlDbType.VarChar, 80).Value = usuario.Nombre;
            cmd.Parameters.Add("_apellido", MySqlDbType.VarChar, 80).Value = usuario.Apellido;
            cmd.Parameters.Add("_correo", MySqlDbType.VarChar, 160).Value = usuario.Correo;
            cmd.Parameters.Add("_telefono", MySqlDbType.VarChar, 25).Value = string.IsNullOrEmpty(usuario.Telefono) ? (object)DBNull.Value : usuario.Telefono;
            cmd.Parameters.Add("_fechaNacimiento", MySqlDbType.Date).Value = usuario.FechaNacimiento.Date;
        }

        private static Usuario Mapear(MySqlDataReader lector)
        {
            return new Usuario {
                IdUsuario = lector.GetInt32("IdUsuario"), Nombre = lector.GetString("Nombre"),
                Apellido = lector.GetString("Apellido"), Correo = lector.GetString("Correo"),
                Telefono = lector.IsDBNull(lector.GetOrdinal("Telefono")) ? "" : lector.GetString("Telefono"),
                FechaNacimiento = lector.GetDateTime("FechaNacimiento"), Activo = lector.GetBoolean("Activo"),
                FechaDeInsercion = lector.GetDateTime("FechaDeInsercion"),
                FechaModificacion = lector.GetDateTime("FechaModificacion"),
                FechaEliminacion = lector.IsDBNull(lector.GetOrdinal("FechaEliminacion")) ? (DateTime?)null : lector.GetDateTime("FechaEliminacion")
            };
        }
    }
}
