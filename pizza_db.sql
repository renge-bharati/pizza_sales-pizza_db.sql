create database Pizza_db;
use pizza_db;
select * from order_details;
select * from orders;
select * from pizza_types;
select * from pizzas;

--  1.	Retrieve the total number of orders placed. 
select count(*) as total_order from orders;

-- 2.2.	Calculate the total revenue generated from pizza sales. 
SELECT ROUND(SUM(oi.quantity * p.price), 2) AS total_revenue
FROM order_details oi
JOIN pizzas p ON oi.pizza_id = p.pizza_id;


-- 3.	Identify the highest-priced pizza. 
select * from pizzas order by price DESC limit 1;

-- 4  Identify the most common pizza size ordered.
SELECT size, COUNT(size) AS total_orders
FROM pizzas p
JOIN order_details od ON p.pizza_id = od.pizza_id
GROUP BY size
ORDER BY total_orders DESC
LIMIT 1; 

-- 5.	List the top 5 most ordered pizza types along with their quantities. 
SELECT pt.name AS pizza_type, SUM(oi.quantity) AS total_quantity
FROM order_details oi
JOIN pizzas p ON oi.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_quantity DESC
LIMIT 5;

-- 1.	Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT pt.category, SUM(oi.quantity) AS total_quantity
FROM order_details oi
JOIN pizzas p ON oi.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY total_quantity DESC;

-- 2.	Determine the distribution of orders by hour of the day. 
SELECT DATE(o.date) AS order_day, SUM(oi.quantity) AS total_pizzas
FROM orders o
JOIN order_details oi ON o.order_id = oi.order_id
GROUP BY order_day
ORDER BY order_day;


-- 3.	Join relevant tables to find the category-wise distribution of pizzas.
SELECT pt.category, pt.name AS pizza_type, SUM(oi.quantity) AS total_quantity
FROM order_details oi
JOIN pizzas p ON oi.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category, pt.name
ORDER BY pt.category, total_quantity DESC;
 
 -- 4.	Group the orders by date and calculate the average number of pizzas ordered per day. 
 SELECT AVG(daily.total_pizzas) AS avg_pizzas_per_day
FROM (
  SELECT DATE(o.date) AS order_day, SUM(oi.quantity) AS total_pizzas
  FROM orders o
  JOIN order_details oi ON o.order_id = oi.order_id
  GROUP BY order_day
) AS daily;

 -- 5.	Determine the top 3 most ordered pizza types based on revenue. 
SELECT pt.name AS pizza_type, ROUND(SUM(oi.quantity * p.price), 2) AS total_revenue
FROM order_details oi
JOIN pizzas p ON oi.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_revenue DESC
LIMIT 3;

-- 1.	Calculate the percentage contribution of each pizza type to total revenue. 
SELECT 
  pt.name AS pizza_type,
  ROUND(SUM(oi.quantity * p.price) * 100 / 
        (SELECT SUM(oi2.quantity * p2.price)
         FROM order_details oi2
         JOIN pizzas p2 ON oi2.pizza_id = p2.pizza_id), 2) AS percent
FROM order_details oi
JOIN pizzas p ON oi.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name;

-- analyze the cumulative revenue generated over time.
SELECT 
  DATE(o.date) AS order_day,
  SUM(oi.quantity * p.price) AS daily_revenue,
  SUM(SUM(oi.quantity * p.price)) OVER (ORDER BY DATE(o.date)) AS cum_revenue
FROM orders o
JOIN order_details oi ON o.order_id = oi.order_id
JOIN pizzas p ON oi.pizza_id = p.pizza_id
GROUP BY order_day;

 
-- 3.	Determine the top 3 most ordered pizza types based on revenue for each pizza category. 
SELECT *
FROM (
  SELECT 
    pt.category,
    pt.name,
    SUM(oi.quantity * p.price) AS revenue,
    RANK() OVER (PARTITION BY pt.category ORDER BY SUM(oi.quantity * p.price) DESC) AS rnk
  FROM order_details oi
  JOIN pizzas p ON oi.pizza_id = p.pizza_id
  JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
  GROUP BY pt.category, pt.name
) x
WHERE rnk <= 3;


 
