-- View a system error
INSERT INTO SalesLT.SalesOrderDetail (SalesOrderID, OrderQty, ProductID, UnitPrice, UnitPriceDiscount)
VALUES
(10000, 1, 600, 1431.50, 0.00);

-- Raise an error with RAISERROR
UPDATE SalesLT.Product
SET DiscontinuedDate = GETDATE()
WHERE ProductID = 0;

IF @@ROWCOUNT < 1
	RAISERROR('The product was not found - no products have been updated', 16, 0);

-- Raise an error with THROW
UPDATE SalesLT.Product
SET DiscontinuedDate = GETDATE()
WHERE ProductID = 0;

IF @@ROWCOUNT < 1
	THROW 50001, 'The product was not found - no products have been updated', 0;

--Catch an error
BEGIN TRY
	UPDATE SalesLT.Product
	SET ProductNumber = ProductID / ISNULL(Weight, 0);
END TRY
BEGIN CATCH
	PRINT 'The following error occured:';
	PRINT ERROR_MESSAGE();
END CATCH;

--Catch and Rethrow
BEGIN TRY
	UPDATE SalesLT.Product
	SET ProductNumber = ProductID / ISNULL(Weight, 0);
END TRY
BEGIN CATCH
	PRINT 'The following error occured:';
	PRINT ERROR_MESSAGE();
	THROW;
END CATCH;

--Catch, log and throw a custom error
BEGIN TRY
	UPDATE SalesLT.Product
	SET ProductNumber = ProductID / ISNULL(Weight, 0);
END TRY
BEGIN CATCH
	DECLARE @ErrorLogID as int, @ErrorMsg AS varchar(250);
	EXECUTE dbo.uspLogError @ErrorLogID OUTPUT;
	SET @ErrorMsg = 'The update failed because of an error. View erro #'
					+ CAST(@ErrorLogID AS Varchar)
					+ ' in the error log for details.';
	THROW 50001, @ErrorMsg, 0;
END CATCH;

-- View the error log
SELECT * FROM dbo.ErrorLog;

--TRANSACTIONS

-- No transaction
BEGIN TRY
	INSERT INTO SalesLT.SalesOrderHeader (DueDate, CustomerID, ShipMethod)
	VALUES
	(DATEADD(dd, 7, GETDATE()), 1, 'STD DELIVERY');

	DECLARE @SalesOrderID int = SCOPE_IDENTITY();

	INSERT INTO SalesLT.SalesOrderDetail (SalesOrderID, OrderQty, ProductID, UnitPrice, UnitPriceDiscount)
	VALUES
	(@SalesOrderID, 1, 99999, 1431.50, 0.00);
END TRY
BEGIN CATCH
	PRINT ERROR_MESSAGE();
END CATCH;
--The above query will insert into the salesorderheader table but gives an error when tried 
--to insert into salesorderdetail table. so data will be inconsistent.orphan record created

-- View orphaned orders
SELECT h.SalesOrderID, h.DueDate, h.CustomerID, h.ShipMethod, d.SalesOrderDetailID
FROM SalesLT. SalesOrderHeader AS h
LEFT JOIN SalesLT.SalesOrderDetail AS d
ON d.SalesOrderID = h.SalesOrderID
WHERE D.SalesOrderDetailID IS NULL;

--Manually delete orphaned record
DELETE FROM SalesLT.SalesOrderHeader
WHERE SalesOrderID = SCOPE_IDENTITY();

-- The same query written using transaction
BEGIN TRY
	BEGIN TRANSACTION
		INSERT INTO SalesLT.SalesOrderHeader (DueDate, CustomerID, ShipMethod)
		VALUES
		(DATEADD(dd, 7, GETDATE()), 1, 'STD DELIVERY');

		DECLARE @SalesOrderID int = SCOPE_IDENTITY();

		INSERT INTO SalesLT.SalesOrderDetail (SalesOrderID, OrderQty, ProductID, UnitPrice, UnitPriceDiscount)
		VALUES
		(@SalesOrderID, 1, 99999, 1431.50, 0.00);
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
	BEGIN
		PRINT XACT_STATE();
		ROLLBACK TRANSACTION;
	END
	PRINT ERROR_MESSAGE();
	THROW 50001, 'An insert failed. The transaction was cancelled.',0;
END CATCH

-- View orphaned orders
SELECT h.SalesOrderID, h.DueDate, h.CustomerID, h.ShipMethod, d.SalesOrderDetailID
FROM SalesLT. SalesOrderHeader AS h
LEFT JOIN SalesLT.SalesOrderDetail AS d
ON d.SalesOrderID = h.SalesOrderID
WHERE D.SalesOrderDetailID IS NULL;
-- the above query returns 0 records because the orphaned order was handled by the transcation
-- and rolled back

-- Use XACT_ABORT
SET XACT_ABORT ON;
BEGIN TRY
	BEGIN TRANSACTION
		INSERT INTO SalesLT.SalesOrderHeader (DueDate, CustomerID, ShipMethod)
		VALUES
		(DATEADD(dd, 7, GETDATE()), 1, 'STD DELIVERY');

		DECLARE @SalesOrderID int =SCOPE_IDENTITY();

		INSERT INTO SalesLT.SalesOrderDetail (SalesOrderID, OrderQty, ProductID, UnitPrice, UnitPriceDiscount)
		VALUES
		(@SalesOrderID, 1, 99999, 1431.50, 0.00);
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	PRINT ERROR_MESSAGE();
	THROW 50001, 'An insert failed. The transaction was cancelled.', 0;
END CATCH
SET XACT_ABORT OFF;

-- View orphaned orders
SELECT h.SalesOrderID, h.DueDate, h.CustomerID, h.ShipMethod, d.SalesOrderDetailID
FROM SalesLT. SalesOrderHeader AS h
LEFT JOIN SalesLT.SalesOrderDetail AS d
ON d.SalesOrderID = h.SalesOrderID
WHERE D.SalesOrderDetailID IS NULL;
-- the above query returns 0 records because the orphaned order was handled by the transcation
-- and rolled back due to XACT_ABORT ON;