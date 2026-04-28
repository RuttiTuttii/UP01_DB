-- решение за 5 день
-- практические работы 15, 16 и 17

USE Market;

-- практическая работа 15
-- создание after-триггеров в mysql

-- 15.5.1 таблица удаленных заказчиков и after delete триггер
DROP TABLE IF EXISTS deleted_customers;

CREATE TABLE deleted_customers LIKE customers;

ALTER TABLE deleted_customers
ADD COLUMN deleted_at DATETIME NOT NULL;

DROP TRIGGER IF EXISTS customers_after_delete;
DELIMITER //
CREATE TRIGGER customers_after_delete
AFTER DELETE ON customers
FOR EACH ROW
BEGIN
    INSERT INTO deleted_customers (
        customer_id,
        login,
        last_name,
        first_name,
        address,
        phone,
        deleted_at
    )
    VALUES (
        OLD.customer_id,
        OLD.login,
        OLD.last_name,
        OLD.first_name,
        OLD.address,
        OLD.phone,
        NOW()
    );
END//
DELIMITER ;

-- 15.5.2 таблица logs и after-триггеры insert, update, delete для books и orders
DROP TABLE IF EXISTS logs;

CREATE TABLE logs (
    log_id INT NOT NULL AUTO_INCREMENT,
    table_name VARCHAR(50) NOT NULL,
    operation_name VARCHAR(20) NOT NULL,
    operation_datetime DATETIME NOT NULL,
    current_user_name VARCHAR(100) NOT NULL,
    CONSTRAINT pk_logs PRIMARY KEY (log_id)
) ENGINE=InnoDB;

DROP TRIGGER IF EXISTS books_after_insert;
DROP TRIGGER IF EXISTS books_after_update;
DROP TRIGGER IF EXISTS books_after_delete;
DROP TRIGGER IF EXISTS orders_after_insert;
DROP TRIGGER IF EXISTS orders_after_update;
DROP TRIGGER IF EXISTS orders_after_delete;

DELIMITER //
CREATE TRIGGER books_after_insert
AFTER INSERT ON books
FOR EACH ROW
BEGIN
    INSERT INTO logs (table_name, operation_name, operation_datetime, current_user_name)
    VALUES ('books', 'insert', NOW(), CURRENT_USER());
END//

CREATE TRIGGER books_after_update
AFTER UPDATE ON books
FOR EACH ROW
BEGIN
    INSERT INTO logs (table_name, operation_name, operation_datetime, current_user_name)
    VALUES ('books', 'update', NOW(), CURRENT_USER());
END//

CREATE TRIGGER books_after_delete
AFTER DELETE ON books
FOR EACH ROW
BEGIN
    INSERT INTO logs (table_name, operation_name, operation_datetime, current_user_name)
    VALUES ('books', 'delete', NOW(), CURRENT_USER());
END//

CREATE TRIGGER orders_after_insert
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    INSERT INTO logs (table_name, operation_name, operation_datetime, current_user_name)
    VALUES ('orders', 'insert', NOW(), CURRENT_USER());
END//

CREATE TRIGGER orders_after_update
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
    INSERT INTO logs (table_name, operation_name, operation_datetime, current_user_name)
    VALUES ('orders', 'update', NOW(), CURRENT_USER());
END//

-- 15.5.3 after delete для orders дополнен удалением заказчиков без заказов
CREATE TRIGGER orders_after_delete
AFTER DELETE ON orders
FOR EACH ROW
BEGIN
    INSERT INTO logs (table_name, operation_name, operation_datetime, current_user_name)
    VALUES ('orders', 'delete', NOW(), CURRENT_USER());

    DELETE FROM customers
    WHERE customer_id NOT IN (
        SELECT DISTINCT customer_id
        FROM orders
    );
END//
DELIMITER ;

-- 15.5.4 after insert для order_items записывает стоимость измененного заказа в @orderCost
DROP TRIGGER IF EXISTS order_items_after_insert;
DELIMITER //
CREATE TRIGGER order_items_after_insert
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    SELECT SUM(oi.quantity * b.price)
    INTO @orderCost
    FROM order_items AS oi
    INNER JOIN books AS b ON b.book_id = oi.book_id
    WHERE oi.order_id = NEW.order_id;
END//
DELIMITER ;

-- практическая работа 16
-- создание before-триггеров в mysql

-- 16.5.1 before delete для customers удаляет заказы и состав заказов
DROP TRIGGER IF EXISTS customers_before_delete;
DELIMITER //
CREATE TRIGGER customers_before_delete
BEFORE DELETE ON customers
FOR EACH ROW
BEGIN
    DELETE FROM order_items
    WHERE order_id IN (
        SELECT order_id
        FROM orders
        WHERE customer_id = OLD.customer_id
    );

    DELETE FROM orders
    WHERE customer_id = OLD.customer_id;
END//
DELIMITER ;

-- 16.5.2 before insert для books ограничивает цену значением 5000
DROP TRIGGER IF EXISTS books_before_insert;
DELIMITER //
CREATE TRIGGER books_before_insert
BEFORE INSERT ON books
FOR EACH ROW
BEGIN
    IF NEW.price > 5000 THEN
        SET NEW.price = 5000;
    END IF;
END//
DELIMITER ;

-- 16.5.3 before insert для orders ставит текущую дату и время
DROP TRIGGER IF EXISTS orders_before_insert;
DELIMITER //
CREATE TRIGGER orders_before_insert
BEFORE INSERT ON orders
FOR EACH ROW
BEGIN
    SET NEW.order_datetime = NOW();
END//
DELIMITER ;

-- 16.5.4 добавление количества книг и before insert для order_items
ALTER TABLE books
ADD COLUMN quantity INT NOT NULL DEFAULT 100;

UPDATE books
SET quantity = 50;

DROP TRIGGER IF EXISTS order_items_before_insert;
DELIMITER //
CREATE TRIGGER order_items_before_insert
BEFORE INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE books
    SET quantity = quantity - NEW.quantity
    WHERE book_id = NEW.book_id;
END//
DELIMITER ;

-- практическая работа 17
-- разграничение прав доступа пользователей mysql

-- 17.5.1 пользователь с правом show databases
DROP USER IF EXISTS 'userTask1'@'localhost';
CREATE USER 'userTask1'@'localhost';
GRANT SHOW DATABASES ON *.* TO 'userTask1'@'localhost';

-- 17.5.2 пользователь со всеми правами уровня сервера и паролем 123
DROP USER IF EXISTS 'userTask2'@'localhost';
CREATE USER 'userTask2'@'localhost' IDENTIFIED BY '123';
GRANT ALL PRIVILEGES ON *.* TO 'userTask2'@'localhost';

-- 17.5.3 пользователь с dml-правами в базе market и паролем qwerty
DROP USER IF EXISTS 'userTask3'@'localhost';
CREATE USER 'userTask3'@'localhost' IDENTIFIED BY 'qwerty';
GRANT SELECT, INSERT, UPDATE, DELETE ON Market.* TO 'userTask3'@'localhost';

-- 17.5.4 пользователь с правом select в таблице books
DROP USER IF EXISTS 'userTask4'@'localhost';
CREATE USER 'userTask4'@'localhost';
GRANT SELECT ON Market.books TO 'userTask4'@'localhost';

-- 17.5.5 пользователь с select по столбцам book_id, title, price и update по price
DROP USER IF EXISTS 'userTask5'@'localhost';
CREATE USER 'userTask5'@'localhost';
GRANT SELECT (book_id, title, price), UPDATE (price) ON Market.books TO 'userTask5'@'localhost';

-- 17.5.6 пользователь из phpmyadmin с глобальными select и show databases
DROP USER IF EXISTS 'userTask6'@'localhost';
CREATE USER 'userTask6'@'localhost';
GRANT SELECT, SHOW DATABASES ON *.* TO 'userTask6'@'localhost';

-- 17.5.7 пользователь из phpmyadmin с правами на authors и books
DROP USER IF EXISTS 'userTask7'@'localhost';
CREATE USER 'userTask7'@'localhost';
GRANT SELECT ON Market.books TO 'userTask7'@'localhost';
GRANT SELECT ON Market.authors TO 'userTask7'@'localhost';
GRANT INSERT ON Market.books TO 'userTask7'@'localhost';

-- 17.5.8 пользователь с паролем 12345 и правом select по базе market
DROP USER IF EXISTS 'userTask8'@'localhost';
CREATE USER 'userTask8'@'localhost' IDENTIFIED BY '12345';
GRANT SELECT ON Market.* TO 'userTask8'@'localhost';

FLUSH PRIVILEGES;

-- контрольные вопросы к практической работе 15
-- 15.8.1 триггер - это объект базы данных, который автоматически выполняется при insert, update или delete.
-- 15.8.2 new хранит новые значения строки при insert и update, old хранит старые значения строки при update и delete.
-- 15.8.3 after-триггер срабатывает после выполнения операции над строкой таблицы.
-- 15.8.4 after-триггеры нужны для журналирования, аудита и дополнительных действий после изменения данных.

-- контрольные вопросы к практической работе 16
-- 16.8.1 триггер - это автоматически выполняемый блок sql-кода, связанный с таблицей и событием.
-- 16.8.2 before выполняется до изменения строки, after выполняется после изменения строки.
-- 16.8.3 before-триггер срабатывает перед insert, update или delete.
-- 16.8.4 before-триггеры нужны для проверки, исправления и подготовки данных перед записью.

-- контрольные вопросы к практической работе 17
-- 17.8.1 пользователей создают для ограничения доступа и безопасной работы с базой данных.
-- 17.8.2 угрозы бд: несанкционированный доступ, изменение данных, удаление данных, утечка информации.
-- 17.8.3 разграничение доступа устраняет угрозу несанкционированного доступа и лишних действий пользователя.
-- 17.8.4 пользователи mysql идентифицируются именем пользователя и хостом, например 'user'@'localhost'.
-- 17.8.5 безопасность mysql разделяется на глобальный уровень, уровень базы данных, уровень таблицы, столбцов и процедур.
-- 17.8.6 пользователю можно назначить select, insert, update, delete, create, drop, alter, grant option и другие привилегии.
