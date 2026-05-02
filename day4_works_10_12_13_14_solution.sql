-- решение за 4 день
-- практические работы 10, 12, 13 и 14
-- практика 11 выполняется через gui mysql workbench

create database if not exists market character set utf8mb4 collate utf8mb4_unicode_ci;
use market;

set sql_safe_updates = 0;

-- подготовка минимальных данных для проверки заданий
insert into authors (last_name, first_name, country)
select 'Пушкин', 'Александр', 'Россия'
where not exists (
    select 1 from authors where last_name = 'Пушкин' and first_name = 'Александр'
);

insert into authors (last_name, first_name, country)
select 'Толстой', 'Лев', 'Россия'
where not exists (
    select 1 from authors where last_name = 'Толстой' and first_name = 'Лев'
);

insert into authors (last_name, first_name, country)
select 'Оруэлл', 'Джордж', 'Великобритания'
where not exists (
    select 1 from authors where last_name = 'Оруэлл' and first_name = 'Джордж'
);

insert into authors (last_name, first_name, country)
select 'Андерсен', 'Ганс', 'Дания'
where not exists (
    select 1 from authors where last_name = 'Андерсен' and first_name = 'Ганс'
);

insert into books (author_id, title, genre, price, pages, publish_year, quantity)
select author_id, 'Капитанская дочка', 'проза', 450.00, 256, 2018, 50
from authors
where last_name = 'Пушкин' and first_name = 'Александр'
  and not exists (select 1 from books where title = 'Капитанская дочка');

insert into books (author_id, title, genre, price, pages, publish_year, quantity)
select author_id, 'Война и мир', 'проза', 1200.00, 1225, 2020, 50
from authors
where last_name = 'Толстой' and first_name = 'Лев'
  and not exists (select 1 from books where title = 'Война и мир');

insert into books (author_id, title, genre, price, pages, publish_year, quantity)
select author_id, '1984', 'проза', 650.00, 352, 2019, 50
from authors
where last_name = 'Оруэлл' and first_name = 'Джордж'
  and not exists (select 1 from books where title = '1984');

insert into books (author_id, title, genre, price, pages, publish_year, quantity)
select author_id, 'Сказки для бруда и покойо', 'другое', 900.00, 300, 2024, 50
from authors
where last_name = 'Андерсен' and first_name = 'Ганс'
  and not exists (select 1 from books where title = 'Сказки для бруда и покойо');

insert into customers (login, last_name, first_name, address, phone)
select 'day4_customer', 'Иванов', 'Иван', 'улица проверки 10', '89990000010'
where not exists (select 1 from customers where login = 'day4_customer');

insert into orders (customer_id, order_datetime)
select customer_id, now()
from customers
where login = 'day4_customer'
  and not exists (
      select 1
      from orders
      where customer_id = customers.customer_id
  );

set @day4_order_id = (
    select order_id
    from orders
    inner join customers on customers.customer_id = orders.customer_id
    where customers.login = 'day4_customer'
    order by order_id
    limit 1
);

set @day4_book_id = (
    select book_id
    from books
    where title = 'Капитанская дочка'
    limit 1
);

insert into order_items (order_id, book_id, quantity)
select @day4_order_id, @day4_book_id, 2
where @day4_order_id is not null
  and @day4_book_id is not null
  and not exists (
      select 1
      from order_items
      where order_id = @day4_order_id and book_id = @day4_book_id
  );

-- практика 10 создание sql запросов на модификацию схемы бд

-- 10.5.1 создание таблицы booksinfo с данными о книгах

drop table if exists BooksInfo;

create table BooksInfo (
    book_id int not null,
    title varchar(100) not null,
    author_last_name varchar(50) not null,
    author_first_name varchar(50) not null,
    publish_year year null,
    price decimal(8,2) unsigned not null,
    pages smallint unsigned not null,
    primary key (book_id)
) engine = InnoDB default character set = utf8mb4 collate = utf8mb4_unicode_ci;

insert into BooksInfo (book_id, title, author_last_name, author_first_name, publish_year, price, pages)
select
    books.book_id,
    books.title,
    authors.last_name,
    authors.first_name,
    books.publish_year,
    books.price,
    books.pages
from books
inner join authors on authors.author_id = books.author_id;

-- 10.5.2 изменение кода книги на auto_increment

alter table BooksInfo
modify column book_id int not null auto_increment;

-- 10.5.3 ограничение уникальности на название, имя и фамилию автора

alter table BooksInfo
add constraint uq_booksinfo_title_author unique (title, author_first_name, author_last_name);

-- 10.5.4 добавление необязательного поля даты поступления

alter table BooksInfo
add column arrival_date date null;

-- 10.5.5 удаление поля количества страниц

alter table BooksInfo
drop column pages;

select 'практика 10 проверка booksinfo' as check_point;
describe BooksInfo;
select * from BooksInfo;
show index from BooksInfo;

-- практика 12 создание представлений

-- 12.5.1 представление заказов текущего года

drop view if exists view_current_year_orders;

create view view_current_year_orders as
select
    orders.order_id,
    orders.order_datetime,
    customers.customer_id,
    customers.login,
    customers.last_name,
    customers.first_name
from orders
inner join customers on customers.customer_id = orders.customer_id
where year(orders.order_datetime) = year(curdate());

select 'практика 12 пункт 5.1 заказы текущего года' as check_point;
select * from view_current_year_orders;

-- 12.5.2 представление информации о книге

drop view if exists view_books_info;

create view view_books_info as
select
    books.book_id,
    authors.last_name,
    authors.first_name,
    books.title,
    books.price
from books
inner join authors on authors.author_id = books.author_id;

select 'практика 12 пункт 5.2 информация о книгах' as check_point;
select * from view_books_info;

-- 12.5.3 представление авторов со списком книг

drop view if exists view_author_books;

create view view_author_books as
select
    authors.author_id,
    authors.last_name,
    authors.first_name,
    group_concat(distinct books.title order by books.title separator '; ') as books_list
from authors
left join books on books.author_id = authors.author_id
group by authors.author_id, authors.last_name, authors.first_name;

select 'практика 12 пункт 5.3 список книг автора' as check_point;
select * from view_author_books;

-- 12.5.4 представление с признаком слова сказки

drop view if exists view_books_skazki_flag;

create view view_books_skazki_flag as
select
    book_id,
    last_name,
    first_name,
    title,
    case
        when lower(title) like '%сказки%' then 'Да'
        else 'Нет'
    end as has_skazki,
    price
from view_books_info;

select 'практика 12 пункт 5.4 признак слова сказки' as check_point;
select * from view_books_skazki_flag;

-- 12.5.5 представление с ценовой категорией

drop view if exists view_books_price_category;

create view view_books_price_category as
select
    book_id,
    last_name,
    first_name,
    title,
    case
        when price < 1000 then 'до 1000'
        when price >= 1000 and price < 5000 then 'от 1000 до 5000'
        else 'от 5000'
    end as price_category,
    price
from view_books_info;

select 'практика 12 пункт 5.5 ценовая категория' as check_point;
select * from view_books_price_category;

-- практика 13 создание функций пользователя

-- 13.5.1 функция стоимости заказа

drop function if exists get_order_cost;

delimiter //
create function get_order_cost(p_order_id int)
returns decimal(12,2)
reads sql data
deterministic
begin
    declare result decimal(12,2);

    select sum(order_items.quantity * books.price)
    into result
    from order_items
    inner join books on books.book_id = order_items.book_id
    where order_items.order_id = p_order_id;

    return ifnull(result, 0);
end//
delimiter ;

select 'практика 13 пункт 5.1 стоимость заказа' as check_point;
select get_order_cost(@day4_order_id) as order_cost;

-- 13.5.2 функция имени и фамилии заказчика по логину

drop function if exists get_customer_upper_name;

delimiter //
create function get_customer_upper_name(p_login varchar(20))
returns varchar(120)
reads sql data
deterministic
begin
    declare result varchar(120);

    select upper(concat(first_name, ' ', last_name))
    into result
    from customers
    where login = p_login
    limit 1;

    return ifnull(result, 'заказчик не найден');
end//
delimiter ;

select 'практика 13 пункт 5.2 имя и фамилия заказчика заглавными' as check_point;
select get_customer_upper_name('day4_customer') as customer_name;

-- 13.5.3 функция списка книг автора

drop function if exists get_author_books_list;

delimiter //
create function get_author_books_list(p_author_id int)
returns text
reads sql data
deterministic
begin
    declare result text;

    select group_concat(distinct title order by title separator '; ')
    into result
    from books
    where author_id = p_author_id;

    return ifnull(result, 'книги не найдены');
end//
delimiter ;

set @day4_author_id = (
    select author_id
    from authors
    where last_name = 'Пушкин' and first_name = 'Александр'
    limit 1
);

select 'практика 13 пункт 5.3 список книг автора' as check_point;
select get_author_books_list(@day4_author_id) as author_books;

-- 13.5.4 функция количества авторов по стране

drop function if exists get_authors_count_by_country;

delimiter //
create function get_authors_count_by_country(p_country varchar(30))
returns int
reads sql data
deterministic
begin
    declare result int;

    select count(*)
    into result
    from authors
    where country = p_country;

    return result;
end//
delimiter ;

select 'практика 13 пункт 5.4 количество авторов по стране' as check_point;
select get_authors_count_by_country('Россия') as authors_count;

-- 13.5.5 функция прибыли за год

drop function if exists get_profit_by_year;

delimiter //
create function get_profit_by_year(p_year int)
returns decimal(12,2)
reads sql data
deterministic
begin
    declare result decimal(12,2);

    select sum(order_items.quantity * books.price)
    into result
    from orders
    inner join order_items on order_items.order_id = orders.order_id
    inner join books on books.book_id = order_items.book_id
    where year(orders.order_datetime) = p_year;

    return ifnull(result, 0);
end//
delimiter ;

select 'практика 13 пункт 5.5 прибыль за год' as check_point;
select get_profit_by_year(year(curdate())) as year_profit;

-- практика 14 создание хранимых процедур

-- 14.5.1 процедура добавления заказчика

drop procedure if exists add_customer;

delimiter //
create procedure add_customer(
    in p_login varchar(20),
    in p_first_name varchar(50),
    in p_last_name varchar(50),
    in p_address varchar(100),
    in p_phone varchar(20)
)
begin
    insert into customers (login, first_name, last_name, address, phone)
    values (p_login, p_first_name, p_last_name, p_address, p_phone);

    select last_insert_id() as new_customer_id;
end//
delimiter ;

set @new_customer_login = concat('day4_auto_', connection_id(), '_', floor(rand() * 100000));
select 'практика 14 пункт 5.1 добавление заказчика' as check_point;
call add_customer(@new_customer_login, 'Покойо', 'Брудский', 'улица автоматической сдачи 14', '89991414114');

-- 14.5.2 процедура поиска книг по части названия

drop procedure if exists find_books_by_title;

delimiter //
create procedure find_books_by_title(in p_text varchar(100))
begin
    select
        book_id,
        author_id,
        title,
        genre,
        price,
        pages,
        publish_year,
        quantity
    from books
    where title like concat('%', p_text, '%');
end//
delimiter ;

select 'практика 14 пункт 5.2 поиск книг по тексту' as check_point;
call find_books_by_title('Капитан');

-- 14.5.3 процедура добавления автора с выходным параметром

drop procedure if exists add_author;

delimiter //
create procedure add_author(
    in p_first_name varchar(50),
    in p_last_name varchar(50),
    in p_country varchar(30),
    out p_author_id int
)
begin
    insert into authors (first_name, last_name, country)
    values (p_first_name, p_last_name, p_country);

    set p_author_id = last_insert_id();
end//
delimiter ;

set @new_author_id = null;
set @new_author_last_name = concat('Автопрепод', connection_id(), floor(rand() * 100000));
select 'практика 14 пункт 5.3 добавление автора с out параметром' as check_point;
call add_author('Бруда', @new_author_last_name, 'Окакстан', @new_author_id);
select @new_author_id as new_author_id;

-- 14.5.4 процедура изменения стоимости книг на процент

drop procedure if exists update_book_prices_by_percent;

delimiter //
create procedure update_book_prices_by_percent(in p_percent decimal(6,2))
begin
    update books
    set price = round(price + price * p_percent / 100, 2);
end//
delimiter ;

select 'практика 14 пункт 5.4 изменение цен на процент внутри транзакции' as check_point;
start transaction;
select book_id, title, price as price_before from books order by book_id limit 5;
call update_book_prices_by_percent(5);
select book_id, title, price as price_after from books order by book_id limit 5;
rollback;

-- 14.5.5 процедура удаления авторов без книг

drop procedure if exists delete_authors_without_books;

delimiter //
create procedure delete_authors_without_books()
begin
    delete from authors
    where author_id not in (
        select distinct author_id
        from books
        where author_id is not null
    );
end//
delimiter ;

select 'практика 14 пункт 5.5 удаление авторов без книг внутри транзакции' as check_point;
start transaction;
insert into authors (last_name, first_name, country)
values (concat('Пустойавтор', connection_id(), floor(rand() * 100000)), 'Безкнигович', 'Нигде');
select count(*) as empty_authors_before
from authors
where author_id not in (
    select distinct author_id
    from books
    where author_id is not null
);
call delete_authors_without_books();
select count(*) as empty_authors_after
from authors
where author_id not in (
    select distinct author_id
    from books
    where author_id is not null
);
rollback;

-- контрольные вопросы практика 10
-- 10.8.1 первичный ключ задается предложением primary key.
-- 10.8.2 внешний ключ задается предложением foreign key references.
-- 10.8.3 ограничения задаются через not null, unique, check, default, primary key и foreign key.
-- 10.8.4 столбец или таблицу нельзя удалить, если на них ссылаются ограничения и связанные объекты без предварительного удаления связей.
-- 10.8.5 совместная уникальность пары столбцов задается ограничением unique на несколько столбцов.
-- 10.8.6 команда drop table удаляет таблицу из базы данных.
-- 10.8.7 индекс это структура для ускорения поиска строк по значениям столбцов.
-- 10.8.8 индексы ускоряют выборку, сортировку, соединение таблиц и проверку уникальности.
-- 10.8.9 индексы создаются в таблицах и могут быть связаны с ограничениями.

-- контрольные вопросы практика 12
-- 12.8.1 представление это сохраненный запрос, который выглядит как таблица, но обычно не хранит данные отдельно.
-- 12.8.2 представления нужны для упрощения запросов, ограничения доступа и повторного использования выборок.
-- 12.8.3 актуальность достигается тем, что данные берутся из исходных таблиц при обращении к представлению.
-- 12.8.4 представление может включать данные из нескольких таблиц одновременно.
-- 12.8.5 обновляемое представление должно быть построено на одной таблице без агрегатных функций, группировок и сложных вычислений.
-- 12.8.6 обновляемое представление создается командой create view на основе запроса, который допускает изменение исходной таблицы.

-- контрольные вопросы практика 13
-- 13.8.1 функции пользователя применяются для вычисления и возврата значения по заданным параметрам.
-- 13.8.2 скалярная функция возвращает одно значение, табличная возвращает набор строк.
-- 13.8.3 переменная объявляется через declare, значение присваивается через set или select into.
-- 13.8.4 параметры передаются в скобках при вызове функции.

-- контрольные вопросы практика 14
-- 14.8.1 хранимые процедуры это сохраненные sql блоки для выполнения повторяемых действий на сервере.
-- 14.8.2 функция возвращает значение и может использоваться в выражениях, процедура вызывается через call и может возвращать наборы данных и out параметры.
-- 14.8.3 выходные параметры задаются через out в списке параметров процедуры.
-- 14.8.4 процедуру может вызывать пользователь, которому выданы права execute.
