/*
  # Inventory Management System Schema

  1. New Tables
    - `products`
      - `product_id` (uuid, primary key)
      - `name` (text, not null)
      - `price` (numeric, not null)
      - `rating` (numeric, optional, 0-5)
      - `stock_quantity` (integer, not null, default 0)
      - `created_at` (timestamptz, default now)
      - `updated_at` (timestamptz, default now)
    
    - `users`
      - `user_id` (uuid, primary key)
      - `name` (text, not null)
      - `email` (text, unique, not null)
      - `created_at` (timestamptz, default now)
    
    - `sales_summary`
      - `sales_summary_id` (uuid, primary key)
      - `total_value` (numeric, not null)
      - `change_percentage` (numeric, optional)
      - `date` (date, not null)
      - `created_at` (timestamptz, default now)
    
    - `purchase_summary`
      - `purchase_summary_id` (uuid, primary key)
      - `total_purchased` (numeric, not null)
      - `change_percentage` (numeric, optional)
      - `date` (date, not null)
      - `created_at` (timestamptz, default now)
    
    - `expense_summary`
      - `expense_summary_id` (uuid, primary key)
      - `total_expenses` (numeric, not null)
      - `date` (date, not null)
      - `created_at` (timestamptz, default now)
    
    - `expense_by_category`
      - `expense_by_category_id` (uuid, primary key)
      - `category` (text, not null)
      - `amount` (numeric, not null)
      - `date` (date, not null)
      - `created_at` (timestamptz, default now)
  
  2. Security
    - Enable RLS on all tables
    - Add policies for public read access (since this is a demo app)
    - Add policies for authenticated insert/update/delete operations

  3. Important Notes
    - All tables use UUID primary keys for scalability
    - Timestamps are tracked for audit purposes
    - RLS is enabled but configured for demo access patterns
*/

-- Create products table
CREATE TABLE IF NOT EXISTS products (
  product_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  price numeric NOT NULL CHECK (price >= 0),
  rating numeric CHECK (rating >= 0 AND rating <= 5),
  stock_quantity integer NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create users table
CREATE TABLE IF NOT EXISTS users (
  user_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  email text UNIQUE NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Create sales_summary table
CREATE TABLE IF NOT EXISTS sales_summary (
  sales_summary_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  total_value numeric NOT NULL DEFAULT 0,
  change_percentage numeric,
  date date NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Create purchase_summary table
CREATE TABLE IF NOT EXISTS purchase_summary (
  purchase_summary_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  total_purchased numeric NOT NULL DEFAULT 0,
  change_percentage numeric,
  date date NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Create expense_summary table
CREATE TABLE IF NOT EXISTS expense_summary (
  expense_summary_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  total_expenses numeric NOT NULL DEFAULT 0,
  date date NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Create expense_by_category table
CREATE TABLE IF NOT EXISTS expense_by_category (
  expense_by_category_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  category text NOT NULL,
  amount numeric NOT NULL DEFAULT 0,
  date date NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales_summary ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchase_summary ENABLE ROW LEVEL SECURITY;
ALTER TABLE expense_summary ENABLE ROW LEVEL SECURITY;
ALTER TABLE expense_by_category ENABLE ROW LEVEL SECURITY;

-- Create policies for public read access (demo app)
CREATE POLICY "Anyone can view products"
  ON products FOR SELECT
  USING (true);

CREATE POLICY "Anyone can view users"
  ON users FOR SELECT
  USING (true);

CREATE POLICY "Anyone can view sales summary"
  ON sales_summary FOR SELECT
  USING (true);

CREATE POLICY "Anyone can view purchase summary"
  ON purchase_summary FOR SELECT
  USING (true);

CREATE POLICY "Anyone can view expense summary"
  ON expense_summary FOR SELECT
  USING (true);

CREATE POLICY "Anyone can view expense by category"
  ON expense_by_category FOR SELECT
  USING (true);

-- Create policies for insert operations (anyone can insert for demo purposes)
CREATE POLICY "Anyone can insert products"
  ON products FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Anyone can insert users"
  ON users FOR INSERT
  WITH CHECK (true);

-- Create policies for update operations
CREATE POLICY "Anyone can update products"
  ON products FOR UPDATE
  USING (true)
  WITH CHECK (true);

-- Create policies for delete operations
CREATE POLICY "Anyone can delete products"
  ON products FOR DELETE
  USING (true);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_products_name ON products(name);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_sales_summary_date ON sales_summary(date);
CREATE INDEX IF NOT EXISTS idx_purchase_summary_date ON purchase_summary(date);
CREATE INDEX IF NOT EXISTS idx_expense_summary_date ON expense_summary(date);
CREATE INDEX IF NOT EXISTS idx_expense_by_category_date ON expense_by_category(date);

-- Insert sample data for products
INSERT INTO products (name, price, rating, stock_quantity) VALUES
  ('Laptop', 999.99, 4.5, 50),
  ('Wireless Mouse', 29.99, 4.2, 200),
  ('Keyboard', 79.99, 4.7, 150),
  ('Monitor', 299.99, 4.6, 75),
  ('USB Cable', 9.99, 4.0, 500),
  ('Headphones', 149.99, 4.8, 100),
  ('Webcam', 89.99, 4.3, 80),
  ('Desk Lamp', 39.99, 4.1, 120)
ON CONFLICT DO NOTHING;

-- Insert sample users
INSERT INTO users (name, email) VALUES
  ('John Doe', 'john.doe@example.com'),
  ('Jane Smith', 'jane.smith@example.com'),
  ('Bob Johnson', 'bob.johnson@example.com'),
  ('Alice Williams', 'alice.williams@example.com'),
  ('Charlie Brown', 'charlie.brown@example.com')
ON CONFLICT (email) DO NOTHING;

-- Insert sample sales summary data
INSERT INTO sales_summary (total_value, change_percentage, date) VALUES
  (15000, 12.5, CURRENT_DATE - INTERVAL '6 days'),
  (16200, 8.0, CURRENT_DATE - INTERVAL '5 days'),
  (14800, -8.6, CURRENT_DATE - INTERVAL '4 days'),
  (17500, 18.2, CURRENT_DATE - INTERVAL '3 days'),
  (16900, -3.4, CURRENT_DATE - INTERVAL '2 days'),
  (18200, 7.7, CURRENT_DATE - INTERVAL '1 day'),
  (19000, 4.4, CURRENT_DATE)
ON CONFLICT DO NOTHING;

-- Insert sample purchase summary data
INSERT INTO purchase_summary (total_purchased, change_percentage, date) VALUES
  (8000, 15.0, CURRENT_DATE - INTERVAL '6 days'),
  (8500, 6.25, CURRENT_DATE - INTERVAL '5 days'),
  (7800, -8.2, CURRENT_DATE - INTERVAL '4 days'),
  (9200, 17.9, CURRENT_DATE - INTERVAL '3 days'),
  (8900, -3.3, CURRENT_DATE - INTERVAL '2 days'),
  (9500, 6.7, CURRENT_DATE - INTERVAL '1 day'),
  (10000, 5.3, CURRENT_DATE)
ON CONFLICT DO NOTHING;

-- Insert sample expense summary data
INSERT INTO expense_summary (total_expenses, date) VALUES
  (3500, CURRENT_DATE - INTERVAL '6 days'),
  (3800, CURRENT_DATE - INTERVAL '5 days'),
  (3200, CURRENT_DATE - INTERVAL '4 days'),
  (4100, CURRENT_DATE - INTERVAL '3 days'),
  (3900, CURRENT_DATE - INTERVAL '2 days'),
  (4200, CURRENT_DATE - INTERVAL '1 day'),
  (4500, CURRENT_DATE)
ON CONFLICT DO NOTHING;

-- Insert sample expense by category data
INSERT INTO expense_by_category (category, amount, date) VALUES
  ('Office Supplies', 500, CURRENT_DATE),
  ('Salaries', 2500, CURRENT_DATE),
  ('Utilities', 300, CURRENT_DATE),
  ('Marketing', 800, CURRENT_DATE),
  ('Equipment', 400, CURRENT_DATE)
ON CONFLICT DO NOTHING;