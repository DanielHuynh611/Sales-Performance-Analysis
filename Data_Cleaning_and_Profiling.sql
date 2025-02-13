-- This SQL script aims to perform data profiling on the five tables involved in the analysis, and clean the data if any error is detected.





-- The "sales" table

-- Question 1: Is there any duplicate in the composite primary key "Order Number"-"Line Item"? (i.e. ENTITY INTEGRITY assurance)
SELECT COUNT(*) - COUNT(DISTINCT `Order Number`, `Line Item`) AS duplicates
FROM sales;

-- Question 2: Checking REFERENTIAL INTEGRITY: Is there any ORPHANED RECORDS (i.e. a record whose foreign key value references a non-existent primary key value) in our table?

-- Checking referential integrity fo the "StoreKey" foreign key
SELECT COUNT(*) AS orphaned_records
FROM sales s1
LEFT JOIN stores AS s2
USING(StoreKey)
WHERE s2.StoreKey IS NULL;

-- There are 13165 orphaned records in the dataset, we will investigate them further by printing out those records
SELECT DISTINCT s1.StoreKey AS foreign_key, s2.StoreKey AS primary_key
FROM sales s1
LEFT JOIN stores AS s2
USING(StoreKey)
WHERE s2.StoreKey IS NULL;
-- Finding: the value "0" in the StoreKey column of the sales table cannot match with any record in the stores table.alter

-- Data Cleaning: We assume that the value "0" in the StoreKey column of the sales table(the foreign key) is supposed to be NULL (we will later proved that is is likely to be true)
-- 				  We also would like to convert the column `Delivery Date` and `Order Date`
CREATE VIEW cleaned_sales AS
SELECT 
	`Order Number`, 
	`Line Item`, 
	STR_TO_DATE(`Order Date`, "%m/%d/%Y") AS "Order Date",
	STR_TO_DATE(`Delivery Date`, "%m/%d/%Y") AS "Delivery Date",
	CustomerKey,
    CASE
		WHEN StoreKey = 0 THEN NULL 
        ELSE StoreKey
        END AS StoreKey,
	ProductKey,
    Quantity,
    `Currency Code`
FROM sales;

-- We also notice that all records in which the "Delivery Date" column has data, the data for the "StoreKey" will be missing (previously has the value "0), 
-- this implies that those records are online sales, thus replacing the value "0" with null for StoreKey is valid.
-- This query verify our previous claim: all records in which the "Delivery Date" column has data, the data for the "StoreKey" will be missing
SELECT COUNT(*)
FROM cleaned_sales
WHERE `Delivery Date` IS NOT NULL AND StoreKey IS NOT NULL;

-- Checking referential integrity for the "CustomerKey" foreign key
SELECT COUNT(*) AS orphaned_records
FROM cleaned_sales s
LEFT JOIN cleaned_customers AS c
USING(CustomerKey)
WHERE c.CustomerKey IS NULL;
-- Finding: no violation detected

-- Checking referential integrity for the ProductKey
SELECT COUNT(*) AS orphaned_records
FROM cleaned_sales s
LEFT JOIN cleaned_products p
USING(ProductKey)
WHERE p.ProductKey IS NULL;
-- Finding: no violation detected

-- Checking referential integrity for the "Currency Code" foreign key
SELECT COUNT(*) AS orphaned_records
FROM cleaned_sales s
LEFT JOIN exchange_rates e
ON s.`Currency Code` = e.Currency AND s.`Order Date` = STR_TO_DATE(e.Date, "%m/%d/%Y")
WHERE e.Currency IS NULL;

SELECT *
FROM sales s
LEFT JOIN exchange_rates e
ON s.`Currency Code` = e.Currency AND s.`Order Date` = STR_TO_DATE(e.Date, "%m/%d/%Y");

-- Question 3: Is there any missing value in the table?
SELECT
	SUM(CASE WHEN `Order Number` IS NULL THEN 1 ELSE 0 END) AS order_number_nulls,
    SUM(CASE WHEN `Line Item` IS NULL THEN 1 ELSE 0 END) AS line_item_nulls,
    SUM(CASE WHEN `Order Date` IS NULL THEN 1 ELSE 0 END) AS order_date_nulls,
    SUM(CASE WHEN `Delivery Date` IS NULL THEN 1 ELSE 0 END) AS delivery_date_nulls,
    SUM(CASE WHEN CustomerKey IS NULL THEN 1 ELSE 0 END) AS customer_key_nulls,
    SUM(CASE WHEN StoreKey IS NULL THEN 1 ELSE 0 END) AS store_key_nulls,
    SUM(CASE WHEN ProductKey IS NULL THEN 1 ELSE 0 END) AS product_key_nulls,
    SUM(CASE WHEN Quantity IS NULL THEN 1 ELSE 0 END) AS quantity_nulls,
    SUM(CASE WHEN `Currency Code` IS NULL THEN 1 ELSE 0 END) AS currency_code_nulls
FROM cleaned_sales;

-- Question 4: MIN and MAX of the "Quantity" column
SELECT MIN(Quantity) AS min_quantity, MAX(Quantity) AS max_quantity
FROM sales;





-- The 'products' table

-- Question 1: How many products do we have?
SELECT COUNT(DISTINCT ProductKey) AS num_products
FROM products;

-- Question 2: ENTITY INTEGRITY assurance: Is there any duplicate in the primary key 'ProductKey'?
SELECT COUNT(*) - COUNT(DISTINCT ProductKey) AS dupllicates
FROM products;

-- Question 3: Is there any missing value in this table?
SELECT
	SUM(CASE WHEN ProductKey IS NULL THEN 1 ELSE 0 END) AS productkey_nulls,
    SUM(CASE WHEN `Product Name` IS NULL THEN 1 ELSE 0 END) AS productname_nulls,
    SUM(CASE WHEN `Brand` IS NULL THEN 1 ELSE 0 END) AS brand_nulls,
    SUM(CASE WHEN Color IS NULL THEN 1 ELSE 0 END) AS color_nulls,
    SUM(CASE WHEN `Unit Price USD` IS NULL THEN 1 ELSE 0 END) AS unit_price_usd_nulls,
    SUM(CASE WHEN SubcategoryKey IS NULL THEN 1 ELSE 0 END) AS subcategory_nulls,
	SUM(CASE WHEN Subcategory IS NULL THEN 1 ELSE 0 END) AS subcategorykey_nulls,
    SUM(CASE WHEN `Unit Cost USD` IS NULL THEN 1 ELSE 0 END) AS unit_cost_usd_nulls,
    SUM(CASE WHEN CategoryKey IS NULL THEN 1 ELSE 0 END) AS categorykey_nulls,
    SUM(CASE WHEN Category IS NULL THEN 1 ELSE 0 END) AS category_nulls
FROM products;

-- Question 4: What are the distinct brands?
SELECT DISTINCT Brand
FROM products;

-- Data Cleaning: The "Unit Price USD" and "Unit Cost USD" columns have a leading "$" sign and are read as text rather than numeric, we will remove the "$" sign and 
-- then convert the data type of the column to numeric. We also want to remove the comma in the number.
CREATE VIEW cleaned_products AS
SELECT  ProductKey, `Product Name`, Brand, Color,
		CAST(REPLACE(REPLACE(`Unit Cost USD`, "$", ""), ",", "") AS DOUBLE) AS "Unit Cost USD",
        CAST(REPLACE(REPLACE(`Unit Price USD`, "$", ""), ",", "") AS DOUBLE) AS "Unit Price USD",
        SubcategoryKey, Subcategory, CategoryKey, Category
FROM products;
        
-- Question 5: What are the distinct pair of Category: Subcategory?
SELECT DISTINCT Category, Subcategory
FROM cleaned_products
ORDER BY Category;

-- Question 6: The distribution of "Unit Cost USD", "Unit Price USD", Profit Margin(ie. "Unit Cost USD", "Unit Price USD")

-- Unit Cost USD
SELECT 
	TRUNCATE(`Unit Cost USD`, -2) AS lower_limit,
    TRUNCATE(`Unit Cost USD`, -2) + 100 AS upper_limit,
    COUNT(*) AS product_counts
FROM cleaned_products
GROUP BY 1, 2
ORDER BY 1;

-- Unit Price USD
SELECT 
	TRUNCATE(`Unit Price USD`, -2) AS lower_limit,
    TRUNCATE(`Unit Price USD`, -2) + 100 AS upper_limit,
    COUNT(*) AS product_counts
FROM cleaned_products
GROUP BY 1, 2
ORDER BY 1;

-- Marginal Profit
SELECT 
	TRUNCATE((`Unit Price USD`-`Unit Cost USD`), -2) AS lower_limit,
    TRUNCATE((`Unit Price USD`-`Unit Cost USD`), -2) + 100 AS upper_limit,
    COUNT(*) AS product_counts
FROM cleaned_products
GROUP BY 1, 2
ORDER BY 1;





-- The 'customers' table

-- Question 1: How many customers do we have?
SELECT COUNT(DISTINCT CustomerKey) AS total_customers
FROM customers;

-- Question 2: ENTITY INTEGRITY assurance: Is there any duplicate in the primary key 'CustomerKey'?
SELECT COUNT(*) - COUNT(DISTINCT CustomerKey) AS duplicates
FROM customers;

-- Question 3: Is there any missing values in the table?
SELECT
	SUM(CASE WHEN CustomerKey IS NULL THEN 1 ELSE 0 END) AS customerkey_nulls,
    SUM(CASE WHEN Gender IS NULL THEN 1 ELSE 0 END) AS gender_nulls,
    SUM(CASE WHEN Name IS NULL THEN 1 ELSE 0 END) AS name_nulls,
    SUM(CASE WHEN City IS NULL THEN 1 ELSE 0 END) AS city_nulls,
    SUM(CASE WHEN `State Code` IS NULL THEN 1 ELSE 0 END) AS state_code_nulls,
    SUM(CASE WHEN State IS NULL THEN 1 ELSE 0 END) AS state_nulls,
    SUM(CASE WHEN `Zip code` IS NULL THEN 1 ELSE 0 END) AS zip_code_nulls,
    SUM(CASE WHEN `Country` IS NULL THEN 1 ELSE 0 END) AS country_nulls,
    SUM(CASE WHEN `Continent` IS NULL THEN 1 ELSE 0 END) AS continent_nulls,
    SUM(CASE WHEN `Birthday` IS NULL THEN 1 ELSE 0 END) AS birthday_nulls
FROM customers;

-- Question 4: What is the proportion of each gender?
SELECT Gender, ROUND(COUNT(Gender)*100/(SELECT COUNT(*) FROM customers), 1) AS proportion
FROM customers
GROUP BY Gender;

-- Question 5: The list of Country-State in which customers live
SELECT DISTINCT Country, State 
FROM customers;

-- Data Cleaning: The 'Birthday' column is represented as text, this query generates a dataset with a cleaned 'Birthday' column.
CREATE VIEW cleaned_customers AS
SELECT CustomerKey, Gender, Name, City, `State Code`, State, `Zip Code`, Country, Continent, STR_TO_DATE(Birthday, '%m/%d/%Y') AS Birthday
FROM customers;

-- Question 6: What is the distribution of customer age?
SELECT  TRUNCATE(DATEDIFF('2021-01-01', Birthday)/365.25, -1) AS lower_limit,
		TRUNCATE(DATEDIFF('2021-01-01', Birthday)/365.25, -1) + 10 AS upper_limit,
        COUNT(*) AS customers_count
FROM cleaned_customers
GROUP BY lower_limit, upper_limit;






-- The "stores" table

-- Data Cleaning: The "Open Date" column is represented as text instead of date, we want to change its data type and format
CREATE VIEW cleaned_stores AS
SELECT StoreKey, Country, State, `Square Meters`, STR_TO_DATE(`Open date`, '%m/%d/%Y') AS "Open Date"
FROM stores;

-- Question 1: What are the number of stores in this database?
SELECT COUNT(DISTINCT StoreKey) AS store_counts
FROM cleaned_stores;

-- QUESTION 2:  ENTITY INTEGRITY assurance: Is there any duplication in the primary key "StoreKey"?
SELECT COUNT(*) - COUNT(DISTINCT StoreKey) AS duplicates
FROM cleaned_stores;

-- Question 3: Is there any missing value in this dataset?
SELECT
	SUM(CASE WHEN StoreKey IS NULL THEN 1 ELSE 0 END) AS storekey_nulls,
    SUM(CASE WHEN Country IS NULL THEN 1 ELSE 0 END) AS country_nulls,
    SUM(CASE WHEN State IS NULL THEN 1 ELSE 0 END) AS state_nulls,
    SUM(CASE WHEN `Square Meters` IS NULL THEN 1 ELSE 0 END) AS square_meters_nulls,
    SUM(CASE WHEN `Open Date` IS NULL THEN 1 ELSE 0 END) AS open_date_nulls
FROM cleaned_stores;
    
-- Question 4: What is the range of "Square Meters"?
SELECT MIN(`Square Meters`) AS min_sq_meters, MAX(`Square Meters`) AS max_sq_meters
FROM cleaned_stores;

-- Question 5: What is the distribution of "Square Meters"?
SELECT
    CASE 
		WHEN `Square Meters` BETWEEN 1 AND 500 THEN 1
        WHEN `Square Meters` BETWEEN 501 AND 1000 THEN 2
        WHEN `Square Meters` BETWEEN 1001 AND 1500 THEN 3
		WHEN `Square Meters` BETWEEN 1501 AND 2000 THEN 4
        ELSE 5
	END AS "Group Index",
	CASE 
		WHEN `Square Meters` BETWEEN 1 AND 500 THEN "1-500"
        WHEN `Square Meters` BETWEEN 501 AND 1000 THEN "501-1000"
        WHEN `Square Meters` BETWEEN 1001 AND 1500 THEN "1001-1500"
		WHEN `Square Meters` BETWEEN 1501 AND 2000 THEN "1501-2200"
        ELSE ">2000" 
	END AS "Group",
    COUNT(*) AS store_counts
FROM cleaned_stores
GROUP BY 1, 2
ORDER BY 1;






-- The "exchange_rates" table

-- Question 1: Is there any duplicate in the composite primary key "Currency"-"Date"? (i.e. ENTITY INTEGRITY assurance)
SELECT COUNT(*) - COUNT(DISTINCT Currency, Date) AS duplicates
FROM exchange_rates;

-- Data Cleaning: we will convert the text column "Date" to date format
CREATE VIEW cleaned_exchange_rates AS
SELECT STR_TO_DATE(Date, "%m/%d/%Y") AS DATE, Currency, Exchange
FROM exchange_rates;

