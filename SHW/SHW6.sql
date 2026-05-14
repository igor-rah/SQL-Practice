--Задание 1
SELECT TOP 1 with ties T2.Название, T3.Название
FROM Карта.Маршруты AS T1 INNER JOIN Карта.Города as T2 ON
		T1.Город_ID_1 = T2.Город_ID
	INNER JOIN Карта.Города AS T3 ON
		T1.Город_ID_2 = T3.Город_ID
ORDER BY Расстояние

--Задание 2
SELECT TOP 1 with ties T2.Название, T3.Название
FROM Карта.Маршруты AS T1 INNER JOIN Карта.Города as T2 ON
		T1.Город_ID_1 = T2.Город_ID
	INNER JOIN Карта.Города AS T3 ON
		T1.Город_ID_2 = T3.Город_ID
WHERE T2.Область_ID = T3.Область_ID
ORDER BY Расстояние

--Задание 3
SELECT T1.Город_ID, T2.Город_ID
FROM Карта.Города AS T1, Карта.Города as T2
WHERE T1.Город_ID < T2.Город_ID

EXCEPT

SELECT Город_ID_1, Город_ID_2
FROM Карта.Маршруты

--Задание 4
SELECT Город_ID 
FROM Карта.Города

EXCEPT

SELECT Город_ID_2
FROM Карта.Маршруты

--Задание 5
SELECT Город_ID 
FROM Карта.Города

EXCEPT

SELECT Город_ID_1
FROM Карта.Маршруты

--Задание 6
DECLARE @city as int
SET @city = 5;

WITH ReadRoads AS (
    SELECT Город_ID_1, Город_ID_2, Расстояние
    FROM Карта.Маршруты

    UNION

    SELECT Город_ID_2, Город_ID_1, Расстояние
    FROM Карта.Маршруты
)

SELECT DISTINCT T3.Город_ID_2 AS Final_city
FROM ReadRoads AS T1 LEFT JOIN ReadRoads AS T2 ON
		T1.Город_ID_2 = T2.Город_ID_1
LEFT JOIN ReadRoads AS T3 ON
		T2.Город_ID_2 = T3.Город_ID_1
WHERE T3.Город_ID_2 is NOT NULL and T1.Город_ID_1 = @city

--Задание 7
WITH ReadRoads AS (
    SELECT Город_ID_1, Город_ID_2, Расстояние
    FROM Карта.Маршруты

    UNION

    SELECT Город_ID_2, Город_ID_1, Расстояние
    FROM Карта.Маршруты
)

SELECT DISTINCT T1.Город_ID_1, T2.Город_ID_2
FROM ReadRoads AS T1 LEFT JOIN ReadRoads AS T2 ON
		T1.Город_ID_2 = T2.Город_ID_1
WHERE T1.Расстояние + T2.Расстояние <
(
SELECT Расстояние 
FROM ReadRoads
WHERE Город_ID_1 = T1.Город_ID_1 AND Город_ID_2 = T2.Город_ID_2
)

--Задание 8
WITH ReadRoads AS (
    SELECT Город_ID_1, Город_ID_2, Расстояние
    FROM Карта.Маршруты

    UNION

    SELECT Город_ID_2, Город_ID_1, Расстояние
    FROM Карта.Маршруты
)
SELECT T1.Расписание_ID, SUM(T3.Расстояние) AS Res
FROM Карта.Расписание AS T1
INNER JOIN Карта.Расписание AS T2 ON 
    T2.Номер = T1.Номер + 1 AND T1.Расписание_ID = T2.Расписание_ID
INNER JOIN ReadRoads AS T3 ON 
    T1.Город_ID = T3.Город_ID_1 AND T2.Город_ID = T3.Город_ID_2
GROUP BY T1.Расписание_ID
HAVING COUNT(*) = (SELECT COUNT(*) - 1 FROM Карта.Расписание T4 WHERE T4.Расписание_ID = T1.Расписание_ID);
