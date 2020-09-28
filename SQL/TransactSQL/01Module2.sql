USE AdventureWorks2017
-- Display a list of product colors with the word 'None' if the value is null sorted by color

SELECT DISTINCT ISNULL(Color, 'None') AS Color
FROM Production.Product 
ORDER BY Color

-- Display a list of product colors with the word 'None' if the value is NULL and a dash if the size is NULL sorted by color
SELECT DISTINCT ISNULL(Color, 'None') AS Color, ISNULL(Size, '-') AS Size FROM Production.Product ORDER BY Color;

-- Display the top 100 products by list price
SELECT TOP 1 Percent Name, ListPrice FROM Production.Product ORDER BY ListPrice DESC

-- Display the first 10 products by product number
SELECT Name, ListPrice FROM Production.Product 
ORDER BY ProductNumber
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY

-- Display the next 10 products by product number
SELECT Name, ListPrice FROM Production.Product
ORDER BY ProductNumber
OFFSET 10 ROWS FETCH FIRST 10 ROW ONLY;

-- PREDICATES
-- List information  about product model 6
SELECT Name, Color, Size FROM Production.Product WHERE ProductModelID = 6;

-- List information about products that have a product number beginning FR
SELECT ProductNumber, Name, ListPrice 
FROM Production.Product
WHERE ProductNumber LIKE 'FR%';

-- Filter the above query to ensure that the product Number contains two sets of two digits
SELECT ProductNumber, Name, ListPrice FROM Production.Product
WHERE ProductNumber LIKE 'FR-_[0-9][0-9]_-[0-9][0-9]'

-- Find products that have no sell end date
SELECT Name FROM Production.Product WHERE SellEndDate IS NOT NULL

-- Find products that have a sell end date in 2006
SELECT Name FROM Production.Product
WHERE SellEndDate BETWEEN '2013/1/1' AND '2013/12/31'

select * from Production.Product where SellEndDate is null

-- Find products that have a categoryID of 5, 6, 7
SELECT ProductSubcategoryID, Name, ListPrice FROM Production.Product
WHERE ProductSubcategoryID IN (5, 6, 7)

-- Find products that have a categoryID of 5, 6, 7 and have a SELL End date
SELECT ProductSubcategoryID, NAME, ListPrice, SellEndDate
FROM Production.Product WHERE ProductSubcategoryID IN (12,13,14) AND SellEndDate IS NULL

-- Select products that have a categoryID of 5, 6, 7 and a product Number that begins with FR
SELECT Name, ProductSubcategoryID, ProductNumber
FROM Production.Product WHERE ProductNumber LIKE 'FR%' OR ProductSubcategoryID in (12,13,14)