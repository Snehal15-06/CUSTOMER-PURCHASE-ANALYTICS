

USE customer_purchase_analytics;

-- 1. View the first records
SELECT *
FROM customer_behavior_clean
LIMIT 10;

-- 2. Count total transactions
SELECT COUNT(*) AS total_transactions
FROM customer_behavior_clean;

-- 3. Count unique customers
SELECT COUNT(DISTINCT `Customer ID`) AS unique_customers
FROM customer_behavior_clean;

-- 4. Total revenue
SELECT
    ROUND(SUM(`Purchase Amount (USD)`), 2) AS total_revenue
FROM customer_behavior_clean;

-- 5. Average purchase amount
SELECT
    ROUND(AVG(`Purchase Amount (USD)`), 2) AS average_purchase
FROM customer_behavior_clean;

-- 6. Highest and lowest purchase
SELECT
    MAX(`Purchase Amount (USD)`) AS highest_purchase,
    MIN(`Purchase Amount (USD)`) AS lowest_purchase
FROM customer_behavior_clean;

-- 7. Orders by category
SELECT
    Category,
    COUNT(*) AS order_count
FROM customer_behavior_clean
GROUP BY Category
ORDER BY order_count DESC;

-- 8. Revenue by category
SELECT
    Category,
    ROUND(SUM(`Purchase Amount (USD)`), 2) AS revenue
FROM customer_behavior_clean
GROUP BY Category
ORDER BY revenue DESC;

-- 9. Average purchase by gender
SELECT
    Gender,
    ROUND(AVG(`Purchase Amount (USD)`), 2) AS average_purchase
FROM customer_behavior_clean
GROUP BY Gender
ORDER BY average_purchase DESC;

-- 10. Average rating by category
SELECT
    Category,
    ROUND(AVG(`Review Rating`), 2) AS average_rating
FROM customer_behavior_clean
GROUP BY Category
ORDER BY average_rating DESC;

-- 11. Most popular products
SELECT
    `Item Purchased` AS product,
    COUNT(*) AS purchase_count
FROM customer_behavior_clean
GROUP BY `Item Purchased`
ORDER BY purchase_count DESC
LIMIT 10;

-- 12. Revenue by season
SELECT
    Season,
    ROUND(SUM(`Purchase Amount (USD)`), 2) AS revenue
FROM customer_behavior_clean
GROUP BY Season
ORDER BY revenue DESC;

-- 13. Most-used payment methods
SELECT
    `Payment Method` AS payment_method,
    COUNT(*) AS orders
FROM customer_behavior_clean
GROUP BY `Payment Method`
ORDER BY orders DESC;

-- 14. Customers with subscriptions
SELECT
    `Subscription Status`,
    COUNT(DISTINCT `Customer ID`) AS customers
FROM customer_behavior_clean
GROUP BY `Subscription Status`;

-- 15. Purchases above the average purchase amount
SELECT
    `Customer ID`,
    `Item Purchased`,
    `Purchase Amount (USD)`
FROM customer_behavior_clean
WHERE `Purchase Amount (USD)` >
      (SELECT AVG(`Purchase Amount (USD)`) FROM customer_behavior_clean)
ORDER BY `Purchase Amount (USD)` DESC;

-- =========================================================

-- 16. CASE WHEN — create customer value groups
SELECT
    CASE
        WHEN `Previous Purchases` >= 35 THEN 'High Value'
        WHEN `Previous Purchases` >= 15 THEN 'Growing'
        ELSE 'New / Low Value'
    END AS customer_segment,
    COUNT(DISTINCT `Customer ID`) AS customers,
    ROUND(AVG(`Purchase Amount (USD)`), 2) AS average_purchase
FROM customer_behavior_clean
GROUP BY customer_segment
ORDER BY average_purchase DESC;

-- 17. HAVING — categories with meaningful order volume
SELECT
    Category,
    COUNT(*) AS orders,
    ROUND(SUM(`Purchase Amount (USD)`), 2) AS revenue
FROM customer_behavior_clean
GROUP BY Category
HAVING COUNT(*) >= 100
ORDER BY revenue DESC;

-- 18. Discount vs full-price performance
SELECT
    CASE
        WHEN LOWER(`Discount Applied`) = 'yes' THEN 'Discounted'
        ELSE 'Full Price'
    END AS pricing_type,
    COUNT(*) AS orders,
    ROUND(AVG(`Purchase Amount (USD)`), 2) AS average_purchase
FROM customer_behavior_clean
GROUP BY pricing_type;

-- 19. Customer-level spending
SELECT
    `Customer ID`,
    COUNT(*) AS orders,
    ROUND(SUM(`Purchase Amount (USD)`), 2) AS total_spend,
    ROUND(AVG(`Purchase Amount (USD)`), 2) AS average_order_value
FROM customer_behavior_clean
GROUP BY `Customer ID`
ORDER BY total_spend DESC
LIMIT 20;

-- 20. CTE — repeat vs one-time customers
WITH customer_summary AS (
    SELECT
        `Customer ID`,
        COUNT(*) AS orders,
        SUM(`Purchase Amount (USD)`) AS total_spend
    FROM customer_behavior_clean
    GROUP BY `Customer ID`
)
SELECT
    CASE
        WHEN orders > 1 THEN 'Repeat'
        ELSE 'One-time'
    END AS customer_type,
    COUNT(*) AS customers,
    ROUND(AVG(total_spend), 2) AS average_customer_spend
FROM customer_summary
GROUP BY customer_type;

-- 21. CTE — category revenue contribution
WITH category_revenue AS (
    SELECT
        Category,
        SUM(`Purchase Amount (USD)`) AS revenue
    FROM customer_behavior_clean
    GROUP BY Category
)
SELECT
    Category,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        100 * revenue / SUM(revenue) OVER (),
        2
    ) AS revenue_share_percent
FROM category_revenue
ORDER BY revenue DESC;

-- 22. Window function — rank customers by total spending
WITH customer_spend AS (
    SELECT
        `Customer ID`,
        SUM(`Purchase Amount (USD)`) AS total_spend
    FROM customer_behavior_clean
    GROUP BY `Customer ID`
)
SELECT
    `Customer ID`,
    ROUND(total_spend, 2) AS total_spend,
    RANK() OVER (ORDER BY total_spend DESC) AS spending_rank
FROM customer_spend
ORDER BY spending_rank
LIMIT 20;

-- 23. Window function — top 3 products in every category
WITH product_sales AS (
    SELECT
        Category,
        `Item Purchased` AS product,
        COUNT(*) AS orders,
        SUM(`Purchase Amount (USD)`) AS revenue
    FROM customer_behavior_clean
    GROUP BY Category, `Item Purchased`
),
ranked_products AS (
    SELECT
        Category,
        product,
        orders,
        revenue,
        RANK() OVER (
            PARTITION BY Category
            ORDER BY revenue DESC
        ) AS category_rank
    FROM product_sales
)
SELECT
    Category,
    product,
    orders,
    ROUND(revenue, 2) AS revenue,
    category_rank
FROM ranked_products
WHERE category_rank <= 3
ORDER BY Category, category_rank;

-- 24. Category + season analysis
SELECT
    Category,
    Season,
    COUNT(*) AS orders,
    ROUND(SUM(`Purchase Amount (USD)`), 2) AS revenue
FROM customer_behavior_clean
GROUP BY Category, Season
ORDER BY Category, revenue DESC;

-- 25. High-rated products with sufficient purchase volume
SELECT
    `Item Purchased` AS product,
    Category,
    COUNT(*) AS orders,
    ROUND(AVG(`Review Rating`), 2) AS average_rating,
    ROUND(AVG(`Purchase Amount (USD)`), 2) AS average_purchase
FROM customer_behavior_clean
GROUP BY `Item Purchased`, Category
HAVING COUNT(*) >= 20
   AND AVG(`Review Rating`) >= 4
ORDER BY average_rating DESC, orders DESC;


-- Basic:
-- SELECT, WHERE, LIMIT, DISTINCT
-- COUNT, SUM, AVG, MIN, MAX
-- GROUP BY, ORDER BY
-- Subquery
--
-- Intermediate:
-- CASE WHEN
-- HAVING
-- CTE (WITH)
-- Window functions
-- RANK()
-- PARTITION BY
-- Conditional aggregation
