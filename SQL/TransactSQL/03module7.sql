-- CREATE A VIEw

CREATE VIEW SalesLT.vCustomerAddress
AS
SELECT C.CustomerID, FirstName, LastName, AddressLine1, City, StateProvince
FROM SalesLT.Customer C JOIN SalesLT.CustomerAddress CA
ON C.CustomerID = CA.CustomerID
JOIN SalesLT.Address A
ON CA.AddressID = A.AddressID

-- Query the VIEW
SELECT CustomerID, City
FROM SalesLT.vCustomerAddress

-- Join the View to a table
SELECT c.StateProvince, c.City, ISNULL(SUM(s.TotalDue), 0.00) AS Revenue
FROM SalesLT.vCustomerAddress AS c
LEFT JOIN SalesLT.SalesOrderHeader AS s
ON s.CustomerID = c.CustomerID
GROUP BY c.StateProvince, c.City
ORDER BY c.StateProvince, Revenue DESC

--Temporary Table
CREATE TABLE #Colors
(Color varchar(15));

INSERT INTO #Colors
SELECT DISTINCT Color FROM  SalesLT.Product;

SELECT * FROM #Colors

--Table Variable
DECLARE @Colors AS TABLE (Color varchar(15));
INSERT INTO @Colors
SELECT DISTINCT Color FROM SalesLT.Product

SELECT * FROM @Colors

--New Batch
SELECT * FROM  #Colors

SELECT * FROM  @Colors --Out of scope now


--Derived Queries
SELECT Category, COUNT(ProductID) AS Products
FROM 
	(SELECT p.ProductID, p.Name AS Product, c.Name AS Category
	 FROM SalesLT.Product AS p
	 JOIN SalesLT.ProductCategory AS c
	 ON p.ProductCategoryID = c.ProductCategoryID) AS ProdCats
GROUP BY Category
ORDER BY Category;

-- Common Table Expressions
WITH ProductsByCategory (ProductID, ProductName, Category)
AS
( SELECT p.ProductID, p.Name, c.Name AS Category
	FROM SalesLT.Product AS p
	JOIN SalesLT.ProductCategory AS c
	ON p.ProductCategoryID = c.ProductCategoryID
)
SELECT Category, COUNT(ProductID) AS Products
FROM ProductsByCategory
GROUP BY Category
ORDER BY Category;

-- Recursive CTE
SELECT * FROM SalesLT.employee

-- USING CTE to perform a recursion

WITH OrgReport (ManagerID,EmployeeID, EmployeeName, Level)
AS (

	-- Anchor Query
	SELECT e.ManagerID, e.EmployeeID, EmployeeName, 0
	FROM SalesLT.Employee AS e
	WHERE ManagerID IS NULL

	UNION ALL

	-- Recursive Query
	SELECT e.ManagerID, e.EmployeeID, e.EmployeeName, Level+1
	FROM SalesLT.Employee AS e
	INNER JOIN OrgReport AS o ON e.ManagerID = o.EmployeeID
	)
SELECT * FROM OrgReport
OPTION (MAXRECURSION 3);