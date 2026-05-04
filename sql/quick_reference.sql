"""
Quick Reference SQL Queries
Copy-paste ready for immediate insights
"""

-- ============================================================================
-- EXECUTIVE SUMMARY - Run this first
-- ============================================================================

-- KPI Dashboard
SELECT 
    'Total Revenue' as metric,
    CONCAT('$', ROUND(SUM(revenue), 2)) as value
FROM sales_data
UNION ALL
SELECT 'Total Profit', CONCAT('$', ROUND(SUM(profit), 2)) FROM sales_data
UNION ALL
SELECT 'Profit Margin %', CONCAT(ROUND(SUM(profit)/SUM(revenue)*100, 2), '%') FROM sales_data
UNION ALL
SELECT 'Total Orders', COUNT(order_id) FROM sales_data
UNION ALL
SELECT 'Unique Customers', COUNT(DISTINCT customer_id) FROM sales_data
UNION ALL
SELECT 'Avg Order Value', CONCAT('$', ROUND(AVG(revenue), 2)) FROM sales_data
UNION ALL
SELECT 'Return Rate %', CONCAT(ROUND(SUM(is_returned)/COUNT(order_id)*100, 2), '%') FROM sales_data;

-- ============================================================================
-- TOP PERFORMERS
-- ============================================================================

-- Top 10 Customers by Revenue
SELECT 
    customer_id,
    customer_segment,
    COUNT(order_id) as orders,
    SUM(revenue) as total_revenue,
    SUM(profit) as total_profit,
    ROUND(AVG(profit_margin), 1) as avg_margin
FROM sales_data
GROUP BY customer_id, customer_segment
ORDER BY total_revenue DESC
LIMIT 10;

-- Top 10 Products by Profit
SELECT 
    product_name,
    category,
    COUNT(order_id) as sold_count,
    SUM(quantity) as units_sold,
    SUM(profit) as total_profit,
    ROUND(AVG(profit_margin), 1) as avg_margin,
    ROUND(SUM(is_returned) / COUNT(order_id) * 100, 1) as return_rate
FROM sales_data
GROUP BY product_id, product_name, category
ORDER BY total_profit DESC
LIMIT 10;

-- Top 5 Performing Days
SELECT 
    DATE(order_date) as date,
    DAYNAME(order_date) as day,
    COUNT(order_id) as orders,
    SUM(revenue) as revenue,
    SUM(profit) as profit
FROM sales_data
GROUP BY DATE(order_date)
ORDER BY revenue DESC
LIMIT 5;

-- ============================================================================
-- CUSTOMER INSIGHTS
-- ============================================================================

-- Customer Segment Comparison
SELECT 
    customer_segment,
    COUNT(DISTINCT customer_id) as customers,
    COUNT(order_id) as total_orders,
    SUM(revenue) as total_revenue,
    SUM(profit) as total_profit,
    ROUND(AVG(revenue), 2) as avg_order_value,
    ROUND(AVG(profit_margin), 1) as avg_margin,
    ROUND(SUM(is_returned) / COUNT(order_id) * 100, 1) as return_rate
FROM sales_data
GROUP BY customer_segment
ORDER BY total_profit DESC;

-- Repeat Customers vs First-Time
WITH customer_orders AS (
    SELECT customer_id, COUNT(order_id) as order_count
    FROM sales_data
    GROUP BY customer_id
)
SELECT 
    CASE WHEN order_count = 1 THEN 'First-Time' ELSE 'Repeat' END as customer_type,
    COUNT(*) as customer_count,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM customer_orders) * 100, 1) as percent
FROM customer_orders
GROUP BY customer_type;

-- High-Value Customers (Premium Segment)
SELECT 
    customer_id,
    COUNT(order_id) as orders,
    SUM(revenue) as lifetime_value,
    MAX(order_date) as last_purchase,
    DATEDIFF(CURDATE(), MAX(order_date)) as days_since_purchase
FROM sales_data
WHERE customer_segment = 'Premium'
GROUP BY customer_id
ORDER BY lifetime_value DESC
LIMIT 10;

-- ============================================================================
-- PRODUCT INSIGHTS
-- ============================================================================

-- Category Performance
SELECT 
    category,
    COUNT(DISTINCT product_id) as products,
    COUNT(order_id) as orders,
    SUM(revenue) as revenue,
    SUM(profit) as profit,
    ROUND(AVG(profit_margin), 1) as avg_margin,
    ROUND(SUM(is_returned) / COUNT(order_id) * 100, 1) as return_rate
FROM sales_data
GROUP BY category
ORDER BY profit DESC;

-- Products with Quality Issues (High Return Rate)
SELECT 
    product_name,
    category,
    COUNT(order_id) as sold_count,
    SUM(is_returned) as returns,
    ROUND(SUM(is_returned) / COUNT(order_id) * 100, 1) as return_rate,
    SUM(profit) as lost_profit
FROM sales_data
GROUP BY product_id, product_name, category
HAVING return_rate > 10
ORDER BY return_rate DESC;

-- Low Margin Products (Pricing Opportunity)
SELECT 
    product_name,
    category,
    unit_price,
    ROUND(AVG(profit_margin), 1) as margin_percent,
    COUNT(order_id) as times_sold,
    SUM(profit) as total_profit
FROM sales_data
GROUP BY product_id, product_name, category, unit_price
HAVING margin_percent < 25
ORDER BY margin_percent ASC
LIMIT 10;

-- ============================================================================
-- REVENUE ANALYSIS
-- ============================================================================

-- Monthly Trends
SELECT 
    order_month,
    COUNT(order_id) as orders,
    SUM(revenue) as revenue,
    SUM(profit) as profit,
    ROUND(SUM(profit) / SUM(revenue) * 100, 1) as margin_percent,
    ROUND(AVG(revenue), 2) as avg_order_value
FROM sales_data
GROUP BY order_month
ORDER BY order_month DESC;

-- Revenue by Day of Week
SELECT 
    DAYNAME(order_date) as day,
    COUNT(order_id) as orders,
    SUM(revenue) as revenue,
    SUM(profit) as profit,
    ROUND(AVG(revenue), 2) as avg_order
FROM sales_data
GROUP BY DAYNAME(order_date)
ORDER BY revenue DESC;

-- ============================================================================
-- REGIONAL ANALYSIS
-- ============================================================================

-- Regional Performance Comparison
SELECT 
    region,
    COUNT(DISTINCT customer_id) as customers,
    COUNT(order_id) as orders,
    SUM(revenue) as revenue,
    SUM(profit) as profit,
    ROUND(AVG(revenue), 2) as avg_order,
    ROUND(AVG(profit_margin), 1) as margin_percent,
    ROUND(AVG(days_to_delivery), 1) as avg_delivery_days
FROM sales_data
GROUP BY region
ORDER BY revenue DESC;

-- Region-Segment Cross-Tab
SELECT 
    region,
    customer_segment,
    COUNT(order_id) as orders,
    SUM(revenue) as revenue,
    ROUND(AVG(profit_margin), 1) as margin
FROM sales_data
GROUP BY region, customer_segment
ORDER BY region, revenue DESC;

-- ============================================================================
-- OPERATIONAL INSIGHTS
-- ============================================================================

-- Payment Method Performance
SELECT 
    payment_method,
    COUNT(order_id) as orders,
    SUM(revenue) as revenue,
    ROUND(SUM(profit) / SUM(revenue) * 100, 1) as margin_percent,
    ROUND(SUM(is_returned) / COUNT(order_id) * 100, 1) as return_rate
FROM sales_data
GROUP BY payment_method
ORDER BY revenue DESC;

-- Discount Impact Analysis
SELECT 
    CASE 
        WHEN discount_percent = 0 THEN 'No Discount'
        WHEN discount_percent <= 10 THEN '1-10%'
        WHEN discount_percent <= 20 THEN '11-20%'
        ELSE '20%+'
    END as discount_range,
    COUNT(order_id) as orders,
    ROUND(SUM(profit) / SUM(revenue) * 100, 1) as margin_percent,
    SUM(revenue) as revenue
FROM sales_data
GROUP BY discount_range
ORDER BY orders DESC;

-- Delivery Performance
SELECT 
    region,
    ROUND(AVG(days_to_delivery), 1) as avg_delivery_days,
    COUNT(order_id) as orders,
    ROUND(AVG(shipping_cost), 2) as avg_shipping
FROM sales_data
GROUP BY region
ORDER BY avg_delivery_days;

-- ============================================================================
-- OPTIMIZATION OPPORTUNITIES
-- ============================================================================

-- Cross-Sell Potential (Single Category Buyers)
SELECT 
    COUNT(*) as customers_buying_one_category,
    ROUND(COUNT(*) / (SELECT COUNT(DISTINCT customer_id) FROM sales_data) * 100, 1) as percent_of_customers,
    'CROSS_SELL_OPPORTUNITY' as recommendation
FROM (
    SELECT customer_id, COUNT(DISTINCT category) as categories
    FROM sales_data
    GROUP BY customer_id
    HAVING categories = 1
) as single_category;

-- Profitability by Price Point
SELECT 
    CASE 
        WHEN unit_price < 20 THEN 'Budget (<$20)'
        WHEN unit_price < 100 THEN 'Mid ($20-100)'
        ELSE 'Premium (>$100)'
    END as price_point,
    COUNT(order_id) as orders,
    SUM(revenue) as revenue,
    SUM(profit) as profit,
    ROUND(SUM(profit) / SUM(revenue) * 100, 1) as margin_percent
FROM sales_data
GROUP BY price_point
ORDER BY profit DESC;

-- Returns Cost Analysis
SELECT 
    ROUND(SUM(profit * is_returned)) as lost_profit_from_returns,
    ROUND(SUM(profit * (1 - is_returned))) as realized_profit,
    CONCAT(ROUND(SUM(profit * is_returned) / SUM(profit) * 100, 1), '%') as return_cost_percent
FROM sales_data;
