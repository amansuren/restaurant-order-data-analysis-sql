# 🧑‍🍳 Restaurant Order Data Analysis - Case Study

## 📋 Table of Contents
 
- [Project Background](#project-background)
- [Business Questions](#business-questions)
- [Objective 1 - Menu Exploration](#objective-1---menu-exploration)
- [Objective 2 - Order Volume & Behavior](#objective-2---order-volume--behavior)
- [Objective 3 - Customer & Revenue Insights](#objective-3---customer--revenue-insights)
- [Key Findings Summary](#key-findings-summary)
- [Business Recommendations](#business-recommendations)

## Project Background
 
A restaurant owner wants to understand how her current menu is impacting sales. Using data exported from her point-of-sale system, this project explores Q1 2023 order transactions to answer key business questions around menu popularity, cuisine performance, and high-value customer behavior.
 
**Business Goal:** Identify which menu items and cuisine categories to promote, optimize, or reconsider - and surface patterns in how customers spend.

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/f453f61c-84ae-4427-904b-cab10ba78a0e" />

## Dataset
 
**Source:** [Maven Analytics — Restaurant Orders Dataset](https://mavenanalytics.io/data-playground/restaurant-orders)  

- **Schema:** `restaurant_db`
- **Tables:** `menu_items` , `order_details`
- **Records:**  12,266

## Business Questions
 
The analysis was organized around three objectives and the following business questions:
 
**Menu Structure**

1. How many items are on the menu, and how are they distributed across categories?
2. What are the cheapest and most expensive items overall?
3. Which category commands the highest average price?

**Order Behavior**

4. How many total orders and items were placed in Q1 2023?
5. Which orders had the most items - are there any unusually large orders?
6. How many orders exceeded 12 items?
 
**Customer & Revenue Insights**

7. Which menu item is ordered most frequently? Which is ordered least?
8. What are the top 5 highest-spend orders?
9. What did the single highest-spend order contain?
10. Which cuisine category dominates high-value orders?

## Objective 1 - Menu Exploration
### Q1. How many items are on the menu?
```sql
SELECT COUNT(*) AS No_of_items FROM menu_items;
```
> **32 items** across 4 cuisine categories: American, Asian, Mexican, and Italian.

### Q2. What are the cheapest and most expensive items on the menu?
```sql
SELECT *
FROM menu_items
WHERE price IN (
    SELECT MIN(price) FROM menu_items
    UNION
    SELECT MAX(price) FROM menu_items
);
```
### Q3. How many dishes are in each category, and what is the average price?
 
```sql
SELECT 
    COUNT(*) AS 'Number of dishes',
    category,
    AVG(price) AS avg_dish_price
FROM menu_items
GROUP BY category;
```
> **Italian is the highest-priced category** at $16.75 average, despite having the same number of dishes as Mexican. American is the most affordable at $10.07.

 
### Q4. How many Italian dishes are on the menu, and what is the price range?
 
```sql
-- Cheapest Italian dish
SELECT * FROM menu_items WHERE category = 'Italian' ORDER BY price LIMIT 1;
 
-- Most expensive Italian dish
SELECT * FROM menu_items WHERE category = 'Italian' ORDER BY price DESC LIMIT 1;
```
 
> Italian dishes range from **Spaghetti ($14.50)** to **Shrimp Scampi ($19.95)** — the most expensive item on the entire menu.

## Objective 2 - Order Volume & Behavior
 
### Q5. What is the date range? How many orders and items were placed?
 
```sql
SELECT MIN(order_date) AS min_date, MAX(order_date) AS max_date FROM order_details;
 
SELECT 
	count(distinct order_id) AS distinct_order, 
	count(*) as items_ordered
FROM order_details;
```
### Q6. Which orders had the most items?
 
```sql
SELECT order_id, COUNT(item_id) AS 'Number of items'
FROM order_details
GROUP BY order_id
ORDER BY 2 DESC;
```
> The largest orders contained **14 items**, indicating potential group dining or large table events.

### Q7. How many orders had more than 12 items?
 
```sql
SELECT COUNT(*) AS 'Number of orders'
FROM (
    SELECT order_id, COUNT(item_id) AS Number_of_items
    FROM order_details
    GROUP BY order_id
    HAVING Number_of_items > 12
) AS num_orders;
```
 
> **20 orders** exceeded 12 items - a small but notable segment that likely represents high-value group visits worth understanding further.

## Objective 3 - Customer & Revenue Insights
 
### Q8. What are the most and least ordered items?
 
```sql
-- Most ordered
SELECT item_name, category, COUNT(item_name) AS 'Number of purchases'
FROM order_details od
INNER JOIN menu_items mi ON od.item_id = mi.menu_item_id
GROUP BY item_name, category
ORDER BY 3 DESC
LIMIT 1;
 
-- Least ordered
SELECT item_name, category, COUNT(*) AS 'Number of purchases'
FROM order_details od
INNER JOIN menu_items mi ON od.item_id = mi.menu_item_id
GROUP BY item_name, category
ORDER BY 3
LIMIT 1;
```
> Despite American being the **lowest-priced category**, the Hamburger dominates order volume — suggesting strong customer preference for familiar, affordable comfort food.

### Q9. What were the top 5 highest-spend orders?
 
```sql
SELECT order_id, SUM(price) AS 'Total amount'
FROM order_details od
INNER JOIN menu_items mi ON od.item_id = mi.menu_item_id
GROUP BY order_id
ORDER BY 2 DESC
LIMIT 5;
```
 
> The top 5 orders all exceeded **$185**, pointing to a high-spend customer segment that places large, multi-item orders.

### Q10. What did the highest-spend order (Order #440) contain?
 
```sql
SELECT category, COUNT(item_id) AS 'Number of items'
FROM order_details od
INNER JOIN menu_items mi ON od.item_id = mi.menu_item_id
WHERE order_id = 440
GROUP BY 1;
```
  
> Order #440 was **heavily Italian-dominated**, with 8 of 14 items from that category. This reinforces Italian as the primary revenue driver in high-spend scenarios.

### Q11. Category breakdown across top 5 highest-spend orders
 
```sql
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
```
 
> Across all top 5 orders, **Italian items consistently dominated**, confirming it as the highest revenue-generating category by spend per order.

## Key Findings Summary
 
| # | Finding |
|---|---|
| 1 | The menu has **32 items** across 4 categories, with Italian holding the highest average price ($16.75) |
| 2 | **Shrimp Scampi ($19.95)** is the most expensive item; **Edamame ($5.00)** is the cheapest |
| 3 | **5,370 orders** and **12,234 items** were placed in Q1 2023 |
| 4 | **20 orders** had more than 12 items, representing potential high-value group dining events |
| 5 | **Hamburger (American)** is the most ordered item with 622 purchases |
| 6 | **Chicken Tacos (Mexican)** is the least ordered item with only 123 purchases |
| 7 | The highest single order (Order #440) totalled **$192.15** and was dominated by Italian dishes |
| 8 | **Italian cuisine drives high-spend orders** despite Asian having the highest order volume overall |

## Business Recommendations
 
**1. Double down on Italian for revenue**
Italian dishes command the highest prices and dominate high-spend orders. Featuring Italian items more prominently on the menu or in promotions could increase average order value.
 
**2. Investigate low performers before cutting them**
Chicken Tacos had only 123 orders in a full quarter. Before removing it, explore whether it's a visibility/placement issue or a genuine lack of demand, a limited-time promotion could test this.
 
**3. Upsell strategies around the Hamburger**
The Hamburger is the most popular item by volume but comes from the lowest-priced category. Combo deals, sides, or drink pairings tied to American dishes could increase per-order revenue from this high-traffic item.
 
**4. Design group dining packages**
20 orders exceeded 12 items - likely large group tables. A dedicated group menu or pre-set dining package (especially Italian-heavy) could encourage more of this high-value behavior.




## 📚 References
 
- [Maven Analytics Guided Project](https://app.mavenanalytics.io/guided-projects/d7167b45-6317-49c9-b2bb-42e2a9e9c0bc)
- [Dataset on Maven Data Playground](https://mavenanalytics.io/data-playground/restaurant-orders)
