-- Задача 1
-- 
-- Условие
-- 
-- Определить, какие клиенты сделали более двух бронирований в разных отелях, и вывести информацию о каждом таком клиенте,
-- включая его имя, электронную почту, телефон, общее количество бронирований, а также список отелей, в которых они бронировали номера
-- (объединенные в одно поле через запятую с помощью CONCAT). Также подсчитать среднюю длительность их пребывания (в днях) по всем бронированиям.
-- Отсортировать результаты по количеству бронирований в порядке убывания.


SELECT 
    C.name AS customer_name,
    C.email,
    C.phone,
    COUNT(B.ID_booking) AS total_bookings,
    GROUP_CONCAT(DISTINCT H.name SEPARATOR ', ') AS hotels_booked,
    AVG(DATEDIFF(B.check_out_date, B.check_in_date)) AS avg_stay_duration
FROM 
    Customer C
JOIN 
    Booking B ON C.ID_customer = B.ID_customer
JOIN 
    Room R ON B.ID_room = R.ID_room
JOIN 
    Hotel H ON R.ID_hotel = H.ID_hotel
GROUP BY 
    C.ID_customer
HAVING 
    COUNT(DISTINCT H.ID_hotel) >= 2 AND total_bookings > 2
ORDER BY 
    total_bookings DESC;
	
	
-- Задача 2
-- 
-- Условие
-- 
-- Необходимо провести анализ клиентов, которые сделали более двух бронирований в разных отелях и потратили более 500 долларов на свои бронирования. Для этого:
-- 
-- Определить клиентов, которые сделали более двух бронирований и забронировали номера в более чем одном отеле.
-- Вывести для каждого такого клиента следующие данные: ID_customer, имя, общее количество бронирований,
-- общее количество уникальных отелей, в которых они бронировали номера, и общую сумму, потраченную на бронирования.
-- Также определить клиентов, которые потратили более 500 долларов на бронирования, и вывести для них ID_customer, имя, общую сумму
-- потраченную на бронирования, и общее количество бронирований.
-- В результате объединить данные из первых двух пунктов, чтобы получить список клиентов, которые соответствуют условиям обоих запросов.
-- Отобразить поля: ID_customer, имя, общее количество бронирований, общую сумму, потраченную на бронирования, и общее количество уникальных отелей.
-- Результаты отсортировать по общей сумме, потраченной клиентами, в порядке возрастания.


WITH CustomerBookings AS (
    SELECT
        C.ID_customer,
        C.name,
        COUNT(B.ID_booking) AS total_bookings,
        COUNT(DISTINCT H.ID_hotel) AS total_unique_hotels,
        SUM(R.price) AS total_spent
    FROM
        Customer C
    JOIN
        Booking B ON C.ID_customer = B.ID_customer
    JOIN
        Room R ON B.ID_room = R.ID_room
    JOIN
        Hotel H ON R.ID_hotel = H.ID_hotel
    GROUP BY
        C.ID_customer, C.name
    HAVING
        COUNT(DISTINCT H.ID_hotel) > 1
        AND COUNT(B.ID_booking) > 2
),
HighSpenders AS (
    SELECT
        C.ID_customer,
        C.name,
        SUM(R.price) AS total_spent,
        COUNT(B.ID_booking) AS total_bookings
    FROM
        Customer C
    JOIN
        Booking B ON C.ID_customer = B.ID_customer
    JOIN
        Room R ON B.ID_room = R.ID_room
    GROUP BY
        C.ID_customer, C.name
    HAVING
        total_spent > 500
)
SELECT
    CB.ID_customer,
    CB.name,
    CB.total_bookings,
    CB.total_spent,
    CB.total_unique_hotels
FROM
    CustomerBookings CB
JOIN
    HighSpenders HS ON CB.ID_customer = HS.ID_customer
ORDER BY
    CB.total_spent ASC;
	
	
-- Задача 3
-- 
-- Условие
-- 
-- Вам необходимо провести анализ данных о бронированиях в отелях и определить предпочтения клиентов по типу отелей. Для этого выполните следующие шаги:
-- 
--     Категоризация отелей.
-- 
--     Определите категорию каждого отеля на основе средней стоимости номера:
--         «Дешевый»: средняя стоимость менее 175 долларов.
--         «Средний»: средняя стоимость от 175 до 300 долларов.
--         «Дорогой»: средняя стоимость более 300 долларов.
--     Анализ предпочтений клиентов.
-- 
--     Для каждого клиента определите предпочитаемый тип отеля на основании условия ниже:
--         Если у клиента есть хотя бы один «дорогой» отель, присвойте ему категорию «дорогой».
--         Если у клиента нет «дорогих» отелей, но есть хотя бы один «средний», присвойте ему категорию «средний».
--         Если у клиента нет «дорогих» и «средних» отелей, но есть «дешевые», присвойте ему категорию предпочитаемых отелей «дешевый».
--     Вывод информации.
-- 
--     Выведите для каждого клиента следующую информацию:
--         ID_customer: уникальный идентификатор клиента.
--         name: имя клиента.
--         preferred_hotel_type: предпочитаемый тип отеля.
--         visited_hotels: список уникальных отелей, которые посетил клиент.
--     Сортировка результатов.
-- 
--     Отсортируйте клиентов так, чтобы сначала шли клиенты с «дешевыми» отелями, затем со «средними» и в конце — с «дорогими».


WITH HotelCategories AS (
    SELECT
        H.ID_hotel,
        H.name AS hotel_name,
        CASE
            WHEN AVG(R.price) < 175 THEN 'Дешевый'
            WHEN AVG(R.price) BETWEEN 175 AND 300 THEN 'Средний'
            ELSE 'Дорогой'
        END AS hotel_category
    FROM
        Hotel H
    JOIN
        Room R ON H.ID_hotel = R.ID_hotel
    GROUP BY
        H.ID_hotel, H.name
),
CustomerPreferences AS (
    SELECT
        C.ID_customer,
        C.name AS customer_name,
        MAX(HC.hotel_category) AS preferred_hotel_type,
        GROUP_CONCAT(DISTINCT HC.hotel_name ORDER BY HC.hotel_name ASC SEPARATOR ', ') AS visited_hotels
    FROM
        Customer C
    JOIN
        Booking B ON C.ID_customer = B.ID_customer
    JOIN
        Room R ON B.ID_room = R.ID_room
    JOIN
        HotelCategories HC ON R.ID_hotel = HC.ID_hotel
    GROUP BY
        C.ID_customer, C.name
)
SELECT
    ID_customer,
    customer_name AS name,
    preferred_hotel_type,
    visited_hotels
FROM
    CustomerPreferences
ORDER BY
    CASE
        WHEN preferred_hotel_type = 'Дешевый' THEN 1
        WHEN preferred_hotel_type = 'Средний' THEN 2
        WHEN preferred_hotel_type = 'Дорогой' THEN 3
    END;
