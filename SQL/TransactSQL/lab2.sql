USE AdventureWorksLT2012

-- CHALLENGE 1 Retrieve Data For Transportation Reports
-- Retrieve a list of cities
SELECT * FROM SalesLT.Address

SELECT DISTINCT City, StateProvince
FROM SalesLT.Address

-- Retrieve the heaviest products
SELECT * from SalesLT.Product
SELECt top 10 percent Name from 
SalesLT.Product order by Weight desc

-- Retrieve the heaviest 100 products not including the heaviest 10
SELECT Name from SalesLT.Product
order by weight desc
offset 10 rows fetch next 100 rows only

-- CHALLENGE 2: Retrieve Product Data
-- select the Name, Color, and Size columns
SELECT Name, Color, Size
FROM SalesLT.Product
-- check ProductModelID is 1
WHERE ProductModelID = 1;

-- select the ProductNumber and Name columns
SELECT ProdcutNumber, Name
FROM SalesLT.Product
-- check that Color is one of 'Black', 'Red' or 'White'
-- check that Size is one of 'S' or 'M'
WHERE Color IN (Black, Red, White) AND Size IN (S, M);

-- select the ProductNumber, Name, and ListPrice columns
SELECT ProductNumber, Name, ListPrice
FROM SalesLT.Product
-- filter for product numbers beginning with BK- using LIKE
WHERE ProductNumber LIKE 'BK-%';

-- select the ProductNumber, Name, and ListPrice columns
SELECT ProductNumber, Name, ListPrice
FROM SalesLT.Product
-- filter for ProductNumbers
WHERE ProductNumber LIKE 'BK-[^R]%-[0-9][0-9]';