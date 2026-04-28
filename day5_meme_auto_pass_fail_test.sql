-- ультра-мемный автотест для практик 15 и 16
-- формат: PASS / FAIL
-- запускать после day5_works_15_16_17_solution.sql
-- если mysql ругается на права userTask - значит практику 17 проверять отдельным подключением

USE Market;

-- чистка старого бруда-следа
DELETE FROM order_items
WHERE order_id IN (
    SELECT order_id
    FROM orders
    WHERE customer_id IN (
        SELECT customer_id
        FROM customers
        WHERE login LIKE 'autobruda_%'
    )
);

DELETE FROM orders
WHERE customer_id IN (
    SELECT customer_id
    FROM customers
    WHERE login LIKE 'autobruda_%'
);

DELETE FROM customers
WHERE login LIKE 'autobruda_%';

DELETE FROM deleted_customers
WHERE login LIKE 'autobruda_%';

DELETE FROM logs
WHERE table_name IN ('books', 'orders');

-- автор и книга для тестов before/after по books и order_items
INSERT INTO authors (last_name, first_name, country)
SELECT 'Автотестов', 'Бруданутий', 'Покойоленд'
WHERE NOT EXISTS (
    SELECT 1
    FROM authors
    WHERE last_name = 'Автотестов'
      AND first_name = 'Бруданутий'
);

DELETE FROM books
WHERE title = 'ультра бруда 3000: покойо нажал execute и стало окак';

INSERT INTO books (author_id, title, genre, price, mass, pages, publish_year)
SELECT
    author_id,
    'ультра бруда 3000: покойо нажал execute и стало окак',
    'другое',
    9999.99,
    0.666,
    228,
    2026
FROM authors
WHERE last_name = 'Автотестов'
  AND first_name = 'Бруданутий';

SET @test_book_id := (
    SELECT book_id
    FROM books
    WHERE title = 'ультра бруда 3000: покойо нажал execute и стало окак'
    LIMIT 1
);

SET @price_after_trigger := (
    SELECT price
    FROM books
    WHERE book_id = @test_book_id
);

SELECT
    '01 books_before_insert ограничивает цену, иначе бруда купит весь маркет' AS test_name,
    CASE
        WHEN @price_after_trigger = 5000.00 THEN 'PASS'
        ELSE 'FAIL'
    END AS result,
    @price_after_trigger AS fact_value,
    'ожидалось 5000.00 после попытки вставить 9999.99' AS expected_value;

SET @book_insert_logs := (
    SELECT COUNT(*)
    FROM logs
    WHERE table_name = 'books'
      AND operation_name = 'insert'
);

SELECT
    '02 books_after_insert пишет лог, база сказала я видела этот кринж' AS test_name,
    CASE
        WHEN @book_insert_logs > 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS result,
    @book_insert_logs AS fact_value,
    'ожидался хотя бы 1 лог insert по books' AS expected_value;

UPDATE books
SET pages = pages + 1
WHERE book_id = @test_book_id;

SET @book_update_logs := (
    SELECT COUNT(*)
    FROM logs
    WHERE table_name = 'books'
      AND operation_name = 'update'
);

SELECT
    '03 books_after_update пишет лог, страницы стали тяжелее на один брудабайт' AS test_name,
    CASE
        WHEN @book_update_logs > 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS result,
    @book_update_logs AS fact_value,
    'ожидался хотя бы 1 лог update по books' AS expected_value;

-- заказчики с максимально бессмысленными, но валидными данными
INSERT INTO customers (last_name, first_name, login, address, phone)
VALUES
('Бруда', 'Пассович', 'autobruda_passovich', 'переулок where 1 равно 1 дом окак', '89990001001'),
('Фейл', 'Недопущенный', 'autobruda_failovich', 'улица syntax error но без syntax error 404', '89990001002'),
('Покойо', 'Откатный', 'autobruda_rollbackovich', 'район транзакционного сна 777', '89990001003'),
('Скуф', 'Селектович', 'autobruda_selectovich', 'остановка джоин налево потом group by', '89990001004');

SET @customers_count := (
    SELECT COUNT(*)
    FROM customers
    WHERE login LIKE 'autobruda_%'
);

SELECT
    '04 insert customers: мемный отряд зашел в базу без пропуска' AS test_name,
    CASE
        WHEN @customers_count = 4 THEN 'PASS'
        ELSE 'FAIL'
    END AS result,
    @customers_count AS fact_value,
    'ожидалось 4 заказчика autobruda_%' AS expected_value;

-- orders_before_insert должен заменить старую дату на NOW()
INSERT INTO orders (customer_id, order_datetime)
SELECT customer_id, '1999-09-09 09:09:09'
FROM customers
WHERE login = 'autobruda_passovich';

SET @test_order_id := LAST_INSERT_ID();

SET @order_year := (
    SELECT YEAR(order_datetime)
    FROM orders
    WHERE order_id = @test_order_id
);

SELECT
    '05 orders_before_insert заменяет древнюю дату, мамонт не прошел face control' AS test_name,
    CASE
        WHEN @order_year = YEAR(NOW()) THEN 'PASS'
        ELSE 'FAIL'
    END AS result,
    @order_year AS fact_value,
    CONCAT('ожидался текущий год: ', YEAR(NOW())) AS expected_value;

SET @order_insert_logs := (
    SELECT COUNT(*)
    FROM logs
    WHERE table_name = 'orders'
      AND operation_name = 'insert'
);

SELECT
    '06 orders_after_insert пишет лог, заказ родился и закричал окак' AS test_name,
    CASE
        WHEN @order_insert_logs > 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS result,
    @order_insert_logs AS fact_value,
    'ожидался хотя бы 1 лог insert по orders' AS expected_value;

-- проверка order_items_before_insert и order_items_after_insert
SET @quantity_before := (
    SELECT quantity
    FROM books
    WHERE book_id = @test_book_id
);

INSERT INTO order_items (order_id, book_id, quantity)
VALUES (@test_order_id, @test_book_id, 5);

SET @quantity_after := (
    SELECT quantity
    FROM books
    WHERE book_id = @test_book_id
);

SELECT
    '07 order_items_before_insert уменьшает склад, покойо унес 5 книг в рюкзаке' AS test_name,
    CASE
        WHEN @quantity_after = @quantity_before - 5 THEN 'PASS'
        ELSE 'FAIL'
    END AS result,
    CONCAT('before=', @quantity_before, ', after=', @quantity_after) AS fact_value,
    'ожидалось after = before - 5' AS expected_value;

SELECT
    '08 order_items_after_insert считает @orderCost, бруда экономика сошлась' AS test_name,
    CASE
        WHEN @orderCost = @price_after_trigger * 5 THEN 'PASS'
        ELSE 'FAIL'
    END AS result,
    @orderCost AS fact_value,
    @price_after_trigger * 5 AS expected_value;

-- rollback-тест: удаление должно откатиться вместе с архивом
START TRANSACTION;

SET @deleted_before_rollback := (
    SELECT COUNT(*)
    FROM deleted_customers
    WHERE login = 'autobruda_rollbackovich'
);

DELETE FROM customers
WHERE login = 'autobruda_rollbackovich';

SET @deleted_inside_transaction := (
    SELECT COUNT(*)
    FROM deleted_customers
    WHERE login = 'autobruda_rollbackovich'
);

ROLLBACK;

SET @customer_after_rollback := (
    SELECT COUNT(*)
    FROM customers
    WHERE login = 'autobruda_rollbackovich'
);

SET @deleted_after_rollback := (
    SELECT COUNT(*)
    FROM deleted_customers
    WHERE login = 'autobruda_rollbackovich'
);

SELECT
    '09 rollback возвращает заказчика, бруда проснулся и понял что delete приснился' AS test_name,
    CASE
        WHEN @deleted_inside_transaction > @deleted_before_rollback
         AND @customer_after_rollback = 1
         AND @deleted_after_rollback = @deleted_before_rollback THEN 'PASS'
        ELSE 'FAIL'
    END AS result,
    CONCAT(
        'inside_deleted=', @deleted_inside_transaction,
        ', customer_after_rollback=', @customer_after_rollback,
        ', archive_after_rollback=', @deleted_after_rollback
    ) AS fact_value,
    'внутри транзакции архив вырос, после rollback заказчик вернулся и архив откатился' AS expected_value;

-- настоящий delete без отката для проверки deleted_customers
SET @deleted_before_real_delete := (
    SELECT COUNT(*)
    FROM deleted_customers
    WHERE login = 'autobruda_failovich'
);

DELETE FROM customers
WHERE login = 'autobruda_failovich';

SET @customer_after_real_delete := (
    SELECT COUNT(*)
    FROM customers
    WHERE login = 'autobruda_failovich'
);

SET @deleted_after_real_delete := (
    SELECT COUNT(*)
    FROM deleted_customers
    WHERE login = 'autobruda_failovich'
);

SELECT
    '10 customers_after_delete архивирует удаленного, фейлович стал музейным экспонатом' AS test_name,
    CASE
        WHEN @customer_after_real_delete = 0
         AND @deleted_after_real_delete > @deleted_before_real_delete THEN 'PASS'
        ELSE 'FAIL'
    END AS result,
    CONCAT(
        'customer_after_delete=', @customer_after_real_delete,
        ', archive_before=', @deleted_before_real_delete,
        ', archive_after=', @deleted_after_real_delete
    ) AS fact_value,
    'ожидалось 0 в customers и +1 в deleted_customers' AS expected_value;

-- проверка customers_before_delete: удаление заказчика должно удалить его orders и order_items
INSERT INTO customers (last_name, first_name, login, address, phone)
VALUES ('Каскад', 'Брудаевич', 'autobruda_cascadeovich', 'улица delete cascade без cascade 505', '89990001005')
ON DUPLICATE KEY UPDATE address = VALUES(address);

INSERT INTO orders (customer_id, order_datetime)
SELECT customer_id, '1988-08-08 08:08:08'
FROM customers
WHERE login = 'autobruda_cascadeovich';

SET @cascade_order_id := LAST_INSERT_ID();

INSERT INTO order_items (order_id, book_id, quantity)
VALUES (@cascade_order_id, @test_book_id, 1);

DELETE FROM customers
WHERE login = 'autobruda_cascadeovich';

SET @cascade_orders_left := (
    SELECT COUNT(*)
    FROM orders
    WHERE order_id = @cascade_order_id
);

SET @cascade_items_left := (
    SELECT COUNT(*)
    FROM order_items
    WHERE order_id = @cascade_order_id
);

SELECT
    '11 customers_before_delete выносит заказы и состав, каскадович ушел без хвостов' AS test_name,
    CASE
        WHEN @cascade_orders_left = 0
         AND @cascade_items_left = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS result,
    CONCAT('orders_left=', @cascade_orders_left, ', items_left=', @cascade_items_left) AS fact_value,
    'ожидалось 0 orders и 0 order_items' AS expected_value;

-- orders_after_delete: если заказ удалили и у заказчика больше нет заказов, заказчик должен удалиться
INSERT INTO customers (last_name, first_name, login, address, phone)
VALUES ('Сирота', 'Заказович', 'autobruda_orphanovich', 'тупик после удаления заказа 0', '89990001006')
ON DUPLICATE KEY UPDATE address = VALUES(address);

INSERT INTO orders (customer_id, order_datetime)
SELECT customer_id, '1977-07-07 07:07:07'
FROM customers
WHERE login = 'autobruda_orphanovich';

SET @orphan_order_id := LAST_INSERT_ID();

DELETE FROM orders
WHERE order_id = @orphan_order_id;

SET @orphan_customer_left := (
    SELECT COUNT(*)
    FROM customers
    WHERE login = 'autobruda_orphanovich'
);

SET @order_delete_logs := (
    SELECT COUNT(*)
    FROM logs
    WHERE table_name = 'orders'
      AND operation_name = 'delete'
);

SELECT
    '12 orders_after_delete удаляет сиротского заказчика, orphanovich не вывез одиночество' AS test_name,
    CASE
        WHEN @orphan_customer_left = 0
         AND @order_delete_logs > 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS result,
    CONCAT('customer_left=', @orphan_customer_left, ', order_delete_logs=', @order_delete_logs) AS fact_value,
    'ожидалось 0 customers и лог delete по orders' AS expected_value;

-- сводка по результатам через временную таблицу
DROP TEMPORARY TABLE IF EXISTS bruda_test_results;
CREATE TEMPORARY TABLE bruda_test_results (
    test_name VARCHAR(255),
    result VARCHAR(10)
);

INSERT INTO bruda_test_results VALUES
('01 price cap', CASE WHEN @price_after_trigger = 5000.00 THEN 'PASS' ELSE 'FAIL' END),
('02 books insert log', CASE WHEN @book_insert_logs > 0 THEN 'PASS' ELSE 'FAIL' END),
('03 books update log', CASE WHEN @book_update_logs > 0 THEN 'PASS' ELSE 'FAIL' END),
('04 customers inserted', CASE WHEN @customers_count = 4 THEN 'PASS' ELSE 'FAIL' END),
('05 orders date replaced', CASE WHEN @order_year = YEAR(NOW()) THEN 'PASS' ELSE 'FAIL' END),
('06 orders insert log', CASE WHEN @order_insert_logs > 0 THEN 'PASS' ELSE 'FAIL' END),
('07 stock changed', CASE WHEN @quantity_after = @quantity_before - 5 THEN 'PASS' ELSE 'FAIL' END),
('08 order cost', CASE WHEN @orderCost = @price_after_trigger * 5 THEN 'PASS' ELSE 'FAIL' END),
('09 rollback', CASE WHEN @deleted_inside_transaction > @deleted_before_rollback AND @customer_after_rollback = 1 AND @deleted_after_rollback = @deleted_before_rollback THEN 'PASS' ELSE 'FAIL' END),
('10 deleted archive', CASE WHEN @customer_after_real_delete = 0 AND @deleted_after_real_delete > @deleted_before_real_delete THEN 'PASS' ELSE 'FAIL' END),
('11 cascade cleanup', CASE WHEN @cascade_orders_left = 0 AND @cascade_items_left = 0 THEN 'PASS' ELSE 'FAIL' END),
('12 orphan cleanup', CASE WHEN @orphan_customer_left = 0 AND @order_delete_logs > 0 THEN 'PASS' ELSE 'FAIL' END);

SELECT
    'ФИНАЛЬНАЯ СВОДКА БРУДА-АВТОТЕСТА' AS title,
    SUM(result = 'PASS') AS pass_count,
    SUM(result = 'FAIL') AS fail_count,
    CASE
        WHEN SUM(result = 'FAIL') = 0 THEN 'ВСЕ PASS, ПОКОЙО ДОВОЛЕН, БАЗА НЕ ОБИДЕЛАСЬ'
        ELSE 'ЕСТЬ FAIL, БРУДА ЗОВЕТ ОТЛАДКУ И ЧАЙ С ПЕЧЕНЬЕМ'
    END AS verdict
FROM bruda_test_results;

SELECT *
FROM bruda_test_results;

SELECT 'окак финал: если выше 12 PASS, то триггеры 15-16 прошли мемную сертификацию' AS final_message;
