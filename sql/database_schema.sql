-- Sales Profitability Database Schema
-- Create tables for comprehensive sales analysis

-- Main Sales Data Table
CREATE TABLE sales_data (
    order_id VARCHAR(10) PRIMARY KEY,
    customer_id VARCHAR(10),
    order_date DATE,
    product_id VARCHAR(10),
    product_name VARCHAR(100),
    category VARCHAR(50),
    quantity INT,
    unit_price DECIMAL(10,2),
    discount_percent DECIMAL(5,2),
    shipping_cost DECIMAL(10,2),
    tax DECIMAL(10,2),
    order_total DECIMAL(10,2),
    revenue DECIMAL(10,2),
    cost_of_goods DECIMAL(10,2),
    region VARCHAR(50),
    customer_segment VARCHAR(20),
    payment_method VARCHAR(20),
    delivery_date DATE,
    days_to_delivery INT,
    return_status VARCHAR(10),
    return_date DATE,
    -- Calculated columns
    profit DECIMAL(10,2) GENERATED ALWAYS AS (revenue - cost_of_goods) STORED,
    profit_margin DECIMAL(5,2) GENERATED ALWAYS AS ((revenue - cost_of_goods) / revenue * 100) STORED,
    order_month VARCHAR(7) GENERATED ALWAYS AS (DATE_FORMAT(order_date, '%Y-%m')) STORED,
    is_returned TINYINT GENERATED ALWAYS AS (CASE WHEN return_status = 'Yes' THEN 1 ELSE 0 END) STORED,
    
    INDEX idx_customer (customer_id),
    INDEX idx_category (category),
    INDEX idx_region (region),
    INDEX idx_order_date (order_date),
    INDEX idx_segment (customer_segment)
);

-- Customer Dimension Table
CREATE TABLE customers (
    customer_id VARCHAR(10) PRIMARY KEY,
    customer_segment VARCHAR(20),
    total_orders INT,
    total_spent DECIMAL(12,2),
    total_profit DECIMAL(12,2),
    last_purchase_date DATE,
    customer_lifetime_value DECIMAL(12,2),
    INDEX idx_segment (customer_segment)
);

-- Product Dimension Table
CREATE TABLE products (
    product_id VARCHAR(10) PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    unit_price DECIMAL(10,2),
    cost_per_unit DECIMAL(10,2),
    profit_per_unit DECIMAL(10,2),
    margin_percent DECIMAL(5,2),
    times_sold INT,
    total_revenue DECIMAL(12,2),
    total_profit DECIMAL(12,2),
    return_rate DECIMAL(5,2),
    INDEX idx_category (category)
);

-- Monthly Summary Table
CREATE TABLE monthly_summary (
    summary_id INT AUTO_INCREMENT PRIMARY KEY,
    year_month VARCHAR(7),
    total_orders INT,
    total_revenue DECIMAL(12,2),
    total_profit DECIMAL(12,2),
    avg_order_value DECIMAL(10,2),
    avg_profit_margin DECIMAL(5,2),
    total_returns INT,
    return_rate DECIMAL(5,2),
    UNIQUE KEY unique_month (year_month)
);

-- Regional Performance Table
CREATE TABLE regional_summary (
    region_id INT AUTO_INCREMENT PRIMARY KEY,
    region VARCHAR(50),
    total_orders INT,
    total_revenue DECIMAL(12,2),
    total_profit DECIMAL(12,2),
    avg_order_value DECIMAL(10,2),
    avg_profit_margin DECIMAL(5,2),
    customer_count INT,
    total_returns INT,
    UNIQUE KEY unique_region (region)
);

-- Segment Performance Table
CREATE TABLE segment_summary (
    segment_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_segment VARCHAR(20),
    total_orders INT,
    total_revenue DECIMAL(12,2),
    total_profit DECIMAL(12,2),
    avg_order_value DECIMAL(10,2),
    avg_profit_margin DECIMAL(5,2),
    customer_count INT,
    total_returns INT,
    UNIQUE KEY unique_segment (customer_segment)
);

-- Create Views for Quick Analytics
CREATE VIEW vw_customer_analysis AS
SELECT 
    customer_id,
    customer_segment,
    COUNT(order_id) as total_orders,
    SUM(revenue) as lifetime_value,
    SUM(profit) as total_profit,
    ROUND(AVG(profit_margin), 2) as avg_margin,
    MAX(order_date) as last_purchase,
    SUM(is_returned) as returns_count
FROM sales_data
GROUP BY customer_id, customer_segment;

CREATE VIEW vw_product_analysis AS
SELECT 
    product_name,
    category,
    COUNT(order_id) as times_sold,
    SUM(quantity) as units_sold,
    SUM(revenue) as total_revenue,
    SUM(profit) as total_profit,
    ROUND(AVG(profit_margin), 2) as avg_margin,
    ROUND(SUM(is_returned) / COUNT(order_id) * 100, 2) as return_rate
FROM sales_data
GROUP BY product_id, product_name, category
ORDER BY total_profit DESC;

CREATE VIEW vw_monthly_analysis AS
SELECT 
    order_month,
    COUNT(order_id) as orders,
    SUM(revenue) as total_revenue,
    SUM(profit) as total_profit,
    ROUND(AVG(revenue), 2) as avg_order_value,
    ROUND(AVG(profit_margin), 2) as avg_margin,
    SUM(is_returned) as returns
FROM sales_data
GROUP BY order_month
ORDER BY order_month;

CREATE VIEW vw_regional_analysis AS
SELECT 
    region,
    COUNT(DISTINCT customer_id) as customers,
    COUNT(order_id) as orders,
    SUM(revenue) as total_revenue,
    SUM(profit) as total_profit,
    ROUND(AVG(revenue), 2) as avg_order_value,
    ROUND(AVG(profit_margin), 2) as avg_margin,
    ROUND(SUM(is_returned) / COUNT(order_id) * 100, 2) as return_rate
FROM sales_data
GROUP BY region;
