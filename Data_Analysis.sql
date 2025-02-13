-- This SQL script aims to reproduce all of the analysis in the "Dashboard.twb" and "Charts_for_Report.twb" files.


-- Dashboard.twb

-- Time Series revenue
SELECT DATE_FORMAT(s.`Order Date`, '%Y-%m') AS time_period, ROUND(SUM(s.Quantity*p.`Unit Price USD`), 0) AS sales
FROM cleaned_sales s
INNER JOIN cleaned_products p
USING(ProductKey)
GROUP BY time_period
ORDER BY time_period;

-- Time series gross profit
SELECT DATE_FORMAT(s.`Order Date`, '%Y-%m') AS time_period, ROUND(SUM(s.Quantity*(p.`Unit Price USD` - p.`Unit COST USD`)), 0) AS profit
FROM cleaned_sales s
INNER JOIN cleaned_products p
USING(ProductKey)
GROUP BY time_period
ORDER BY time_period;

-- Time series order volume
SELECT DATE_FORMAT(s.`Order Date`, '%Y-%m') AS time_period, COUNT(DISTINCT `Order Number`) AS order_volume
FROM cleaned_sales s
INNER JOIN cleaned_products p
USING(ProductKey)
GROUP BY time_period
ORDER BY time_period;

-- Time Series revenue by category and country
SELECT category, country, DATE_FORMAT(s.`Order Date`, '%Y-%m') AS time_period, ROUND(SUM(s.Quantity*p.`Unit Price USD`), 0) AS sales
FROM cleaned_sales s
INNER JOIN cleaned_products p
USING(ProductKey)
INNER JOIN cleaned_customers c
USING(CustomerKey)
GROUP BY category, country, time_period
ORDER BY category, country, time_period;

-- Time Series gross profit by category and country
SELECT category, country, DATE_FORMAT(s.`Order Date`, '%Y-%m') AS time_period, ROUND(SUM(s.Quantity*(p.`Unit Price USD` - p.`Unit COST USD`)), 0) AS profit
FROM cleaned_sales s
LEFT JOIN cleaned_products p
USING(ProductKey)
LEFT JOIN cleaned_customers c
USING(CustomerKey)
GROUP BY category, country, time_period
ORDER BY category, country, time_period;

-- Time Series Order Volume by category and country
SELECT category, country, DATE_FORMAT(s.`Order Date`, '%Y-%m') AS time_period, COUNT(DISTINCT s.`Order Number`) as order_volume
FROM cleaned_sales s
LEFT JOIN cleaned_products p
USING(ProductKey)
LEFT JOIN cleaned_customers c
USING(CustomerKey)
GROUP BY category, country, time_period
ORDER BY category, country, time_period;

-- Revenue by category
SELECT YEAR(`Order Date`) AS time_period, p.Category, ROUND(SUM(s.Quantity*p.`Unit Price USD`), 0) AS sales
FROM cleaned_sales s
LEFT JOIN cleaned_products p
USING(ProductKey)
GROUP BY time_period, p.Category
ORDER BY time_period, sales DESC;

-- Profit by category
SELECT YEAR(`Order Date`) AS time_period, p.Category, ROUND(SUM(s.Quantity*(p.`Unit Price USD` - p.`Unit COST USD`)), 0) AS profit
FROM cleaned_sales s
LEFT JOIN cleaned_products p
USING(ProductKey)
GROUP BY time_period, p.Category
ORDER BY time_period, profit DESC;

-- Order volume by category
SELECT YEAR(`Order Date`) AS time_period, p.Category, COUNT(DISTINCT `Order Number`) AS order_volume
FROM cleaned_sales s
LEFT JOIN cleaned_products p
USING(ProductKey)
GROUP BY time_period, p.Category
ORDER BY time_period, order_volume DESC;

-- Revenue By brand
SELECT YEAR(`ORDER DATE`) AS time_period, p.Brand, ROUND(SUM(s.Quantity*p.`Unit Price USD`), 0) AS sales
FROM cleaned_sales s
LEFT JOIN cleaned_products p
USING(ProductKey)
GROUP BY time_period, p.Brand
ORDER BY time_period, sales DESC;

-- Gross profit by brand
SELECT YEAR(`ORDER DATE`) AS time_period, p.Brand, ROUND(SUM(s.Quantity*(p.`Unit Price USD` - p.`Unit COST USD`)), 0) AS profit
FROM cleaned_sales s
LEFT JOIN cleaned_products p
USING(ProductKey)
GROUP BY time_period, p.Brand
ORDER BY time_period, profit DESC;

-- Order Volumes by brand
SELECT YEAR(s.`ORDER DATE`) AS time_period, p.Brand, COUNT(DISTINCT s.`Order Number`) as order_volume
FROM cleaned_sales s
LEFT JOIN cleaned_products p
USING(ProductKey)
GROUP BY time_period, p.Brand
ORDER BY time_period, order_volume DESC;

-- Revenue per square meter
SELECT YEAR(`ORDER DATE`) AS time_period, StoreKey, ROUND(SUM(s.Quantity*p.`Unit Price USD`/`Square Meters`), 0) AS Sales_per_sqmt
FROM cleaned_sales s 
INNER JOIN cleaned_products p
USING(ProductKey)
INNER JOIN cleaned_stores st
USING(StoreKey)
GROUP BY time_period, StoreKey
ORDER BY time_period, CAST(StoreKey AS DECIMAL);

-- Sales growth rate
WITH CTE AS(
	SELECT `Order Date`, Quantity, `Unit Price USD`
    FROM cleaned_sales
    INNER JOIN cleaned_products
    USING(ProductKey)
),
Sales_2020_2019 AS (
	SELECT 
		(SELECT ROUND(SUM(Quantity*`Unit Price USD`), 0) FROM CTE WHERE YEAR(`ORDER DATE`)=2019) AS Sales_2019,
        (SELECT ROUND(SUM(Quantity*`Unit Price USD`), 0) FROM CTE WHERE YEAR(`ORDER DATE`)=2020) AS Sales_2020
	FROM CTE
)
SELECT DISTINCT Sales_2019, Sales_2020, ROUND((Sales_2020-Sales_2019)*100/Sales_2019, 1) AS Growth_Rate
FROM Sales_2020_2019;

-- Profit growth rate
WITH CTE AS(
	SELECT `Order Date`, Quantity, `Unit Price USD`, `Unit Cost USD`
    FROM cleaned_sales
    INNER JOIN cleaned_products
    USING(ProductKey)
),
Profit_2020_2019 AS (
	SELECT 
		(SELECT ROUND(SUM(Quantity*(`Unit Price USD`-`Unit Cost USD`)), 0) FROM CTE WHERE YEAR(`ORDER DATE`)=2019) AS Profit_2019,
        (SELECT ROUND(SUM(Quantity*(`Unit Price USD`-`Unit Cost USD`)), 0) FROM CTE WHERE YEAR(`ORDER DATE`)=2020) AS Profit_2020
	FROM CTE
)
SELECT DISTINCT Profit_2019, Profit_2020, ROUND((Profit_2020-Profit_2019)*100/Profit_2019, 1) AS Growth_Rate
FROM Profit_2020_2019;

-- order volume growth rate
With CTE AS (
	SELECT 
		(SELECT COUNT(DISTINCT `Order Number`) FROM cleaned_sales WHERE YEAR(`ORDER DATE`)=2019) AS Total_orders_2019,
        (SELECT COUNT(DISTINCT `Order Number`) FROM cleaned_sales WHERE YEAR(`ORDER DATE`)=2020) AS Total_orders_2020
)
SELECT DISTINCT Total_orders_2019, Total_orders_2020, (Total_orders_2020-Total_orders_2019)*100/Total_orders_2019 AS Growth_Rate
FROM CTE;


-- Charts_for_Report.twb

-- Share of online sales in total sales over time
SELECT YEAR(`ORDER DATE`) AS time_period, ROUND(COUNT(`Delivery Date`)*100/(SELECT COUNT(*) FROM cleaned_sales WHERE YEAR(`ORDER DATE`) = time_period),2) AS online_sales_share
FROM cleaned_sales
GROUP BY time_period;

-- Delivery days over time
SELECT YEAR(`ORDER DATE`) AS time_period, AVG(DATEDIFF(`Delivery Date`, `Order Date`)) AS AVG_Delivery_Days
FROM cleaned_sales s
GROUP BY time_period
ORDER BY time_period;

-- Median of revenue generated by stores
WITH CTE AS (
	SELECT StoreKey, ROUND(SUM(`Unit Price USD`*Quantity),0) AS sales, RANK() OVER(ORDER BY ROUND(SUM(`Unit Price USD`*Quantity), 0)) AS ranking
	FROM cleaned_sales
	INNER JOIN cleaned_products
	USING(ProductKey)
	WHERE YEAR(`ORDER DATE`)=2020 AND StoreKey <> 0
	GROUP BY StoreKey
)

SELECT CASE 
	WHEN COUNT(*)%2 = 0 THEN (SELECT AVG(Sales) FROM CTE WHERE ranking IN((SELECT COUNT(*)/2 FROM CTE), (SELECT COUNT(*)/2 + 1 FROM CTE)))
    ELSE (SELECT AVG(Sales) FROM CTE WHERE ranking = (SELECT ROUND(COUNT(*)/2, 0) FROM CTE)) END AS median
FROM CTE;




























UPDATE Customers
SET Customers.Birthday = STR_TO_DATE(Customers.Birthday, '%m/%d/%Y');

UPDATE Exchange_Rates
SET Exchange_Rates.Date = STR_TO_DATE(Exchange_Rates.Date, '%m/%d/%Y');

UPDATE Sales
SET Sales.`Order Date` = STR_TO_DATE(Sales.`Order Date`, '%m/%d/%Y');

UPDATE Sales
SET Sales.`Delivery Date` = STR_TO_DATE(Sales.`Delivery Date`, '%m/%d/%Y');

UPDATE Sales
SET StoreKey = NULL
WHERE StoreKey = 0;

UPDATE Products
SET Products.`Unit Price USD` = CAST(REPLACE(Products.`Unit Price USD`, '$', '') AS DECIMAL(65, 2));

UPDATE Products
SET Products.`Unit Cost USD` = CAST(REPLACE(Products.`Unit Cost USD`, '$', '') AS DECIMAL(65, 2));


select distinct subcategory, category from products;
