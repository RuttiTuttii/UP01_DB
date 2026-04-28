DROP DATABASE IF EXISTS Market;
CREATE DATABASE Market
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE Market;

-- таблица authors
CREATE TABLE authors (
    author_id INT NOT NULL AUTO_INCREMENT,
    last_name VARCHAR(50) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    country VARCHAR(30) NOT NULL DEFAULT 'Россия',
    CONSTRAINT pk_authors PRIMARY KEY (author_id),
    CONSTRAINT uq_authors_full_name UNIQUE (last_name, first_name)
) ENGINE=InnoDB;

-- таблица books
CREATE TABLE books (
    book_id INT NOT NULL AUTO_INCREMENT,
    author_id INT NOT NULL,
    title VARCHAR(50) NOT NULL,
    genre ENUM('проза', 'поэзия', 'другое') NOT NULL DEFAULT 'проза',
    price DECIMAL(6,2) UNSIGNED NOT NULL DEFAULT 0.00,
    mass DECIMAL(4,3) UNSIGNED NOT NULL DEFAULT 0.000,
    pages SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    publish_year YEAR NULL,
    CONSTRAINT pk_books PRIMARY KEY (book_id),
    CONSTRAINT fk_books_author_id
        FOREIGN KEY (author_id)
        REFERENCES authors (author_id)
        ON UPDATE CASCADE
        ON DELETE NO ACTION,
    CONSTRAINT chk_books_price CHECK (price >= 0 AND price <= 9999.99),
    CONSTRAINT chk_books_mass CHECK (mass >= 0 AND mass <= 9.999)
) ENGINE=InnoDB;

-- таблица customers
CREATE TABLE customers (
    customer_id INT NOT NULL AUTO_INCREMENT,
    login VARCHAR(20) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    address VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NULL,
    CONSTRAINT pk_customers PRIMARY KEY (customer_id),
    CONSTRAINT uq_customers_login UNIQUE (login)
) ENGINE=InnoDB;

-- таблица orders
CREATE TABLE orders (
    order_id INT NOT NULL AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_datetime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_orders PRIMARY KEY (order_id),
    CONSTRAINT fk_orders_customer_id
        FOREIGN KEY (customer_id)
        REFERENCES customers (customer_id)
        ON UPDATE CASCADE
        ON DELETE NO ACTION
) ENGINE=InnoDB;

-- таблица order_items
CREATE TABLE order_items (
    order_id INT NOT NULL,
    book_id INT NOT NULL,
    quantity TINYINT UNSIGNED NOT NULL DEFAULT 1,
    CONSTRAINT pk_order_items PRIMARY KEY (order_id, book_id),
    CONSTRAINT fk_order_items_order_id
        FOREIGN KEY (order_id)
        REFERENCES orders (order_id)
        ON UPDATE CASCADE
        ON DELETE NO ACTION,
    CONSTRAINT fk_order_items_book_id
        FOREIGN KEY (book_id)
        REFERENCES books (book_id)
        ON UPDATE CASCADE
        ON DELETE NO ACTION,
    CONSTRAINT chk_order_items_quantity CHECK (quantity > 0 AND quantity <= 100)
) ENGINE=InnoDB;
