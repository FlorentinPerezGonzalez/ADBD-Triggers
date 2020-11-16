CREATE PROCEDURE `crear_email` (IN Nombre VARCHAR(45), IN dominio VARCHAR(45), OUT email VARCHAR(60))
BEGIN
	SET Email = CONCAT(LEFT(Nombre, 3), '@', dominio);
END