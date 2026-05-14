--Задание 1
DECLARE @max_volume as int
SET @max_volume = 100

SELECT Good_id
FROM Goods
WHERE (QtyInStock * Volume) > @max_volume

--Задание 2
SELECT City 
FROM Customers
GROUP BY City
HAVING Count(*) < 5 

--Задание 3
DECLARE @c_id as int
SET @c_id = 1

SELECT Customer, Data, Docs_data.DocNum, Good, Qty, Docs_data.Price
FROM Customers INNER JOIN Docs ON
		Customers.Cust_ID = Docs.Cust_ID
	INNER JOIN Docs_data ON
		Docs.DocNum = Docs_data.DocNum
	INNER JOIN Goods ON 
		Docs_data.Good_id = Goods.Good_id
WHERE Docs.Cust_ID = @c_id

--Задание 4
SELECT distinct Good
FROM Docs INNER JOIN Docs_data ON
		Docs.DocNum = Docs_data.DocNum
	INNER JOIN Goods ON 
		Docs_data.Good_id = Goods.Good_id 
WHERE ('20251001' <= Data) and (Data < '20251101')

--Задание 5
DECLARE @g_id as int
SET @g_id = 2

SELECT distinct City
FROM Customers INNER JOIN Docs ON
		Customers.Cust_id = Docs.Cust_ID
	INNER JOIN Docs_data ON 
		Docs.DocNum = Docs_data.DocNum
WHERE Good_id = @g_id

--Задание 6
SELECT top 1 with ties Customer
FROM Customers INNER JOIN Docs ON
		Customers.Cust_id = Docs.Cust_ID
	INNER JOIN Docs_data ON 
		Docs.DocNum = Docs_data.DocNum
WHERE ('20251001' <= Data) and (Data < '20251101')
ORDER BY Price desc

--Задание 7
SELECT SUM(Volume * Qty) as Summary_Volume
FROM Docs INNER JOIN Docs_data ON
		Docs.DocNum = Docs_data.DocNum
	INNER JOIN Goods ON 
		Docs_data.Good_id = Goods.Good_id 
WHERE ('20251001' <= Data) and (Data < '20251101')

--Задание 8
SELECT top 1 with ties City
FROM Docs INNER JOIN Customers
	ON Docs.Cust_ID = Customers.Cust_id
GROUP BY City
ORDER BY SUM(Total) desc

--Задание 9
SELECT 
    Customers.Customer,
    ISNULL(SUM(Docs_data.Qty), 0) as Sum_count,
    ISNULL(SUM(Docs_data.Price * Docs_data.Qty), 0) as Sum_price,
    ISNULL(SUM(Goods.Volume * Docs_data.Qty), 0) as Sum_Vol,
    ISNULL(SUM(Goods.Mass * Docs_data.Qty), 0) as Sum_mass
FROM Customers LEFT JOIN Docs ON 
		Customers.Cust_ID = Docs.Cust_ID
	LEFT JOIN Docs_data ON 
		Docs.DocNum = Docs_data.DocNum
	LEFT JOIN Goods ON 
		Docs_data.Good_id = Goods.Good_id
GROUP BY Customers.Cust_ID, Customers.Customer

SELECT 
	MAX(Customer) as Customer, 
	ISNULL(SUM(CASE WHEN Good LIKE '%Монитор%' THEN Qty END), 0) as Sum_count,
	ISNULL(SUM((CASE WHEN Good LIKE '%Монитор%' THEN Docs_data.Price END) * (CASE WHEN Good LIKE '%Монитор%' THEN Qty END)), 0) as Sum_price, 
	ISNULL(SUM((CASE WHEN Good LIKE '%Монитор%' THEN Volume END) * (CASE WHEN Good LIKE '%Монитор%' THEN Qty END)), 0) as Sum_Vol, 
	ISNULL(SUM((CASE WHEN Good LIKE '%Монитор%' THEN Mass END) * (CASE WHEN Good LIKE '%Монитор%' THEN Qty END)), 0) as Sum_mass
FROM Customers LEFT JOIN Docs ON
		Customers.Cust_ID = Docs.Cust_ID
	LEFT JOIN Docs_data ON
		Docs.DocNum = Docs_data.DocNum
	LEFT JOIN Goods ON 
		Docs_data.Good_id = Goods.Good_id
GROUP BY Docs.Cust_ID

--Задание 10
SELECT MAX(Docs.DocNum) as Res
FROM Docs INNER JOIN Docs_data ON
		Docs.DocNum = Docs_data.DocNum
GROUP BY Docs_Data.DocNum, Total
HAVING Total != SUM(Price * Qty)