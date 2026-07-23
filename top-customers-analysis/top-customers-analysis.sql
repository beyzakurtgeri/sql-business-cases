 /*
 PROJECT: Top Customers Analysis

 OBJECTIVE: 
	Identify the top customers based on total sales using the Northwind database.

 KPIs:
	- Order Count
	- Total Sales
	- Average Order Value
	- Customer Rank
 */

 ----Calculate total orders and total sales for each customer
WITH CustomerSales AS
(SELECT
	   O.CustomerID,
	   C.CompanyName,
	   COUNT(DISTINCT O.OrderID) AS [Order Count],
	   ROUND(SUM(OD.Quantity*OD.UnitPrice*(1-OD.Discount)),2) AS [Total Sales]
FROM [Order Details] OD
JOIN Orders O
ON OD.OrderID = O.OrderID
JOIN Customers C
ON O.CustomerID = C.CustomerID
GROUP BY O.CustomerID, C.CompanyName)

--Calculate rank and average order value for the top customers
SELECT TOP 5
	   DENSE_RANK() OVER(ORDER BY [Total Sales] DESC) AS [RANK],
	   *,
	   ROUND([Total Sales]/[Order Count],2) AS [AVG Order Value]
FROM CustomerSales
ORDER BY [Total Sales] desc
