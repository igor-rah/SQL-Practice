--Задание 1
CREATE TABLE Goods(Good_ID int primary key, Good nvarchar(50), CurrPrice float)
CREATE TABLE Customers(Customer_ID int primary key, Customer nvarchar(50))
CREATE TABLE Docs(Ndoc int primary key, DocDate datetime, Customer_ID int, Total float)
CREATE TABLE Docs_data(NDoc int, Good_ID int, Price float, Qty int, primary key (NDoc, Good_ID))

--Задание 2
INSERT Customers
VALUES (1, 'Pavel'), (2, 'Alex'), (3, 'Joe')

INSERT Goods
VALUES (1, 'PC', 1000), (2, 'Notebook', 500), (3, 'Phone', 200)

--Задание 3
INSERT Docs_data
SELECT 
    Customers.Customer_ID AS NDoc,
    Goods.Good_ID,
    Goods.CurrPrice AS Price,
    ABS(CHECKSUM(NEWID())) % 5 + 1 AS Qty  
FROM Customers, Goods

--Задание 4
INSERT Docs
SELECT 
    NDoc,
    GETDATE() as DocDate,
    NDoc as Customer_ID,
    SUM(Qty*Price) as Total
FROM Docs_data AS T1
GROUP BY NDoc

--Задание 5
UPDATE Docs_data
SET Price = Price * 1.5
FROM 
(
    SELECT TOP 1 Good_ID
    FROM Docs_data
    ORDER BY Good_ID
) as T1
WHERE T1.Good_ID = Docs_data.Good_ID

--Задание 6
UPDATE Docs
SET Total = T1.NewTotal
FROM 
(
    SELECT NDoc, SUM(Qty*Price) As NewTotal
    FROM Docs_data
    GROUP BY NDoc
) AS T1 
WHERE T1.NDoc = Docs.Ndoc

--Задание 7
SELECT DISTINCT Customer_ID
FROM Docs
WHERE Total > 
(
    SELECT ISNULL(AVG(Total), 0)
    FROM Docs
    WHERE DocDate >= '20241101' AND DocDate < '20241201'
)