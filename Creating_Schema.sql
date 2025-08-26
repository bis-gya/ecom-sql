-- ===============================================
-- E-commerce Training Dataset (PostgreSQL)
-- Creates a fresh schema and loads sample data
-- ===============================================

DROP SCHEMA IF EXISTS training_ecom CASCADE;
CREATE SCHEMA training_ecom;


-- ---------- Tables ----------
CREATE TABLE customers (
    customer_id      SERIAL PRIMARY KEY,
    full_name        VARCHAR(100) NOT NULL,
    city             VARCHAR(60)  NOT NULL,
    signup_date      DATE         NOT NULL DEFAULT CURRENT_DATE,
    email            VARCHAR(120) UNIQUE
);

create table products (
    product_id       SERIAL primary key,
    product_name     VARCHAR(100) not null,
    category         VARCHAR(60) not null,
    unit_price       NUMERIC(10,2) not null check(unit_price > 0),
    active           BOOLEAN not null default TRUE
);

CREATE TABLE orders (
    order_id    SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES training_ecom.customers(customer_id),
    order_date  TIMESTAMP NOT NULL,
    status      VARCHAR(20) NOT NULL CHECK (status IN ('placed','shipped','delivered','cancelled'))
);

CREATE TABLE order_items (
    order_id   INT NOT NULL REFERENCES training_ecom.orders(order_id) ON DELETE CASCADE,
    product_id INT NOT NULL REFERENCES training_ecom.products(product_id),
    quantity   INT NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price > 0),
    CONSTRAINT pk_order_items PRIMARY KEY (order_id, product_id)
);

CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    order_id   INT NOT NULL REFERENCES training_ecom.orders(order_id) ON DELETE CASCADE,
    amount     NUMERIC(10,2) NOT NULL CHECK (amount > 0),
    method     VARCHAR(20) NOT NULL CHECK (method IN ('card','cash','wallet')),
    paid_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
