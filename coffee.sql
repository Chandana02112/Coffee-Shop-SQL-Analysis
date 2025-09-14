-- What are the total sales in month 5?
SELECT 
ROUND(SUM(unit_price * transaction_qty)) as Total_Sales 
FROM coffee_shop_sales 
WHERE MONTH(transaction_date) = 5;

-- How many orders received in the month 5?
SELECT 
COUNT(transaction-id) AS total_orders
FROM coffee_shop_sales
WHERE MONTH(transaction-date) = 5;

-- How much quantity sold in month 5?
SELECT SUM(transaction-qty) AS total_qty_sold
FROM coffee_shop_sales
WHERE MONTH(transaction-date) = 5;

-- TOTAL SALES KPI - MOM DIFFERENCE AND MOM GROWTH
WITH monthly_sales AS (
 SELECT 
  MONTH(transaction_date) AS Month,
        ROUND(SUM(unit_price * transaction_qty)) AS Total_sales
    FROM coffee_shop_sales
    WHERE MONTH(transaction_date) IN (4,5)
    GROUP BY MONTH(transaction_date)
)
SELECT Month,
    Total_sales, 
    ROUND(
        (Total_sales - LAG(Total_sales) OVER (ORDER BY Month)) 
        / LAG(Total_sales) OVER (ORDER BY Month) * 100, 2
    ) AS Increase_Decrease_Percentage
FROM monthly_sales 
ORDER BY Month;

-- TOTAL ORDERS KPI - MOM DIFFERENCE AND MOM GROWTH

with order_analysis as (
select
month(transaction_date) as month,
round(count(transaction_id)) as total_orders
from coffee_shop_sales
where month(transaction_date) in (1,6)
group by month(transaction_date)
)
select
month,
total_orders,
round(
(total_orders - lag(total_orders) over (order by month))
/ Nullif(lag(total_orders) over (order by month),0) *100, 2) as increase_decrease_percentage
from
order_analysis
order by month;

-- TOTAL QUANTITY SOLD KPI - MOM DIFFERENCE AND MOM GROWTH
with quantity_sold as (
select
month(transaction_date) as month,
round(sum(transaction_qty)) as total_quantity_sold
from coffee_shop_sales
where month(transaction_date) in (1,6)
group by month(transaction_date)
)
select
month,
total_quantity_sold,
round(
(total_quantity_sold - lag(total_quantity_sold) over (order by month))
/ Nullif(lag(total_quantity_sold) over (order by month),0) * 100, 2) as increase_decrease_percentage
from
quantity_sold
order by month;

-- Daily sales, orders, quantity for specific date

Select
date (transaction_date) as day,
sum(unit_price*transaction_qty) as Total_sales,
count(transaction_id) as Total_orders,
sum(transaction_qty) as Total_quantity_sold
from coffee_shop_sales
where date(transaction_date) = '2023-02-01'
group by day;

-- If you want to get exact Rounded off values then use
SELECT 
    CONCAT(ROUND(SUM(unit_price * transaction_qty) / 1000, 1),'K') AS total_sales,
    CONCAT(ROUND(COUNT(transaction_id) / 1000, 1),'K') AS total_orders,
    CONCAT(ROUND(SUM(transaction_qty) / 1000, 1),'K') AS total_quantity_sold
FROM 
    coffee_shop_sales
WHERE 
    transaction_date = '2023-05-18';

-- SALES TREND OVER PERIOD
-- Average of total sales for the month 4,5
with avg_sales as (
select
month(transaction_date) as month,
concat(round(sum(unit_price*transaction_qty)/1000,1),'k') as sales
from coffee_shop_sales
where month(transaction_date) in (4,5)
group by month(transaction_date)
)
select
month,
sales,
avg(sales) over() as average_sales
from avg_sales;

-- DAILY SALES FOR MONTH SELECTED
SELECT 
    DAY(transaction_date) AS day_of_month,
    ROUND(SUM(unit_price * transaction_qty),1) AS total_sales
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 5
GROUP BY 
    DAY(transaction_date)
ORDER BY 
    DAY(transaction_date);

-- COMPARING DAILY SALES WITH AVERAGE SALES – IF GREATER THAN “ABOVE AVERAGE” and LESSER THAN “BELOW AVERAGE”
SELECT
  day_of_month,
  total_sales,
  CASE
    WHEN total_sales > avg_sales THEN 'above average'
    WHEN total_sales < avg_sales THEN 'below average'
    ELSE 'average'
  END AS average_status
FROM (
  SELECT
    DAY(transaction_date) AS day_of_month,
    SUM(unit_price * transaction_qty) AS total_sales,
    AVG(SUM(unit_price * transaction_qty)) OVER () AS avg_sales
  FROM coffee_shop_sales
  WHERE MONTH(transaction_date) = 5
  GROUP BY DAY(transaction_date)
) AS sales_data
ORDER BY day_of_month;

-- SALES BY WEEKDAY / WEEKEND:
SELECT 
    CASE 
        WHEN DAYOFWEEK(transaction_date) IN (1, 7) THEN 'Weekends'
        ELSE 'Weekdays'
    END AS day_type,
    ROUND(SUM(unit_price * transaction_qty),2) AS total_sales
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 5  -- Filter for May
GROUP BY 
    CASE 
        WHEN DAYOFWEEK(transaction_date) IN (1, 7) THEN 'Weekends'
        ELSE 'Weekdays'
    END;

-- SALES BY STORE LOCATION
select
store_location,
sum(transaction_qty * unit_price) as total_sales
from coffee_shop_sales
where month(transaction_date) = 1
group by store_location
order by sum(transaction_qty * unit_price) desc;

-- SALES BY PRODUCT CATEGORY
SELECT 
	product_category,
	ROUND(SUM(unit_price * transaction_qty),1) as Total_Sales
FROM coffee_shop_sales
WHERE
	MONTH(transaction_date) = 5 
GROUP BY product_category
ORDER BY SUM(unit_price * transaction_qty) DESC;


-- SALES BY PRODUCTS (TOP 10)
SELECT 
	product_type,
	ROUND(SUM(unit_price * transaction_qty),1) as Total_Sales
FROM coffee_shop_sales
WHERE
	MONTH(transaction_date) = 5 
GROUP BY product_type
ORDER BY SUM(unit_price * transaction_qty) DESC
LIMIT 10;


-- SALES BY DAY | HOUR
SELECT 
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales,
    SUM(transaction_qty) AS Total_Quantity,
    COUNT(*) AS Total_Orders
FROM 
    coffee_shop_sales
WHERE 
    DAYOFWEEK(transaction_date) = 3 -- Filter for Tuesday (1 is Sunday, 2 is Monday, ..., 7 is Saturday)
    AND HOUR(transaction_time) = 8 -- Filter for hour number 8
    AND MONTH(transaction_date) = 5; -- Filter for May (month number 5)


-- TO GET SALES FROM MONDAY TO SUNDAY FOR MONTH OF MAY
SELECT 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
ELSE 'Sunday'
    END AS Day_of_Week,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END;


-- TO GET SALES FOR ALL HOURS FOR MONTH OF MAY
SELECT 
    HOUR(transaction_time) AS Hour_of_Day,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY 
    HOUR(transaction_time)
ORDER BY 
    HOUR(transaction_time);








