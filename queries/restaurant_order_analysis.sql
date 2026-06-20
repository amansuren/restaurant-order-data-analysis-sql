-------------------------------------------------
-- Objective 1
-- EXPLORE MENU ITEMS
--------------------------------------------------
-- Overview of menu structure
SELECT * FROM menu_items;

--  Numbers of items on the menu
SELECT COUNT(*) as No_of_items FROM menu_items;

-- 2. What are the least and most expensive items on the menu?
SELECT *
FROM menu_items
WHERE price IN (
    SELECT MIN(price) FROM menu_items
    UNION
    SELECT MAX(price) FROM menu_items
);

-- How many Italian dishes are on the menu? 

SELECT COUNT(*) AS 'Number of Italian Dishes'
FROM menu_items
WHERE category = 'Italian';

-- What are the least and most expensive Italian dishes on the menu?
SELECT *
FROM menu_items
WHERE category = 'Italian'
ORDER BY price
LIMIT 1;

SELECT *
FROM menu_items
WHERE category = 'Italian'
ORDER BY price DESC
LIMIT 1;

-- How many dishes are in each category? 
-- What is the average dish price within each category?

SELECT 
	    category,
	count(*) AS 'Number of dishes',
    ROUND(AVG(price), 2) as avg_dish_price
FROM menu_items
GROUP BY  category;


 ------------------------------------------
-- Objective 2 
-- EXPLORE MENU ITEMS
--------------------------------------------
-- View the order_details table. 
SELECT * FROM order_details;

-- date range in order table
SELECT
    MIN(order_date) AS min_date,
    MAX(order_date) AS max_date
FROM order_details;

-- How many Order made within this date range?
SELECT 
	count(distinct order_id) AS distinct_order, 
	count(*) as items_ordered
FROM order_details;

-- How many Items were ordered within this date range?
SELECT COUNT(*) AS items_ordered FROM order_details;

-- Which orders had the most number of items?
SELECT order_id, COUNT(item_id) AS 'Number of items'
FROM order_details
GROUP BY order_id
ORDER BY 2 DESC;

-- How many orders had more than 12 items?
SELECT 
	count(*) AS 'Number of orders'
FROM 
(SELECT
	order_id,
    COUNT(item_id) AS 'Number_of_items'
FROM order_details
GROUP BY order_id
HAVING Number_of_items > 12) as num_orders;

----------------------------------------------------
-- Objective 3
-- Analyze customer behaviour
----------------------------------------------------

-- Combine the menu_items and order_details tables into a single table
SELECT *
FROM menu_items mi 
JOIN order_details od ON mi.menu_item_id = od.item_id;

-- What were the least and most ordered items? What categories were they in?

-- Least ordered items 
SELECT item_name, category, COUNT(*) AS 'Number of purchases'
FROM order_details od
INNER JOIN menu_items mi ON od.item_id = mi.menu_item_id
GROUP BY item_name, category
ORDER BY 3
LIMIT 1;

-- Most Ordered items
SELECT item_name, category, COUNT(item_name) AS 'Number of purchases'
FROM order_details od
INNER JOIN menu_items mi ON od.item_id = mi.menu_item_id
GROUP BY item_name, category
ORDER BY 3 DESC
LIMIT 1;

-- What were the top 5 orders that spent the most money?
SELECT order_id, SUM(price) AS 'Total amount'
FROM order_details od
INNER JOIN menu_items mi on od.item_id = mi.menu_item_id
GROUP BY order_id
ORDER BY 2 DESC
LIMIT 5;

-- View the details of the highest spend order. Which specific items were purchased?
SELECT *
FROM order_details od
INNER JOIN menu_items mi on od.item_id = mi.menu_item_id
WHERE order_id = 440;

SELECT category, COUNT(item_id) as 'Number of items'
FROM order_details od
INNER JOIN menu_items mi on od.item_id = mi.menu_item_id
WHERE order_id = 440
GROUP BY 1;

-- BONUS: View the details of the top 5 highest spend orders

WITH top5_orders AS (
    SELECT order_id
    FROM order_details od
    INNER JOIN menu_items mi ON od.item_id = mi.menu_item_id
    GROUP BY order_id
    ORDER BY SUM(mi.price) DESC
    LIMIT 5
)
SELECT od.order_id, mi.category, COUNT(od.item_id) AS 'Number of items'
FROM order_details od
INNER JOIN menu_items mi ON od.item_id = mi.menu_item_id
WHERE od.order_id IN (SELECT order_id FROM top5_orders)
GROUP BY od.order_id, mi.category;

-- What Was the Most Expensive Order?
SELECT
    MAX(order_total) AS highest_order_value
FROM (
    SELECT 
        od.order_id,
        SUM(mi.price) AS order_total
    FROM order_details od INNER JOIN menu_items mi
         ON od.item_id = mi.menu_item_id
    GROUP BY od.order_id
) AS order_totals;


