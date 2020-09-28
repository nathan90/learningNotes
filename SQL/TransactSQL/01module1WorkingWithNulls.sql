--NULL Numbers = 0 This will set null values in the Size columnt to 0

SELECT Name, ISNULL(TRY_CAST(Size AS INTEGER), 0) AS NumericSize
FROM Production.Product

-- NULL Strings = blank strings
SELECT ProductNumber, ISNULL(Color, '') + ', ' + ISNULL(Size, '') AS ProductDetails
FROM Production.Product

SELECT  distinct color from Production.Product
SELECT  distinct color from Production.Product where color is NULL-- 'Silver/Black'
SELECT  count(*) from Production.Product where color is NULL-- 'Silver/Black'

-- Multi color = NULL
SELECT Name, NULLIF(Color, 'Silver/Black') as SingleColor
FROM Production.Product

--Find the first non- null date
SELECT Name, COALESCE(DiscontinuedDate, SellEndDate, SellStartDate) AS LastActivity
FROM Production.Product;

-- Searched Case
SELECT Name, COALESCE(DiscontinuedDate, SellEndDate, SellStartDate) AS LastActivity,
		CASE 
			WHEN SellEndDate IS NULL THEN 'On Sale'
			ELSE 'Discontinued'
		END AS SaleStatus
FROM Production.Product

-- Simple CASE
select size from Production.Product
SELECT Name,
		CASE Size
			WHEN 'S' THEN 'Small'
			WHEN 'M' THEN 'Medium'
			WHEN 'L' THEN 'Large'
			WHEN 'XL' THEN 'Extra Large'
			ELSE ISNULL(Size, 'n/a')
		END AS ProductSize
FROM Production.Product;




