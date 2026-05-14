-- Задание номер 2
SELECT DISTINCT CAST(Дата AS date) AS Дата
FROM Продажи

--Задание номер 3
SELECT DISTINCT Покупатель AS Покупатель
FROM Продажи
ORDER BY Покупатель

--Задание номер 4
SELECT DISTINCT Товар AS Товар
FROM Продажи
WHERE Цена > 100

--Задание номер 5
SELECT DISTINCT Покупатель AS Покупатель
FROM Продажи
WHERE (CAST('2025-09-08' AS date) <= Дата) AND (Дата < CAST('2025-09-15' AS date))

--Задание номер 6
SELECT *, Колво * Цена AS Стоимость
FROM Продажи

--Задание номер 7
SELECT *
FROM Продажи
WHERE (CAST('2025-01-01' AS date) <= Дата) AND (Дата < CAST('2025-02-01' AS date)) AND ((LEFT(Покупатель, 1) = 'А') OR (Цена < 10 AND Колво > 5))
ORDER BY Дата, Цена desc

--Задание номер 8
SELECT DISTINCT top 5 Покупатель AS Покупатель
FROM Продажи
WHERE (CAST('2024-09-01' AS date) <= Дата) AND (Дата < CAST('2024-10-01' AS date))
ORDER BY Покупатель

--Задание номер 9
DECLARE @textparam nvarchar(50) = 'ПК'
SELECT DISTINCT Покупатель AS Покупатель
FROM Продажи
WHERE (Товар = @textparam)

--Задание номер 10
SELECT top 1 with ties нДок AS нДок
FROM Продажи
ORDER BY Колво * Цена desc

--Задание номер 11
SELECT нДок AS нДок, SUM(Колво * Цена) AS Итого
FROM Продажи
GROUP BY нДок
