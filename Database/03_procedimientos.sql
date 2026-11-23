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
