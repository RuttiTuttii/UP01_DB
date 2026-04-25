-- решение за 3 день
-- практические работы 8, 9 и 10

CREATE DATABASE IF NOT EXISTS Market CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE Market;

SET NAMES cp866;

-- подготовка тестовых таблиц, если база пустая
CREATE TABLE IF NOT EXISTS authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    last_name VARCHAR(50) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    country VARCHAR(50) NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    author_id INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    release_year YEAR NULL,
    price DECIMAL(8,2) NOT NULL DEFAULT 0,
    pages INT NOT NULL DEFAULT 0,
    CONSTRAINT fk_books_authors FOREIGN KEY (author_id)
        REFERENCES authors(author_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

INSERT INTO authors (last_name, first_name, country)
SELECT 'Толстой', 'Лев', 'Россия'
WHERE NOT EXISTS (SELECT 1 FROM authors WHERE last_name = 'Толстой' AND first_name = 'Лев');

INSERT INTO authors (last_name, first_name, country)
SELECT 'Достоевский', 'Федор', 'Россия'
WHERE NOT EXISTS (SELECT 1 FROM authors WHERE last_name = 'Достоевский' AND first_name = 'Федор');

INSERT INTO authors (last_name, first_name, country)
SELECT 'Пушкин', 'Александр', 'Россия'
WHERE NOT EXISTS (SELECT 1 FROM authors WHERE last_name = 'Пушкин' AND first_name = 'Александр');

INSERT INTO authors (last_name, first_name, country)
SELECT 'Булгаков', 'Михаил', 'Россия'
WHERE NOT EXISTS (SELECT 1 FROM authors WHERE last_name = 'Булгаков' AND first_name = 'Михаил');

INSERT INTO authors (last_name, first_name, country)
SELECT 'Чехов', 'Антон', 'Россия'
WHERE NOT EXISTS (SELECT 1 FROM authors WHERE last_name = 'Чехов' AND first_name = 'Антон');

INSERT INTO authors (last_name, first_name, country)
SELECT 'Тестовый', 'Безкниг', 'Россия'
WHERE NOT EXISTS (SELECT 1 FROM authors WHERE last_name = 'Тестовый' AND first_name = 'Безкниг');

INSERT INTO books (author_id, title, release_year, price, pages)
SELECT a.author_id, 'Война и мир', 1869, 1200.00, 1225
FROM authors a
WHERE a.last_name = 'Толстой' AND a.first_name = 'Лев'
  AND NOT EXISTS (SELECT 1 FROM books WHERE title = 'Война и мир');

INSERT INTO books (author_id, title, release_year, price, pages)
SELECT a.author_id, 'Преступление и наказание', 1866, 650.00, 672
FROM authors a
WHERE a.last_name = 'Достоевский' AND a.first_name = 'Федор'
  AND NOT EXISTS (SELECT 1 FROM books WHERE title = 'Преступление и наказание');

INSERT INTO books (author_id, title, release_year, price, pages)
SELECT a.author_id, 'Евгений Онегин', 1833, 350.00, 224
FROM authors a
WHERE a.last_name = 'Пушкин' AND a.first_name = 'Александр'
  AND NOT EXISTS (SELECT 1 FROM books WHERE title = 'Евгений Онегин');

INSERT INTO books (author_id, title, release_year, price, pages)
SELECT a.author_id, 'Мастер и Маргарита', 1967, 800.00, 480
FROM authors a
WHERE a.last_name = 'Булгаков' AND a.first_name = 'Михаил'
  AND NOT EXISTS (SELECT 1 FROM books WHERE title = 'Мастер и Маргарита');

-- практическая работа 8
-- 8.5.1 отключить автокоммит и начать транзакцию
SET AUTOCOMMIT = 0;
BEGIN;

-- 8.5.2 добавить запись в authors, вывести таблицу, выполнить откат
INSERT INTO authors (last_name, first_name, country)
VALUES ('Гоголь', 'Николай', 'Россия');

SELECT *
FROM authors;

ROLLBACK;

SELECT *
FROM authors;

-- 8.5.3 добавить запись, создать точку сохранения, вывести таблицу
BEGIN;

INSERT INTO authors (last_name, first_name, country)
VALUES ('Лермонтов', 'Михаил', 'Россия');

SAVEPOINT savepoint_after_insert;

SELECT *
FROM authors;

-- 8.5.4 изменить запись, вывести таблицу, откатиться к точке сохранения
UPDATE authors
SET country = 'Российская империя'
WHERE last_name = 'Лермонтов' AND first_name = 'Михаил';

SELECT *
FROM authors;

ROLLBACK TO SAVEPOINT savepoint_after_insert;

SELECT *
FROM authors;

-- 8.5.5 изменить запись, вывести таблицу, зафиксировать транзакцию
UPDATE authors
SET country = 'Россия'
WHERE last_name = 'Лермонтов' AND first_name = 'Михаил';

SELECT *
FROM authors;

COMMIT;

SELECT *
FROM authors;

SET AUTOCOMMIT = 1;

-- практическая работа 9
-- 9.5.1 включение планировщика событий
SET GLOBAL event_scheduler = ON;

SHOW PROCESSLIST;

DROP TABLE IF EXISTS myEventTable;

CREATE TABLE myEventTable (
    id INT AUTO_INCREMENT PRIMARY KEY,
    eventTime DATETIME NOT NULL,
    eventName VARCHAR(50) NOT NULL
) ENGINE=InnoDB;

DROP EVENT IF EXISTS event1;
DROP EVENT IF EXISTS event2;
DROP EVENT IF EXISTS event3;
DROP EVENT IF EXISTS eventAuthor;

-- 9.5.1.4 событие каждые 10 секунд в течение 5 минут
CREATE EVENT event1
ON SCHEDULE EVERY 10 SECOND
STARTS CURRENT_TIMESTAMP
ENDS CURRENT_TIMESTAMP + INTERVAL 5 MINUTE
ON COMPLETION PRESERVE
COMMENT 'записывает дату, время и название события каждые 10 секунд в течение пяти минут'
DO
    INSERT INTO myEventTable (eventTime, eventName)
    VALUES (NOW(), 'event1');

-- 9.5.2 событие каждые 2 минуты 30 секунд в течение суток
CREATE EVENT event2
ON SCHEDULE EVERY 150 SECOND
STARTS CURRENT_TIMESTAMP
ENDS CURRENT_TIMESTAMP + INTERVAL 1 DAY
ON COMPLETION PRESERVE
COMMENT 'записывает дату, время и название события каждые две минуты тридцать секунд в течение суток'
DO
    INSERT INTO myEventTable (eventTime, eventName)
    VALUES (NOW(), 'event2');

-- 9.5.3 одноразовое событие в указанное время
CREATE EVENT event3
ON SCHEDULE AT CURRENT_TIMESTAMP + INTERVAL 1 MINUTE
ON COMPLETION NOT PRESERVE
COMMENT 'одноразовое событие, которое записывает дату, время и название события'
DO
    INSERT INTO myEventTable (eventTime, eventName)
    VALUES (NOW(), 'event3');

-- 9.5.4 ежедневное событие для удаления авторов без книг
CREATE EVENT eventAuthor
ON SCHEDULE EVERY 1 DAY
STARTS TIMESTAMP(CURRENT_DATE, '15:00:00')
ON COMPLETION PRESERVE
COMMENT 'ежедневно записывает факт запуска и удаляет авторов, у которых нет книг'
DO
BEGIN
    INSERT INTO myEventTable (eventTime, eventName)
    VALUES (NOW(), 'eventAuthor');

    DELETE a
    FROM authors a
    LEFT JOIN books b ON b.author_id = a.author_id
    WHERE b.book_id IS NULL;
END;

-- 9.5.5 просмотр созданных событий
SELECT
    EVENT_SCHEMA,
    EVENT_NAME,
    STATUS,
    EVENT_TYPE,
    EXECUTE_AT,
    INTERVAL_VALUE,
    INTERVAL_FIELD,
    STARTS,
    ENDS,
    EVENT_COMMENT
FROM information_schema.EVENTS
WHERE EVENT_SCHEMA = DATABASE();

SELECT *
FROM myEventTable
ORDER BY id;

-- практическая работа 10
-- 10.5.1 создать таблицу booksinfo
DROP TABLE IF EXISTS BooksInfo;

CREATE TABLE BooksInfo (
    book_code INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    author_last_name VARCHAR(50) NOT NULL,
    author_first_name VARCHAR(50) NOT NULL,
    release_year YEAR NULL,
    price DECIMAL(8,2) NOT NULL,
    page_count INT NOT NULL,
    PRIMARY KEY (book_code)
) ENGINE=InnoDB;

INSERT INTO BooksInfo (
    book_code,
    title,
    author_last_name,
    author_first_name,
    release_year,
    price,
    page_count
)
SELECT
    b.book_id,
    b.title,
    a.last_name,
    a.first_name,
    b.release_year,
    b.price,
    b.pages
FROM books b
JOIN authors a ON a.author_id = b.author_id;

SELECT *
FROM BooksInfo;

-- 10.5.2 сделать код книги автоинкрементным
ALTER TABLE BooksInfo
MODIFY book_code INT NOT NULL AUTO_INCREMENT;

-- 10.5.3 добавить ограничение уникальности на название, имя и фамилию автора
ALTER TABLE BooksInfo
ADD CONSTRAINT uq_booksinfo_title_author UNIQUE (title, author_first_name, author_last_name);

-- 10.5.4 добавить необязательное поле дата поступления
ALTER TABLE BooksInfo
ADD COLUMN arrival_date DATE NULL;

-- 10.5.5 удалить поле количество страниц
ALTER TABLE BooksInfo
DROP COLUMN page_count;

SELECT *
FROM BooksInfo;
