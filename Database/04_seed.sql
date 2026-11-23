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
