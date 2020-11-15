CREATE PROCEDURE crear_email(IN dominio varchar(3), OUT email VARCHAR(60))
BEGIN
	SET email = CONCAT(LEFT(NEW.Nombre, 3), '@', dominio);
END;

CREATE DEFINER = CURRENT_USER TRIGGER `mydb`.`trigger_crear_email_before_insert` BEFORE INSERT ON `Cliente` FOR EACH ROW
BEGIN
	IF NEW.Email = NULL THEN
		NEW.Email := CALL crear_email('ull.com');
	END IF
END