USE AdventureWorksLt2012
-- Union Queries
SELECT FirstName, LastName, 'Employee' AS Type
FROM SalesLT.Employees
UNION ALL
SELECT FirstName, LastName 'Customer'
FROM SalesLT.Customer
ORDER BY LastName