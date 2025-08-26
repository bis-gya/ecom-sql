/* 1. **Create View: `vw_recent_orders_30d`**
   - View of orders placed in the **last 30 days** from `CURRENT_DATE`, excluding `cancelled`.
   - Columns: order_id, customer_id, order_date, status, order_total (sum of items). */

CREATE OR REPLACE VIEW training_ecom.vw_recent_orders_30d AS
SELECT 
    o.order_id,
    o.customer_id,
    o.order_date,
    o.status,
    SUM(oi.quantity * oi.unit_price) AS order_total
FROM training_ecom.orders o
JOIN training_ecom.order_items oi 
    ON o.order_id = oi.order_id
WHERE o.status <> 'cancelled'
  AND o.order_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY o.order_id, o.customer_id, o.order_date, o.status;


/* 2. **Products Never Ordered**
   - Using a subquery, list products that **never** appear in `order_items`. */

SELECT p.product_id, p.product_name, p.category
FROM training_ecom.products p
LEFT JOIN training_ecom.order_items oi 
       ON p.product_id = oi.product_id
WHERE oi.product_id IS NULL;


/* 3. **Top Category by City**
   - For each `city`, find the **single category** with the highest total revenue. Use an inner subquery or a view plus a filter on rank. */

SELECT city, category, total_revenue
FROM (
    SELECT
        c.city,
        p.category,
        SUM(oi.quantity * oi.unit_price) AS total_revenue,
        RANK() OVER (
            PARTITION BY c.city 
            ORDER BY SUM(oi.quantity * oi.unit_price) DESC
        ) AS revenue_rank
    FROM training_ecom.customers c
    JOIN training_ecom.orders o 
        ON c.customer_id = o.customer_id
    JOIN training_ecom.order_items oi 
        ON o.order_id = oi.order_id
    JOIN training_ecom.products p 
        ON oi.product_id = p.product_id
    GROUP BY c.city, p.category
) t
WHERE revenue_rank = 1;



/* 4. **Customers Without Delivered Orders**
   - Using `NOT EXISTS`, list customers who have **no orders** with status `delivered`. */ 

SELECT c.customer_id, c.full_name, c.city, c.email
FROM training_ecom.customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM training_ecom.orders o
    WHERE o.customer_id = c.customer_id
      AND o.status = 'delivered'
);
