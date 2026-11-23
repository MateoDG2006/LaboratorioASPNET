# Validación realizada

Fecha: 23 de noviembre de 2026.

| Comprobación | Resultado |
| --- | --- |
| Restauración de dependencias NuGet | Correcta en los tres proyectos. |
| Compilación de Logica, Diseno y Pruebas | Correcta con MSBuild de Visual Studio Community 18. Sin errores ni advertencias en la compilación final. |
| Precompilación ASP.NET de las páginas | Correcta con aspnet_compiler de .NET Framework 4.8. El proyecto apunta a 4.7.2. |
| Pruebas del servicio | 17 comprobaciones aprobadas. |
| Creación del esquema y procedimientos | Ejecutada correctamente en una instancia MySQL 8.0.46 aislada, sin usar las bases del estudiante. |
| Seed repetido | El script de instalación se ejecutó dos veces y mantuvo cinco usuarios. |
| SQL de alta y edición | Alta con ID generado; edición del usuario correcto; auditoría conservada y actualizada. |
| Concurrencia SQL | Una versión anterior no pudo sobrescribir una edición. |
| Correo duplicado | La restricción única rechazó el duplicado. |
| Anulación SQL | Conservó el registro con estado inactivo y fecha; rechazó la segunda anulación y la edición de anulados. |
| Consultas SQL | sp_read y ambas variantes de sp_load se ejecutaron. |
| Reversión de datos de prueba | Se revirtieron los cambios de la prueba, conservando los cinco registros del seed. |
| Scripts PowerShell | Sintaxis válida. |
| Instalador de carpeta | Copió el proyecto a un directorio temporal y rechazó una segunda copia sobre el mismo destino. |
| Ejecución web local | IIS Express respondió correctamente en el listado y en las pantallas de alta, detalle y confirmación de anulación. Se guardaron capturas reales en `docs/images/`. |

## Alcance y comprobaciones pendientes

La validación SQL se realizó ejecutando los scripts y las comprobaciones dentro del proceso de una instancia temporal. Esa sesión no pudo ejecutar el modo de integración del conector. Posteriormente se abrió la aplicación local con IIS Express y se comprobaron visualmente el listado y las páginas de alta, detalle y confirmación de anulación. Las capturas no prueban por sí solas las operaciones de escritura en el navegador.

Queda revisar los casos de escritura y conflicto de `PRUEBAS.md` en la instalación de destino. El paquete no contiene credenciales reales.

## Corrección de conexión y caracteres

El ejemplo de conexión y el configurador generan la cadena sin `Pwd` por defecto. La opción `-SolicitarContrasena` queda disponible para cuentas MySQL que sí la necesiten. No se ha sustituido el proveedor MySQL por SqlClient, porque la base sigue siendo MySQL.

Las páginas y la Master Page se guardan en UTF-8 con BOM; Web.config fija también fileEncoding, requestEncoding y responseEncoding en utf-8. Se cambió el carácter especial del menú por SVG y se agregó una versión a la URL del CSS para renovar la caché del navegador. Se verificaron de nuevo la compilación y la precompilación ASP.NET. El actualizador se comprobó en una copia temporal de la instalación, conservando la configuración distinta de la contraseña y generando respaldos.

## Diagnóstico de errores del motor

La versión anterior mostraba un mensaje genérico con una referencia, que ocultaba el número de MySQL. Se cambió ese comportamiento para identificar errores de cuenta, instancia, permisos, tablas y procedimientos. El detalle del motor se muestra solo en peticiones locales y se codifica como texto HTML.

Se agregó un diagnóstico de consola que lee la configuración del proyecto indicado, verifica los binarios y prueba la conexión y sp_load. Solo realiza lecturas. La conectividad de la instalación del estudiante sigue requiriendo ejecutar ese diagnóstico en su equipo; la referencia genérica anterior no permite afirmar cuál es la causa concreta.

La creación directa en `C:\Users\mateo\source\repos` también fue rechazada por los permisos de la sesión. La solución se entrega preparada con `Instalar_en_repos.cmd` y su script PowerShell para realizar la copia desde el equipo del usuario, sin sobrescribir una carpeta existente.
