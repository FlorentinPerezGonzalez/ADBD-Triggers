CREATE DEFINER = CURRENT_USER TRIGGER `mydb`.`Update_Stock_BEFORE_INSERT` BEFORE INSERT ON `Producto_Pedido` FOR EACH ROW
BEGIN
	DECLARE current_stock INT;
	DECLARE new_stock INT;
    SET current_stock := (SELECT Stock FROM Productos WHERE Productos.CódigoBarras = Producto_Pedido.CódigoBarras);
    IF NEW.Cantidad > current_stock THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cantidad solicitada mayor que stock existente';
	END IF;
    SET new_stock := current_stock - NEW.Cantidad;
    UPDATE Productos
    SET Stock = new_stock
    WHERE Productos.CódigoBarras = NEW.CódigoBarras;
END