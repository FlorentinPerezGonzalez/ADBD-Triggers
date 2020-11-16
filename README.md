# **Triggers MYSQL**

## **Apartado 1**

El procedimiento creado es el siguiente:

```sql
CREATE PROCEDURE `crear_email` (IN Nombre VARCHAR(45), IN dominio VARCHAR(45), OUT email VARCHAR(60))
BEGIN
	SET Email = CONCAT(LEFT(Nombre, 3), '@', dominio);
END
```
Por su parte, el trigger diseñado es el siguiente:

```sql
CREATE DEFINER = CURRENT_USER TRIGGER `Viveros_db`.`trigger_crear_email_before_insert` BEFORE INSERT ON `Cliente` FOR EACH ROW
BEGIN
	DECLARE temp VARCHAR(60);
	IF NEW.Email = NULL THEN
		CALL crear_email(NEW.Nombre, 'ull.com', @temp);
        SET NEW.Email = @temp;
	END IF;
END
```

---

## **Apartado 2**
Para la realización de este apartado se crearon dos triggers, uno en cada tabla que relacionaba, por un lado las personas con las viviendas que habitan, y por otro las personas con los pisos que habitan. Estos triggers comprueban antes de una insercción si el DNI de la persona en cuestión ya está presente en la otra tabla. En caso afirmativo, se cancela la operación.
A continuación, el trigger aplicado sobre la tabla **Persona_Piso**.

```sql
CREATE DEFINER = CURRENT_USER TRIGGER `Catastro_db`.`Persona_Piso_BEFORE_INSERT` BEFORE INSERT ON `Persona_Piso` FOR EACH ROW
BEGIN
	IF (NEW.DNI IN (SELECT DNI
    FROM Persona_Vivienda)) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Persona ya viviendo en una vivienda';
	END IF;
END
```

Y por último, el trigger aplicado sobre **Persona_Vivienda**.

```sql
CREATE DEFINER = CURRENT_USER TRIGGER `Catastro_db`.`Persona_Vivienda_BEFORE_INSERT` BEFORE INSERT ON `Persona_Vivienda` FOR EACH ROW
BEGIN
    IF (NEW.DNI IN (SELECT DNI
    FROM Persona_Piso)) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Persona viviendo en un piso';
    END IF;
END
```

---

## **Apartado 3**
Cada producto tiene un stock determinado. Este puede reducirse de dos maneras distintas. Por un lado, los clientes que sean socios pueden realizar pedidos de estos productos, reduciendo de manera efectiva el stock. Por otro, el stock puede ser reducido porque se asigne cierta cantidad a las zonas de los viveros ya existentes. En consecuencia, debemos crear dos trigger, donde uno controlará la relación entre los productos y los pedidos, y el otro, la existente entre los productos y las zonas.

En primera instancia, el trigger aplicado sobre la tabla **Producto_Pedido**.

```sql
CREATE DEFINER = CURRENT_USER TRIGGER `Viveros_db`.`Update_Stock_BEFORE_INSERT` BEFORE INSERT ON `Producto_Pedido` FOR EACH ROW
BEGIN
	DECLARE current_stock INT;
	DECLARE new_stock INT;
    SET current_stock := (SELECT Stock FROM Productos WHERE Productos.CódigoBarras = NEW.CódigoBarras);
    IF NEW.Cantidad > current_stock THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cantidad solicitada mayor que stock existente';
	END IF;
    SET new_stock := current_stock - NEW.Cantidad;
    UPDATE Productos
    SET Stock = new_stock
    WHERE Productos.CódigoBarras = NEW.CódigoBarras;
END
```

En última instancia, el trigger aplicado sobre la tabla **Zona_Producto**.

```sql
CREATE DEFINER = CURRENT_USER TRIGGER `Viveros_db`.`Zona_Producto_BEFORE_INSERT` BEFORE INSERT ON `Zona_Producto` FOR EACH ROW
BEGIN
	DECLARE current_stock INT;
    DECLARE new_stock INT;
	SET current_stock := (SELECT Stock FROM Productos WHERE Productos.CódigoBarras = NEW.CódigoBarras);
    IF NEW.Cantidad > current_stock THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cantidad asignada a la zona mayor que stock existente';
	END IF;
    SET new_stock := current_stock - NEW.Cantidad;
	UPDATE Productos
    SET Stock = new_stock
    WHERE Productos.CódigoBarras = NEW.CódigoBarras;
END
```
