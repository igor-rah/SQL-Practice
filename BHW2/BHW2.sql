--Задание 1
SELECT 
    MONTH(Date_of_Order) AS OrderMonth,
    Book_ID,
    CASE WHEN MAX(CASE WHEN Qty_ord IS NOT NULL THEN 1 ELSE 0 END) = 1 THEN SUM(Price_RUR) END AS Ordered,
    CASE WHEN MAX(CASE WHEN Qty_ord IS NOT NULL THEN 1 ELSE 0 END) = 1 AND MAX(Pmnt_RUR) = MAX(Sum_RUR) THEN SUM(Price_RUR) END AS Sold,
    CASE WHEN MAX(CASE WHEN Qty_ord IS NOT NULL THEN 1 ELSE 0 END) = 1 AND MAX(Qty_out) = MAX(Qty_ord) THEN SUM(Price_RUR) END AS Issued
FROM Orders AS T1 INNER JOIN Orders_data AS T2 ON 
    T1.ndoc = T2.ndoc
WHERE YEAR(Date_of_Order) = 2025
GROUP BY MONTH(Date_of_Order), Book_ID
ORDER BY OrderMonth

--Задание 2
SELECT 
	T1.Section_ID,
	--(SELECT COUNT(DISTINCT DAY(Date_of_Order)) FROM Orders WHERE Date_of_Order BETWEEN DATEADD(month, -1, GETDATE()) AND GETDATE()) AS Sum_days,
	--SUM(Qty_ord * Orders_data.Price_RUR) as Sum_Revenue,
	ISNULL(SUM((CASE WHEN Date_of_Order BETWEEN DATEADD(month, -1, GETDATE()) AND GETDATE() THEN Qty_ord ELSE 0 END) * Orders_data.Price_RUR), 0)
	/ (SELECT COUNT(DISTINCT CAST(Date_of_Order as date)) FROM Orders WHERE Date_of_Order BETWEEN DATEADD(month, -1, GETDATE()) AND GETDATE()) AS Average_rev
FROM Sections AS T1 LEFT JOIN Books ON 
	T1.Section_ID = Books.Section_ID
LEFT JOIN Orders_data ON
	Orders_data.Book_ID = Books.Book_ID
LEFT JOIN Orders ON
	Orders.ndoc = Orders_data.ndoc 
GROUP BY T1.Section_ID

--Задание 3
SELECT T1.Author_ID, T1.Sum_Revenue AS Sum_Revenue, COUNT(T2.Author_ID) as Rating
FROM (
SELECT Authors.Author_ID, ISNULL(SUM(Qty_ord * Orders_data.Price_RUR), 0) as Sum_Revenue
FROM Authors LEFT JOIN Books ON 
	Authors.Author_ID = Books.Author_ID
LEFT JOIN Orders_data ON 
	Orders_data.Book_ID = Books.Book_ID
LEFT JOIN Orders ON
	Orders_data.ndoc = Orders.ndoc AND Date_of_Order BETWEEN DATEADD(month, -1, GETDATE()) AND GETDATE()
GROUP BY Authors.Author_ID
) AS T1 LEFT JOIN 
(
SELECT Authors.Author_ID, ISNULL(SUM(Qty_ord * Orders_data.Price_RUR), 0) as Sum_Revenue
FROM Authors LEFT JOIN Books ON 
	Authors.Author_ID = Books.Author_ID
LEFT JOIN Orders_data ON 
	Orders_data.Book_ID = Books.Book_ID
LEFT JOIN Orders ON
	Orders_data.ndoc = Orders.ndoc AND Date_of_Order BETWEEN DATEADD(month, -1, GETDATE()) AND GETDATE()
GROUP BY Authors.Author_ID
) AS T2 ON T1.Sum_Revenue <= T2.Sum_Revenue
GROUP BY T1.Author_ID, T1.Sum_Revenue
ORDER BY Rating

--Задание 4
SELECT Customers.Cust_ID, ISNULL(SUM(Pmnt_RUR), 0) as Overall_pmnt
FROM Customers LEFT JOIN Orders ON
	Orders.Cust_ID = Customers.Cust_ID AND Date_of_Order BETWEEN DATEADD(month, -1, GETDATE()) AND GETDATE() 
GROUP BY Customers.Cust_ID

--Задание 5
SELECT Book_ID
FROM Stock
WHERE Qty_in_Stock > 0

EXCEPT

SELECT Book_ID
FROM Orders INNER JOIN Orders_data ON
	Orders.ndoc = Orders_data.ndoc
WHERE Date_of_Order > '20251001'

--Задание 6
SELECT Cust_ID, Book_ID
FROM Orders INNER JOIN Orders_data ON
	Orders.ndoc = Orders_data.ndoc
GROUP BY Cust_ID, Book_ID

EXCEPT

SELECT Cust_ID, Orders_data.Book_ID
FROM Orders INNER JOIN Orders_data ON
	Orders.ndoc = Orders_data.ndoc
INNER JOIN Stock ON
	Stock.Book_ID = Orders_data.Book_ID
WHERE (Qty_in_Stock = 0) or (Date_of_Order > '20251001')
GROUP BY Cust_ID, Orders_data.Book_ID

--Задание 7
SELECT 
	CAST(SUM(Qty_rsrv) AS float) / SUM(Qty_in_stock) as Physic_percent,
	CAST(SUM(Qty_rsrv * Price_RUR) AS float) / SUM(Qty_in_stock * Price_RUR) as RUR_percent
FROM Stock LEFT JOIN Books ON
	Books.Book_ID = Stock.Book_ID

--Задание 8 
SELECT
	'Not claimed' AS Comment,
	Cust_ID,
	SUM(CASE WHEN Qty_out = 0 AND Pmnt_RUR > 0 THEN Pmnt_RUR * Qty_ord ELSE 0 END) AS Summary_pmnt
FROM Orders_data INNER JOIN Orders ON
	Orders_data.ndoc = Orders.ndoc
WHERE Qty_out = 0 AND Pmnt_RUR > 0
GROUP BY Cust_ID

UNION ALL

SELECT
	'Not paid' AS Comment,
	Cust_ID,
	SUM(CASE WHEN Pmnt_RUR = 0 AND Qty_out > 0 THEN Price_RUR * Qty_out ELSE 0 END) AS Summary_unclmd
FROM Orders_data INNER JOIN Orders ON
	Orders_data.ndoc = Orders.ndoc
WHERE Pmnt_RUR = 0 AND Qty_out > 0
GROUP BY Cust_ID

--Задание 9
DECLARE @b_id as int, @amount as int, @c_id as int
SET @b_id = 57
SET @amount = 3
SET @c_id = 7

SELECT 
	CASE WHEN (Qty_in_Stock - Qty_rsrv >= @amount) AND
	(SELECT MAX(Balance) - SUM(Pmnt_RUR) AS Remain
	 FROM Customers INNER JOIN Orders ON
		Customers.Cust_ID = Orders.Cust_ID
	 GROUP BY Customers.Cust_ID
	 HAVING Customers.Cust_ID = @c_id) >= Price_RUR * @amount
	THEN 'YES' ELSE 'NO' END AS Res
FROM Stock INNER JOIN Books ON
	Stock.Book_ID = Books.Book_ID
WHERE Books.Book_ID = @b_id

--Задание 10
UPDATE Orders
SET Orders.Sum_RUR = T1.Sum_rur
FROM Orders INNER JOIN 
(
	SELECT ndoc, SUM(Qty_ord * Price_RUR) as Sum_rur
	FROM Orders_data
	GROUP BY ndoc
) as T1 ON T1.ndoc = Orders.ndoc

--Задание 11

DECLARE @ndoc as int
SET @ndoc = 100

SELECT 
	CASE 
		WHEN Customers.Balance >= Orders.Sum_RUR 
		     AND ISNULL(Orders.Pmnt_RUR, 0) = 0 
		THEN 1 ELSE 0 
	END as CanPay
FROM Orders INNER JOIN Customers ON
	Orders.Cust_ID = Customers.Cust_ID
WHERE Orders.ndoc = @ndoc


--Задание 12

DECLARE @nd as int, @sum as float, @cust as int
SET @nd = 100

SELECT 
	@sum = Sum_RUR,
	@cust = Cust_ID
FROM Orders
WHERE ndoc = @nd

IF (SELECT Balance FROM Customers WHERE Cust_ID = @cust) >= @sum 
   AND ISNULL((SELECT Pmnt_RUR FROM Orders WHERE ndoc = @nd), 0) = 0
BEGIN
	UPDATE Customers
	SET Balance = Balance - @sum
	WHERE Cust_ID = @cust

	UPDATE Orders
	SET Pmnt_RUR = @sum
	WHERE ndoc = @nd
END


--Задание 13

DECLARE @nd1 as int
SET @nd1 = 100

UPDATE Stock
SET Qty_rsrv = Qty_rsrv + T1.Qty_sum
FROM Stock INNER JOIN
(
	SELECT Book_ID, SUM(Qty_ord) as Qty_sum
	FROM Orders_data
	WHERE ndoc = @nd1
	GROUP BY Book_ID
) as T1 ON
	Stock.Book_ID = T1.Book_ID

	
--Задание 14
	
DECLARE @nd2 as int
SET @nd2 = 100

UPDATE Stock
SET 
	Qty_in_Stock = Qty_in_Stock - T1.Qty_sum,
	Qty_rsrv     = Qty_rsrv     - T1.Qty_sum
FROM Stock INNER JOIN
(
	SELECT Book_ID, SUM(Qty_out) as Qty_sum
	FROM Orders_data
	WHERE ndoc = @nd2
	GROUP BY Book_ID
) as T1 ON
	Stock.Book_ID = T1.Book_ID

	
--Задание 15
	
UPDATE Stock
SET Qty_rsrv = Qty_rsrv - T1.Qty_sum
FROM Stock INNER JOIN
(
	SELECT Orders_data.Book_ID, SUM(Qty_ord) as Qty_sum
	FROM Orders_data INNER JOIN Orders ON
		Orders_data.ndoc = Orders.ndoc
	WHERE Pmnt_RUR = 0 
	  AND Qty_out = 0
	  AND CAST(Date_of_Order as date) = DATEADD(day, -1, CAST(GETDATE() as date))
	GROUP BY Orders_data.Book_ID
) as T1 ON
	Stock.Book_ID = T1.Book_ID
