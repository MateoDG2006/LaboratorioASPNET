using System;
using System.Collections.Generic;
using LaboratorioCrud.Logica.Modelos;

namespace LaboratorioCrud.Logica.Datos
{
    public interface IUsuarioRepositorio
    {
        IList<Usuario> Listar(string busqueda, bool incluirAnulados);
        Usuario Obtener(int id);
        int Crear(Usuario usuario);
        bool Actualizar(Usuario usuario, DateTime version);
        bool Anular(int id, DateTime version);
    }
}
