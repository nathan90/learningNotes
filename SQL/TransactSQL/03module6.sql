-- Scalar SubQuery

SELECT MAX(UnitPrice) FROM  SalesLT.SalesOrderDetail

SELECT * FROM SalesLT.Product
WHERE ListPrice > 1466.01

SELECT * FROM SalesLT.Product
WHERE ListPrice >
( SELECT MAX(UnitPrice)  FROM SalesLT.SalesOrderDetail)

-- Correlated SubQuery

SELECT CustomerID, SalesOrderID, OrderDate
FROM SalesLT.SalesOrderHeader AS SO1
ORDER BY CustomerID, OrderDate

SELECT CustomerID, SalesOrderID, OrderDate
FROM SalesLT.SalesOrderHeader AS SO1
WHERE OrderDate = 
	(SELECT MAX(OrderDate) FROM SalesLT.SalesOrderHeader)

SELECT CustomerID, SalesOrderID, OrderDate
FROM SalesLT.SalesOrderHeader AS S01
WHERE OrderDate = 
	(SELECT MAX(OrderDate) 
	FROM SalesLT.SalesOrderHeader AS S02
	WHERE S02.CustomerID = S01.CustomerID)
ORDER BY CustomerID

-- CROSS APPLY
-- Display the salesOrder Details for items that are equal to the maximum unit price for that sales Order

SELECT SOH.SalesOrderID, MUP.MaxUnitPrice
FROM SalesLT.SalesOrderHeader AS SOH
CROSS APPLY SalesLT.udfMaxUnitPrice(SOH.SalesOrderID) AS MUP
ORDER BY SOH.SalesOrderID

-- sp_helptext '(Funtion name/ storedProcedure)' name will return you the syntax of the function