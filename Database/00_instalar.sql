-- Instalacion completa. Generado a partir de 01, 02, 03 y 04.

-- 01_base_de_datos.sql
-- MySQL 8.0.16 o posterior. No borra bases existentes.
CREATE DATABASE IF NOT EXISTS laboratorio_crud
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE laboratorio_crud;


-- 02_tablas.sql
USE laboratorio_crud;
CREATE TABLE IF NOT EXISTS usuarios (
  IdUsuario INT NOT NULL AUTO_INCREMENT,
  Nombre VARCHAR(80) NOT NULL,
  Apellido VARCHAR(80) NOT NULL,
  Correo VARCHAR(160) NOT NULL,
  Telefono VARCHAR(25) NULL,
  FechaNacimiento DATE NOT NULL,
  Activo TINYINT(1) NOT NULL DEFAULT 1,
  FechaDeInsercion DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  FechaModificacion DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
    ON UPDATE CURRENT_TIMESTAMP(6),
  FechaEliminacion DATETIME(6) NULL,
  PRIMARY KEY (IdUsuario),
  UNIQUE KEY uq_usuarios_correo (Correo),
  KEY ix_usuarios_estado_nombre (Activo, Apellido, Nombre),
  CONSTRAINT ck_usuarios_nombre CHECK (CHAR_LENGTH(TRIM(Nombre)) > 0),
  CONSTRAINT ck_usuarios_apellido CHECK (CHAR_LENGTH(TRIM(Apellido)) > 0),
  CONSTRAINT ck_usuarios_estado CHECK (
    (Activo = 1 AND FechaEliminacion IS NULL) OR
    (Activo = 0 AND FechaEliminacion IS NOT NULL))
) ENGINE=InnoDB;


-- 03_procedimientos.sql
USE laboratorio_crud;
DELIMITER $$

DROP PROCEDURE IF EXISTS sp_load$$
CREATE PROCEDURE sp_load(IN _busqueda VARCHAR(160), IN _incluirAnulados BOOLEAN)
BEGIN
  SELECT IdUsuario, Nombre, Apellido, Correo, Telefono, FechaNacimiento,
         Activo, FechaDeInsercion, FechaModificacion, FechaEliminacion
  FROM usuarios
  WHERE (_incluirAnulados = TRUE OR Activo = 1)
    AND (COALESCE(TRIM(_busqueda), '') = ''
      OR LOCATE(TRIM(_busqueda), CONCAT(Nombre, ' ', Apellido, ' ', Correo)) > 0)
  ORDER BY Activo DESC, Apellido, Nombre, IdUsuario;
END$$

DROP PROCEDURE IF EXISTS sp_read$$
CREATE PROCEDURE sp_read(IN _idUsuario INT)
BEGIN
  SELECT IdUsuario, Nombre, Apellido, Correo, Telefono, FechaNacimiento,
         Activo, FechaDeInsercion, FechaModificacion, FechaEliminacion
  FROM usuarios WHERE IdUsuario = _idUsuario;
END$$

DROP PROCEDURE IF EXISTS sp_create$$
CREATE PROCEDURE sp_create(
  IN _nombre VARCHAR(80), IN _apellido VARCHAR(80), IN _correo VARCHAR(160),
  IN _telefono VARCHAR(25), IN _fechaNacimiento DATE, OUT _nuevoId INT)
BEGIN
  IF COALESCE(CHAR_LENGTH(TRIM(_nombre)), 0) = 0
     OR COALESCE(CHAR_LENGTH(TRIM(_apellido)), 0) = 0
     OR COALESCE(CHAR_LENGTH(TRIM(_correo)), 0) = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nombre, apellido y correo son obligatorios.';
  END IF;
  IF _fechaNacimiento IS NULL OR _fechaNacimiento > CURRENT_DATE()
     OR _fechaNacimiento < DATE_SUB(CURRENT_DATE(), INTERVAL 120 YEAR) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La fecha de nacimiento no es valida.';
  END IF;
  INSERT INTO usuarios (Nombre, Apellido, Correo, Telefono, FechaNacimiento)
  VALUES (TRIM(_nombre), TRIM(_apellido), LOWER(TRIM(_correo)),
          NULLIF(TRIM(_telefono), ''), _fechaNacimiento);
  SET _nuevoId = LAST_INSERT_ID();
END$$

DROP PROCEDURE IF EXISTS sp_update$$
CREATE PROCEDURE sp_update(
  IN _idUsuario INT, IN _nombre VARCHAR(80), IN _apellido VARCHAR(80),
  IN _correo VARCHAR(160), IN _telefono VARCHAR(25), IN _fechaNacimiento DATE,
  IN _version DATETIME(6), OUT _afectados INT)
BEGIN
  IF COALESCE(CHAR_LENGTH(TRIM(_nombre)), 0) = 0
     OR COALESCE(CHAR_LENGTH(TRIM(_apellido)), 0) = 0
     OR COALESCE(CHAR_LENGTH(TRIM(_correo)), 0) = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nombre, apellido y correo son obligatorios.';
  END IF;
  IF _fechaNacimiento IS NULL OR _fechaNacimiento > CURRENT_DATE()
     OR _fechaNacimiento < DATE_SUB(CURRENT_DATE(), INTERVAL 120 YEAR) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La fecha de nacimiento no es valida.';
  END IF;
  -- Version de auditoria: evita sobrescribir una edicion concurrente.
  UPDATE usuarios
  SET Nombre = TRIM(_nombre), Apellido = TRIM(_apellido), Correo = LOWER(TRIM(_correo)),
      Telefono = NULLIF(TRIM(_telefono), ''), FechaNacimiento = _fechaNacimiento,
      FechaModificacion = GREATEST(CURRENT_TIMESTAMP(6), FechaModificacion + INTERVAL 1 MICROSECOND)
  WHERE IdUsuario = _idUsuario AND Activo = 1 AND FechaModificacion = _version;
  SET _afectados = ROW_COUNT();
END$$

DROP PROCEDURE IF EXISTS sp_delete$$
CREATE PROCEDURE sp_delete(IN _idUsuario INT, IN _version DATETIME(6), OUT _afectados INT)
BEGIN
  UPDATE usuarios
  SET Activo = 0, FechaEliminacion = CURRENT_TIMESTAMP(6),
      FechaModificacion = GREATEST(CURRENT_TIMESTAMP(6), FechaModificacion + INTERVAL 1 MICROSECOND)
  WHERE IdUsuario = _idUsuario AND Activo = 1 AND FechaModificacion = _version;
  SET _afectados = ROW_COUNT();
END$$
DELIMITER ;


-- 04_seed.sql
USE laboratorio_crud;
-- Repetible: un correo existente se conserva sin reactivar ni modificar usuarios.
START TRANSACTION;
INSERT INTO usuarios (Nombre, Apellido, Correo, Telefono, FechaNacimiento)
SELECT 'Ana', 'Torres', 'ana.torres@example.test', '6000-1001', '2002-03-14'
WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE Correo = 'ana.torres@example.test');
INSERT INTO usuarios (Nombre, Apellido, Correo, Telefono, FechaNacimiento)
SELECT 'Luis', 'Mendez', 'luis.mendez@example.test', '6000-1002', '2000-07-22'
WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE Correo = 'luis.mendez@example.test');
INSERT INTO usuarios (Nombre, Apellido, Correo, Telefono, FechaNacimiento)
SELECT 'Sofia', 'Castillo', 'sofia.castillo@example.test', '6000-1003', '2003-11-05'
WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE Correo = 'sofia.castillo@example.test');
INSERT INTO usuarios (Nombre, Apellido, Correo, Telefono, FechaNacimiento)
SELECT 'Diego', 'Rios', 'diego.rios@example.test', '6000-1004', '1999-01-30'
WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE Correo = 'diego.rios@example.test');
INSERT INTO usuarios (Nombre, Apellido, Correo, Telefono, FechaNacimiento)
SELECT 'Valeria', 'Vega', 'valeria.vega@example.test', '6000-1005', '2001-09-18'
WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE Correo = 'valeria.vega@example.test');
COMMIT;
