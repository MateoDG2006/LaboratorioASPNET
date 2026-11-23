USE laboratorio_crud;
-- Ejecutar en una sesion propia: los cambios de datos se revierten al final.
-- Los numeros AUTO_INCREMENT consumidos no se revierten.
START TRANSACTION;
SET @correo_prueba = CONCAT('prueba.', REPLACE(UUID(), '-', ''), '@example.test');
CALL sp_create('Prueba', 'Temporal', @correo_prueba, NULL, '2001-01-02', @id);
SELECT IdUsuario, Nombre, Activo, FechaDeInsercion FROM usuarios WHERE IdUsuario = @id;
CALL sp_read(@id);
SET @version = (SELECT FechaModificacion FROM usuarios WHERE IdUsuario = @id);
CALL sp_update(@id, 'Prueba editada', 'Temporal', @correo_prueba, '6000-9999', '2001-01-02', @version, @afectados);
SELECT @afectados = 1 AS actualizacion_correcta;
-- Una version anterior ya no debe poder sobrescribir el registro.
CALL sp_update(@id, 'Dato obsoleto', 'Temporal', @correo_prueba, NULL, '2001-01-02', @version, @afectados);
SELECT @afectados = 0 AS concurrencia_protegida;
SET @version = (SELECT FechaModificacion FROM usuarios WHERE IdUsuario = @id);
CALL sp_delete(@id, @version, @afectados);
SELECT @afectados = 1 AS anulacion_correcta;
SELECT Activo = 0 AND FechaEliminacion IS NOT NULL AS auditoria_correcta
FROM usuarios WHERE IdUsuario = @id;
CALL sp_load('', FALSE);
CALL sp_load('', TRUE);
ROLLBACK;
