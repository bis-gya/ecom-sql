/* 1. **Monthly Customer Rank by Spend**
   - For each month (based on `order_date`), rank customers by **total order value** in that month using `RANK()`.
   - Output: month (YYYY-MM), customer_id, total_monthly_spend, rank_in_month. */

SELECT  month, customer_id, monthly_spend,
    RANK() OVER (PARTITION BY month ORDER BY monthly_spend DESC) AS rank_in_month

FROM(
    SELECT 
        o.customer_id,
        DATE_TRUNC('month', o.order_date) AS month,
        SUM(oi.quantity * oi.unit_price) AS monthly_spend
    FROM training_ecom.orders o
    JOIN training_ecom.order_items oi ON o.order_id = oi.order_id
    GROUP BY o.customer_id, DATE_TRUNC('month', o.order_date)
) t;



/* 2. **Share of Basket per Item**
   - For each order, compute each item's **revenue share** in that order:
     `item_revenue / order_total` using `SUM() OVER (PARTITION BY order_id)`. */

select order_id, product_id, quantity,unit_price,
    (quantity * unit_price) AS item_revenue,

    -- Window function: order total
    SUM(quantity * unit_price) OVER (PARTITION BY order_id) AS order_total,

    -- Share of basket
    (quantity * unit_price)::numeric / SUM(quantity * unit_price) OVER (PARTITION BY order_id) AS revenue_share
FROM training_ecom.order_items;


/* 3. **Time Between Orders (per Customer)**
   - Show days since the **previous order** for each customer using `LAG(order_date)` and `AGE()`.*/

select customer_id, order_id, order_date,

    -- Previous order date for the same customer
    LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS prev_order_date,

    -- Days since previous order
    AGE(order_date, LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date)) AS days_since_prev_order
FROM training_ecom.orders
ORDER BY customer_id, order_date;

/* 4. **Product Revenue Quartiles**
   - Compute total revenue per product and assign **quartiles** using `NTILE(4)` over total revenue.*/

SELECT product_id,total_revenue,
CASE NTILE(4) OVER (ORDER BY total_revenue DESC)
   WHEN 1 THEN 'Top 25%'
   WHEN 2 THEN 'Second 25%'
   WHEN 3 THEN 'Third 25%'
   WHEN 4 THEN 'Bottom 25%'
END AS revenue_group
FROM (
    SELECT 
        product_id,
        SUM(quantity * unit_price) AS total_revenue
    FROM training_ecom.order_items
    GROUP BY product_id
) AS t;


/*5. **First and Last Purchase Category per Customer**
   - For each customer, show the **first** and **most recent** product category they've bought using `FIRST_VALUE` and `LAST_VALUE` over `order_date`.*/

SELECT DISTINCT
    customer_id,
    FIRST_VALUE(category) OVER (
        PARTITION BY customer_id 
        ORDER BY order_date ASC
    ) AS first_category,
    LAST_VALUE(category) OVER (
        PARTITION BY customer_id 
        ORDER BY order_date ASC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS last_category

    FROM (
    SELECT 
        c.customer_id,
        o.order_date,
        p.category
    FROM training_ecom.customers c
    JOIN training_ecom.orders o 
        ON c.customer_id = o.customer_id
    JOIN training_ecom.order_items oi 
        ON o.order_id = oi.order_id
    JOIN training_ecom.products p 
        ON oi.product_id = p.product_id
) t;
