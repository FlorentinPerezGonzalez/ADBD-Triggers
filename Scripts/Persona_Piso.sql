CREATE DEFINER = CURRENT_USER TRIGGER `Catastro_db`.`Persona_Piso_BEFORE_INSERT` BEFORE INSERT ON `Persona_Piso` FOR EACH ROW
BEGIN
	IF (NEW.DNI IN (SELECT DNI
    FROM Persona_Vivienda)) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Persona ya viviendo en una vivienda';
	END IF;
END