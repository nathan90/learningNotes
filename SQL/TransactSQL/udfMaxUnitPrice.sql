-- ================================================
-- Template generated from Template Explorer using:
-- Create Inline Function (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the function.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Viswanath>
-- Create date: <Today>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION SalesLT.udfMaxUnitPrice
(	
	-- Add the parameters for the function here
	@SalesOrderID int 
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	SELECT SalesOrderID, MAX(UnitPrice) AS MaxUnitPrice
	FROM SalesLT.SalesOrderDetail
	WHERE SalesOrderID = @SalesOrderID
	GROUP BY SalesOrderID
)
GO
