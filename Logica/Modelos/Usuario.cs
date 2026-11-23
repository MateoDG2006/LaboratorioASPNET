using System;

namespace LaboratorioCrud.Logica.Modelos
{
    public sealed class Usuario
    {
        public int IdUsuario { get; set; }
        public string Nombre { get; set; }
        public string Apellido { get; set; }
        public string Correo { get; set; }
        public string Telefono { get; set; }
        public DateTime FechaNacimiento { get; set; }
        public bool Activo { get; set; }
        public DateTime FechaDeInsercion { get; set; }
        public DateTime FechaModificacion { get; set; }
        public DateTime? FechaEliminacion { get; set; }
        public string NombreCompleto { get { return Nombre + " " + Apellido; } }
        public string Estado { get { return Activo ? "Activo" : "Anulado"; } }
    }
}
