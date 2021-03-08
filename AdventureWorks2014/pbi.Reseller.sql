SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [pbi].[Reseller] 
AS 
WITH CTE_SalesTotals AS (
	SELECT DISTINCT
           soh.CustomerID,
           c.StoreID,
           SUM(soh.SubTotal) OVER (PARTITION BY c.StoreID) StoreSalesTotal,
           SUM(soh.SubTotal) OVER (PARTITION BY cr.CountryRegionCode) CountryRegionSalesTotal
    FROM Sales.SalesOrderHeader soh
        INNER JOIN Sales.Customer c ON c.CustomerID = soh.CustomerID
		INNER JOIN Sales.Store ss ON ss.BusinessEntityID = c.StoreID
		INNER JOIN [Person].[BusinessEntityAddress] bea ON bea.[BusinessEntityID] = ss.[BusinessEntityID] AND bea.AddressTypeID = 3
		INNER JOIN Person.Person p ON p.BusinessEntityID = c.PersonID
		INNER JOIN [Person].[Address] a ON a.[AddressID] = bea.[AddressID]
		INNER JOIN [Person].[StateProvince] sp ON sp.[StateProvinceID] = a.[StateProvinceID]
		INNER JOIN [Person].[CountryRegion] cr ON cr.[CountryRegionCode] = sp.[CountryRegionCode]
    WHERE soh.OnlineOrderFlag = 0
)

SELECT DISTINCT
	c.CustomerID [ResellerID],
	RANK() OVER (ORDER BY StoreSalesTotal Desc) AS ResellerSort,
	--CTE_SalesTotals.StoreSalesTotal,
    c.AccountNumber,
    ss.Name [Reseller Name],
	a.[AddressLine1],
    a.[AddressLine2],
    a.[City],
    sp.[Name] AS [State or Province],
    a.[PostalCode] [Post Code],
    cr.[Name] AS [Reseller Country],
	RANK() OVER (ORDER BY CTE_SalesTotals.CountryRegionSalesTotal DESC) CountrySort,
	p.FirstName + ' ' + p.LastName [Reseller Contact],
	ea.EmailAddress [Resller Email]
FROM Sales.Customer c
    INNER JOIN Sales.Store ss ON ss.BusinessEntityID = c.StoreID
    INNER JOIN [Person].[BusinessEntityAddress] bea ON bea.[BusinessEntityID] = ss.[BusinessEntityID] AND bea.AddressTypeID = 3
	INNER JOIN Person.Person p ON p.BusinessEntityID = c.PersonID
	INNER JOIN [Person].[Address] a ON a.[AddressID] = bea.[AddressID]
    INNER JOIN [Person].[StateProvince] sp ON sp.[StateProvinceID] = a.[StateProvinceID]
    INNER JOIN [Person].[CountryRegion] cr ON cr.[CountryRegionCode] = sp.[CountryRegionCode]
	INNER JOIN CTE_SalesTotals ON CTE_SalesTotals.CustomerID = c.CustomerID	
	LEFT OUTER JOIN [Person].[EmailAddress] ea ON ea.[BusinessEntityID] = p.[BusinessEntityID];
GO
