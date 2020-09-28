SELECT * FROM Production.Product

SELECT ProductID, Name, ListPrice, StandardCost, ListPrice - StandardCost AS Margin, Color
FROM Production.Product

SELECT ProductID, Name, Color, Size
FROM Production.Product

--CAST
SELECT CAST(ProductID AS varchar(5)) + ':' + Name AS ProductName
FROM Production.Product

--CONVERT
SELECT CONVERT(varchar(5), ProductID) + ':' + Name AS ProductName
FROM Production.Product

--CONVERT Dates
SELECT SellStartDate,
		CONVERT(nvarchar(30), SellStartDate) AS convertedDate,
	CONVERT(nvarchar(30), SellStartDate, 126) AS ISO8601FormatDate
FROM Production.Product

-- Try to cast since Size contains both integer as well as size like small medium, large
SELECT Name, TRY_CAST(Size AS Integer) AS NumericSize
FROM Production.Product