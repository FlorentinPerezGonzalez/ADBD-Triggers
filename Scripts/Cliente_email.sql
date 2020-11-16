CREATE DEFINER = CURRENT_USER TRIGGER `Viveros_db`.`trigger_crear_email_before_insert` BEFORE INSERT ON `Cliente` FOR EACH ROW
BEGIN
	DECLARE temp VARCHAR(60);
	IF NEW.Email = NULL THEN
		CALL crear_email(NEW.Nombre, 'ull.com', @temp);
        SET NEW.Email = @temp;
	END IF;
END