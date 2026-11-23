-- OPCIONAL. Editar la clave antes de ejecutar como administrador MySQL.
-- No se ejecuta automaticamente. Restringir el host segun el entorno.
CREATE USER IF NOT EXISTS 'crud_app'@'localhost' IDENTIFIED BY 'CAMBIAR_CLAVE_LOCAL';
GRANT EXECUTE ON PROCEDURE laboratorio_crud.sp_load TO 'crud_app'@'localhost';
GRANT EXECUTE ON PROCEDURE laboratorio_crud.sp_read TO 'crud_app'@'localhost';
GRANT EXECUTE ON PROCEDURE laboratorio_crud.sp_create TO 'crud_app'@'localhost';
GRANT EXECUTE ON PROCEDURE laboratorio_crud.sp_update TO 'crud_app'@'localhost';
GRANT EXECUTE ON PROCEDURE laboratorio_crud.sp_delete TO 'crud_app'@'localhost';
