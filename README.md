# Laboratorio CRUD de ASP.NET

Aplicación de usuarios para Herramientas de Programación Aplicada III. Usa ASP.NET Web Forms con C#, .NET Framework 4.7.2, una Master Page y MySQL 8.0.16 o posterior. Incluye creación, listado, búsqueda, detalle, edición y anulación de usuarios, con fechas de auditoría.

## Estructura solicitada

| Carpeta | Responsabilidad |
| --- | --- |
| `Database/` | Crear la base, tablas, procedimientos y cinco usuarios de prueba. |
| `Diseno/` | Aplicación web: Master Page, páginas ASPX, estilos, JavaScript y eventos de interfaz. |
| `Logica/` | Biblioteca C#: modelo, validaciones y acceso a MySQL mediante procedimientos almacenados. |
| `Pruebas/` | Pruebas ejecutables de validación y pruebas de integración opcionales contra una base aislada. |
| `docs/` | Arquitectura, relación con la rúbrica, pruebas y decisiones de implementación. |

Los archivos `aspx.cs` dentro de `Diseno` gestionan eventos y muestran resultados. Las operaciones SQL y reglas del usuario están en `Logica`; las páginas no contienen sentencias SQL. La carpeta se llama `Diseno` sin tilde para facilitar las rutas de herramientas.

## Abrir en Visual Studio Community

1. Colocar esta carpeta en `C:\Users\mateo\source\repos\LaboratorioCrudAspNet`. Si se recibió como ZIP, extraerla y ejecutar `Instalar_en_repos.cmd`. El instalador se niega a sobrescribir una carpeta existente.
2. Abrir `LaboratorioCrudAspNet.sln` con Visual Studio Community.
3. Tener instalada la carga **Desarrollo de ASP.NET y web**, las plantillas de .NET Framework, el targeting pack 4.7.2 e IIS Express. La solución tiene proyectos clásicos, no ASP.NET Core.
4. Restaurar los paquetes NuGet. El conector está fijado a `MySql.Data` 8.0.33, disponible en el entorno de desarrollo original. No es una afirmación de que esa sea la versión más reciente.
5. Establecer `LaboratorioCrud.Web` como proyecto de inicio. La página inicial es `Default.aspx`, que abre `Pages/Index.aspx`.
6. Preparar la base y la conexión como se indica abajo, recompilar y ejecutar con IIS Express.

Bootstrap 5.3.3 se incluye por CDN. Se necesita internet para cargar Bootstrap; `Content/site.css` mantiene una interfaz funcional y adaptable sin esa descarga, y las operaciones CRUD no dependen de JavaScript de Bootstrap. Para un aula sin internet se pueden copiar los archivos oficiales a `Content/vendor` y `Scripts/vendor` y cambiar las dos referencias de `Site.Master`.

## Crear y seedear la base de datos

La base utilizada es **`laboratorio_crud`**. Se eligió un nombre exclusivo para este laboratorio.

**Con MySQL Workbench:** abrir `Database/00_instalar.sql` y ejecutar el script completo con una cuenta que pueda crear la base, tablas y procedimientos. Este archivo reúne los scripts 01 a 04 y no requiere cambiar el directorio de trabajo.

**Con PowerShell:** abrir una terminal en la raíz del proyecto y ejecutar:

```powershell
.\Database\Instalar_database.ps1 -Usuario root
```

El cliente MySQL solicita la contraseña directamente; no debe escribirse dentro del comando. Si MySQL está en otro puerto o ubicación:

```powershell
.\Database\Instalar_database.ps1 -Servidor localhost -Puerto 3307 -Usuario root -MySqlExe 'D:\MySQL\bin\mysql.exe'
```

También se pueden ejecutar en orden:

1. `01_base_de_datos.sql`: base y codificación utf8mb4.
2. `02_tablas.sql`: tabla, restricciones e índices.
3. `03_procedimientos.sql`: cinco procedimientos con parámetros.
4. `04_seed.sql`: cinco usuarios ficticios con correos `example.test`.

Los scripts no borran la base ni vacían tablas. Al repetirlos, los procedimientos se recrean y el seed conserva usuarios cuyo correo ya existe, incluso anulados. `CREATE TABLE IF NOT EXISTS` no migra una tabla incompatible: si se modifica el modelo después, escribir una migración. Si se edita un script 01-04, actualizar también su sección dentro de `00_instalar.sql`.

`05_pruebas.sql` verifica el flujo con una fila temporal y revierte los datos al terminar. Puede consumir un número autoincremental. `06_usuario_app_ejemplo.sql` es opcional: permite crear un usuario con permisos limitados a ejecutar los procedimientos. **Cambiar la contraseña del ejemplo antes de ejecutarlo.** No se ejecuta automáticamente.

## Configurar la conexión local

El archivo `Diseno/Web.config` lee la sección `conexion` desde `Diseno/App_Data/Conexion.local.config`. Ese archivo queda excluido de Git. El primer build crea una copia con valores de ejemplo si no existe; todavía se debe configurar una cuenta real de MySQL.

Ejecutar desde la raíz:

```powershell
.\Configurar_conexion.ps1 -Usuario crud_app -Sobrescribir
```

La conexión se genera sin `Pwd` y el comando no pide contraseña. Esto corresponde a una cuenta MySQL configurada sin contraseña. Se puede usar otra cuenta ya existente con permisos adecuados mediante `-Usuario`; la aplicación no crea cuentas MySQL automáticamente. Si una cuenta requiere contraseña, añadir `-SolicitarContrasena`; solo en ese caso se solicita oculta y se guarda en el archivo local excluido de Git.

La cadena de ejemplo es `Server=localhost;Port=3306;Database=laboratorio_crud;Uid=crud_app;CharSet=utf8mb4;`. MySQL utiliza `MySql.Data.MySqlClient`; `System.Data.SqlClient` es el proveedor de SQL Server y no conecta a esta base MySQL.

Para otra instancia:

```powershell
.\Configurar_conexion.ps1 -Servidor localhost -Puerto 3307 -Usuario mi_usuario -BaseDatos laboratorio_crud -Sobrescribir
```

Si la política del equipo impide ejecutar scripts, usar la terminal de Visual Studio o copiar `Conexion.ejemplo.config` a `Conexion.local.config` y completar la cadena manualmente. No es necesario cambiar permanentemente la política del sistema.

## Corregir una instalación existente

Para aplicar las correcciones de conexión sin `Pwd` y caracteres de la interfaz, extraer el paquete actualizado en una carpeta distinta de la instalación y ejecutar `Actualizar_instalado.cmd`. Este actualizador modifica la instalación en `source\repos\LaboratorioCrudAspNet`, conserva servidor, base, usuario y proveedor configurados y guarda un respaldo local antes de cada cambio. No ejecuta scripts SQL ni modifica los datos de MySQL. Si se usa otra ubicación, ejecutar `Actualizar_instalado.ps1 -Proyecto 'ruta de la instalación'`.

Las páginas ASPX, la Master Page y los estilos se guardan en UTF-8 con BOM. Web.config especifica también `fileEncoding="utf-8"`, además de las codificaciones de solicitud y respuesta. El menú usa SVG para el icono de usuarios en lugar de un carácter que dependa de la fuente instalada. Después de actualizar, detener IIS Express, recompilar y abrir nuevamente la página.

## Diagnosticar un error de conexión

Después de compilar, ejecutar `Diagnosticar_conexion.cmd`. Si se ejecuta desde la carpeta compilada, revisa esa instalación; si se ejecuta desde el paquete sin compilar, busca la instalación en `source\repos\LaboratorioCrudAspNet`. Revisa el archivo real indicado por Web.config, prueba la conexión y llama al procedimiento de listado sin modificar datos. Imprime el número y el mensaje de MySQL, sin mostrar la contraseña ni la cadena completa.

También se puede ejecutar `Diagnosticar_conexion.ps1 -Proyecto 'ruta de la solución'`. Si indica que faltan el archivo local o los binarios y la página está funcionando en otro navegador, comprobar la ruta del proyecto abierto en Visual Studio: puede haber más de una copia.

Los mensajes de la interfaz ahora incluyen códigos de MySQL. `1045` significa que se rechazó la cuenta o autenticación; `1049`, que no existe la base indicada; `1305`, que falta un procedimiento; y `1318`, que su firma no coincide. Crear `laboratorio_crud` no crea automáticamente la cuenta `crud_app`: se debe usar una cuenta existente o ejecutar el script opcional de usuario con la autenticación elegida. No cambiar usuarios, contraseñas ni permisos del servidor hasta identificar el error concreto.

El actualizador crea Conexion.local.config desde el ejemplo si el archivo faltaba. Esto completa el archivo, pero no acredita que la cuenta de ejemplo exista en MySQL. Tras actualizar PaginaBase.cs se debe recompilar para que la aplicación utilice los nuevos mensajes. Una referencia corta de la versión anterior, sin el número de MySQL, no identifica por sí sola la causa de un error.

## Uso del CRUD

- **Crear:** seleccionar Nuevo usuario, completar los campos y guardar. Nombre, apellido, correo y fecha de nacimiento son obligatorios; teléfono es opcional.
- **Leer:** el listado muestra activos; la búsqueda filtra nombre, apellido o correo. Ver abre el detalle, incluidas las fechas de auditoría.
- **Actualizar:** Editar carga los datos; Guardar cambios actualiza únicamente el ID seleccionado. Si otro proceso modificó el registro, se informa del conflicto.
- **Eliminar:** Anular abre una pantalla de confirmación. Solo Confirmar anulación ejecuta el procedimiento; abrir el enlace nunca elimina datos.
- **Ver anulados:** marcar Incluir anulados. Estos registros conservan el detalle y no permiten nuevas ediciones ni una segunda anulación.

Los correos son únicos para todo el historial. Anular a una persona no libera su correo; la interfaz explica el conflicto si se intenta reutilizarlo. Las fechas de auditoría corresponden al reloj de la instancia MySQL.

## Compilar y probar

En **Developer PowerShell for Visual Studio**, desde la raíz:

```powershell
msbuild LaboratorioCrudAspNet.sln /restore /p:Configuration=Debug
.\Pruebas\bin\Debug\LaboratorioCrud.Pruebas.exe
```

Las pruebas normales utilizan un repositorio simulado y no necesitan MySQL. Comprueban validaciones, normalización y conflictos, sin modificar bases de datos.

Las pruebas de integración requieren una base cuyo nombre termine en `_test`. Preparar una base exclusiva, ejecutar los scripts 02 y 03 cambiando la instrucción USE a esa base, y definir `CRUD_TEST_CONNECTION` en la terminal con su cadena local. Después ejecutar:

```powershell
.\Pruebas\bin\Debug\LaboratorioCrud.Pruebas.exe --mysql
```

Ese modo crea una fila temporal, prueba los cinco procedimientos y limpia exclusivamente su propia fila en la base `_test`. Rechaza bases con otro nombre. No ejecutarlo contra datos de otras aplicaciones.

## Relación con la rúbrica

El CRUD representa 70 %; repositorio y documentación, 15 %; puntualidad, 15 %. Ver `docs/RUBRICA.md` para localizar cada implementación y sus evidencias. La entrega debe incluir este código y los scripts SQL; la puntualidad y el envío del enlace corresponden al estudiante.

El modelo implementado incluye Nombre, Apellido, Correo, Teléfono y FechaNacimiento, además del ID y la auditoría. Los campos complementarios son una decisión explícita del proyecto; la rúbrica no enumera un inventario completo de columnas.

## Alcance de ejecución

Este es un laboratorio local sin autenticación. Ejecutar con IIS Express en localhost. Un despliegue compartido requiere agregar autenticación y autorización antes de exponer los datos. Los procedimientos usan parámetros y el formulario mantiene la protección de ViewState y su vinculación a la sesión.

Referencias técnicas: [procedimientos en Connector/NET](https://dev.mysql.com/doc/connector-net/en/connector-net-programming-stored-proc.html), [ViewStateUserKey](https://learn.microsoft.com/en-us/dotnet/api/system.web.ui.page.viewstateuserkey), y los materiales y la rúbrica suministrados en clase.
