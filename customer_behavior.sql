show databases;
USE customer_behavior;
SELECT * FROM customer;
#generate revenue by male and female
select gender, sum(purchase_amount)as revenue
from customer
group by gender
#customer used a discount and spent avg purchase amt
SELECT customer_id, purchase_amount
FROM customer
WHERE discount_applied = 'yes'
AND purchase_amount >= (
    SELECT AVG(purchase_amount) FROM customer
);
# average product rating
SELECT 
    item_purchased,
    ROUND(AVG(CAST(review_rating AS DECIMAL(10,2))), 2) AS "Average Product Rating"
FROM customer
GROUP BY item_purchased
ORDER BY AVG(CAST(review_rating AS DECIMAL(10,2))) DESC
LIMIT 5;

#compare std and express shipping by purchase amount
select shipping_type, 
ROUND(AVG(purchase_amount),2)
from customer
where shipping_type in ('Standard','Express')
group by shipping_type;

# who purchases more subscribe and non subscribrs
SELECT subscription_status,
       COUNT(customer_id) AS total_customers,
       ROUND(AVG(purchase_amount),2) AS avg_spend,
       ROUND(SUM(purchase_amount),2) AS total_revenue
FROM customer
GROUP BY subscription_status
ORDER BY total_revenue,avg_spend DESC;

#higest purchases by applied discount

SELECT item_purchased,

# new, returing,loyal customer check
with customer_type as (
SELECT customer_id, previous_purchases,
CASE 
    WHEN previous_purchases = 1 THEN 'New'
    WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
    ELSE 'Loyal'
    END AS customer_segment
FROM customer)

select customer_segment,count(*) AS "Number of Customers" 
from customer_type 
group by customer_segment;


#3 most purchased products within each categor
WITH item_counts AS (
    SELECT category,
           item_purchased,
           COUNT(customer_id) AS total_orders,
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY COUNT(customer_id) DESC) AS item_rank
    FROM customer
    GROUP BY category, item_purchased
)
SELECT item_rank,category, item_purchased, total_orders
FROM item_counts
WHERE item_rank <=3;

#repeat buyers (more than 5 previous purchases) also likely to subscribe

SELECT subscription_status,
       COUNT(customer_id) AS repeat_buyers
FROM customer
WHERE previous_purchases > 5
GROUP BY subscription_status;


#revenue contribution of each age group
SELECT 
    age_group,
    SUM(purchase_amount) AS total_revenue
FROM customer
GROUP BY age_group
ORDER BY total_revenue desc;

