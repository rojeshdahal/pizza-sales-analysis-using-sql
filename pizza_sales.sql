-- Retrieve the total number of orders placed.

select count(order_id) as total_orders from orders;

-- Calculate the total revenue generated from pizza sales. 

SELECT 
    SUM(order_details.quantity * pizzas.price) AS total_sales
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;

-- Identify the highest-priced pizza.
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.

SELECT 
    pizzas.size, COUNT(order_details.order_details_id) as order_count
FROM
    pizzas
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;

-- List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.name, COUNT(order_details.quantity) AS quantity
FROM
    pizzas
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;


-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pizza_types.category, SUM(order_details.quantity)
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category;

-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time), COUNT(order_id)
FROM
    orders
GROUP BY HOUR(order_time);


-- Group the orders by date and calculate the average number of pizzas ordered per days
SELECT 
    AVG(quantity)
FROM
    (SELECT 
        DATE(orders.order_date),
            SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY DATE(order_date)) AS order_quantity;
    
    -- Determine the top 3 most ordered pizza types based on revenue.
   SELECT 
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;
    
-- Calculate the percentage contribution of each pizza type to total revenue.

   SELECT 
    pizza_types.category,
    round(SUM(order_details.quantity * pizzas.price) / (SELECT 
    SUM(order_details.quantity * pizzas.price) AS total_sales
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id) * 100,2)  as revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;

-- Analyze the cumulative revenue generated over time.

select order_date, sum(revenue) over (order by order_date) as cum_revenue from  
(select orders.order_date, sum(order_details.quantity * pizzas.price) as revenue
from orders
join order_details 
on orders.order_id = order_details.order_id 
join pizzas
on order_details.pizza_id = pizzas.pizza_id
group by orders.order_date) as sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select category, name, revenue from(
Select category, name, revenue, rank() over (partition by category order by revenue desc) as rev
from 
 (SELECT 
    pizza_types.category,
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category, pizza_types.name) as a) as b
where rev<=3;

-- Join tables to get full order details.
select orders.order_id, order_details.pizza_id, pizza_types.name, pizza_types.category, pizzas.size, pizzas.price, order_details.quantity 
from orders
join order_details
on orders.order_id = order_details.order_id
join pizzas
on order_details.pizza_id = pizzas.pizza_id
join pizza_types 
on pizzas.pizza_type_id = pizza_types.pizza_type_id;

-- Find month-over-month revenue growth
select month(orders.order_date), sum(order_details.quantity*pizzas.price)
from orders
join order_details
on orders.order_id = order_details.order_id
join pizzas
on order_details.pizza_id = pizzas.pizza_id
join pizza_types 
on pizzas.pizza_type_id = pizza_types.pizza_type_id
group by month(orders.order_date)
;

 