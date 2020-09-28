-- Grouping Sets

SELECT cat.ParentProductCategoryName, cat.ProductCategoryName, COUNT(prd.ProductID) AS Products
FROM SalesLT.vGetAllCategories as cat
LEFT JOIN SalesLT.Product AS prd
ON prd.ProductCategoryID = cat.ProductCategoryID
--GROUP BY cat.ParentProductCategoryName, cat.ProductCategoryName
--GROUP BY GROUPING SETS(cat.ParentProductCategoryName, cat.ProductCategoryName, ())
GROUP BY GROUPING SETS(cat.ParentProductCategoryName, cat.ProductCategoryName,(cat.ParentProductCategoryName, cat.ProductCategoryName), ())
--GROUP BY ROLLUP (cat.ParentProductCategoryName, cat.ProductCategoryName)
--GROUP BY CUBE (cat.ParentProductCategoryName, cat.ProductCategoryName)
ORDER BY cat.ParentProductCategoryName, cat.ProductCategoryName

-- Pivoting Data

SELECT * FROM
(SELECT P.ProductID, PC.Name, ISNULL(P.Color, 'Uncolored') AS Color
FROM SalesLT.ProductCategory AS PC
JOIN SalesLT.Product AS P
ON PC.ProductCategoryID = P.ProductCategoryID
) AS PPC
PIVOT(COUNT(ProductID) FOR Color IN ([Red],[Blue],[Black],[Silver],[Yellow],[Grey],[Multi],[Uncolored])) AS pvt
ORDER BY Name

-- You could create a view based on above statement and send to reporting dashboard

CREATE TABLE #ProductColorPivot
(Name varchar(50), Red int, Blue int, Black int, Silver int, Yellow int, Grey int, multi int, uncolored int)

INSERT INTO #ProductColorPivot
SELECT * FROM 
(SELECT P.ProductID, PC.Name, ISNULL(P.Color, 'Uncolored') AS Color
FROM SalesLT.ProductCategory AS PC
JOIN SalesLT.Product AS P
ON PC.ProductCategoryID = P.ProductCategoryID
) AS PPC
PIVOT(COUNT(ProductID) FOR Color IN ([Red],[Blue],[Black],[Silver],[Yellow],[Grey],[Multi],[Uncolored])) as pvt
ORDER BY NAME

SELECT * FROM #ProductColorPivot

SELECT Name, Color, ProductCount
FROM
(SELECT Name,
[Red],[Blue],[Black],[Silver],[Yellow],[Grey],[Multi],[Uncolored]
FROM #ProductColorPivot) pcp
UNPIVOT
(ProductCount FOR Color IN ([Red],[Blue],[Black],[Silver],[Yellow],[Grey],[Multi],[Uncolored])
) AS ProductCounts