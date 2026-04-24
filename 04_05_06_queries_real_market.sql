USE Market;

-- практика 4, задание 5.1
-- книги русских авторов
SELECT
    a.last_name,
    a.first_name,
    b.title,
    b.price
FROM authors AS a
INNER JOIN books AS b
    ON b.author_id = a.author_id
WHERE a.country = 'Россия';

-- практика 4, задание 5.2
-- количество книг каждого автора
SELECT
    a.last_name,
    a.first_name,
    COUNT(b.book_id) AS books_count
FROM authors AS a
LEFT JOIN books AS b
    ON b.author_id = a.author_id
GROUP BY a.author_id, a.last_name, a.first_name
ORDER BY a.last_name, a.first_name;

-- практика 4, задание 5.3
-- авторы без книг со словами linux или windows
SELECT
    a.first_name,
    a.last_name
FROM authors AS a
WHERE a.author_id NOT IN (
    SELECT b.author_id
    FROM books AS b
    WHERE b.title LIKE '%linux%'
       OR b.title LIKE '%windows%'
);

-- практика 4, задание 5.4
-- статистика заказов по каждому заказчику
SELECT
    c.login,
    COUNT(DISTINCT o.order_id) AS orders_count,
    COALESCE(SUM(oi.quantity), 0) AS books_count,
    COALESCE(SUM(oi.quantity * b.price), 0) AS total_sum
FROM customers AS c
LEFT JOIN orders AS o
    ON o.customer_id = c.customer_id
LEFT JOIN order_items AS oi
    ON oi.order_id = o.order_id
LEFT JOIN books AS b
    ON b.book_id = oi.book_id
GROUP BY c.customer_id, c.login
ORDER BY c.login;

-- практика 4, задание 5.5
-- заказчики, купившие больше десяти книг
SELECT
    c.login,
    COUNT(DISTINCT o.order_id) AS orders_count,
    SUM(oi.quantity) AS books_count
FROM customers AS c
INNER JOIN orders AS o
    ON o.customer_id = c.customer_id
INNER JOIN order_items AS oi
    ON oi.order_id = o.order_id
GROUP BY c.customer_id, c.login
HAVING SUM(oi.quantity) > 10
ORDER BY c.login;

-- практика 5, задание 5.1
-- создание и заполнение временной таблицы книг
DROP TABLE IF EXISTS tempBooks;

CREATE TABLE tempBooks (
    last_name VARCHAR(50) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    title VARCHAR(50) NOT NULL,
    price DECIMAL(6,2) UNSIGNED NOT NULL
) ENGINE=InnoDB;

INSERT INTO tempBooks (last_name, first_name, title, price)
SELECT
    a.last_name,
    a.first_name,
    b.title,
    b.price
FROM authors AS a
INNER JOIN books AS b
    ON b.author_id = a.author_id;

SELECT *
FROM tempBooks;

-- практика 5, задание 5.2
-- удаление книг со словом компьютер
DELETE FROM tempBooks
WHERE title LIKE '%компьютер%';

SELECT *
FROM tempBooks;

-- практика 5, задание 5.3
-- изменение цены в зависимости от автора
UPDATE tempBooks
SET price = CASE
    WHEN last_name = 'Пушкин' THEN price * 2
    WHEN last_name = 'Иванов' THEN GREATEST(price - 50, 0)
    ELSE price
END;

SELECT *
FROM tempBooks;

-- практика 5, задание 5.4
-- очистка временной таблицы
TRUNCATE TABLE tempBooks;

SELECT *
FROM tempBooks;

-- практика 5, задание 5.5
-- увеличение цены книг русских авторов
UPDATE books AS b
INNER JOIN authors AS a
    ON a.author_id = b.author_id
SET b.price = b.price + 100
WHERE a.country = 'Россия';

SELECT
    a.last_name,
    a.first_name,
    b.title,
    b.price
FROM books AS b
INNER JOIN authors AS a
    ON a.author_id = b.author_id
WHERE a.country = 'Россия';

-- практика 5, задание 5.6
-- удаление заказчиков без заказов
DELETE FROM customers
WHERE customer_id NOT IN (
    SELECT customer_id
    FROM orders
);

SELECT *
FROM customers;

-- практика 5, задание 5.7
-- добавление автора через replace
REPLACE INTO authors (last_name, first_name, country)
VALUES ('Булгаков', 'Михаил', 'Россия');

SELECT *
FROM authors
WHERE last_name = 'Булгаков'
  AND first_name = 'Михаил';

-- практика 5, задание 5.8
-- добавление автора через on duplicate key update
INSERT INTO authors (last_name, first_name, country)
VALUES ('Пушкин', 'Александр', 'Россия')
ON DUPLICATE KEY UPDATE
    country = VALUES(country);

SELECT *
FROM authors
WHERE last_name = 'Пушкин'
  AND first_name = 'Александр';

-- практика 6, задание 5.1
-- текущая база, пользователь, дата и время
SELECT
    DATABASE() AS current_database,
    USER() AS current_user,
    CURDATE() AS current_date,
    CURTIME() AS current_time,
    NOW() AS current_datetime;

-- практика 6, задание 5.2
-- заказы текущего года
SELECT
    order_id,
    DATE(order_datetime) AS order_date,
    DAY(order_datetime) AS order_day,
    MONTH(order_datetime) AS order_month
FROM orders
WHERE YEAR(order_datetime) = YEAR(CURDATE())
ORDER BY order_datetime;

-- практика 6, задание 5.3
-- замена двойных пробелов и округление цены до десятков
UPDATE books
SET
    title = REPLACE(title, '  ', ' '),
    price = ROUND(price, -1);

SELECT
    book_id,
    title,
    price
FROM books;

-- практика 6, задание 5.4
-- автор и книга с ценой
SELECT
    CONCAT(a.last_name, ' ', LEFT(a.first_name, 1), '.') AS author_name,
    CONCAT_WS(' ', b.title, CONCAT(b.price, ' руб.')) AS book_info
FROM authors AS a
INNER JOIN books AS b
    ON b.author_id = a.author_id
ORDER BY a.last_name, a.first_name, b.title;

-- практика 6, задание 5.5
-- книги каждого автора через group_concat
SELECT
    a.last_name,
    a.first_name,
    GROUP_CONCAT(DISTINCT b.title ORDER BY b.title ASC SEPARATOR ', ') AS books
FROM authors AS a
LEFT JOIN books AS b
    ON b.author_id = a.author_id
GROUP BY a.author_id, a.last_name, a.first_name
ORDER BY a.last_name, a.first_name;

-- практика 6, задание 5.6
-- данные о заказчиках с заменой пустых значений
SELECT
    customer_id,
    login,
    last_name,
    first_name,
    NULLIF(address, '') AS address,
    IFNULL(phone, '--') AS phone
FROM customers
ORDER BY login;

-- практика 6, задание 5.7
-- нумерация книг по названию
SELECT
    ROW_NUMBER() OVER (ORDER BY title) AS row_number,
    book_id,
    title,
    price
FROM books
ORDER BY title;

-- практика 6, задание 5.8
-- топ три цены в каждом жанре
SELECT
    genre,
    title,
    price,
    price_rank
FROM (
    SELECT
        genre,
        title,
        price,
        DENSE_RANK() OVER (PARTITION BY genre ORDER BY price DESC) AS price_rank
    FROM books
) AS ranked_books
WHERE price_rank <= 3
ORDER BY genre, price_rank, title;
