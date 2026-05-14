--Задача 1
CREATE TABLE FT (b int, e int, w int)

INSERT FT
VALUES (1, 2, 1), (1, 3, 5), (2, 7, 16), (2, 6, 1), (3, 4, 1), (3, 5, 1), (7, 8, 1), (7, 9, 1);

WITH Ierarchy AS
	(
	SELECT T1.b AS Изделие, 
		T1.e AS Компонента_1, T1.w AS Колво1,
		T2.e AS Компонента_2, T2.w AS Колво2,
		T3.e AS Компонента_3, T3.w AS Колво3
	FROM FT AS T1 LEFT JOIN FT AS T2 ON
		T1.e = T2.b
	LEFT JOIN FT AS T3 ON
		T2.e = T3.b
	WHERE T1.b = 1 
	)
SELECT Изделие,
	ISNULL(Компонента_3, ISNULL(Компонента_2, Компонента_1)) AS Компонента,
	SUM(ISNULL(Колво3, 1) * ISNULL(Колво2, 1) * ISNULL(Колво1, 1)) AS Колво
FROM Ierarchy
GROUP BY Изделие, ISNULL(Компонента_3, ISNULL(Компонента_2, Компонента_1))
ORDER BY SUM(ISNULL(Колво3, 1) * ISNULL(Колво2, 1) * ISNULL(Колво1, 1)) desc -- результат выполнения совпадает с примером

-- Полный граф
DECLARE @count AS INT = 1

WHILE @count > 0
BEGIN 
SET @count = 
(
	SELECT COUNT(*)
	FROM 
	(
		SELECT T1.b, T2.e, T1.w * T2.w as w
		FROM FT AS T1 INNER JOIN FT AS T2 ON
			T1.e = T2.b
	) AS NEW LEFT JOIN FT ON
		FT.b = NEW.b AND FT.e = NEW.e AND FT.w = NEW.w
	WHERE FT.b is NULL
)
	INSERT FT
	SELECT NEW.b, NEW.e, NEW.w
	FROM 
	(
		SELECT T1.b, T2.e, T1.w * T2.w AS w
		FROM FT AS T1 INNER JOIN FT AS T2 ON
			T1.e = T2.b
	) AS NEW LEFT JOIN FT ON
		FT.b = NEW.b AND FT.e = NEW.e AND FT.w = NEW.w
	WHERE FT.b is NULL
END

--Решение проблемы неед. листьев я выбрал кардинальную - хранить пути каждого листа (это исп. и для сетевых графов в 2)
CREATE TABLE FTp (b int, e int, w int, path varchar(100))

INSERT FTp
SELECT b, e, w, CAST(CONCAT(b, '-', e) AS varchar(100))
FROM (VALUES (1, 2, 1), (1, 3, 5), (2, 7, 16), (2, 6, 1), (3, 4, 1), (3, 5, 1), (7, 8, 1), (7, 9, 1)) AS V(b, e, w)

DECLARE @count_ AS INT = 1

WHILE @count_ > 0
BEGIN 
	SET @count_ = 
	(
		SELECT COUNT(*)
		FROM 
		(
			SELECT T1.b, T2.e, T1.w * T2.w AS w,
				CAST(CONCAT(T1.path, '-', T2.e) AS varchar(100)) AS path
			FROM FTp AS T1 INNER JOIN FT AS T2 ON
				T1.e = T2.b
		) AS NEW LEFT JOIN FTp ON
			FTp.path = NEW.path
		WHERE FTp.b IS NULL
	)

	INSERT FTp
	SELECT NEW.b, NEW.e, NEW.w, NEW.path
	FROM 
	(
		SELECT T1.b, T2.e, T1.w * T2.w AS w,
			CAST(CONCAT(T1.path, '-', T2.e) AS varchar(100)) AS path
		FROM FTp AS T1 INNER JOIN FT AS T2 ON
			T1.e = T2.b
	) AS NEW LEFT JOIN FTp ON
		FTp.path = NEW.path
	WHERE FTp.b IS NULL
END;

-- Считаем состав
WITH Leaves AS
(
	SELECT DISTINCT e AS leaf
	FROM FT
	WHERE e NOT IN (SELECT DISTINCT b FROM FT)
)
SELECT FTp.b AS Изделие,
	FTp.e AS Компонента,
	SUM(FTp.w) AS Колво
FROM FTp INNER JOIN Leaves ON
	FTp.e = Leaves.leaf
WHERE FTp.b = 1
GROUP BY FTp.b, FTp.e
ORDER BY SUM(FTp.w) desc


--Задание 2 (по сути тоже самое, что и задание 1, но вместо * используется +)
CREATE TABLE WT (b int, e int, w int)

INSERT WT
VALUES (1, 2, 1), (1, 3, 4), (1, 4, 3), (2, 5, 2), (3, 6, 2), (4, 6, 2), (5, 7, 2), (5, 6, 1), (6, 8, 4), (7, 8, 3)

CREATE TABLE WTp (b int, e int, w int, path varchar(100))

INSERT WTp
SELECT b, e, w, CAST(CONCAT(b, '-', e) AS varchar(100))
FROM (VALUES (1, 2, 1), (1, 3, 4), (1, 4, 3), (2, 5, 2), (3, 6, 2), (4, 6, 2), (5, 7, 2), (5, 6, 1), (6, 8, 4), (7, 8, 3)) AS V(b, e, w)

DECLARE @count__ AS INT = 1

WHILE @count__ > 0
BEGIN 
	SET @count__ = 
	(
		SELECT COUNT(*)
		FROM 
		(
			SELECT T1.b, T2.e, T1.w + T2.w AS w,
				CAST(CONCAT(T1.path, '-', T2.e) AS varchar(100)) AS path
			FROM WTp AS T1 INNER JOIN WT AS T2 ON
				T1.e = T2.b
		) AS NEW LEFT JOIN WTp ON
			WTp.path = NEW.path
		WHERE WTp.b IS NULL
	)

	INSERT WTp
	SELECT NEW.b, NEW.e, NEW.w, NEW.path
	FROM 
	(
		SELECT T1.b, T2.e, T1.w + T2.w AS w,
			CAST(CONCAT(T1.path, '-', T2.e) AS varchar(100)) AS path
		FROM WTp AS T1 INNER JOIN WT AS T2 ON
			T1.e = T2.b
	) AS NEW LEFT JOIN WTp ON
		WTp.path = NEW.path
	WHERE WTp.b IS NULL
END;

-- Критический путь (максимальный путь от начала до конца)
WITH Leaves AS
(
	SELECT DISTINCT e AS leaf
	FROM WT
	WHERE e NOT IN (SELECT DISTINCT b FROM WT)
),
Roots AS
(
	SELECT DISTINCT b AS root
	FROM WT
	WHERE b NOT IN (SELECT DISTINCT e FROM WT)
)
SELECT WTp.b AS Начало,
	WTp.e AS Конец,
	MAX(WTp.w) AS Критический_Путь,
	(
		SELECT TOP 1 path 
		FROM WTp AS W2 
		WHERE W2.b = WTp.b AND W2.e = WTp.e 
		ORDER BY W2.w desc
	) AS Маршрут
FROM WTp 
	INNER JOIN Leaves ON WTp.e = Leaves.leaf
	INNER JOIN Roots ON WTp.b = Roots.root
GROUP BY WTp.b, WTp.e
ORDER BY MAX(WTp.w) desc --cовпало с примером

