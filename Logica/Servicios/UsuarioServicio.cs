using System;
using System.Collections.Generic;
using System.Net.Mail;
using System.Text.RegularExpressions;
using LaboratorioCrud.Logica.Datos;
using LaboratorioCrud.Logica.Modelos;

namespace LaboratorioCrud.Logica.Servicios
{
    public sealed class UsuarioServicio
    {
        private readonly IUsuarioRepositorio repositorio;
        public UsuarioServicio(IUsuarioRepositorio repositorio)
        {
            this.repositorio = repositorio ?? throw new ArgumentNullException(nameof(repositorio));
        }
        public IList<Usuario> Listar(string busqueda, bool incluirAnulados)
        {
            busqueda = (busqueda ?? "").Trim();
            if (busqueda.Length > 160) throw new ArgumentException("La busqueda admite hasta 160 caracteres.");
            return repositorio.Listar(busqueda, incluirAnulados);
        }
        public Usuario Obtener(int id)
        {
            ValidarId(id);
            return repositorio.Obtener(id);
        }
        public int Crear(Usuario usuario)
        {
            Validar(usuario);
            return repositorio.Crear(usuario);
        }
        public void Actualizar(Usuario usuario, DateTime version)
        {
            Validar(usuario);
            ValidarId(usuario.IdUsuario);
            if (!repositorio.Actualizar(usuario, version)) throw Conflicto();
        }
        public void Anular(int id, DateTime version)
        {
            ValidarId(id);
            if (!repositorio.Anular(id, version)) throw Conflicto();
        }
        private static InvalidOperationException Conflicto()
        {
            return new InvalidOperationException("El usuario cambio o ya fue anulado. Vuelva al listado y abra el registro otra vez.");
        }
        private static void ValidarId(int id)
        {
            if (id <= 0) throw new ArgumentException("El identificador del usuario no es valido.");
        }
        public static void Validar(Usuario usuario)
        {
            if (usuario == null) throw new ArgumentNullException(nameof(usuario));
            usuario.Nombre = (usuario.Nombre ?? "").Trim();
            usuario.Apellido = (usuario.Apellido ?? "").Trim();
            usuario.Correo = (usuario.Correo ?? "").Trim().ToLowerInvariant();
            usuario.Telefono = (usuario.Telefono ?? "").Trim();
            if (usuario.Nombre.Length == 0 || usuario.Nombre.Length > 80)
                throw new ArgumentException("Escriba un nombre de hasta 80 caracteres.");
            if (usuario.Apellido.Length == 0 || usuario.Apellido.Length > 80)
                throw new ArgumentException("Escriba un apellido de hasta 80 caracteres.");
            if (usuario.Correo.Length == 0 || usuario.Correo.Length > 160)
                throw new ArgumentException("Escriba un correo de hasta 160 caracteres.");
            try {
                var direccion = new MailAddress(usuario.Correo);
                if (direccion.Address != usuario.Correo || !direccion.Host.Contains(".")) throw new FormatException();
            } catch (FormatException) { throw new ArgumentException("Escriba un correo electronico valido."); }
            if (usuario.Telefono.Length > 25 || !Regex.IsMatch(usuario.Telefono, @"^[0-9+().\s-]*$"))
                throw new ArgumentException("El telefono admite hasta 25 caracteres: numeros, espacios, +, parentesis y guiones.");
            if (usuario.FechaNacimiento.Date > DateTime.Today || usuario.FechaNacimiento.Date < DateTime.Today.AddYears(-120))
                throw new ArgumentException("La fecha de nacimiento debe estar entre hoy y hace 120 anos.");
        }
    }
}
