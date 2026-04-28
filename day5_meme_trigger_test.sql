-- мемный проверочный скрипт для практики 15-16
-- проверяет customers, deleted_customers, logs, orders, order_items и @orderCost
-- запускать после day5_works_15_16_17_solution.sql

USE Market;

-- стартовая разведка перед бруда-операцией
SELECT 'стартовый чек: живые заказчики до нашествия покойо' AS info;
SELECT * FROM customers;

SELECT 'стартовый чек: кладбище deleted_customers до бруда-шторминга' AS info;
SELECT * FROM deleted_customers;

SELECT 'стартовый чек: logs до того как база сказала окак' AS info;
SELECT * FROM logs;

-- чистим только наших тестовых мемных персонажей, чтобы не ломать чужие данные
DELETE FROM order_items
WHERE order_id IN (
    SELECT order_id
    FROM orders
    WHERE customer_id IN (
        SELECT customer_id
        FROM customers
        WHERE login IN (
            'bruda_bober_228',
            'pokoyo_legendarny',
            'okak_moment_real',
            'skibidi_sql_master',
            'sigma_pelmen_v_tumane'
        )
    )
);

DELETE FROM orders
WHERE customer_id IN (
    SELECT customer_id
    FROM customers
    WHERE login IN (
        'bruda_bober_228',
        'pokoyo_legendarny',
        'okak_moment_real',
        'skibidi_sql_master',
        'sigma_pelmen_v_tumane'
    )
);

DELETE FROM customers
WHERE login IN (
    'bruda_bober_228',
    'pokoyo_legendarny',
    'okak_moment_real',
    'skibidi_sql_master',
    'sigma_pelmen_v_tumane'
);

-- добавим автора и книгу для проверки books_before_insert и логов books
INSERT INTO authors (last_name, first_name, country)
SELECT 'Брудинский', 'Покойослав', 'Окакстан'
WHERE NOT EXISTS (
    SELECT 1
    FROM authors
    WHERE last_name = 'Брудинский'
      AND first_name = 'Покойослав'
);

-- цена 9999.99 должна стать 5000 из-за before insert trigger
INSERT INTO books (author_id, title, genre, price, mass, pages, publish_year)
SELECT
    author_id,
    'бруда брудское покойо окак: SQL вошел в чат',
    'другое',
    9999.99,
    0.777,
    322,
    2026
FROM authors
WHERE last_name = 'Брудинский'
  AND first_name = 'Покойослав'
  AND NOT EXISTS (
      SELECT 1
      FROM books
      WHERE title = 'бруда брудское покойо окак: SQL вошел в чат'
  );

SELECT 'проверка books_before_insert: цена должна быть не выше 5000' AS info;
SELECT book_id, title, price, quantity
FROM books
WHERE title = 'бруда брудское покойо окак: SQL вошел в чат';

-- транзакция для проверки отката: after delete сработает, но rollback откатит удаление и архив
START TRANSACTION;

INSERT INTO customers (last_name, first_name, login, address, phone)
VALUES
('Бруда', 'Бобер', 'bruda_bober_228', 'канавный вайб 404, подъезд окак', '89990000111'),
('Покойо', 'Легендарный', 'pokoyo_legendarny', 'улица брудского спокойствия 52', '89990000222'),
('Окак', 'Моментович', 'okak_moment_real', 'переулок зачем я это сделал 13', '89990000333'),
('Скибиди', 'Эс-Кью-Эльевич', 'skibidi_sql_master', 'проспект транзакций без паники 8', '89990000444'),
('Сигма', 'Пельменьвтумане', 'sigma_pelmen_v_tumane', 'жк нормисам не понять 777', '89990000555');

SELECT 'после insert внутри transaction: бруда-отряд появился' AS info;
SELECT customer_id, login, last_name, first_name, address, phone
FROM customers
WHERE login IN (
    'bruda_bober_228',
    'pokoyo_legendarny',
    'okak_moment_real',
    'skibidi_sql_master',
    'sigma_pelmen_v_tumane'
)
ORDER BY customer_id;

-- before insert orders должен сам поставить NOW(), даже если передали старую дату
INSERT INTO orders (customer_id, order_datetime)
SELECT customer_id, '2001-01-01 01:01:01'
FROM customers
WHERE login = 'bruda_bober_228';

INSERT INTO orders (customer_id, order_datetime)
SELECT customer_id, '2002-02-02 02:02:02'
FROM customers
WHERE login = 'pokoyo_legendarny';

SELECT 'проверка orders_before_insert: дата должна быть текущей, не древней как мамонт' AS info;
SELECT o.order_id, c.login, o.order_datetime
FROM orders AS o
INNER JOIN customers AS c ON c.customer_id = o.customer_id
WHERE c.login IN ('bruda_bober_228', 'pokoyo_legendarny')
ORDER BY o.order_id;

-- добавляем состав заказа, чтобы order_items_before_insert уменьшил quantity, а after insert записал @orderCost
INSERT INTO order_items (order_id, book_id, quantity)
SELECT
    o.order_id,
    b.book_id,
    3
FROM orders AS o
INNER JOIN customers AS c ON c.customer_id = o.customer_id
INNER JOIN books AS b ON b.title = 'бруда брудское покойо окак: SQL вошел в чат'
WHERE c.login = 'bruda_bober_228'
LIMIT 1;

SELECT 'проверка @orderCost после order_items_after_insert: цена * количество, бруда экономика' AS info;
SELECT @orderCost AS order_cost_bruda_moment;

SELECT 'проверка склада books.quantity после order_items_before_insert: минус 3, покойо грустит' AS info;
SELECT book_id, title, price, quantity
FROM books
WHERE title = 'бруда брудское покойо окак: SQL вошел в чат';

-- удаляем часть заказчиков внутри транзакции, чтобы проверить deleted_customers и rollback
DELETE FROM customers
WHERE login IN ('okak_moment_real', 'skibidi_sql_master');

SELECT 'после delete внутри transaction: двое улетели в deleted_customers, но это пока сон' AS info;
SELECT customer_id, login, last_name, first_name, deleted_at
FROM deleted_customers
WHERE login IN ('okak_moment_real', 'skibidi_sql_master')
ORDER BY deleted_at DESC;

SELECT 'логи внутри transaction: база шепчет insert update delete и немного окак' AS info;
SELECT log_id, table_name, operation_name, operation_datetime, current_user_name
FROM logs
ORDER BY log_id DESC
LIMIT 20;

ROLLBACK;

SELECT 'после rollback: удаленные вернулись, как будто бруда сон отменили' AS info;
SELECT customer_id, login, last_name, first_name
FROM customers
WHERE login IN (
    'bruda_bober_228',
    'pokoyo_legendarny',
    'okak_moment_real',
    'skibidi_sql_master',
    'sigma_pelmen_v_tumane'
)
ORDER BY customer_id;

-- финальная проверка без отката: создаем двух новых и реально удаляем
INSERT INTO customers (last_name, first_name, login, address, phone)
VALUES
('Финальный', 'Брудачело', 'bruda_bober_228', 'последний подъезд перед дедлайном 15', '89991112233'),
('Архивный', 'Покойоед', 'pokoyo_legendarny', 'кладбище контрольных вопросов 16', '89993332211')
ON DUPLICATE KEY UPDATE
    address = VALUES(address),
    phone = VALUES(phone);

SELECT 'перед финальным delete: два мемных свидетеля готовы стать историей' AS info;
SELECT customer_id, login, last_name, first_name, address
FROM customers
WHERE login IN ('bruda_bober_228', 'pokoyo_legendarny');

DELETE FROM customers
WHERE login IN ('bruda_bober_228', 'pokoyo_legendarny');

SELECT 'финальный deleted_customers: тут должны быть бруда и покойо после настоящего delete' AS info;
SELECT customer_id, login, last_name, first_name, address, deleted_at
FROM deleted_customers
WHERE login IN ('bruda_bober_228', 'pokoyo_legendarny')
ORDER BY deleted_at DESC;

SELECT 'финальные logs: если тут есть books/orders/delete insert update значит база не нормис, а сигма' AS info;
SELECT log_id, table_name, operation_name, operation_datetime, current_user_name
FROM logs
ORDER BY log_id DESC
LIMIT 30;

SELECT 'окак итог: тестовый скрипт дошел до конца без синтаксического кринжа' AS result;
