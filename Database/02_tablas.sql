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
