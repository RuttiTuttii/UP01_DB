-- =========================================================
-- Проектирование базы данных обувного магазина
-- MySQL 8.0+ / MySQL Workbench
-- =========================================================

DROP DATABASE IF EXISTS shoe_store;
CREATE DATABASE shoe_store
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE shoe_store;

-- =========================================================
-- Таблица: manufacturer
-- =========================================================
CREATE TABLE manufacturer (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    country VARCHAR(100),
    contact_info TEXT
) ENGINE=InnoDB;

-- =========================================================
-- Таблица: shoe_category
-- =========================================================
CREATE TABLE shoe_category (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

-- =========================================================
-- Таблица: shoe
-- =========================================================
CREATE TABLE shoe (
    id INT AUTO_INCREMENT PRIMARY KEY,
    manufacturer_id INT NOT NULL,
    category_id INT NOT NULL,
    model_name VARCHAR(255),
    description TEXT,
    base_price DECIMAL(10,2) NOT NULL,
    release_year YEAR,
    CONSTRAINT chk_shoe_base_price CHECK (base_price >= 0),
    CONSTRAINT fk_shoe_manufacturer
        FOREIGN KEY (manufacturer_id) REFERENCES manufacturer(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_shoe_category
        FOREIGN KEY (category_id) REFERENCES shoe_category(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- =========================================================
-- Таблица: assortment
-- =========================================================
CREATE TABLE assortment (
    id INT AUTO_INCREMENT PRIMARY KEY,
    shoe_id INT NOT NULL,
    size DECIMAL(4,1) NOT NULL,
    color VARCHAR(50) NOT NULL,
    stock_count INT NOT NULL DEFAULT 0,
    discount_percent DECIMAL(5,2) DEFAULT 0.00,
    CONSTRAINT chk_assortment_size CHECK (size > 0),
    CONSTRAINT chk_assortment_stock CHECK (stock_count >= 0),
    CONSTRAINT chk_assortment_discount CHECK (discount_percent >= 0 AND discount_percent <= 100),
    CONSTRAINT fk_assortment_shoe
        FOREIGN KEY (shoe_id) REFERENCES shoe(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- =========================================================
-- Таблица: customer
-- =========================================================
CREATE TABLE customer (
    id INT AUTO_INCREMENT PRIMARY KEY,
    fio VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(255) UNIQUE,
    registration_date DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- =========================================================
-- Таблица: `order`
-- =========================================================
CREATE TABLE `order` (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('ожидает оплаты', 'оплачен', 'в сборке', 'отправлен', 'доставлен', 'отменён')
        DEFAULT 'ожидает оплаты',
    total_amount DECIMAL(12,2) NOT NULL,
    shipping_address TEXT NOT NULL,
    payment_method ENUM('наличные', 'карта онлайн', 'перевод'),
    CONSTRAINT chk_order_total_amount CHECK (total_amount >= 0),
    CONSTRAINT fk_order_customer
        FOREIGN KEY (customer_id) REFERENCES customer(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- =========================================================
-- Таблица: order_item
-- =========================================================
CREATE TABLE order_item (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    assortment_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price_at_order DECIMAL(10,2) NOT NULL,
    CONSTRAINT chk_order_item_quantity CHECK (quantity > 0),
    CONSTRAINT chk_order_item_price CHECK (unit_price_at_order >= 0),
    CONSTRAINT fk_order_item_order
        FOREIGN KEY (order_id) REFERENCES `order`(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_order_item_assortment
        FOREIGN KEY (assortment_id) REFERENCES assortment(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- =========================================================
-- Индексы
-- =========================================================
CREATE INDEX idx_manufacturer_title ON manufacturer(title);
CREATE INDEX idx_shoe_category_name ON shoe_category(name);
CREATE INDEX idx_shoe_model_name ON shoe(model_name);
CREATE INDEX idx_shoe_manufacturer_id ON shoe(manufacturer_id);
CREATE INDEX idx_shoe_category_id ON shoe(category_id);
CREATE INDEX idx_assortment_shoe_id ON assortment(shoe_id);
CREATE INDEX idx_assortment_size_color ON assortment(size, color);
CREATE INDEX idx_customer_fio ON customer(fio);
CREATE INDEX idx_order_customer_id ON `order`(customer_id);
CREATE INDEX idx_order_status ON `order`(status);
CREATE INDEX idx_order_item_order_id ON order_item(order_id);
CREATE INDEX idx_order_item_assortment_id ON order_item(assortment_id);

-- =========================================================
-- Тестовые данные
-- =========================================================
INSERT INTO manufacturer (title, country, contact_info) VALUES
('Nike', 'США', 'Тел.: +1-800-344-6453; Email: support@nike.com; Адрес: Beaverton, Oregon, USA'),
('Adidas', 'Германия', 'Тел.: +49-9132-84-0; Email: service@adidas.com; Адрес: Herzogenaurach, Germany'),
('Puma', 'Германия', 'Тел.: +49-9132-81-0; Email: contact@puma.com; Адрес: Herzogenaurach, Germany'),
('New Balance', 'США', 'Тел.: +1-800-595-9138; Email: info@newbalance.com; Адрес: Boston, Massachusetts, USA'),
('Timberland', 'США', 'Тел.: +1-888-802-9947; Email: help@timberland.com; Адрес: Stratham, New Hampshire, USA');

INSERT INTO shoe_category (name) VALUES
('кроссовки'),
('полуботинки'),
('ботинки'),
('сапоги'),
('тапочки');

INSERT INTO shoe (manufacturer_id, category_id, model_name, description, base_price, release_year) VALUES
(1, 1, 'Air Max 270', 'Легкие повседневные кроссовки с воздушной амортизацией.', 12990.00, 2022),
(2, 1, 'Ultraboost 22', 'Беговые кроссовки с мягкой подошвой Boost.', 14990.00, 2022),
(3, 3, 'Puma Rebound', 'Высокие ботинки в спортивном стиле.', 8990.00, 2021),
(4, 2, '574 Classic', 'Универсальные полуботинки в ретро-стиле.', 10990.00, 2020),
(5, 3, '6-Inch Premium Boot', 'Классические кожаные ботинки для города и туризма.', 18990.00, 2023),
(1, 5, 'Comfort Slide', 'Удобные домашние тапочки с мягкой стелькой.', 2990.00, 2024);

INSERT INTO assortment (shoe_id, size, color, stock_count, discount_percent) VALUES
(1, 41.0, 'черный', 12, 10.00),
(1, 42.0, 'белый', 8, 5.00),
(2, 42.5, 'серый', 10, 15.00),
(2, 43.0, 'черный', 6, 0.00),
(3, 44.0, 'белый/красный', 5, 7.50),
(4, 41.5, 'темно-синий', 9, 0.00),
(5, 43.0, 'коричневый', 4, 12.00),
(5, 44.0, 'песочный', 3, 8.00),
(6, 40.0, 'серый', 20, 20.00),
(6, 41.0, 'черный', 15, 0.00);

INSERT INTO customer (fio, phone, email, registration_date) VALUES
('Иванов Иван Иванович', '+7-900-111-22-33', 'ivanov@example.com', '2026-04-01 10:15:00'),
('Петров Петр Сергеевич', '+7-900-222-33-44', 'petrov@example.com', '2026-04-03 12:00:00'),
('Сидорова Анна Павловна', '+7-900-333-44-55', 'sidorova@example.com', '2026-04-05 15:40:00'),
('Кузнецов Дмитрий Олегович', NULL, 'kuznetsov@example.com', '2026-04-07 09:25:00');

INSERT INTO `order` (customer_id, order_date, status, total_amount, shipping_address, payment_method) VALUES
(1, '2026-04-10 11:00:00', 'оплачен', 24432.50, 'г. Москва, ул. Ленина, д. 10, кв. 25', 'карта онлайн'),
(2, '2026-04-11 14:20:00', 'в сборке', 25026.95, 'г. Санкт-Петербург, Невский пр., д. 18', 'перевод'),
(3, '2026-04-12 16:45:00', 'ожидает оплаты', 32460.80, 'г. Казань, ул. Баумана, д. 7', 'наличные'),
(1, '2026-04-13 09:10:00', 'доставлен', 2392.00, 'г. Москва, ул. Тверская, д. 3', 'карта онлайн');

INSERT INTO order_item (order_id, assortment_id, quantity, unit_price_at_order) VALUES
(1, 1, 1, 11691.00),
(1, 3, 1, 12741.50),
(2, 5, 1, 8315.75),
(2, 7, 1, 16711.20),
(3, 8, 1, 17470.80),
(3, 4, 1, 14990.00),
(4, 9, 1, 2392.00);

-- =========================================================
-- Полезные проверочные запросы
-- =========================================================

-- 1. Все модели обуви с производителем и категорией
SELECT
    s.id,
    m.title AS manufacturer,
    c.name AS category,
    s.model_name,
    s.base_price,
    s.release_year
FROM shoe s
JOIN manufacturer m ON s.manufacturer_id = m.id
JOIN shoe_category c ON s.category_id = c.id
ORDER BY s.id;

-- 2. Ассортимент с расчетом цены со скидкой
SELECT
    a.id,
    s.model_name,
    a.size,
    a.color,
    a.stock_count,
    a.discount_percent,
    s.base_price,
    ROUND(s.base_price * (1 - a.discount_percent / 100), 2) AS final_price
FROM assortment a
JOIN shoe s ON a.shoe_id = s.id
ORDER BY a.id;

-- 3. Заказы клиентов
SELECT
    o.id AS order_id,
    c.fio,
    o.order_date,
    o.status,
    o.total_amount,
    o.payment_method
FROM `order` o
JOIN customer c ON o.customer_id = c.id
ORDER BY o.id;

-- 4. Состав заказов
SELECT
    oi.id,
    oi.order_id,
    s.model_name,
    a.size,
    a.color,
    oi.quantity,
    oi.unit_price_at_order,
    ROUND(oi.quantity * oi.unit_price_at_order, 2) AS line_total
FROM order_item oi
JOIN assortment a ON oi.assortment_id = a.id
JOIN shoe s ON a.shoe_id = s.id
ORDER BY oi.id;
