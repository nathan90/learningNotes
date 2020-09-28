## Module 1: Introduction to Transact SQL
**Entities**, **relations** are also called tables.  
**attributes**, **domains** are also called columns  

The point of relational database is to not have any duplication ie database should be normalized

RDBS have a notion called **Schema** and **Objects**.  
**Objects** which we deal are mostly tables, views, stored procedures  
**Schema** is a namespace for our tables. They are a way of having some extended name that help us identify that table. The fully qualified name of an object in a database is the server name, followed by the database name, beacuse a server could have multliple databases followed by the schema name,  and database could have multple schemas, followed by individual object names.

In AZURE we can only work with one database at a time.

DML - Data Manipulation Language - This deals with querying database, getting information out of the tables, updating data in our tables, deleting data, etc.

DDL - Data Definition Language - This is used for creating database or creating tables. CREATE ALTER, DROP are based on DDL

DCL - Data Control Language - We use these to set permissions, securing objects by assigning who can access which objects

**The SELECT Statement**

| Element  | Expression       | Role                             |
|----------|------------------|----------------------------------|
| SELECT   | select list      | Defines which column to return   |
| FROM     | table source     | Defines table(s) to query        |
| WHERE    | search condition | Filters rows using a predicate   |
| GROUP BY | group by a list  | Arrage rows by groups            |
| HAVING   | search condition | Filters groups using a predicate |
| ORDER BY | order by list    | Sorts the output                 

* SELECT returns specified columns, literal values, or expressions from single table or multiple tables. The result of a select table is always a virutal table
* Returned tables are not ordered in any way. SQL will find the best way to return the data.


### **Order of Execution of SQL Statement**

The order of execution of a SQL Query is as below  
SELECT FROM WHERE GROUPBY HAVING ORDER BY
1. **`FROM`** is first called
2. **`WHERE`** to filter the table
3. **`GROUP BY`** to aggregate data
4. **`HAVING`** to filter the aggregated data
5. **`SELECT`** to select the data
6. **`ORDER`** BY orders the selected data

We should specify each column name rather than using * so that we can let know what the user is getting in the order that we specify

By default we are connected to the **master database** which is a system database used by the system internally

Nulls are unknowns, NULL is not treated as a blank string or empty column. If you add subtract or do any operation with a NULL it will evaluate to NULL

**TransactSQL DataTypes**

| Exact Numeric   | Approx Numeric | Character | Date/Time      | Binary    | Other            |
|-----------------|----------------|-----------|----------------|-----------|------------------|
| tinyint         | float          | char      | date           | binary    | cursor           |
| smallint        | real           | varchar   | time           | varbinary | hierarchyid      |
| int             |                | text      | datetime       | image     | sql_variant      |
| bigint          |                | nchar     | datetime2      |           | table            |
| bit             |                | nvarchar  | smalldatetime  |           | timestamp        |
| decimal/numeric |                | ntext     | datetimeoffset |           | uniqueidentifier |
| numeric         |                |           |                |           | xml              |
| money           |                |           |                |           | geography        |
| smallmoney      |                |           |                |           | geometry         |

n prefixed data types means that we are allocating two bytes for each character. These are for unicode characters, which are not in the ascii table

There is **implicit conversion** between specific datatype subtypes like addition between varchar and nvarchar, int and float. These will be handled by the query engine itself.

**Explicit conversion** requires an explicit conversion function
* `CAST/ TRY_CAST` ( try cast tries to convert returns NULL if failed)
* `CONVERT/ TRY_CONVERT`( Used with dates)
* `PARSE/ TRY_PARSE` (To convert to number)
* `STR`

**CAST** and **CONVERT** work almost the same way, but we have to use **CONVERT** while working with **dates**

**Working With Nulls**
* NULL represents a missing or unknown value
* ANSI behaviour for NULL values:
  * The result of any expression containing a NULL value is NULL
    * 2 + NULL = NULL
    * 'MyString' + NULL = NULL
  * Equality comparisons always returns false for NULL values
  * NULL = NULL returns ***false***
  * NULL ***IS NULL*** returns ***true***
* NULL Functions
  * **`ISNULL`**(column/variable, value)
    * Returns value if the column or variable is NULL
  * **`NULLIF`**(column/variable, value)
    * Check for a specific value and if found, we use NULL
    * Returns NULL if the column or variable is value
  * **`COALESCE`**(column/variable1, column/variable2,..)
    * Returns the value of the first non-NULL column or variable in the list
  * **`CASE`**(CASE WHEN statements END)
    * Case can be used to have a column where the value depends on some logic that I want to work out.


### **Removing Duplicates**

SELECT Statement by default includes all duplicates  
SELECT DISTINCT removes duplicates

IF we put multiple columns after DISTINCT it will return the distinct combination. For eg: SELECT DISTINCT Color, Size returns the unique color, size combination.

### **Sorting Results**
* Use `ORDER BY` to sort results by one or more columns
  * Aliases created in the SELECT clause are visible to ORDER BY
  * You can order by columns in the source that are not included in the SELECT clause
  * You can specify ASC or DESC (ASC is the default)

```sql
SELECT ProductCategory AS Category, ProductName 
FROM Production.Product
ORDER BY Category, Price DESC
```
In the above example we are ordering by Category in ascending order then Ordering by Price in descending order

### Limiting Sorted Results
* TOP allows you to limit the number or percentage of rows returned by a query
* Works with ORDER BY clause to limit rows by sort order
* The table should be ordered before using a select top clause
* Added to SELECT clause
  * SELECT TOP(N) | TOP(N) Percent
    * With Percent, number of rows are rounded up
  * SELECT TOP(N) WITH TIES
    * Retrieve duplicates where applicable (non deterministic). Means if there is tie for the 10th item, it will return both the records
    ```sql
    SELECT TOP 10 ProductName, ListPrice
    FROM Production.Product
    ORDER BY ListPrice DESC;
    ```

### Paging Through Results
* `OFFSET-FETCH` is an extension to the `ORDER BY` clause:
  * Allows filtering a requested range of rows
    * Dependent on ORDER BY clause
  * Provides a mechanism for paging through results
  * Specify number of rows to skip, number of rows to retrieve
    ```sql
    ORDER BY <order_by_list>
    OFFSET <offset_value> ROW(S)
    FETCH FIRST|NEXT <fetch_value> ROW(S) ONLY
    ```
    ```sql
    -- Display the next 10 products by product number
    SELECT Name, ListPrice FROM Production.Product
    ORDER BY ProductNumber
    OFFSET 10 ROWS FETCH FIRST 10 ROW ONLY
    ```

### Filtering and Using Predicates
Predicates are specified in the WHERE clause
| Predicates and Operators | Description                                                                                             |
|--------------------------|---------------------------------------------------------------------------------------------------------|
| =<>                      | Compares values for equality/ non-equality                                                              |
| IN                       | Determines whether a specified value matches any value in a subquery or a list                          |
| BETWEEN                  | Specifies an inclusive range to test.                                                                   |
| LIKE                     | Determines whether a specific character string matches a specified pattern, which can include wildcards |
| AND                      | Combines two Boolean Expressions and return TRUE only if both of THEM are TRUE                          |
| OR                       | Combines two Boolean Expressions and return TRUE if either one of THEM are TRUE                         |
| NOT                      | Reverses the result of a search condition                                                               |
We use wildcards like `%` and `_` to find matches that start or end with a particular value  
