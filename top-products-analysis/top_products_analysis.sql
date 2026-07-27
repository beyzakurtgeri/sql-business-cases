/*
PROJECT: Top Products Analysis

BUSINESS PROBLEM: The sales manager wants to identify the best-selling products based on total sales.

OBJECTIVE: Analyze product sales performance and identify the top-selling products.

KPIs:
- Product ID
- Product Name
- Category
- Unit Price
- Total Sales
- Order Count
- Unit Sold Quantity
- Average Sales per Order
- Product Rank
*/

WITH ProductSales AS
(SELECT
	   P.CategoryID,
	   C.CategoryName,
	   P.ProductID,
	   P.ProductName,
	   ROUND(AVG(OD.UnitPrice),2) AS [Unit Price],
	   SUM(OD.Quantity) AS [Unit Sold Quantity],
	   COUNT(DISTINCT OD.OrderID) AS [Order Count],
	   ROUND(SUM(OD.Quantity * OD.UnitPrice * (1-OD.Discount)),2) AS [Total Sales]
FROM [Order Details] OD
JOIN Products P
ON OD.ProductID = P.ProductID
JOIN Categories C
ON P.CategoryID = C.CategoryID
GROUP BY 
		P.ProductID,
		P.ProductName,
		P.CategoryID,
		C.CategoryName)

SELECT TOP 5
	   DENSE_RANK() OVER(ORDER BY [Total Sales] DESC) AS [Product Rank],
	   *,
	   ROUND([Total Sales]/[Order Count],2) AS [Avg. Sales per Order]   
FROM ProductSales
ORDER BY [Total Sales] DESC
