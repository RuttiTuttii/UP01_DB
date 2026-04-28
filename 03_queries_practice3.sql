USE Market;

-- 5.1 получить все данные обо всех авторах
SELECT *
FROM authors;

-- 5.2 получить выборку данных, состоящую из столбцов Фамилия и Имя
-- для первых трех авторов
SELECT last_name, first_name
FROM authors
LIMIT 3;

-- 5.3 получить список стран происхождения авторов без дубликатов,
-- упорядоченный по алфавиту
SELECT DISTINCT country
FROM authors
ORDER BY country;

-- 5.4 получить выборку данных о книгах/заказчиках из четырех столбцов:
-- 1 столбец — идентификатор книги;
-- 2 столбец — название книги;
-- 3 столбец — скидка 5%;
-- 4 столбец — цена со скидкой
SELECT
    book_id,
    title,
    5 AS discount_percent,
    ROUND(price * 0.95, 2) AS discounted_price
FROM books;

-- 5.5 получить выборку данных, содержащую информацию о книгах
-- с указанием категории цены
SELECT
    book_id,
    title,
    price,
    CASE
        WHEN price < 100 THEN 'дешевые'
        WHEN price <= 1000 THEN 'средние'
        ELSE 'дорогие'
    END AS price_category
FROM books
ORDER BY price DESC;

-- 5.6 получить выборку данных, содержащую Логин, Фамилию, Имя и Телефон
-- для всех заказчиков, у которых указан телефон
SELECT login, last_name, first_name, phone
FROM customers
WHERE phone IS NOT NULL;

-- 5.7 получить выборку данных, содержащую наименования книг,
-- которые содержат подстроку "компьютер" % _ 
SELECT title
FROM books
WHERE title LIKE '%компьютер%';

-- 5.8 получить выборку данных, содержащую минимальную, максимальную и среднюю
-- стоимость книг
SELECT
    MIN(price) AS min_price,
    MAX(price) AS max_price,
    AVG(price) AS avg_price
FROM books;

-- 5.9 получить выборку данных, содержащую идентификатор автора,
-- уникальные названия книг и количество написанных автором книг
-- под каждым названием книг (используем COUNT)
SELECT
    author_id,
    title,
    COUNT(*) AS books_count
FROM books
GROUP BY author_id, title;

-- Альтернативно: сколько книг написал каждый автор
SELECT
    author_id,
    COUNT(*) AS books_count
FROM books
GROUP BY author_id;

-- 5.10 получить выборку данных, содержащую названия стран и количество
-- авторов в них для тех стран, к которым приписано больше одного автора
SELECT
    country,
    COUNT(*) AS authors_count
FROM authors
GROUP BY country
HAVING COUNT(*) > 1;
