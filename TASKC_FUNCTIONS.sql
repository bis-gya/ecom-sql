/* 1. **Scalar Function: `fn_customer_lifetime_value(customer_id)`**
    - Return total **paid** amount for the customer's delivered/shipped/placed (non-cancelled) orders.*/

CREATE OR REPLACE FUNCTION training_ecom.fn_customer_lifetime_value(p_customer_id INT)
RETURNS NUMERIC(12,2) AS
$$
DECLARE
    total_amount NUMERIC(12,2);
BEGIN
    SELECT SUM(amount)
    INTO total_amount
    FROM training_ecom.payments pay
    JOIN training_ecom.orders o ON pay.order_id = o.order_id
    WHERE o.customer_id = p_customer_id
      AND o.status <> 'cancelled';

    -- Return 0 if customer has no orders/payments
    RETURN COALESCE(total_amount, 0);
END;
$$
LANGUAGE plpgsql;


--USE THE ABOVE FUNCTION

SELECT training_ecom.fn_customer_lifetime_value(1) AS lifetime_value;


/*2. **Table Function: `fn_recent_orders(p_days INT)`**
    - Return `order_id, customer_id, order_date, status, order_total` for orders in the last `p_days` days.*/


CREATE OR REPLACE FUNCTION training_ecom.fn_recent_orders(p_days INT)
RETURNS TABLE (
    order_id INT,
    customer_id INT,
    order_date TIMESTAMP,
    status VARCHAR,
    order_total NUMERIC(12,2)
) AS
$$
BEGIN
    RETURN QUERY
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
      AND o.order_date >= CURRENT_DATE - (p_days || ' days')::interval
    GROUP BY o.order_id, o.customer_id, o.order_date, o.status;
END;
$$
LANGUAGE plpgsql;

--USE THE ABOVE FUNCTION

SELECT * FROM training_ecom.fn_recent_orders(10);


/* 3. **Utility Function: `fn_title_case_city(text)`**
    - Return city name with first letter of each word capitalized (hint: split/upper/lower or use `initcap()` in PostgreSQL).*/

CREATE OR REPLACE FUNCTION training_ecom.fn_title_case_city(p_city TEXT)
RETURNS TEXT AS
$$
BEGIN
    RETURN initcap(p_city);
END;
$$
LANGUAGE plpgsql;

--uSE THE ABOVE FUNCTION

SELECT training_ecom.fn_title_case_city('biratnagar city') AS city_formatted;
