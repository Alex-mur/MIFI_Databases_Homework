-- Задача 1
-- 
-- Условие
-- 
-- Определить, какие автомобили из каждого класса имеют наименьшую среднюю позицию в гонках,
-- и вывести информацию о каждом таком автомобиле для данного класса,
-- включая его класс, среднюю позицию и количество гонок, в которых он участвовал.
-- Также отсортировать результаты по средней позиции.

WITH CarAvgPosition AS (
    SELECT
        c.class,
        c.name AS car_name,
        AVG(r.position) AS average_position,
        COUNT(r.race) AS race_count
    FROM
        Cars c
    JOIN
        Results r ON c.name = r.car
    GROUP BY
        c.class, c.name
),
MinAvgPositionPerClass AS (
    SELECT
        class,
        MIN(average_position) AS min_avg_position
    FROM
        CarAvgPosition
    GROUP BY
        class
)
SELECT
    cap.car_name,
    cap.class,
    cap.average_position,
    cap.race_count
FROM
    CarAvgPosition cap
JOIN
    MinAvgPositionPerClass mapc ON cap.class = mapc.class AND cap.average_position = mapc.min_avg_position
ORDER BY
    cap.average_position;
	
	
-- Задача 2
-- 
-- Условие
-- 
-- Определить автомобиль, который имеет наименьшую среднюю позицию в гонках среди всех автомобилей,
-- и вывести информацию об этом автомобиле, включая его класс, среднюю позицию, количество гонок, в которых он участвовал,
-- и страну производства класса автомобиля.
-- Если несколько автомобилей имеют одинаковую наименьшую среднюю позицию,
-- выбрать один из них по алфавиту (по имени автомобиля).

WITH CarAvgPosition AS (                 
    SELECT                               
        c.name AS car_name,              
        c.class AS car_class,            
        AVG(r.position) AS average_positi
        COUNT(r.race) AS race_count      
    FROM                                 
        Cars c                           
    JOIN                                 
        Results r ON c.name = r.car      
    GROUP BY                             
        c.name, car_class                
),                                       
MinAvgPositionCar AS (                   
    SELECT                               
        car_name,                        
        car_class,                       
        average_position,                
        race_count                       
    FROM                                 
        CarAvgPosition                   
    ORDER BY                             
        average_position, car_name       
    LIMIT 1                              
)                                        
SELECT                                   
    m.car_name,                          
    m.car_class,                         
    m.average_position,                  
    m.race_count,                        
    cl.country AS car_country            
FROM                                     
    MinAvgPositionCar m                  
JOIN                                     
    Classes cl ON m.car_class = cl.class;
	

-- Задача 3
-- 
-- Условие
-- 
-- Определить классы автомобилей, которые имеют наименьшую среднюю позицию в гонках,
-- и вывести информацию о каждом автомобиле из этих классов, включая его имя,
-- среднюю позицию, количество гонок, в которых он участвовал, страну производства класса автомобиля,
-- а также общее количество гонок, в которых участвовали автомобили этих классов.
-- Если несколько классов имеют одинаковую среднюю позицию, выбрать все из них.


WITH ClassAvgPosition AS (
    SELECT
        c.class,
        AVG(r.position) AS avg_position
    FROM
        Cars c
    JOIN
        Results r ON c.name = r.car
    GROUP BY
        c.class
),
MinAvgPositionClass AS (
    SELECT
        class,
        avg_position
    FROM
        ClassAvgPosition
    WHERE
        avg_position = (SELECT MIN(avg_position) FROM ClassAvgPosition)
),
CarInfo AS (
    SELECT
        c.name AS car_name,
        c.class,
        AVG(r.position) AS avg_position,
        COUNT(r.race) AS race_count,
        cl.country,
        (SELECT COUNT(*) FROM Results r2 JOIN Cars c2 ON r2.car = c2.name WHERE c2.class = c.class) AS total_races_for_class
    FROM
        Cars c
    JOIN
        Results r ON c.name = r.car
    JOIN
        Classes cl ON c.class = cl.class
    GROUP BY
        c.name, c.class, cl.country
)
SELECT
    ci.car_name,
    ci.class,
    ci.avg_position,
    ci.race_count,
    ci.country,
    ci.total_races_for_class
FROM
    CarInfo ci
JOIN
    MinAvgPositionClass mapc ON ci.class = mapc.class
ORDER BY
    ci.class, ci.car_name;
	
	
-- Задача 4
-- 
-- Условие
-- 
-- Определить, какие автомобили имеют среднюю позицию лучше (меньше) средней позиции всех автомобилей в своем классе
-- (то есть автомобилей в классе должно быть минимум два, чтобы выбрать один из них). Вывести информацию об этих автомобилях,
-- включая их имя, класс, среднюю позицию, количество гонок, в которых они участвовали, и страну производства класса автомобиля.
-- Также отсортировать результаты по классу и затем по средней позиции в порядке возрастания.

WITH CarAvgPosition AS (
    SELECT
        c.name AS car_name,
        c.class,
        AVG(r.position) AS avg_position,
        COUNT(r.race) AS race_count
    FROM
        Cars c
    JOIN
        Results r ON c.name = r.car
    GROUP BY
        c.name, c.class
),
ClassAvgPosition AS (
    SELECT
        c.class,
        AVG(r.position) AS class_avg_position,
        COUNT(DISTINCT c.name) AS car_count
    FROM
        Cars c
    JOIN
        Results r ON c.name = r.car
    GROUP BY
        c.class
)
SELECT
    cap.car_name,
    cap.class,
    cap.avg_position,
    cap.race_count,
    cl.country
FROM
    CarAvgPosition cap
JOIN
    ClassAvgPosition clap ON cap.class = clap.class
JOIN
    Classes cl ON cap.class = cl.class
WHERE
    cap.avg_position < clap.class_avg_position
    AND clap.car_count >= 2
ORDER BY
    cap.class, cap.avg_position;
	
	
-- Задача 5
-- 
-- Условие
-- 
-- Определить, какие классы автомобилей имеют наибольшее количество автомобилей с низкой средней позицией (больше 3.0)
-- и вывести информацию о каждом автомобиле из этих классов, включая его имя, класс, среднюю позицию, количество гонок,
-- в которых он участвовал, страну производства класса автомобиля, а также общее количество гонок для каждого класса.
-- Отсортировать результаты по количеству автомобилей с низкой средней позицией.


WITH CarAvgPosition AS (
    SELECT
        c.name AS car_name,
        c.class,
        AVG(r.position) AS avg_position,
        COUNT(r.race) AS race_count
    FROM
        Cars c
    JOIN
        Results r ON c.name = r.car
    GROUP BY
        c.name, c.class
),
LowPositionCars AS (
    SELECT
        car_name,
        class,
        avg_position,
        race_count
    FROM
        CarAvgPosition
    WHERE
        avg_position > 3.0
),
ClassLowPositionCount AS (
    SELECT
        class,
        COUNT(car_name) AS low_position_car_count
    FROM
        LowPositionCars
    GROUP BY
        class
),
MaxLowPositionClass AS (
    SELECT
        class,
        low_position_car_count
    FROM
        ClassLowPositionCount
    WHERE
        low_position_car_count = (SELECT MAX(low_position_car_count) FROM ClassLowPositionCount)
),
ClassTotalRaces AS (
    SELECT
        c.class,
        COUNT(r.race) AS total_races_for_class
    FROM
        Cars c
    JOIN
        Results r ON c.name = r.car
    GROUP BY
        c.class
)
SELECT
    lpc.car_name,
    lpc.class,
    lpc.avg_position,
    lpc.race_count,
    cl.country,
    ctr.total_races_for_class
FROM
    LowPositionCars lpc
JOIN
    MaxLowPositionClass mlpc ON lpc.class = mlpc.class
JOIN
    Classes cl ON lpc.class = cl.class
JOIN
    ClassTotalRaces ctr ON lpc.class = ctr.class
ORDER BY
    mlpc.low_position_car_count, lpc.class, lpc.car_name;

