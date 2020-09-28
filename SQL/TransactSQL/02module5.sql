-- Scalar Functions
SELECT YEAR(SellStartDate) AS SellStartYear, ProductID, Name
FROM SalesLT.Product
ORDER BY SellStartYear

-- A bit complex
SELECT YEAR(SellStartDate) SellStartYear, DATENAME(mm, SellStartDate) SellStartMonth,
		DAY(SellStartDate) SellStartDay, DATENAME(dw, SellStartDate) SellStartWeekDay,
		ProductId, Name
FROM SalesLT.Product
ORDER BY SellStartYear

--Difference of Dates
SELECT DATEDIFF(yy, SellStartDate, GETDATE()) YearsSold, ProductID, Name
FROM SalesLT.Product
ORDER BY ProductID

-- Upper Case
SELECT UPPER(Name) AS ProductName
FROM SalesLT.Product

--Concatenation
SELECT CONCAT(FirstName + ' ', LastName) AS FullName
FROM SalesLT.Customer

--Left of some Item
SELECT Name, ProductNumber, LEFT(ProductNumber, 2) AS ProductType
FROM SalesLT.Product

--Complex Substring Operations

SELECT Name, ProductNumber, LEFT(ProductNumber, 2) AS ProductType,
							SUBSTRING(ProductNumber, CHARINDEX('-', ProductNumber) +1, 4) AS ModelCode,
							SUBSTRING(ProductNumber, LEN(ProductNumber) - CHARINDEX('-', REVERSE(RIGHT(ProductNumber, 3))) + 2, 2) AS SizeCode
FROM SalesLT.Product

-- Break Down of the above query
SELECT Name, ProductNumber, LEFT(ProductNumber, 2) AS ProductType,
							SUBSTRING(ProductNumber, CHARINDEX('-', ProductNumber) +1, 4) AS ModelCode,
							SUBSTRING(ProductNumber, LEN(ProductNumber) - CHARINDEX('-', REVERSE(RIGHT(ProductNumber, 3))) + 2, 2) AS SizeCode,
							RIGHT(ProductNumber, 3) as [right],
							REVERSE(RIGHT(ProductNumber, 3)) [right Reversed],
							CHARINDEX('-', REVERSE(RIGHT(ProductNumber, 3))) as [CI for reversed],
							LEN(ProductNumber) - CHARINDEX('-', REVERSE(RIGHT(ProductNumber, 3))) + 2 as [Some Length]

FROM SalesLT.Product

--Logical Functions
SELECT Name, Size AS NumericSize
FROM SalesLT.Product
WHERE ISNUMERIC(Size) = 1;

SELECT Name, IIF(ProductCategoryID IN (5,6,7), 'Bike', 'Other') ProductType
FROM SalesLT.Product

SELECT Name, IIF(ISNUMERIC(Size) = 1, 'Numeric', 'Non Numeric') SizeType
FROM SalesLT.Product

SELECT prd.Name AS productName, cat.Name as Category,
	CHOOSE (cat.ParentProductCategoryID, 'Bikes', 'Components', 'Clothing', 'Accessories') AS ProductType
FROM SalesLT.Product AS prd
JOIN SalesLT.ProductCategory AS cat
ON prd.ProductCategoryID = cat.ProductCategoryID

-- Window Functions
SELECT TOP (100) ProductID, Name, ListPrice, 
RANK() OVER (ORDER BY ListPrice DESC) AS RankByPrice
FROM SalesLT.Product AS p
ORDER BY RankByPrice;

SELECT c.Name AS Category, p.Name AS Product, ListPrice,
	RANK() OVER (PARTITION BY c.Name ORDER BY ListPrice DESC) AS RankByPrice
FROM SalesLT.Product AS p
JOIN SalesLT.ProductCategory AS c
ON p.ProductCategoryID = c.ProductCategoryID
ORDER BY Category, RankByPrice

-- Aggregate Functions 
SELECT COUNT(*) AS Products, COUNT(DISTINCT ProductCategoryID) AS Categories, AVG(ListPrice) AS AveragePrice
FROM SalesLT.Product;

SELECT COUNT(p.productID) BikeModels, AVG(p.ListPrice) AveragePrice
FROM SalesLT.Product AS p
JOIN SalesLT.ProductCategory AS c
ON p.ProductCategoryID = c.ProductCategoryID
WHERE c.Name LIKE '%B ikes';


-- Using GROUP BY Clause
SELECT c.SalesPerson, ISNULL(SUM(oh.subTotal), 0.00) SalesRevenue
FROM SalesLT.Customer c
LEFT JOIN SalesLT.SalesOrderHeader oh
ON c.CustomerID = oh.CustomerID
GROUP BY c.SalesPerson
ORDER BY SalesRevenue DESC;

SELECT c.SalesPerson, CONCAT(c.FirstName + ' ', c.LastName) AS Customer, ISNULL(SUM(oh.SubTotal), 0.00) SalesRevenue
FROM SalesLT.Customer c
LEFT JOIN  SalesLT.SalesOrderHeader oh
ON c.CustomerID = oh.CustomerID
GROUP BY c.SalesPerson,CONCAT(c.FirstName + ' ', c.LastName) --Cannot use alias for CONCAT due to the order of running 
ORDER BY SalesRevenue DESC, Customer;

-- Using HAVING clause
SELECT ProductID, SUM(sod.OrderQty) AS Quantity
FROM SalesLT.SalesOrderDetail AS sod
JOIN SalesLT.SalesOrderHeader AS soh
ON sod.SalesOrderID = soh.SalesOrderID
WHERE YEAR(soh.OrderDate) = 2004
GROUP BY ProductID
HAVING SUM(sod.OrderQty) > 50

select YEAR(SalesLT.SalesOrderHeader.OrderDate) FROM SalesLT.SalesOrderHeader

