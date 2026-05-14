--Create tables

CREATE TABLE [Order] (ndoc int primary key, supp_id int, dateOrd datetime)

CREATE TABLE Order_data (ndoc int, good_id int, supp_id int, quantity int, price float, primary key (ndoc, good_id))

CREATE TABLE Goods (good_id int, mass float, volume float)

CREATE TABLE Supplier (supp_id int primary key, name nvarchar(50))

INSERT Supplier
VALUES 
	(1, 'ООО Альфа'),
	(2, 'ЗАО Бета'),
	(3, 'ИП Гамма'),
	(4, 'ООО Дельта'),
	(5, 'АО Эпсилон')

-- Товары
INSERT Goods
VALUES 
	(1, 0.5, 0.001),
	(2, 1.2, 0.003),
	(3, 0.3, 0.0005),
	(4, 2.5, 0.01),
	(5, 0.8, 0.002),
	(6, 5.0, 0.025),
	(7, 0.1, 0.0001),
	(8, 3.2, 0.015),
	(9, 1.5, 0.004),
	(10, 0.7, 0.0018)

INSERT [Order]
VALUES 
	(1, 1, '20250101'),
	(2, 1, '20250115'),
	(3, 2, '20250120'),
	(4, 2, '20250205'),
	(5, 3, '20250210'),
	(6, 3, '20250301'),
	(7, 4, '20250315'),
	(8, 4, '20250401'),
	(9, 5, '20250410'),
	(10, 5, '20250420'),
	(11, 1, '20250501'),
	(12, 2, '20250515'),
	(13, 3, '20250520'),
	(14, 4, '20250601'),
	(15, 5, '20250615')

INSERT Order_data
VALUES 
	(1, 1, 1, 10, 100.0),
	(1, 2, 1, 5, 250.0),
	(1, 3, 1, 20, 50.0),
	(2, 4, 1, 3, 500.0),
	(2, 5, 1, 15, 80.0),
	(3, 1, 2, 8, 110.0),
	(3, 6, 2, 2, 1500.0),
	(4, 2, 2, 12, 240.0),
	(4, 7, 2, 50, 20.0),
	(5, 3, 3, 30, 45.0),
	(5, 8, 3, 4, 800.0),
	(6, 4, 3, 6, 480.0),
	(6, 9, 3, 10, 150.0),
	(7, 5, 4, 25, 75.0),
	(7, 10, 4, 18, 90.0),
	(8, 1, 4, 15, 95.0),
	(8, 2, 4, 8, 260.0),
	(9, 6, 5, 3, 1450.0),
	(9, 7, 5, 100, 18.0),
	(10, 8, 5, 5, 780.0),
	(10, 9, 5, 12, 145.0),
	(11, 1, 1, 20, 98.0),
	(11, 3, 1, 35, 48.0),
	(12, 2, 2, 10, 255.0),
	(12, 4, 2, 4, 510.0),
	(13, 5, 3, 22, 78.0),
	(13, 6, 3, 1, 1550.0),
	(14, 7, 4, 80, 19.0),
	(14, 8, 4, 6, 790.0),
	(15, 9, 5, 14, 148.0),
	(15, 10, 5, 20, 88.0)


--Задание 1 
DECLARE @n int = 1;
--DECLARE @str nvarchar(100) = '     Hello,,,  test; string. ....   fgvdyugvfyu';
WITH D(num) AS 
(
	SELECT 1

	UNION ALL

	SELECT num + 1
	FROM D
	WHERE num < 100
),
Chars AS
(
	SELECT SUBSTRING(@str, num, 1) AS symb
	FROM D
	WHERE num <= LEN(@str)
)

SELECT symb, COUNT(*) AS Res
FROM Chars
WHERE symb != ''
GROUP BY symb
ORDER BY COUNT(*) DESC

--Задание 2 
DECLARE @str nvarchar(100) = '     Hello,,,  test; string. ....   fgvdyugvfyu'
SET @str = LTRIM(RTRIM(@str))

CREATE TABLE #T (word nvarchar(50))

DECLARE @runner AS INT = 1
DECLARE @d AS nvarchar(10) = ' ;,.!?'
DECLARE @ender AS INT
DECLARE @word AS nvarchar(50)

WHILE @runner <= LEN(@str)
BEGIN
	WHILE @runner <= LEN(@str) AND CHARINDEX(SUBSTRING(@str, @runner, 1), @d) > 0
	BEGIN
		SET @runner += 1
	END

	SET @ender = @runner
	WHILE @ender <= LEN(@str) AND CHARINDEX(SUBSTRING(@str, @ender, 1), @d) = 0
	BEGIN
		SET @ender += 1
	END
	
	IF @runner <= LEN(@str)
	BEGIN
		SET @word = SUBSTRING(@str, @runner, @ender - @runner)
		
		INSERT #T
		SELECT @word
	END
	
	SET @runner = @ender + 1
END

SELECT word AS Слово, COUNT(*) AS Количество
FROM #T
GROUP BY word
ORDER BY COUNT(*) DESC

DROP TABLE #T

GO

--Задание 3
CREATE VIEW v_Orders
AS
	SELECT ndoc, CAST(dateOrd as date) as DateOrd
	FROM [Order]
	WHERE DATEDIFF(month, GETDATE(), CAST(dateOrd AS date)) <= 1
GO

--Залание 4
CREATE PROC M_v_good
	@param as int
AS
	SELECT @param as Good, SUM(volume) AS Res_v, SUM(mass) as Res_m
	FROM [Order] AS T1 INNER JOIN Order_data AS T2 ON
			T1.ndoc = T2.ndoc
		INNER JOIN Goods AS T3 ON 
			T3.good_id = T2.good_id
	WHERE CAST(dateOrd as date) > '20260101'
	GROUP BY T3.good_id
	HAVING T3.good_id = @param
GO

--Задание 5
CREATE TABLE #A (good_id int, res_v float, res_m float)

INSERT #A
EXEC M_v_good 2

DROP TABLE #A
DROP PROCEDURE M_v_good
GO

--Задание 6
CREATE FUNCTION Last_order_num(@num int)
RETURNS INT AS
BEGIN
RETURN
(
	SELECT TOP 1 T1.ndoc
	FROM [Order] AS T1 INNER JOIN Order_data AS T2 ON
			T1.ndoc = T2.ndoc
	WHERE good_id = @num
	ORDER BY dateOrd desc
)
END 
GO

SELECT dbo.Last_order_num(5)
GO

--Задание 7
CREATE FUNCTION F_top(@n as int, @good as int)
RETURNS @T TABLE (ндок int)
AS
BEGIN
	INSERT @T
		SELECT TOP (@n) with ties ndoc
		FROM Order_data
		WHERE good_id = @good
		ORDER BY price asc
RETURN 
END
GO

SELECT *
FROM dbo.F_top(2, 1)
GO

--Задание 8 
CREATE FUNCTION Last_order(@supp int)
RETURNS TABLE
AS
RETURN
(
	SELECT TOP 1 WITH TIES ndoc, CAST(dateOrd as date) as dateord
	FROM Supplier LEFT JOIN [Order] ON 
		Supplier.supp_id = [Order].supp_id
	WHERE Supplier.supp_id = @supp
	ORDER BY dateOrd desc
)
GO
--DROP FUNCTION Last_order

SELECT *
FROM dbo.Last_order(2)
GO

--Задание 9
SET STATISTICS TIME ON
SET STATISTICS IO ON

SELECT *
FROM Supplier
CROSS APPLY Last_order(Supplier.supp_id) Result

SET STATISTICS TIME OFF
SET STATISTICS IO OFF

--Задание 10
SET STATISTICS TIME ON
SET STATISTICS IO ON

SELECT T1.supp_id, CAST(dateOrd AS date) as dateord
FROM Supplier AS T1 LEFT JOIN [Order] ON
	T1.supp_id = [Order].supp_id AND ndoc in 
(
	SELECT TOP 1 ndoc
	FROM Supplier LEFT JOIN [Order] ON 
		Supplier.supp_id = [Order].supp_id
	WHERE Supplier.supp_id = T1.supp_id
	ORDER BY dateOrd desc
)

SET STATISTICS TIME OFF
SET STATISTICS IO OFF

--Сравнение
DELETE FROM Order_data
DELETE FROM [Order];

-- Генерируем 100 заказов
WITH Numbers AS
(
	SELECT 1 AS n
	
	UNION ALL
	
	SELECT n + 1
	FROM Numbers
	WHERE n < 100
)
INSERT [Order]
SELECT n AS ndoc,
	(n % 5) + 1 AS supp_id,
	DATEADD(DAY, n, '20260101') AS dateOrd
FROM Numbers
OPTION (MAXRECURSION 100)

SELECT COUNT(*)
FROM [Order]
GO

-- c CROSS APPLY: 16.1667 sec
-- Подзапрос: 18.7 sec

--Задание 11
CREATE FUNCTION Last_order_3(@supp int)
RETURNS TABLE
AS
RETURN
(
	SELECT TOP 3 ndoc, CAST(dateOrd AS date) AS dateord
	FROM Supplier LEFT JOIN [Order] ON 
		Supplier.supp_id = [Order].supp_id
	WHERE Supplier.supp_id = @supp
	ORDER BY dateOrd DESC
)
GO

SET STATISTICS TIME ON
SET STATISTICS IO ON

SELECT *
FROM Supplier
CROSS APPLY Last_order_3(Supplier.supp_id) Result

SET STATISTICS TIME OFF
SET STATISTICS IO OFF
-- 16.3 sec


SET STATISTICS TIME ON
SET STATISTICS IO ON

SELECT Supplier.supp_id, Supplier.name, ndoc, CAST(dateOrd AS date) AS dateord
FROM Supplier LEFT JOIN [Order] ON
	Supplier.supp_id = [Order].supp_id and ndoc in
(
	SELECT ndoc
	FROM
	(
		SELECT ndoc, supp_id, ROW_NUMBER() OVER (PARTITION BY supp_id ORDER BY dateOrd DESC) AS rn
		FROM [Order]
	) AS Ranked
	WHERE Ranked.rn <= 3 AND Ranked.supp_id = Supplier.supp_id
)

SET STATISTICS TIME OFF
SET STATISTICS IO OFF
--18.0 sec

