## Modifying Data

### Inserting Data into Tables
* INSERT .. VALUES
  * Inserts explicit values
  * You can omit identity columns, columns that allow NULL, and columns with default constraints
  * You can also explicitly specify **NULL** and **DEFAULT**
    *  If a value is not given a *default value* will be inserted into the record
* INSERT...SELECT / INSERT...EXEC 
  * Inserts the results returned by the query or stored procedure into an existing table
* SELECT...INTO
  * Creates a new table from the results of a query
  * Not currently supported in Azure SQL database
  * The new table **doesnt have any indexes, primary keys etc**

### Generating Identifiers (Using Identity columns)
* INDENTITY property of a column generates sequential numbers automatically for insertion into table
  * Can specify optional seed and increment values
  * Use system variables and functions to return the last inserted identity:
    * `@@IDENTITY`:The last identity generated in the session
    * `SCOPE_IDENTITY()`: The last identity generated in the current scope
    * `IDENT_CURRENT('<table_name>')`: The last identity inserted into a table
    ```sql
    INSERT INTO Sales.Orders(CustomerID, Amount)
    VALUES
    (12, 2056.99)
    ...
    SELECT SCOPE_IDENTITY() AS OrderID;
    ```
### Generating Identifiers (Using Sequences)
* Sequences are objects that generate sequential numbers but it is not associated with any table. We can insert to any tables as unique value
  * Supported in SQL SERVER 2012 and later
  * Exists independently of tables, so offer greater flexibility than identity(**order numbers will be unique across different tables even**)
  * Use SELECT NEXT VALUE FOR to retrieve the next sequential number
    * Can be set as the default value for a column
    ```sql
    CREATE SEQUENCE Sales.OrderNumbers AS INT
    START WITH 1 INCREMENT BY 1;
    ...
    SELECT NEXT VALUE FOR Sales.OrderNumbers;
    ```

### Updating and Deleting Data (UPDATE Statement)
* Updates all rows in a table or view
  * Set can be filtered with a WHERE clause
  * Set can be defined with a FROM clause
  * Only the columns specified in the SET clause are modified
    ```sql
    UPDATE Production.Product
    SET unitprice = (unitprice * 1.04)
    WHERE categoryID = 1 AND discontinued = 0
    ```

### Updating Data in the Table (MERGE Statement)
* MERGE modifies data based on a condition
  * When the source matches the target
  * When the source has no match in the target
  * When the target has no match in the source
    ```sql
    MERGE INTO Production.Products as P
        USING Production.ProductsStaging as S
        ON P.ProductID = S.ProductID
    WHEN MATCHED THEN
        UPDATE SET
        P.UnitPrice = S.UnitPrice, P.Discontinued = S.Discontinued
    WHEN NOT MATCHED THEN
        INSERT (ProductName, CategoryID, UnitPrice, Discontinued)
        VALUES (S.ProductName, S.CategoryID, S.UnitPrice, S.Discontinued)

### Deleting Data From a Table
* DELETE without a WHERE clause deletes all rows
  * Use a WHERE clause to delete specific rows
    ```sql
    DELETE FROM Sales.OrderDetails
    WHERE orderid = 10248;
    ```
* TRUNCATE TABLE clears the entire table
  * Storage physically deallocated, rows not individually removed
  * Minimally logged
  * Can be rolled back if TRUNCATE issued within a transaction
  * **TRUNCATE TABLE will fail** if the table is referenced by a **foreign key constraint** in another table. To prevent orphaned records

## Programming With TransactSQL
### Batches
* Batches are a set of commands send to SQL Server as a unit
  * When a GO word is used, then that batch is sent. When there is another GO, another batch is sent.
* Batches determine variable scope, name resolution
* Client applications interpret the word `GO` and they send the statement before and then they send the next statement after the word `GO`.
* To separate statements into batches use a separator
  * SQL Server tools use the GO keyword
  * GO is not a T-SQL command
  * GO [count] executes the batch the specified number of times
    ```sql
    SELECT * FROM Production.Product
    SELECT * FROM Sales.Customer
    GO
    ```
### Comments
* Marks T-SQL code as a comment
  * For a block, enclose it between /* and */ characters
  * For inline text, precede the comments with --

### Variables
* Variables are objects that allow storage of a value for use later in the same batch
* Variables are defined with the DECLARE keyword
  * Variables can be declared and initialized in the same statement
* Variables are always local to the batch in which they are declared and go out of scope when the batch ends
    ```sql
    -- Declare and Initialize Variables
    DECLARE @color nvarchar(15)='Black', @size nvarchar(5)='L';
    -- Use variables in statements
    SELECT * 
    FROM Production.Product
    WHERE Color=@color and Size=@size;
    GO
    ```

### Conditional Branching

* `IF...ELSE` uses a predicate to determine the flow of the code
  * The code in the IF block is executed if the predicate evaluates to TRUE
  * The code in the ELSE block is executed if the predicate evaluates to FALSE or UNKNOWN
  ```sql
    IF @COLOR IS NULL
        SELECT * FROM Production.Product
    ELSE
        SELECT * FROM Production.Product
    WHERE Color = @Color
    ```
* Enclose multiple statements in an `IF` or `ELSE` clause between BEGIN and END keywords

### Looping

* WHILE enables code to execute in a loop
* Statements in the WHILE block repeat as the predicate evaluates to TRUE
* The loop will end when the predicate evaluates to FALSE or UNKNOWN
* Execution can be altered by BREAK or CONTINUE

  ```sql
  DECLARE @custID AS INT = 1, @lname AS NVARCHAR(20);
  WHILE @custID <= 5
    BEGIN
        SELECT @lname = lastname FROM Sales.Customer
        WHERE customerid = @custid
        PRINT @lname;
        SET @custID += 1;
    END;
    ```

### Stored Procedures
* Database objects that encapsulate Transact-SQL code. It can be reused
* Can be parameterized
  * Input Parameters
  * Output Parameters
* Stored procedures can return RowSets (Usually the results of the SELECT statement). They can return the output parameters, and they always return a value, which is used to indicate status
  ```sql
  CREATE PROCEDURE SalesLT.GetProductsByCategory (@CategoryID INT = NULL)
  AS
  IF @CategoryID IS NULL
    SELECT ProductID, Name, Color, Size, ListPrice
    FROM SalesLT.Product
  ELSE
    SELECT ProductID, Name, Color, Size, ListPrice
    FROM SalsesLT.Product
    WHERE ProductCategoryID = @CategoryID;
  ```
* Executed with the EXECUTE command
    ```sql
    EXECUTE SalesLT.GetProductsByCategory 6;
    ```

## Error and Error Messages

### Elements of Database Engine Errors
* Error number - Unique number identifying the specific error
* Error message - Text describing the error
* Severity - Numeric indication of seriousness from 1-25. 1-10 are the less severe messages
* State - Internal state code for database engine condition
* Procedure - The name of the stored procedure or trigger in which the error occured
* Which statement in the batch or procedure generated the error

In SQL Server(Not in AzureSQL Database)
  * Error messages are in sys.messages
  * You can add custom messages using sp_addmessage

If an error is thrown that has a critical level of severity, SQL Server will automatically close the connection and perhaps take the database offline etc.

### Raising Errors
* The RAISERROR Command
  * Raise a user-defined error in sys.messages (SQL Server Only)
  * Raise an explicit error message, severity, and state (SQL Server and Azure SQL Database)
    ```sql
    RAISERROR ('An error occured', 16, 0)
    ```
* The THROW Command
  * Replacement for RAISERROR
  * Throw explicit error number, message and state (severity is 16)
  * Re-throw existing error
    ```sql
    THROW 50001,'An error occured', 0;
    ```

### Catching and Handling Error
* Use a TRY.. CATCH block
* Handle errors in the CATCH block
  * Get error information
    * @@ERROR
    * ERROR_MESSAGE()
    * ERROR_SEVERITY()
    * ERROR_STATE()
    * ERROR_PROCEDURE()
    * ERROR_LINE()
  * Execute custom correction or logging code
  * Re-throw the original error, or throw a custom error
    ```sql
    DECLARE @Discount INT = 0;
    BEGIN TRY
            UPDATE Production.Product
            SET Price = Price/@Discount
    END TRY
    BEGIN CATCH
            PRINT ERROR_MESSAGE();
            THROW 50001, 'An error occured',0;
    END CATCH;
    ```

### Introduction to Transactions
* A transaction is a group of tasks defining a unit of work
* The entire unit must succeed or fail together - no partial completion is permitted
    ```sql
    --Two tasks that make up a unit of work
    INSERT INTO Sales.Order...
    INSERT INTO Sales.OrderDetail...
    ```
* Individual data modification statements are automatically treated as standalone transactions. If you do an INSERT or UPDATE or DELETE statement as we've seen, it might affect multiple rows just that onse statement. Any **individual Transact-SQL statement** that gets executed, SQL server itself treats that as a transaction. So if it falls over half way through the rows, it will never just do half the rows.
* The way SQL works is that it has a **write-ahead transaction log.** It logs all the things it's going to do. And only when it's finished does it write that it's finished. It writes that it's committed the transaction and that's beem what they call check-pointed. What it will do is when it comes back up again, it will read the log, and it finds something where it started to do something but then never finished it, it will roll it back. So it will make sure that we finish with a consistent database ie either all the transactions succeeded or all of them failed
* SQL Server uses locking mechanisms and the transaction log to support transactions

### Implementing Explicit Transactions
* Use BEGIN TRANSACTION to start a transaction
  ```sql
  BEGIN TRY
    BEGIN TRANSACTION
      INSERT INTO Sales.Order...
      INSERT INTO Sales.OrderDetail...
    COMMIT TRANSACTION
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0
    BEGIN
      ROLLBACK TRANSACTION
    END
    PRINT ERROR_MESSAGE();
    THROW 50001, 'An error occured', 0;
  END CATCH;
  ```
* Use COMMIT TRANSACTION to complete a transaction
* Use ROLLBACK TRANSACTION to cancel a transaction
  * Or enable XACT_ABORT to automatically rollback on error
*  Use @@TRANCOUNT and XACT_STATE() to check transaction status