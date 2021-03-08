SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [pbi].[Sales Order] 
AS 
SELECT 
	--soh.SalesOrderID,
       soh.OrderDate,
       soh.DueDate,
       soh.ShipDate,
       soh.Status,
       soh.SalesOrderNumber,
       soh.AccountNumber,
       soh.CustomerID,
       soh.SalesPersonID,
       soh.TerritoryID,
       soh.BillToAddressID,
       soh.ShipToAddressID,
       soh.ShipMethodID,
       --soh.CurrencyRateID,
	   --cr.CurrencyRateID,
       --cr.CurrencyRateDate,
       --cr.FromCurrencyCode,
       --cr.ToCurrencyCode,
       --cr.AverageRate,
       --cr.EndOfDayRate,
       --cr.ModifiedDate,
       --soh.SubTotal,
       --soh.TaxAmt,
       --soh.Freight,
       --soh.TotalDue,
	   --sod.SalesOrderID,
       --sod.SalesOrderDetailID,
       sod.OrderQty,
       sod.ProductID,
       ISNULL(cr.AverageRate,1.00) * sod.UnitPrice [USD Unit Price],
       sod.UnitPriceDiscount,
        ISNULL(cr.AverageRate,1.00) * sod.LineTotal [USD Line Total]
       --sod.ModifiedDate
FROM Sales.SalesOrderHeader soh
INNER JOIN sales.SalesOrderDetail sod ON sod.SalesOrderID = soh.SalesOrderID
LEFT JOIN Sales.CurrencyRate cr ON cr.CurrencyRateID = soh.CurrencyRateID
WHERE soh.OnlineOrderFlag = 0;
GO
