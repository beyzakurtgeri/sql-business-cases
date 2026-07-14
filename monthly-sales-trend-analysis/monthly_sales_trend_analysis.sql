 /*
 PROJECT: Monthly Sales Trend Analysis

 OBJECTIVE: 
	Analyze monthly sales performance for the last 12 complete months available in the Northwind dataset.

 KPIs:
	- Order Count
	- Sales Amount
	- Month-over-Month Order Change (%)
	- Month-over-Month Sales Change (%)
 */

--Calculate monthly order count and sales amount
 WITH MonthlySales AS
 (SELECT 
		YEAR(O.OrderDate) AS [ORDER YEAR],
		MONTH(O.OrderDate) AS [ORDER MONTH],
		DATENAME(MONTH, O.OrderDate) AS [MONTH NAME],
		COUNT(DISTINCT O.OrderID) AS [Order Count],
		ROUND(SUM(OD.Quantity*OD.UnitPrice*(1-OD.Discount)),2) as [Sales Amount]
 fROM Orders O
 JOIN [Order Details] OD
 on O.OrderID = OD.OrderID
 WHERE O.OrderDate >= DATEFROMPARTS(1997,5,1)
  AND O.OrderDate < DATEFROMPARTS(1998,5,1)
 GROUP BY YEAR(O.OrderDate), MONTH(O.OrderDate), DATENAME(MONTH, O.OrderDate)),

--Get previous month's values using LAG()
 SalesTrend AS
 (SELECT *,
		lag ([Order Count]) over(order by [ORDER YEAR], [ORDER MONTH]) as [Previous Order Count],
		lag([Sales Amount]) over (order by [ORDER YEAR], [ORDER MONTH]) as [Previous Sales Amount]
	FROM MonthlySales),

--Calculate monthly differences and trends
MonthlyAnalysis AS
 (SELECT *,
		[Order Count]-[Previous Order Count] as [Order Difference],
		round([Sales Amount]-[Previous Sales Amount],2) as [Sales Difference],
		round(100.0 * ([Order Count]-[Previous Order Count])/NULLIF([Previous Order Count],0),2) as [% Order Change],
		round(100.0 * ([Sales Amount]-[Previous Sales Amount])/NULLIF([Previous Sales Amount],0),2) as [% Sales Change],

		CASE
			WHEN [Previous Order Count] IS NULL THEN NULL
			WHEN ([Order Count]-[Previous Order Count]) > 0 THEN 'INCREASED'
			WHEN ([Order Count]-[Previous Order Count])< 0 THEN 'DECREASED'
			ELSE 'NO CHANGE'
		END AS [ORDER TREND],

		CASE
			WHEN [Previous Sales Amount] IS NULL THEN NULL
			WHEN([Sales Amount]-[Previous Sales Amount]) > 0 THEN 'INCREASED'
			WHEN ([Sales Amount]-[Previous Sales Amount]) < 0 THEN 'DECREASED'
			ELSE 'NO CHANGE'
		END AS [SALES TREND]
FROM SalesTrend)

SELECT 

		--Date Information
		[ORDER YEAR],
		[ORDER MONTH],
		[MONTH NAME],
   

		--Order Analysis
		[Order Count],
		[Previous Order Count],
		[Order Difference],
		[% Order Change],
		[ORDER TREND],


		--Sales Analysis
		[Sales Amount],
		[Previous Sales Amount],
		[Sales Difference],
		[% Sales Change],
		[SALES TREND]
FROM MonthlyAnalysis
ORDER BY [ORDER YEAR], [ORDER MONTH]
