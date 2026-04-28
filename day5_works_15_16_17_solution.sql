-- решение за 5 день
-- практические работы 15, 16 и 17

CREATE DATABASE IF NOT EXISTS Market CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE Market;

-- подготовка таблиц market, если они не были загружены из первого дня
CREATE TABLE IF NOT EXISTS authors (
    author_id INT NOT NULL AUTO_INCREMENT,
    last_name VARCHAR(50) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    country VARCHAR(30) NOT NULL DEFAULT 'Россия',
    CONSTRAINT pk_authors PRIMARY KEY (author_id),
    CONSTRAINT uq_authors_full_name UNIQUE (last_name, first_name)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS books (
    book_id INT NOT NULL AUTO_INCREMENT,
    author_id INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    genre VARCHAR(30) NOT NULL DEFAULT 'проза',
    price DECIMAL(8,2) UNSIGNED NOT NULL DEFAULT 0.00,
    mass DECIMAL(6,3) UNSIGNED NOT NULL DEFAULT 0.000,
    pages SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    publish_year YEAR NULL,
    CONSTRAINT pk_books PRIMARY KEY (book_id),
    CONSTRAINT fk_books_author_id FOREIGN KEY (author_id)
        REFERENCES authors (author_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS customers (
    customer_id INT NOT NULL AUTO_INCREMENT,
    login VARCHAR(20) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    address VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NULL,
    CONSTRAINT pk_customers PRIMARY KEY (customer_id),
    CONSTRAINT uq_customers_login UNIQUE (login)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS orders (
    order_id INT NOT NULL AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_datetime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_orders PRIMARY KEY (order_id),
    CONSTRAINT fk_orders_customer_id FOREIGN KEY (customer_id)
        REFERENCES customers (customer_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS order_items (
    order_id INT NOT NULL,
    book_id INT NOT NULL,
    quantity TINYINT UNSIGNED NOT NULL DEFAULT 1,
    CONSTRAINT pk_order_items PRIMARY KEY (order_id, book_id),
    CONSTRAINT fk_order_items_order_id FOREIGN KEY (order_id)
        REFERENCES orders (order_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_order_items_book_id FOREIGN KEY (book_id)
        REFERENCES books (book_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- практическая работа 15
-- создание after-триггеров в mysql

DROP TABLE IF EXISTS deleted_customers;
CREATE TABLE deleted_customers LIKE customers;
ALTER TABLE deleted_customers ADD COLUMN deleted_at DATETIME NOT NULL;

DROP TRIGGER IF EXISTS customers_after_delete;
DELIMITER //
CREATE TRIGGER customers_after_delete
AFTER DELETE ON customers
FOR EACH ROW
BEGIN
    INSERT INTO deleted_customers (customer_id, login, last_name, first_name, address, phone, deleted_at)
    VALUES (OLD.customer_id, OLD.login, OLD.last_name, OLD.first_name, OLD.address, OLD.phone, NOW());
END//
DELIMITER ;

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

CREATE TRIGGER orders_after_delete
AFTER DELETE ON orders
FOR EACH ROW
BEGIN
    INSERT INTO logs (table_name, operation_name, operation_datetime, current_user_name)
    VALUES ('orders', 'delete', NOW(), CURRENT_USER());

    DELETE FROM customers
    WHERE customer_id NOT IN (
        SELECT customer_id
        FROM orders
        WHERE customer_id IS NOT NULL
    );
END//
DELIMITER ;

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

DROP TRIGGER IF EXISTS orders_before_insert;
DELIMITER //
CREATE TRIGGER orders_before_insert
BEFORE INSERT ON orders
FOR EACH ROW
BEGIN
    SET NEW.order_datetime = NOW();
END//
DELIMITER ;

ALTER TABLE books ADD COLUMN quantity INT NOT NULL DEFAULT 100;
UPDATE books SET quantity = 50;

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

DROP USER IF EXISTS 'userTask1'@'localhost';
CREATE USER 'userTask1'@'localhost';
GRANT SHOW DATABASES ON *.* TO 'userTask1'@'localhost';

DROP USER IF EXISTS 'userTask2'@'localhost';
CREATE USER 'userTask2'@'localhost' IDENTIFIED BY '123';
GRANT ALL PRIVILEGES ON *.* TO 'userTask2'@'localhost';

DROP USER IF EXISTS 'userTask3'@'localhost';
CREATE USER 'userTask3'@'localhost' IDENTIFIED BY 'qwerty';
GRANT SELECT, INSERT, UPDATE, DELETE ON Market.* TO 'userTask3'@'localhost';

DROP USER IF EXISTS 'userTask4'@'localhost';
CREATE USER 'userTask4'@'localhost';
GRANT SELECT ON Market.books TO 'userTask4'@'localhost';

DROP USER IF EXISTS 'userTask5'@'localhost';
CREATE USER 'userTask5'@'localhost';
GRANT SELECT (book_id, title, price), UPDATE (price) ON Market.books TO 'userTask5'@'localhost';

DROP USER IF EXISTS 'userTask6'@'localhost';
CREATE USER 'userTask6'@'localhost';
GRANT SELECT, SHOW DATABASES ON *.* TO 'userTask6'@'localhost';

DROP USER IF EXISTS 'userTask7'@'localhost';
CREATE USER 'userTask7'@'localhost';
GRANT SELECT ON Market.books TO 'userTask7'@'localhost';
GRANT SELECT ON Market.authors TO 'userTask7'@'localhost';
GRANT INSERT ON Market.books TO 'userTask7'@'localhost';

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
