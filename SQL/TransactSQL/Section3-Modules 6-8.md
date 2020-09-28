## Using SubQueries And APPLY
* Sub Queries are queries within queries or Nested Sub Queries
* Results of the inner query are passed to the outer query
  * Inner query acts like an expression from the perspective of the outer query

Scalar or Multivalued
* Scalar subquery returns single value to outer query
  * Can be used anywhere single-valued expression is used: SELECT, WHERE, and so on
  ```Sql
  SELECT orderID, productID, unitPrice, qty 
  FROM Sales.OrderDetails 
  WHERE orderID =
    (SELECT MAX(orderID) AS lastOrder FROM Sales.Orders)
    ```
* Multi-valued subquery returns multiple values as a single column set to the outer query
  * Used with IN predicate
  ```Sql
  SELECT custID, orderId
  FROM Sales.Orders
  WHERE custID IN 
            (SELECT custID FROM Sales.Customers
                WHERE countryRegion = 'NMexico')
    ```
  * The returned value of multi-valued subQuery is essentially a column of single rows so we use `IN`

Self Contained or Correlated
* Most subqueries are self-contained and have no connection with the outer query other than passing its results
* Correlated subqueries refer to elements of tables used in outer query
    * Dependent on outer query, cannote be executed separately
    * Behaves as if inner query is executed once per outer row
    * May return scalar values or multiple values
        ```sql
        SELECT orderID, empID, orderDate
        FROM Sales.Order AS O1
        WHERE orderDate = (SELECT MAX(orderDate)
                            FROM Sales.Orders AS O2
                            WHERE O2.empID = O1.empID)
        ORDER BY empID, orderDate;
        ```
    * What happens is for each row in the outer query, return me an employeeID and run the subquery using that value, and then go backwards and do the comparison of the outer query, then go to the next row and do it again
    * It is very resourse intensive and should be avoided whenever possible

### The APPLY Operator
Using APPLY with Table-Valued-Functions
* CROSS APPLY applies the right table expression to each row in the left table
    * Conceptually similar to CROSS JOIN between two tables, but can correlate data between sources
        ```sql
        SELECT S.SupplierID, S.CompanyName, P.ProductID, P.ProductName, P.UnitPrice FROM Production.Suppliers AS S
        CROSS APPLY dbo.fn_TopProductsByShipper(S.SupplierID) AS P 
        ```
    * Conceptually CROSS APPLY is running the function for each with a value that we are getting for each row.
* OUTER APPLY adds rows for those with NULL in columns for right table
    * Conceptually similar to LEFT OUTER JOIN between two tables

## TABLE Expressions

### Querying **VIEWS**
* Views are database objects that encapsulates SELECT queries
* Views are like named queries, Like a presentation of data with defintions stored in the database
    * Views can provide abstraction, encapsulation and simplification
    * From an administrative perspective, views can provide a security layer to the database. Can give developer access to the view rather than access to the whole table
    * Views can be referenced in a SELECT statement just like a table
    ```sql
    CREATE VIEW Sales.vSalesOrders
    AS
    SELECT oh.OrderID, oh.OrderDate, oh.CustomerID, od.LineItemNo, od.ProductID, od.Quantity
    FROM Sales.OrderHeaders AS oh
    JOIN Sales.OrderDetails AS od
    ON od.OrderID = oh.OrderID;
    ```
    ```sql
    SELECT OrderID, CustomerID, ProductID
    FROM Sales.vSalesOrder
    ORDER BY OrderID;
    ```
    * If you are inserting or updating data through view, it will affect only one of the underlying tables that the view is based on

### Using Temporary Tables and Table Variables

**Temporary Tables**
```sql
CREATE TABLE #tmpProducts
(ProductID INTEGER,
 ProductName varchar(50));
GO

SELECT * FROM #tmpProducts;
```
* Temporary tables are used to hold temporary result sets within a user's session
  * Created in tempdb and deleted automatically
  * Created with a # prefix (scoped to current users session)
  * Global temporary tables are created with a ## prefix
  * TempDB is maintained by the system

**Table Variables**
```sql
DECLARE @varProducts table
(ProductID INTEGER,
 ProductName varchar(50));
....
SELECT * FROM @varProducts
```
* Introduced because temporary tables can cause recompilations
* Used similarly to temporary tables but scoped to the batch
* Recommended to use only on very small datasets

### Table Valued Functions
```sql
CREATE FUNCTION  Sales.fn_GetOrderItems (@OrderID AS Integer)
RETURNS TABLE
AS
RETURN
(SELECT ProdcutID, UnitPrice, Quantity
 FROM Sales.OrderDetails
 WHERE OrderID = @OrderID);
 ...
 SELECT * FROM Sales.fn_GetOrderItems(1025) AS LineItems
 ```
 * TVFs are named objects with definitions stored in the Database. It is a type of function that returns an table/rowset
 * TVFs return a virtual table to the calling query
 * Unlike views, TVFs support input parameters
   * TVFs may be thought of as parameterized views

### Derived Tables
* Derived Tables are subqueries that return table that have multiple columns
* Derived tables are named query expressions created within an outer SELECT statement
```Sql
SELECT orderYear, COUNT(DISTINCT custID) AS cust_count 
FROM 
    (SELECT YEAR(OrderDate) AS orderYear, custID
    FROM Sales.Orders) AS derived_year
GROUP BY orderYear;
```
* Not Stored In the Database - represents a virtual relational table
* Scope of a derived table is the query in which it is defined
* Derived Tables ***must***
  * Have an alias
  * Have unique names for all columns
  * Not use an ORDER BY clause (without TOP or OFFSET/FETCH)
  * Not to be referred to multiple times in the same query
* Derived tables ***may***
  * Use internal or external aliases for columns
  * Refer to parameters and/or variables
  * Be nested within other derived tables
* Specifying Column Aliases
  * Column aliases may be defined inline:
    ```sql
     SELECT orderYear, COUNT(DISTINCT custID) AS cust_count FROM 
        (SELECT YEAR(OrderDate) AS orderYear, custID
        FROM Sales.Orders) AS derived_year
    GROUP BY orderYear;
    ```
  * Or Externally
    ```sql
     SELECT orderYear, COUNT(DISTINCT custID) AS cust_count FROM 
        (SELECT YEAR(OrderDate), custID
        FROM Sales.Orders) AS derived_year(orderYear, custID)
    GROUP BY orderYear;
    ```

### Common Table Expressions
* CTEs are named table expressions defined in a Query
  ```sql
  WITH CTE_year(OrderYear, CustID)
  AS
  (
      SELECT YEAR(orderDate), custid
      FROM Sales.Orders
  )
  SELECT OrderYear, COUNT(DISTINCT(CustID)) AS Cust_Count
  FROM CTE_year
  GROUP BY orderYear;
  ```
* CTEs are similar to derived tables in scope and naming requirements
* Unlike derived tables, CTEs support multiple references and recursion

RECURSION

```sql
WITH OrgReport (ManagerID, EmployeeID, EmployeeName, Level)
AS 
(
    SELECT e.ManagerID, e.EmployeeID, e.EmployeeName, 0
    FROM HR.Employee AS e
    WHERE ManagerID IS NULL
    UNION ALL
    SELECT e.ManagerID, e.EmployeeID, e.EmployeeName, Level +1 
    FROM HR.Employee AS e
    INNER JOIN OrgReport AS o ON e.ManagerID = o.EmployeeID
)
SELECT * FROM OrgReport
OPTION (MAXRECURSION 3)
```
* We have an anchor query, getting the top level of the hierarchy ie specify a query for the root/anchor level
* Use UNION ALL to add a recursive query for other levels
* CTE is the only way for recursive queries

## Grouping Sets and Pivoting Data

### Grouping Sets
* GROUPING SETS subclause builds on GROUP BY clause
* Allows multiple groupings to be defined in same query
    ```sql
    SELECT <column list with aggregate(s)>
    FROM <source>
    GROUP BY
    GROUPING SETS
    (
        <column_name>,--one or more columns
        <column_name>,--one or more columns
        () -- empty paranthesis if aggregating all rows
    );
    ```
* Example
    ```sql
    SELECT EmployeeID, CustomerID, SUM(Amount) AS TotalAmount
    FROM Sales.SalesOrder
    GROUP BY
    GROUPING SETS(EmployeeID, CustomerID, ())

### ROLLUP and CUBE
* ROLLUP provides shortcut for defining grouping sets with combinations that assume input columns form a hierarchy
    ```Sql
    SELECT StateProvince, City, COUNT(CustomerID) AS Customers
    FROM Sales.vCustomerDetails
    GROUP BY ROLLUP(StateProvince, City)
    ORDER BY StateProvince, City;
    ```
* CUBE provides shortcut for defining grouping sets in which all possible combinations of grouping sets created
    ```sql
    SELECT SalesPersonName, CustomerName, SUM(Amount) AS TotalAmount FROM Sales.vSalesOrders
    GROUP BY CUBE(SalesPersonName, CustomerName)
    ORDER BY SalesPersonName, CustomerName
    ```

#### Identifying Groupings in Results
* Multiple grouping sets present a problem in identifying the source of each row in the result set
* NULLS could come from the source data or could be a placeholder in the grouping set
* The **GROUPING_ID** function provides a method to mark a row with a 1 or 0 to identify which grouping set for the row
    ```Sql
    SELECT GROUPING_ID(SalesPersonName) AS SalesPersonGroup,
            GROUPING_ID(CustomerName) AS CustomerGroup,
            SalesPersonName, CustomerName, SUM(Amount) AS TotalAmount
    FROM Sales.vSalesOrders
    GROUP BY CUBE(SalesPersonName, CustomerName)
    ORDER BY SalesPersonName, CustomerName;
    ```
* Look into **GROUPING and GROUPING_ID**
### Pivoting Data
* Pivoting data is rotating data from a rows-based orientation to a columns-based orientation
* Distinct values from a single column are projected across as headings for other columns - may include aggregation
    ```sql
    SELECT OrderID, Bikes, Accessories, Clothing
    FROM 
        (SELECT OrderID, Category, Revenue, FROM Sales.SalesDetails) AS sales
        PIVOT (SUM(Revenue) FOR Category IN ([Bikes], [Accessories], [Clothing])) AS pvt
    ```
### Unpivoting Data
* Unpivoting data is rotating data from a columns-based orientation to a rows-based orientation
* Spreads or splits values from one Source Row into one or more target rows
* Each source row becomes one or more rows in result set based on numbe rof columns being pivoted
    ```sql
    SELECT OrderID, Category, Revenue
    FROM
        (SELECT OrderID, Bikes, Accessories, Clothing FROM Sales.SalesByCat) AS pvt
    UNPIVOT (Revenue FOR Category IN ([Bikes], [Accessories], [Clothing])) AS unpvt
    ```

