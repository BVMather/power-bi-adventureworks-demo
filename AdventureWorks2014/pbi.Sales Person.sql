SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [pbi].[Sales Person] 
AS 
SELECT e.[BusinessEntityID],
       p.[FirstName],
       p.[LastName],
       e.[JobTitle],
       d.[Name] AS [Department],
       d.[GroupName],
       edh.[StartDate],
       s.CommissionPct,
	   st.Name AS SalesTerritoyName,
	   st.[Group] AS SalesTerritoryGroup,
	   pcr.Name [SalesTerritoryCountry]
FROM [Sales].[SalesPerson] s
    INNER JOIN [HumanResources].[Employee] e
        ON e.BusinessEntityID = s.BusinessEntityID
    INNER JOIN [Person].[Person] p
        ON p.[BusinessEntityID] = e.[BusinessEntityID]
    INNER JOIN [HumanResources].[EmployeeDepartmentHistory] edh
        ON e.[BusinessEntityID] = edh.[BusinessEntityID]
    INNER JOIN [HumanResources].[Department] d
        ON edh.[DepartmentID] = d.[DepartmentID]
		LEFT OUTER JOIN [Sales].[SalesTerritory] st
        ON st.[TerritoryID] = s.[TerritoryID]
		LEFT JOIN Person.CountryRegion pcr ON pcr.CountryRegionCode = st.CountryRegionCode
WHERE edh.EndDate IS NULL;
GO
