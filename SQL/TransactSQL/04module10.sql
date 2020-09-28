-- Search by city using a variable
DECLARE @City VARCHAR(20)='Toronto'
SET @City ='Bellevue'

SELECT FirstName + ' ' + LastName AS [Name], AddressLine1 AS Address, City
FROM SalesLT.Customer AS C
JOIN SalesLT.CustomerAddress AS CA
ON C.CustomerID = CA.CustomerID
JOIN SalesLT.Address AS A
ON CA.AddressID = A.AddressID
WHERE City = @City

--Use a variable as an output
DECLARE @Result MONEY
SELECT @Result = MAX(TotalDue)
FROM SalesLT.SalesOrderHeader

PRINT(@RESULT)

-- Simple logical Test
IF 'Yes' = 'Yes'
PRINT 'True'

-- Change code based on a condition
UPDATE SalesLT.Product
SET DiscontinuedDate = GETDATE()
WHERE ProductID = 6810;

IF @@ROWCOUNT < 1
BEGIN
	PRINT 'Product was not found'
END
ELSE
BEGIN
	PRINT 'Product Updated'
END

SELECT * FROM sys.dm_os_wait_stats;


--LOOPS

CREATE TABLE SalesLT.DemoTable


DECLARE @Counter INT = 1
WHILE @Counter <= 5

BEGIN
	INSERT SalesLT.DemoTable(Description)
	VALUES ('ROW' + CONVERT(varchar(5), @Counter))
SET @Counter=@Counter+1
END
-- SET based operation is much faster than looping through n number of times

SELECT Description FROM SalesLT.DemoTable


-- Create A Stored Procedure
CREATE PROCEDURE SalesLT.GetProductsByCategory (@CategoryID INT = NULL)
AS
IF @CategoryID IS NULL
	SELECT ProductID, Name, Color, Size, ListPrice
	FROM SalesLT.Product
ELSE
	SELECT ProductID, Name, Color, Size, ListPrice
	FROM SalesLT.Product
	WHERE ProductCategoryID = @CategoryID

-- Execute the procedure without a parameter
EXEC SalesLT.GetProductsByCategory

-- Execute the procedure with a parameter
EXEC SalesLT.GetProductsByCategory 6

