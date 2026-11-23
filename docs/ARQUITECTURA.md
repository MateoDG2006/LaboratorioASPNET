# Organización y flujo

La solución contiene una aplicación web clásica y una biblioteca de clases. `Diseno` referencia `Logica`. `Logica` no conoce las páginas ni los controles visuales.

## Componentes

| Componente | Función |
| --- | --- |
| `Diseno/Site.Master` | Navegación, encabezado, estilos y contenedor de las páginas. |
| `Diseno/Pages/Index.aspx` | GridView, búsqueda, filtro y selección por ID. |
| `Diseno/Pages/Crud.aspx` | Formulario de crear, ver, editar o confirmar anulación. |
| `Diseno/Infraestructura/PaginaBase.cs` | Conexión configurada, mensajes y ViewState asociado a sesión. |
| `Logica/Servicios/UsuarioServicio.cs` | Validación y reglas del CRUD. |
| `Logica/Datos/IUsuarioRepositorio.cs` | Contrato de persistencia para separar las pruebas de MySQL. |
| `Logica/Datos/MySqlUsuarioRepositorio.cs` | Parámetros tipados, procedimientos, lectura y liberación de conexiones. |
| `Logica/Modelos/Usuario.cs` | Datos del registro y su auditoría. |

## Operaciones

| Acción | Método de servicio | Procedimiento |
| --- | --- | --- |
| Listado y búsqueda | `Listar` | `sp_load` |
| Detalle | `Obtener` | `sp_read` |
| Alta | `Crear` | `sp_create` |
| Edición | `Actualizar` | `sp_update` |
| Anulación | `Anular` | `sp_delete` |

`sp_load` y `sp_read` se ejecutan con `ExecuteReader`. Los cambios usan `ExecuteNonQuery` y parámetros de salida para recuperar el ID o el número de registros afectados. No se depende del valor de retorno agregado de un procedimiento para identificar una edición correcta.

## Identificación y concurrencia

El GridView enlaza `CommandArgument` con `Eval("IdUsuario")`. El ID viaja por URL y se valida como entero positivo. El formulario guarda su ID, modo y versión original en ViewState protegido y no recarga sus campos en un postback.

La versión es `FechaModificacion`, almacenada con precisión de microsegundos. Actualizar y anular requieren que esa versión coincida con la fila actual. Si cambia, el procedimiento no modifica filas y el servicio informa al usuario. Una edición sin cambios también actualiza la versión explícitamente. La anulación cambia `Activo` a 0 y registra `FechaEliminacion`; no hay borrado físico en el CRUD.

## Configuración y datos

La cadena está en `App_Data/Conexion.local.config`, referenciada desde Web.config. La biblioteca recibe la cadena por constructor. Cada operación abre su propia conexión y usa `using` para cerrarla incluso si falla. Los scripts de Database están fuera del directorio web.

La unicidad del correo incluye anulados. Las cuentas del seed son ficticias. Los procedimientos se crean con el usuario instalador como definidor de MySQL; para cambiar de servidor se deben recrear ejecutando los scripts allí. El script opcional de permisos solo concede EXECUTE al usuario de aplicación.

## Diseño

La página maestra centraliza Bootstrap 5.3.3 y los estilos propios. El diseño usa un menú lateral, tabla con acciones, resúmenes del resultado actual y formulario con auditoría. Los estilos locales permiten usarlo sin conexión al CDN. La aplicación usa enlaces y controles de servidor para sus operaciones, con JavaScript solo para el menú móvil.
