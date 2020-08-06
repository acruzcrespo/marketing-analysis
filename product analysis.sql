--Query #1
--Count how many users we have

SELECT COUNT(*)
from dsv1069.users
LIMIT 100

--Query #2
--Find out how many users have ever ordered

SELECT count(distinct user_id) as users_with_orders
FROM dsv1069.orders
LIMIT 100

--Query #3
--Goal find how many users have reordered the same item

SELECT COUNT(distinct user_id) as users_who_reordered
FROM
(
select user_id, item_id, 
count(distinct line_item_id) as times_user_ordered
FROM dsv1069.orders
GROUP BY 
user_id,
item_id
) user_level_orders
WHERE
times_user_ordered > 1
LIMIT 100

--Query #4
---Do users even order more than once?

SELECT count(distinct user_id)
FROM
(
SELECT user_id,
COUNT(distinct invoice_id) as order_count
FROM dsv1069.orders
GROUP by 
user_id
) user_level
WHERE order_count > 1
LIMIT 100

--Query #5
--Orders per item

SELECT 
item_id, 
COUNT(line_item_id) as times_ordered
FROM dsv1069.orders
group by item_id
LIMIT 100

--Query #6
--Orders per category

SELECT item_category, 
count(line_item_id) as times_ordered
FROM dsv1069.orders
group by item_category
LIMIT 100

--Query #7
--Do user order multiple things from the same category?

SELECT user_id,
item_category,
COUNT(distinct line_item_id) as times_category_ordered
FROM
dsv1069.orders
GROUP BY
user_id,
item_category
LIMIT 100

--Query #8
--Goal: Find the average time between orders
--Decide if this analysis is necessary

SELECT
first_orders.user_id, 
date(first_orders.paid_at) as first_order_date,
date(second_orders.paid_at) as second_order_date,
date(second_orders.paid_at) - date(first_orders.paid_at) as date_diff
FROM
(
SELECT
user_id, 
invoice_id,
paid_at,
dense_rank() over(partition by user_id order by paid_at ASC)
as order_num
FROM 
dsv1069.orders
) first_orders
JOIN
(
SELECT
user_id, 
invoice_id,
paid_at,
dense_rank () over(partition by user_id order by paid_at ASC) as order_num
FROM
dsv1069.orders
) second_orders
ON
first_orders.user_id = second_orders.user_id
WHERE 
first_orders.order_num = 1
AND
second_orders.order_num = 2
LIMIT 100

--Query #9
-- Average

SELECT
item_category,
AVG(times_category_ordered) as avg_times_category_ordered
FROM
(
SELECT user_id,
item_category,
COUNT(distinct line_item_id) as times_category_ordered
FROM
dsv1069.orders
GROUP BY
user_id,
item_category
) user_level
group by item_category
LIMIT 100
