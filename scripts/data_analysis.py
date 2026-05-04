"""
Sales Profitability Data Analysis
Analyze customer behavior, product performance, and revenue trends
"""

import pandas as pd
import numpy as np
from datetime import datetime
import warnings
warnings.filterwarnings('ignore')

# Configuration
DATA_FILE = 'data/raw_sales_data.csv'
OUTPUT_DIR = 'data/cleaned'

class SalesProfitabilityAnalyzer:
    """Analyze sales data for profitability insights"""
    
    def __init__(self, data_file):
        """Initialize analyzer and load data"""
        self.df = pd.read_csv(data_file)
        self.cleaned_df = None
        self.summary_stats = {}
        
    def inspect_data(self):
        """Inspect raw data quality and structure"""
        print("=" * 80)
        print("DATA INSPECTION REPORT")
        print("=" * 80)
        print(f"\nDataset Shape: {self.df.shape[0]} rows, {self.df.shape[1]} columns")
        print(f"\nData Types:\n{self.df.dtypes}")
        print(f"\nMissing Values:\n{self.df.isnull().sum()}")
        print(f"\nFirst 5 Rows:\n{self.df.head()}")
        
    def clean_data(self):
        """Clean and transform raw data"""
        print("\n" + "=" * 80)
        print("DATA CLEANING")
        print("=" * 80)
        
        self.cleaned_df = self.df.copy()
        
        # Convert date columns to datetime
        date_cols = ['order_date', 'delivery_date', 'return_date']
        for col in date_cols:
            if col in self.cleaned_df.columns:
                self.cleaned_df[col] = pd.to_datetime(self.cleaned_df[col], errors='coerce')
        
        # Calculate profit margin
        self.cleaned_df['profit'] = self.cleaned_df['revenue'] - self.cleaned_df['cost_of_goods']
        self.cleaned_df['profit_margin'] = (self.cleaned_df['profit'] / self.cleaned_df['revenue'] * 100).round(2)
        
        # Extract order month and year
        self.cleaned_df['order_month'] = self.cleaned_df['order_date'].dt.to_period('M')
        self.cleaned_df['order_year_month'] = self.cleaned_df['order_date'].dt.strftime('%Y-%m')
        
        # Return rate flag
        self.cleaned_df['is_returned'] = self.cleaned_df['return_status'].apply(lambda x: 1 if x == 'Yes' else 0)
        
        print(f"✓ Cleaned dataset: {self.cleaned_df.shape[0]} rows")
        print(f"✓ Added calculated columns: profit, profit_margin, is_returned")
        print(f"✓ Date columns converted to datetime format")
        
        return self.cleaned_df
    
    def analyze_customer_behavior(self):
        """Analyze customer segments and behavior"""
        print("\n" + "=" * 80)
        print("CUSTOMER BEHAVIOR ANALYSIS")
        print("=" * 80)
        
        # Customer segment analysis
        segment_stats = self.cleaned_df.groupby('customer_segment').agg({
            'order_id': 'count',
            'revenue': ['sum', 'mean'],
            'profit': ['sum', 'mean'],
            'profit_margin': 'mean',
            'is_returned': 'sum'
        }).round(2)
        segment_stats.columns = ['Order_Count', 'Total_Revenue', 'Avg_Order_Value', 
                                  'Total_Profit', 'Avg_Profit', 'Avg_Margin_%', 'Returns']
        
        print("\n📊 Customer Segment Performance:")
        print(segment_stats)
        self.summary_stats['customer_segments'] = segment_stats
        
        # Customer lifetime value (repeat customers)
        customer_ltv = self.cleaned_df.groupby('customer_id').agg({
            'order_id': 'count',
            'revenue': 'sum',
            'profit': 'sum',
            'customer_segment': 'first'
        }).rename(columns={'order_id': 'Order_Count', 'revenue': 'LTV_Revenue', 
                           'profit': 'LTV_Profit', 'customer_segment': 'Segment'})
        customer_ltv = customer_ltv.sort_values('LTV_Revenue', ascending=False)
        
        print("\n💰 Top 10 Customers by Lifetime Value:")
        print(customer_ltv.head(10))
        self.summary_stats['top_customers'] = customer_ltv.head(10)
        
        return segment_stats, customer_ltv
    
    def analyze_product_performance(self):
        """Analyze product categories and individual product metrics"""
        print("\n" + "=" * 80)
        print("PRODUCT PERFORMANCE ANALYSIS")
        print("=" * 80)
        
        # Category performance
        category_stats = self.cleaned_df.groupby('category').agg({
            'order_id': 'count',
            'quantity': 'sum',
            'revenue': ['sum', 'mean'],
            'profit': ['sum', 'mean'],
            'profit_margin': 'mean',
            'is_returned': 'mean'
        }).round(2)
        category_stats.columns = ['Orders', 'Units_Sold', 'Total_Revenue', 'Avg_Order_Value',
                                   'Total_Profit', 'Avg_Profit', 'Avg_Margin_%', 'Return_Rate_%']
        category_stats['Return_Rate_%'] = (category_stats['Return_Rate_%'] * 100).round(2)
        
        print("\n📦 Category Performance:")
        print(category_stats)
        self.summary_stats['categories'] = category_stats
        
        # Top products by profit
        product_stats = self.cleaned_df.groupby('product_name').agg({
            'order_id': 'count',
            'quantity': 'sum',
            'revenue': 'sum',
            'profit': 'sum',
            'profit_margin': 'mean',
            'category': 'first'
        }).rename(columns={'order_id': 'Orders', 'quantity': 'Units', 
                           'revenue': 'Revenue', 'profit': 'Profit',
                           'profit_margin': 'Margin_%', 'category': 'Category'})
        product_stats = product_stats.sort_values('Profit', ascending=False)
        
        print("\n⭐ Top 10 Products by Profit:")
        print(product_stats.head(10))
        self.summary_stats['top_products'] = product_stats.head(10)
        
        return category_stats, product_stats
    
    def analyze_revenue_trends(self):
        """Analyze revenue trends over time"""
        print("\n" + "=" * 80)
        print("REVENUE TREND ANALYSIS")
        print("=" * 80)
        
        # Monthly trends
        monthly_stats = self.cleaned_df.groupby('order_year_month').agg({
            'order_id': 'count',
            'revenue': ['sum', 'mean'],
            'profit': ['sum', 'mean'],
            'profit_margin': 'mean'
        }).round(2)
        monthly_stats.columns = ['Orders', 'Total_Revenue', 'Avg_Order_Value', 
                                  'Total_Profit', 'Avg_Profit', 'Avg_Margin_%']
        
        print("\n📈 Monthly Revenue Trends:")
        print(monthly_stats)
        self.summary_stats['monthly_trends'] = monthly_stats
        
        # Regional analysis
        regional_stats = self.cleaned_df.groupby('region').agg({
            'order_id': 'count',
            'revenue': ['sum', 'mean'],
            'profit': ['sum', 'mean'],
            'profit_margin': 'mean',
            'is_returned': 'mean'
        }).round(2)
        regional_stats.columns = ['Orders', 'Total_Revenue', 'Avg_Order_Value',
                                   'Total_Profit', 'Avg_Profit', 'Avg_Margin_%', 'Return_Rate_%']
        regional_stats['Return_Rate_%'] = (regional_stats['Return_Rate_%'] * 100).round(2)
        
        print("\n🌍 Regional Performance:")
        print(regional_stats)
        self.summary_stats['regions'] = regional_stats
        
        return monthly_stats, regional_stats
    
    def analyze_operational_metrics(self):
        """Analyze delivery and operational efficiency"""
        print("\n" + "=" * 80)
        print("OPERATIONAL METRICS")
        print("=" * 80)
        
        # Delivery time analysis
        avg_delivery_days = self.cleaned_df['days_to_delivery'].mean()
        print(f"\n⏱️  Average Delivery Time: {avg_delivery_days:.1f} days")
        
        # Return analysis
        total_returns = self.cleaned_df['is_returned'].sum()
        return_rate = (total_returns / len(self.cleaned_df) * 100)
        print(f"📦 Total Returns: {total_returns} ({return_rate:.1f}%)")
        
        # Payment method analysis
        payment_stats = self.cleaned_df.groupby('payment_method').agg({
            'order_id': 'count',
            'revenue': 'sum',
            'is_returned': 'sum'
        }).round(2)
        payment_stats.columns = ['Orders', 'Revenue', 'Returns']
        print(f"\n💳 Payment Method Distribution:")
        print(payment_stats)
        
        return avg_delivery_days, return_rate, payment_stats
    
    def generate_recommendations(self):
        """Generate actionable recommendations"""
        print("\n" + "=" * 80)
        print("KEY RECOMMENDATIONS FOR IMPROVING PROFITABILITY")
        print("=" * 80)
        
        # Find low-margin products
        low_margin_products = self.cleaned_df.groupby('product_name')['profit_margin'].mean().sort_values()
        print(f"\n⚠️  LOW MARGIN PRODUCTS (consider pricing/cost strategy):")
        for product, margin in low_margin_products.head(5).items():
            print(f"   • {product}: {margin:.1f}% margin")
        
        # High-return products
        high_return_products = self.cleaned_df[self.cleaned_df['is_returned'] == 1].groupby('product_name')['order_id'].count().sort_values(ascending=False)
        if len(high_return_products) > 0:
            print(f"\n🔄 HIGH RETURN PRODUCTS (quality/description issues?):")
            for product, count in high_return_products.head(5).items():
                print(f"   • {product}: {count} returns")
        
        # Best performing segments
        top_segment = self.cleaned_df.groupby('customer_segment')['profit_margin'].mean().idxmax()
        print(f"\n✨ HIGHEST MARGIN SEGMENT: {top_segment}")
        
        # Regional opportunities
        top_region = self.cleaned_df.groupby('region')['revenue'].sum().idxmax()
        print(f"\n🎯 HIGHEST REVENUE REGION: {top_region}")
        
    def save_cleaned_data(self):
        """Save cleaned dataset"""
        import os
        os.makedirs(OUTPUT_DIR, exist_ok=True)
        output_file = f"{OUTPUT_DIR}/cleaned_sales_data.csv"
        self.cleaned_df.to_csv(output_file, index=False)
        print(f"\n✅ Cleaned data saved to: {output_file}")
        
    def run_full_analysis(self):
        """Run complete analysis pipeline"""
        print("\n🚀 Starting Sales Profitability Analysis...\n")
        
        self.inspect_data()
        self.clean_data()
        self.analyze_customer_behavior()
        self.analyze_product_performance()
        self.analyze_revenue_trends()
        self.analyze_operational_metrics()
        self.generate_recommendations()
        self.save_cleaned_data()
        
        print("\n" + "=" * 80)
        print("✅ ANALYSIS COMPLETE")
        print("=" * 80)

if __name__ == "__main__":
    # Run the analysis
    analyzer = SalesProfitabilityAnalyzer(DATA_FILE)
    analyzer.run_full_analysis()
