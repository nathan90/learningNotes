## JOINS
Joins combine rows from multiple tables by specifying matching criteria
* Usually based on primary key foreign key relationships
* For example, return rows that combine data from  the Employee and SalesOrder tables by matching the Employee.EmployeeID primary key to the SalesOrder.EmployeeID foreign key
* A primary ID can be a unique column or a composite key of multiple column
* Venn diagram is analogous to joins
* ANSI SQL 92
  * Tables joined by JOIN operator in FROM Clause
  * Preferred Syntax
    ```sql
    SELECT ...
    FROM Table1 JOIN Table2
        ON <on_predicate>
    ```
### INNER JOINS
* Return only rows where a match is found in both Input tables
* Match rows based on attributes supplied in predicate
* If join predicate operator is `=` also known as equi-join
  ```sql
  SELECT emp.FirstName, ord.Amount
  FROM HR.Employee AS emp
  [INNER] JOIN Sales.SalesOrder AS ord
  ON emp.EmployeeID = ord.EmployeeID
  ```
* No need to specify inner for Inner Joins

Internally SQL will do a Cartesian Product and then filter out based on the predicates and the joins that I have defined

### OUTER JOINS
* Return all rows from one table and any matching rows from second table
* One table's rows are "preserved"
  * Designated with **LEFT, RIGHT, FULL** keyword.
  * All rows from the preserved table output to the result set.
* Matches from the other table retrieved
* Additional rows added to results for non matched rows
  * NULLS added in places where attributes do not match
* Example: Return all employees and for those who have taken orders, return the order amount. Employees without matching orders will display NULL for order amount.
  ```sql
  SELECT emp.FirstName, ord.Amount FROM HR.Employee AS emp
  LEFT [OUTER] JOIN Sales.SalesOrder AS ord
  ON emp.EmployeeID = ord.EmployeeID;
  ```
* Once you have declared a LEFT or RIGHT JOIN, if you then continue to add tables on to the chain of tables, you should use the same join. For example, if you have a **LEFT JOIN** and you add another table to the right, you have to keep using **LEFT JOINs**

### CROSS JOIN
* Combine each row from first table with each row from second table. No Need to have an ***ON clause***
* All possible combinations output
* Logical foundation for inner and outer joins
  * Inner join starts with Cartesian Product, adds filter
  * Outer join takes Cartesian output, filtered, adds back non-matching rows (with NULL placeholders)
* Due to Cartesian product output, not typically a desired form of join
  * Some useful exceptions
    * Table of numbers, generating data for testing
  ```sql
  SELECT emp.FirstName, prd.Name FROM HR.Employee AS emp CROSS JOIN Production.Product AS prd;
  ```

### SELF JOIN
* Compare rows in the same table to each other
* Create two instances of the same table in FROM clause
  * Atleast 1 alias required
* eg Return all employees and the name of the employee's manager
  ```sql
  SELECT emp.FirstName AS Employee, 
         man.FirstName AS Manager
  FROM HR.Employee AS emp
  LEFT JOIN HR.Employee AS man
  ON emp.ManagerID = man.EmployeeID;
  ```

## UNION Queries
* UNION returns a result set of **distinct rows** combined from all statements
* UNION returns a result set that removes duplicate rows(affects performance)
* UNION ALL retains duplicates during query processing
* UNION guidelines
  * Must be expressed in the first query
  * Aliases in the 2nd and subsequent queries are ignored
* Number of columns
  * Must be the same
* Datatypes
  * Must be compatible for implicit conversion(or converted explicitly)

  ```sql
  SELECT countryregion, city FROM HR.Employees
  UNION
  SELECT countryregion, city FROM Sales.Customers;
  ```

### INTERSECT and EXCEPT Queries

#### INTERSECT
* Returns only **distinct rows** that appear in both result sets

  ```sql
  -- Only rows that exist in both queries will be returned 
  SELECT countryregion, city FROM HR.Employees
  INTERSECT 
  SELECT countryregion, city FROM Sales.Customers;
  ```

#### EXCEPT
* Returns only distinct rows that appear in the first set but not the second
  * Order in which sets are specified matters

  ```sql
  -- only rows from Employees will be returned
  SELECT countryregion, city FROM HR.Employees
  EXCEPT
  SELECT countryregion, city FROM Sales.Customers;
  ```

## FUNCTIONS
| Function Category | Description                                                                      |
|-------------------|----------------------------------------------------------------------------------|
| Scalar            | Operate on a single row, return a single value                                   |
| Logical           | Scalar functions that compare multiple values to determine a single output       |
| Aggregate         | Take one or more input values, return a single summarizing value                 |
| Window            | Operate on a window(set) of rows                                                 |
| Rowset            | Return a virtual table that can be used subsequently in a Transact-SQL statement |

### Scalar Functions
* Operate on elements from a single row as inputs, return a single value as output
* Return a single(scalar) value
* Can be used like an expression in queries
* May be deterministic or non-determinstic

## Logical Functions
* Output is determined by comparative logic
* ISNUMERIC
  ```sql
  SELECT ISNUMERIC('101.99') AS Is_a_Number;
  ```
* IIF
  ```sql
  SELECT productID, listPrice, IIF(listPrice > 50, 'high', 'low') AS PricePoint 
  FROM Production.Product
  ```
* CHOOSE
  ```sql
  SELECT ProductName, Color, Size,
    CHOOSE (ProductCategoryID, 'Bikes', 'Components', 'Clothing', 'Accessories') AS Category
    FROM Production.Product
    ```

## Window Functions

* Functions applied to a window, or a set of rows
* Include ranking, offset, aggregate and distribution functions
  ```sql
  SELECT TOP(3) ProductId, Name, ListPrice, RANK() OVER (ORDER BY ListPrice DESC) AS RankByPrice
  FROM Production.Product
  ORDER BY RankByPrice
  ```

## Aggregate Functions
* Functions that operate on sets, or rows of data
* Summarize input rows
* Without GROUP BY clause, all rows are rearranged as one group
  ```sql
  SELECT COUNT(*) AS OrderLines,
    SUM(OrderQty * UnitPrice) AS TotalSales
  FROM Sales.OrderDetail;
  ```
* Aggregates ignores NULLS

### Grouping With GROUP BY
* GROUP BY creates groups for output rows, according to a unique combination of values specified in the GROUP BY clause
* GROUP BY calculates a summary value  for aggregate functions in the subsequent phases
* Detail Rows are "*lost*" after GROUP BY clause is processed
  ```sql
  SELECT CustomerID, COUNT(*) AS Orders
  FROM Sales.SalesOrderHeader
  GROUP BY CustomerID;
  ```

### Filtering Groups
* HAVING clause provides a search condition that each group must satisfy
* WHERE clause is processed before GROUP BY, HAVING clause is PROCESSED after GROUP BY
  ```sql
  SELECT CustomerID, COUNT(*) AS Orders 
  FROM Sales.SalesOrderHeader
  GROUP BY CustomerID
  HAVING COUNT(*) > 10;
  ```
  