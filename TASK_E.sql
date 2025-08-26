-- 1. **Average Order Value by City (Delivered Only)** Output: city, avg_order_value, delivered_orders_count. Order by `avg_order_value` desc. Use `HAVING` to keep cities with at least 2 delivered orders.

SELECT c.city,
    AVG(oi.quantity * oi.unit_price) AS avg_order_value,
    COUNT(DISTINCT o.order_id) AS delivered_orders_count
FROM training_ecom.customers c
JOIN training_ecom.orders o ON c.customer_id = o.customer_id
JOIN training_ecom.order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'delivered'
GROUP BY c.city
HAVING COUNT(DISTINCT o.order_id) >= 2
ORDER BY avg_order_value DESC;


-- 2. **Category Mix per Customer** For each customer, list categories purchased and the **count of distinct orders** per category. Order by customer and count desc.

SELECT c.customer_id, c.full_name,p.category,
    COUNT(DISTINCT o.order_id) AS orders_per_category
FROM training_ecom.customers c
JOIN training_ecom.orders o ON c.customer_id = o.customer_id
JOIN training_ecom.order_items oi ON o.order_id = oi.order_id
JOIN training_ecom.products p ON oi.product_id = p.product_id
GROUP BY c.customer_id, c.full_name, p.category
ORDER BY c.customer_id, orders_per_category DESC;



--3. **Set Ops: Overlapping Customers** Split customers into two sets: those who bought `Electronics` and those who bought `Fitness`. Show:- `UNION` of both sets, - `INTERSECT` (bought both), - `EXCEPT` (bought Electronics but not Fitness).

--Customer who bought Electronics

SELECT DISTINCT c.customer_id
FROM training_ecom.customers c
JOIN training_ecom.orders o
    ON c.customer_id = o.customer_id
JOIN training_ecom.order_items oi
    ON o.order_id = oi.order_id
JOIN training_ecom.products p
    ON oi.product_id = p.product_id
WHERE p.category = 'Electronics';

--Customer who bought Fitness

SELECT DISTINCT c.customer_id
FROM training_ecom.customers c
JOIN training_ecom.orders o
    ON c.customer_id = o.customer_id
JOIN training_ecom.order_items oi
    ON o.order_id = oi.order_id
JOIN training_ecom.products p
    ON oi.product_id = p.product_id
WHERE p.category = 'Fitness';

--Union who bought Electronics OR Fitness

SELECT DISTINCT c.customer_id
FROM training_ecom.customers c
JOIN training_ecom.orders o ON c.customer_id = o.customer_id
JOIN training_ecom.order_items oi ON o.order_id = oi.order_id
JOIN training_ecom.products p ON oi.product_id = p.product_id
WHERE p.category IN ('Electronics','Fitness');

-- Intersect who bought both

SELECT c.customer_id
FROM training_ecom.customers c
JOIN training_ecom.orders o ON c.customer_id = o.customer_id
JOIN training_ecom.order_items oi ON o.order_id = oi.order_id
JOIN training_ecom.products p ON oi.product_id = p.product_id
WHERE p.category = 'Electronics'

INTERSECT

SELECT c.customer_id
FROM training_ecom.customers c
JOIN training_ecom.orders o ON c.customer_id = o.customer_id
JOIN training_ecom.order_items oi ON o.order_id = oi.order_id
JOIN training_ecom.products p ON oi.product_id = p.product_id
WHERE p.category = 'Fitness';

-- Except bought Electronics but not Fitness

SELECT c.customer_id
FROM training_ecom.customers c
JOIN training_ecom.orders o ON c.customer_id = o.customer_id
JOIN training_ecom.order_items oi ON o.order_id = oi.order_id
JOIN training_ecom.products p ON oi.product_id = p.product_id
WHERE p.category = 'Electronics'

EXCEPT

SELECT c.customer_id
FROM training_ecom.customers c
JOIN training_ecom.orders o ON c.customer_id = o.customer_id
JOIN training_ecom.order_items oi ON o.order_id = oi.order_id
JOIN training_ecom.products p ON oi.product_id = p.product_id
WHERE p.category = 'Fitness';