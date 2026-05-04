# Sales Data Dictionary

Complete field reference for the Sales Profitability dataset.

## Transaction Data Fields

### Core Order Information

**order_id** (String)
- Unique identifier for each transaction
- Format: ORD001 - ORD100
- Use: Primary key, transaction tracking

**customer_id** (String)
- Unique customer identifier
- Format: CUST001 - CUST092
- Use: Linking to customer segment, repeat purchase analysis

**order_date** (Date)
- Date transaction was placed
- Format: YYYY-MM-DD
- Range: 2026-01-05 to 2026-04-14
- Use: Trend analysis, time-based aggregations

### Product Information

**product_id** (String)
- Unique product identifier
- Format: PROD001 - PROD076
- Use: Product tracking, profitability by SKU

**product_name** (String)
- Human-readable product name
- Examples: Wireless Headphones, USB-C Cable, Desk Chair
- Use: Product performance analysis, reporting

**category** (String)
- Product category classification
- Values:
  - **Electronics**: Headphones, keyboards, monitors, chargers, docks
  - **Furniture**: Desks, chairs, stands, organizers, shelves
  - **Accessories**: Cables, cases, mounts, pads, organizers
- Use: Category-level profitability, segment analysis

**quantity** (Integer)
- Number of units purchased in single order
- Range: 1-12
- Use: Volume analysis, average order size

### Pricing & Financial

**unit_price** (Decimal)
- Price per individual unit
- Range: $3.99 - $449.99
- Use: Pricing analysis, revenue calculations

**discount_percent** (Decimal)
- Percentage discount applied to order
- Range: 0 - 25%
- Common values: 0%, 5%, 10%, 15%, 20%
- Use: Discount impact analysis, margin analysis

**shipping_cost** (Decimal)
- Shipping charge
- Range: $2.00 - $60.00
- Use: Operational cost analysis, profitability

**tax** (Decimal)
- Sales tax amount
- Varies by region and product
- Use: Net revenue calculations

**order_total** (Decimal)
- Total customer payment
- Calculation: (unit_price × quantity × (1 - discount)) + shipping + tax
- Use: AOV (Average Order Value) analysis

**revenue** (Decimal)
- Net revenue from transaction
- Calculation: (unit_price × quantity × (1 - discount)) + shipping + tax - (cost-related adjustments)
- Use: Revenue tracking, profitability baseline

**cost_of_goods** (Decimal)
- Cost to acquire/produce item
- Range: $2.00 - $200.00
- Use: Profit calculations, margin analysis

### Customer Segmentation

**customer_segment** (String)
- Customer classification based on value/behavior
- Values:
  - **Premium**: High-value customers, average order value $150+, loyal
  - **Standard**: Regular customers, moderate order values
  - **Budget**: Price-sensitive, lower average order values
- Use: Segment-level profitability, targeted analysis

**payment_method** (String)
- Method used for payment
- Values:
  - Credit Card (most common)
  - PayPal
  - Debit Card
  - Wire Transfer
- Use: Payment risk analysis, regional patterns

### Geographic Information

**region** (String)
- Geographic region where customer is located
- Values:
  - **North America**: USA, Canada
  - **Europe**: EU countries, UK
  - **Asia**: Asian markets
- Use: Regional performance comparison, market analysis

### Delivery & Fulfillment

**delivery_date** (Date)
- Expected or actual delivery date
- Format: YYYY-MM-DD
- Use: Delivery timeline analysis

**days_to_delivery** (Integer)
- Number of days from order to delivery
- Range: 0 - 16 days
- Common ranges:
  - 0-3 days: Express
  - 4-7 days: Standard
  - 8-14 days: Standard+
  - 15+ days: Delayed
- Use: Delivery performance, return correlation

**return_status** (String)
- Whether order was returned
- Values: Yes, No
- Use: Return rate calculation, quality analysis

**return_date** (Date)
- Date item was returned
- Null if not returned
- Use: Return timeline analysis, RMA processing

## Calculated Fields (Generated During Analysis)

### Profitability Metrics

**profit** (Decimal)
- Calculated: revenue - cost_of_goods
- Interpretation: Absolute profit contribution
- Use: Product profitability ranking

**profit_margin** (Decimal)
- Calculated: (profit / revenue) × 100
- Range: 2% - 35%
- Interpretation: Profit as percentage of revenue
- Use: Margin analysis, price optimization

**is_returned** (Binary)
- Calculated: 1 if return_status = 'Yes', else 0
- Use: Return rate aggregation, quality metrics

### Temporal Fields

**order_month** (String)
- Calculated: Format YYYY-MM from order_date
- Values: 2026-01 through 2026-04
- Use: Monthly trend analysis, period-over-period comparison

**order_year_month** (String)
- Alternative format for order_month
- Use: Time series analysis, reporting

## Data Quality Notes

### Data Ranges & Distributions

**Sample Size**: 100 transactions

**Date Range**: 2026-01-05 to 2026-04-14 (129 days)

**Customer Unique Count**: 92 distinct customers
- 7 repeat customers (highest: 8 orders)
- Customer 001 has 8 orders (highest value repeat customer)

**Product Count**: 76 unique products

**Category Distribution**:
- Electronics: ~40 products (40% of catalog)
- Furniture: ~20 products (25% of catalog)
- Accessories: ~36 products (35% of catalog)

**Return Rate**: 10% (10 of 100 orders returned)

**Discount Distribution**:
- No discount: 40 orders
- 5-10% discount: 35 orders
- 15-20% discount: 20 orders
- 25% discount: 5 orders

### Data Validation Rules

✓ All order_ids are unique
✓ All dates are chronologically valid
✓ Revenue > 0 for all records
✓ Profit margin between -50% and 90% (legitimate range)
✓ Quantity ≥ 1 for all records
✓ Discount percent 0-100
✓ Return dates only populated when return_status = 'Yes'

### Missing Data

No missing values in raw dataset. All fields are complete.

## Analysis Use Cases

### Revenue Analysis
- Use: revenue, order_date, region, customer_segment
- Example: "Total Q1 revenue by segment"

### Profitability Analysis
- Use: profit, profit_margin, cost_of_goods, quantity
- Example: "Top 10 products by profit margin"

### Customer Behavior
- Use: customer_id, customer_segment, order_date, revenue
- Example: "Customer lifetime value by segment"

### Operational Efficiency
- Use: days_to_delivery, return_status, shipping_cost
- Example: "Impact of delivery time on returns"

### Product Performance
- Use: product_name, category, quantity, profit_margin
- Example: "Category profitability comparison"

### Regional Comparison
- Use: region, revenue, profit, return_status
- Example: "Revenue per customer by region"

## Data Standards

### Date Format
YYYY-MM-DD (ISO 8601)

### Currency
USD ($) - Assumed for all monetary values

### Percentage Format
0-100 scale (e.g., 10 = 10%)

### Aggregation Guidelines
- Use SUM for: revenue, profit, quantity, cost_of_goods
- Use COUNT for: order_id, customer_id (distinct)
- Use AVG for: profit_margin, unit_price, revenue per transaction
- Use MAX/MIN for: pricing ranges, delivery times

---

**Document Version**: 1.0
**Last Updated**: 2026-05-04
