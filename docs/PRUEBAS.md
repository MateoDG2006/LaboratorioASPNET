# Pruebas de aceptación

## Reglas automatizadas

Ejecutar el proyecto Pruebas desde una terminal. Verifica las validaciones del servicio con un repositorio simulado. El modo `--mysql` requiere explícitamente una conexión de pruebas y verifica persistencia, parámetros de salida, auditoría, unicidad, filtro de activos y conflictos de edición sobre MySQL real.

## Comprobaciones en navegador

| Caso | Acción | Resultado esperado |
| --- | --- | --- |
| Alta válida | Completar los campos y guardar | Se crea una fila, aparece un mensaje y el listado se actualiza. |
| Alta inválida | Dejar el nombre vacío o indicar fecha futura | Aparece un error sin cambios en MySQL. |
| Unicidad | Repetir un correo existente | Mensaje legible sin mostrar una excepción SQL. |
| Detalle | Abrir dos usuarios diferentes | Los datos y el ID corresponden a la fila elegida. |
| Buscar | Escribir parte de un nombre o correo | La tabla contiene solo coincidencias; Limpiar restablece activos. |
| Actualizar | Editar un dato y guardar | Cambia ese usuario y su fecha de modificación. |
| Conflicto | Abrir la edición en dos pestañas y guardar ambas | La segunda informa que el registro cambió. |
| Cancelar | Abrir Anular y volver al listado | El usuario sigue activo. |
| Anular | Confirmar una anulación | No aparece entre activos; tiene estado y fecha de anulación. |
| Historial | Activar Incluir anulados y abrir Ver | Conserva la información; no muestra Editar ni Anular. |
| ID inválido | Abrir Crud.aspx?accion=editar&id=abc | Mensaje de ID inválido y formulario oculto. |
| ID inexistente | Abrir un ID positivo inexistente | Mensaje de registro no encontrado. |
| Sin MySQL | Detener la instancia propia de prueba o usar un puerto incorrecto | Mensaje de conexión sin revelar credenciales. |
| Pantalla pequeña | Abrir las páginas a 390 px de ancho | Menú móvil, formulario legible y tabla con desplazamiento horizontal. |

## Capturas sugeridas

Listado inicial; alta terminada; detalle; actualización con auditoría; confirmación de anulación; listado de activos posterior; detalle anulado; tabla de MySQL y árbol del repositorio. Los archivos pueden guardarse en `docs/evidencias/` después de ejecutar la aplicación.

No publicar capturas de las contraseñas ni del archivo de conexión local. Los correos del seed están reservados para ejemplos.
