--CHALLENGE 1 Retrieve Customer Data
-- Retrieve Customer Details
SELECT * FROM SalesLT.Customer

-- Retrieve Customer Name Data
SELECT ISNULL(Title, '') + ' ' + FirstName + ' ' + ISNULL(MiddleName, '') + ' ' + LastName + ' ' + ISNULL(Suffix, '')
FROM SalesLT.Customer

-- Retrieve Customer Name and Phone Numbers
SELECT SalesPerson,  ISNULL(Title, '') + ' ' + LastName AS CustomerName, Phone
FROM SalesLT.Customer

-- CHALLENGE 2 Retrieve Customer and Sales Data

-- Retrieve a list of customer companies
SELECT CONVERT(varchar,CustomerID)+ ': ' + CompanyName AS [Customer Companies]
FROM SalesLT.Customer

-- Retrieve a list of Saler Order Revision
SELECT * FROM SalesLT.SalesOrderHeader
SELECT SalesOrderNumber + ' (' + CAST(RevisionNumber AS varchar) + ')' AS OrderNumber, CONVERT(date, OrderDate, 102) AS [Order Date]
FROM SalesLT.SalesOrderHeader

-- CHALLENGE 3 Retrieve Primary Contact Details
-- Retrieve customer contact names with middle names if known
SELECT FirstName + ' ' + ISNULL(MiddleName, '') + ' ' + LastName AS [CUSTOMER NAMES]
FROM SalesLT.Customer 

-- Retrieve primary contact details
SELECT CustomerID, COALESCE(EmailAddress, Phone) AS PrimaryContact
FROM SalesLT.Customer

-- Retrieve Shipping Status
SELECT * FROM SalesLT.SalesOrderHeader
SELECT SalesOrderID,
		CASE
			WHEN ShipDate IS NOT NULL THEN 'Shipped'
			ELSE 'Not Shipped'
		END as ShippingStatus
FROM SalesLT.SalesOrderHeader