SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [pbi].[Product] 
AS 
WITH CTE_ProductSales AS (
	SELECT DISTINCT
		   ProductsSold.ProductID,
		   psc.Name AS [Product SubCategory],
		   SUM(ProductsSold.ProductSales) OVER (PARTITION BY p.ProductSubcategoryID) ProductSubCategorySales,
		   pc.Name AS [Product Category],
		   SUM(ProductsSold.ProductSales) OVER (PARTITION BY pc.ProductCategoryID) ProductCategorySales
	FROM
	(
		SELECT DISTINCT
			   sod.ProductID,
			   SUM(sod.LineTotal) OVER (PARTITION BY sod.ProductID) ProductSales
		FROM Sales.SalesOrderDetail sod
	) ProductsSold
		INNER JOIN Production.Product p ON p.ProductID = ProductsSold.ProductID
		INNER JOIN Production.ProductSubcategory psc ON psc.ProductSubcategoryID = p.ProductSubcategoryID
		INNER JOIN Production.ProductCategory pc ON pc.ProductCategoryID = psc.ProductCategoryID
)

SELECT p.ProductID,
       p.Name [Product],
       p.ProductNumber [Product Number],
       p.Color [Product Color],
       p.StandardCost,
       p.ListPrice,
       p.Size [Product Size],
       CASE p.ProductLine 
		WHEN 'R' THEN 'Road'
		WHEN 'M' THEN 'Mountain' WHEN 'T' THEN 'Touring' WHEN 'S' THEN 'Standard' ELSE 'N/A' END  AS  [Product Line],
       CASE p.Style WHEN 'M' THEN 'Mens' WHEN 'W' THEN 'Womens' WHEN 'U' THEN 'Universal' ELSE 'N/A' END AS [Product Style],
       CTE_ProductSales.[Product SubCategory],
	   RANK() OVER (ORDER BY CTE_ProductSales.ProductSubCategorySales DESC) [Product SubCategorySort],
       CTE_ProductSales.[Product Category],
	   RANK() OVER (ORDER BY CTE_ProductSales.ProductCategorySales DESC) [Product CategorySort],
	   pm.Name [Product Model],
       pp.ThumbNailPhoto,
       pp.LargePhoto
FROM [Production].[Product] p
	INNER JOIN CTE_ProductSales ON CTE_ProductSales.ProductID = p.ProductID
    INNER JOIN Production.ProductModel pm ON pm.ProductModelID = p.ProductModelID
    INNER JOIN [Production].ProductProductPhoto pph ON pph.ProductID = p.ProductID AND pph.[Primary] = 1
    INNER JOIN Production.ProductPhoto pp ON pp.ProductPhotoID = pph.ProductPhotoID;
GO
