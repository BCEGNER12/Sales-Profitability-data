-- Sales Profitability Analysis Queries
-- Comprehensive SQL queries for business intelligence

-- ============================================================================
-- CUSTOMER BEHAVIOR & ANALYSIS
-- ============================================================================

-- 1. Customer Lifetime Value (CLV) Analysis
SELECT 
    customer_id,
    customer_segment,
    COUNT(order_id) as total_orders,
    SUM(revenue) as lifetime_value,
    SUM(profit) as total_profit,
    ROUND(AVG(profit_margin), 2) as avg_profit_margin,
    MAX(order_date) as last_purchase,
    DATEDIFF(CURDATE(), MAX(order_date)) as days_since_purchase,
    SUM(is_returned) as returns_count
FROM sales_data
GROUP BY customer_id, customer_segment
ORDER BY lifetime_value DESC;

-- 2. Customer Segmentation Analysis
SELECT 
    customer_segment,
    COUNT(DISTINCT customer_id) as unique_customers,
    COUNT(order_id) as total_orders,
    SUM(revenue) as segment_revenue,
    SUM(profit) as segment_profit,
    ROUND(AVG(revenue), 2) as avg_order_value,
    ROUND(AVG(profit_margin), 2) as avg_profit_margin,
    ROUND(SUM(is_returned) / COUNT(order_id) * 100, 2) as return_rate
FROM sales_data
GROUP BY customer_segment
ORDER BY segment_profit DESC;

-- 3. Customer Churn Risk Analysis (No purchase in last 60 days)
SELECT 
    customer_id,
    customer_segment,
    MAX(order_date) as last_purchase_date,
    DATEDIFF(CURDATE(), MAX(order_date)) as days_inactive,
    COUNT(order_id) as total_orders,
    SUM(revenue) as customer_value,
    'CHURN_RISK' as status
FROM sales_data
GROUP BY customer_id, customer_segment
HAVING days_inactive > 60
ORDER BY customer_value DESC;

-- 4. High-Value Customer Retention Analysis
SELECT 
    customer_id,
    customer_segment,
    COUNT(order_id) as order_frequency,
    SUM(revenue) as total_value,
    SUM(profit) as total_profit,
    MIN(order_date) as first_purchase,
    MAX(order_date) as last_purchase,
    DATEDIFF(MAX(order_date), MIN(order_date)) as customer_lifespan_days,
    ROUND(SUM(is_returned) / COUNT(order_id) * 100, 2) as return_rate
FROM sales_data
WHERE customer_segment = 'Premium'
GROUP BY customer_id, customer_segment
ORDER BY total_value DESC
LIMIT 20;

-- 5. Customer Purchase Pattern Analysis
SELECT 
    customer_segment,
    COUNT(DISTINCT customer_id) as customers,
    ROUND(COUNT(order_id) / COUNT(DISTINCT customer_id), 2) as avg_orders_per_customer,
    ROUND(SUM(revenue) / COUNT(DISTINCT customer_id), 2) as avg_customer_value,
    MIN(order_date) as earliest_order,
    MAX(order_date) as latest_order
FROM sales_data
GROUP BY customer_segment;

-- ============================================================================
-- PRODUCT PERFORMANCE ANALYSIS
-- ============================================================================

-- 6. Product Profitability Ranking
SELECT 
    product_name,
    category,
    COUNT(order_id) as times_sold,
    SUM(quantity) as units_sold,
    SUM(revenue) as total_revenue,
    SUM(cost_of_goods) as total_cost,
    SUM(profit) as total_profit,
    ROUND(AVG(profit_margin), 2) as avg_profit_margin,
    ROUND(SUM(is_returned) / COUNT(order_id) * 100, 2) as return_rate
FROM sales_data
GROUP BY product_id, product_name, category
ORDER BY total_profit DESC;

-- 7. Low Margin Products (Pricing Opportunity)
SELECT 
    product_name,
    category,
    unit_price,
    ROUND(AVG(profit_margin), 2) as avg_margin,
    COUNT(order_id) as times_sold,
    SUM(profit) as total_profit,
    'OPTIMIZATION_NEEDED' as recommendation
FROM sales_data
GROUP BY product_id, product_name, category, unit_price
HAVING AVG(profit_margin) < 20
ORDER BY avg_margin ASC;

-- 8. Product Category Performance
SELECT 
    category,
    COUNT(DISTINCT product_id) as unique_products,
    COUNT(DISTINCT customer_id) as unique_customers,
    COUNT(order_id) as total_orders,
    SUM(quantity) as units_sold,
    SUM(revenue) as category_revenue,
    SUM(profit) as category_profit,
    ROUND(AVG(profit_margin), 2) as avg_margin,
    ROUND(SUM(is_returned) / COUNT(order_id) * 100, 2) as return_rate
FROM sales_data
GROUP BY category
ORDER BY category_profit DESC;

-- 9. High Return Products (Quality Issues)
SELECT 
    product_name,
    category,
    COUNT(order_id) as times_sold,
    SUM(is_returned) as return_count,
    ROUND(SUM(is_returned) / COUNT(order_id) * 100, 2) as return_rate,
    SUM(profit) as lost_profit,
    'QUALITY_REVIEW_NEEDED' as action
FROM sales_data
GROUP BY product_id, product_name, category
HAVING return_count > 0
ORDER BY return_rate DESC;

-- 10. Best Selling Products by Quantity
SELECT 
    product_name,
    category,
    COUNT(order_id) as order_count,
    SUM(quantity) as total_quantity,
    SUM(revenue) as revenue,
    SUM(profit) as profit,
    ROUND(SUM(revenue) / SUM(quantity), 2) as revenue_per_unit
FROM sales_data
GROUP BY product_id, product_name, category
ORDER BY total_quantity DESC
LIMIT 15;

-- ============================================================================
-- REVENUE & TREND ANALYSIS
-- ============================================================================

-- 11. Monthly Revenue Trends
SELECT 
    order_month,
    COUNT(order_id) as orders,
    COUNT(DISTINCT customer_id) as unique_customers,
    SUM(revenue) as total_revenue,
    SUM(profit) as total_profit,
    ROUND(AVG(revenue), 2) as avg_order_value,
    ROUND(AVG(profit_margin), 2) as avg_margin,
    SUM(quantity) as units_sold
FROM sales_data
GROUP BY order_month
ORDER BY order_month DESC;

-- 12. Daily Revenue Trends
SELECT 
    DATE(order_date) as order_day,
    DAYNAME(order_date) as day_of_week,
    COUNT(order_id) as orders,
    SUM(revenue) as daily_revenue,
    SUM(profit) as daily_profit,
    ROUND(AVG(revenue), 2) as avg_order_value
FROM sales_data
GROUP BY DATE(order_date), DAYNAME(order_date)
ORDER BY order_date DESC;

-- 13. Year-over-Year Revenue Growth
SELECT 
    YEAR(order_date) as year,
    MONTH(order_date) as month,
    COUNT(order_id) as orders,
    SUM(revenue) as revenue,
    SUM(profit) as profit,
    ROUND(SUM(revenue) / COUNT(order_id), 2) as avg_order_value
FROM sales_data
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY year DESC, month DESC;

-- 14. Top Revenue Days
SELECT 
    DATE(order_date) as sales_date,
    DAYNAME(order_date) as day_name,
    COUNT(order_id) as orders,
    COUNT(DISTINCT customer_id) as unique_customers,
    SUM(revenue) as daily_revenue,
    SUM(profit) as daily_profit,
    ROUND(SUM(revenue) / COUNT(order_id), 2) as avg_order
FROM sales_data
GROUP BY DATE(order_date)
ORDER BY daily_revenue DESC
LIMIT 10;

-- 15. Revenue Growth by Segment Over Time
SELECT 
    order_month,
    customer_segment,
    COUNT(order_id) as orders,
    SUM(revenue) as revenue,
    SUM(profit) as profit,
    ROUND(AVG(profit_margin), 2) as margin
FROM sales_data
GROUP BY order_month, customer_segment
ORDER BY order_month DESC, revenue DESC;

-- ============================================================================
-- REGIONAL ANALYSIS
-- ============================================================================

-- 16. Regional Performance Analysis
SELECT 
    region,
    COUNT(DISTINCT customer_id) as unique_customers,
    COUNT(order_id) as total_orders,
    SUM(revenue) as total_revenue,
    SUM(profit) as total_profit,
    ROUND(AVG(revenue), 2) as avg_order_value,
    ROUND(AVG(profit_margin), 2) as avg_margin,
    ROUND(SUM(is_returned) / COUNT(order_id) * 100, 2) as return_rate,
    SUM(shipping_cost) as shipping_expense
FROM sales_data
GROUP BY region
ORDER BY total_profit DESC;

-- 17. Regional Revenue Trends
SELECT 
    order_month,
    region,
    COUNT(order_id) as orders,
    SUM(revenue) as revenue,
    SUM(profit) as profit
FROM sales_data
GROUP BY order_month, region
ORDER BY order_month DESC, revenue DESC;

-- 18. Customer Segment Performance by Region
SELECT 
    region,
    customer_segment,
    COUNT(DISTINCT customer_id) as customers,
    COUNT(order_id) as orders,
    SUM(revenue) as revenue,
    SUM(profit) as profit,
    ROUND(AVG(profit_margin), 2) as avg_margin
FROM sales_data
GROUP BY region, customer_segment
ORDER BY region, profit DESC;

-- ============================================================================
-- OPERATIONAL METRICS
-- ============================================================================

-- 19. Delivery Performance Analysis
SELECT 
    region,
    ROUND(AVG(days_to_delivery), 1) as avg_delivery_days,
    MIN(days_to_delivery) as min_delivery_days,
    MAX(days_to_delivery) as max_delivery_days,
    COUNT(order_id) as total_orders,
    SUM(shipping_cost) as total_shipping,
    ROUND(AVG(shipping_cost), 2) as avg_shipping
FROM sales_data
GROUP BY region
ORDER BY avg_delivery_days ASC;

-- 20. Payment Method Analysis
SELECT 
    payment_method,
    COUNT(order_id) as orders,
    SUM(revenue) as total_revenue,
    SUM(profit) as total_profit,
    ROUND(AVG(revenue), 2) as avg_order_value,
    SUM(is_returned) as returns,
    ROUND(SUM(is_returned) / COUNT(order_id) * 100, 2) as return_rate
FROM sales_data
GROUP BY payment_method
ORDER BY total_revenue DESC;

-- 21. Return Analysis by Region and Category
SELECT 
    region,
    category,
    COUNT(order_id) as total_orders,
    SUM(is_returned) as returns,
    ROUND(SUM(is_returned) / COUNT(order_id) * 100, 2) as return_rate,
    SUM(CASE WHEN is_returned = 1 THEN profit ELSE 0 END) as lost_profit
FROM sales_data
GROUP BY region, category
ORDER BY return_rate DESC;

-- 22. Discount Impact Analysis
SELECT 
    CASE 
        WHEN discount_percent = 0 THEN 'No Discount'
        WHEN discount_percent <= 10 THEN '1-10%'
        WHEN discount_percent <= 20 THEN '11-20%'
        ELSE '20%+'
    END as discount_range,
    COUNT(order_id) as orders,
    SUM(revenue) as revenue,
    SUM(profit) as profit,
    ROUND(AVG(profit_margin), 2) as avg_margin,
    ROUND(SUM(is_returned) / COUNT(order_id) * 100, 2) as return_rate
FROM sales_data
GROUP BY discount_range
ORDER BY orders DESC;

-- 23. Shipping Cost Impact on Profitability
SELECT 
    ROUND(shipping_cost / 5) * 5 as shipping_range,
    COUNT(order_id) as orders,
    SUM(revenue) as revenue,
    SUM(profit) as profit,
    ROUND(AVG(profit_margin), 2) as avg_margin,
    ROUND(AVG(shipping_cost), 2) as avg_shipping
FROM sales_data
GROUP BY shipping_range
ORDER BY shipping_range ASC;

-- 24. Tax vs Profitability
SELECT 
    region,
    SUM(tax) as total_tax,
    SUM(profit) as total_profit,
    ROUND(SUM(tax) / SUM(revenue) * 100, 2) as tax_rate,
    ROUND(SUM(profit) / SUM(revenue) * 100, 2) as profit_rate
FROM sales_data
GROUP BY region;

-- ============================================================================
-- GROWTH & OPPORTUNITY ANALYSIS
-- ============================================================================

-- 25. Cross-Sell Opportunities (Customers buying in one category)
SELECT 
    customer_id,
    COUNT(DISTINCT category) as categories_purchased,
    COUNT(DISTINCT product_id) as unique_products,
    SUM(revenue) as total_value
FROM sales_data
GROUP BY customer_id
HAVING categories_purchased = 1
ORDER BY total_value DESC;

-- 26. Product Bundle Opportunities (Frequently bought together)
SELECT 
    DISTINCT s1.product_name as product_1,
    s2.product_name as product_2,
    COUNT(DISTINCT s1.customer_id) as customers,
    ROUND(COUNT(DISTINCT s1.customer_id) / (SELECT COUNT(DISTINCT customer_id) FROM sales_data) * 100, 2) as co_purchase_rate
FROM sales_data s1
JOIN sales_data s2 ON s1.customer_id = s2.customer_id 
    AND s1.order_date = s2.order_date 
    AND s1.product_id < s2.product_id
GROUP BY s1.product_id, s2.product_id
ORDER BY customers DESC
LIMIT 20;

-- 27. High-Margin Product Promotion Opportunities
SELECT 
    product_name,
    category,
    ROUND(AVG(profit_margin), 2) as avg_margin,
    SUM(quantity) as quantity_sold,
    SUM(profit) as total_profit,
    'PROMOTION_CANDIDATE' as recommendation
FROM sales_data
WHERE profit_margin > 40
GROUP BY product_id, product_name, category
ORDER BY total_profit DESC;

-- 28. Customer Acquisition Efficiency
SELECT 
    order_month,
    COUNT(DISTINCT customer_id) as new_customers,
    SUM(revenue) as revenue,
    ROUND(SUM(revenue) / COUNT(DISTINCT customer_id), 2) as revenue_per_customer,
    SUM(profit) as profit
FROM sales_data
GROUP BY order_month
ORDER BY order_month DESC;

-- 29. Repeat Purchase Rate Analysis
WITH customer_purchase_count AS (
    SELECT 
        customer_id,
        COUNT(order_id) as purchase_count
    FROM sales_data
    GROUP BY customer_id
)
SELECT 
    CASE 
        WHEN purchase_count = 1 THEN 'First Time'
        WHEN purchase_count = 2 THEN 'Repeat (2)'
        WHEN purchase_count BETWEEN 3 AND 5 THEN 'Repeat (3-5)'
        ELSE 'Loyal (5+)'
    END as customer_type,
    COUNT(*) as customer_count,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM customer_purchase_count) * 100, 2) as percent
FROM customer_purchase_count
GROUP BY customer_type;

-- 30. Profitability Score Card (Executive Summary)
SELECT 
    'Total Revenue' as metric,
    CONCAT('$', ROUND(SUM(revenue), 2)) as value
FROM sales_data
UNION ALL
SELECT 'Total Profit' as metric, CONCAT('$', ROUND(SUM(profit), 2)) as value FROM sales_data
UNION ALL
SELECT 'Profit Margin %' as metric, CONCAT(ROUND(SUM(profit)/SUM(revenue)*100, 2), '%') as value FROM sales_data
UNION ALL
SELECT 'Total Orders' as metric, COUNT(order_id) as value FROM sales_data
UNION ALL
SELECT 'Avg Order Value' as metric, CONCAT('$', ROUND(AVG(revenue), 2)) as value FROM sales_data
UNION ALL
SELECT 'Return Rate %' as metric, CONCAT(ROUND(SUM(is_returned)/COUNT(order_id)*100, 2), '%') as value FROM sales_data
UNION ALL
SELECT 'Unique Customers' as metric, COUNT(DISTINCT customer_id) as value FROM sales_data;
