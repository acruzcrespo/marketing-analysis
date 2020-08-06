--Query #1
--Create a subtable of orders per day. Make sure you decide whether you are
--counting invoices or line items.

select date(paid_at) as day, 
count(distinct invoice_id) as orders, 
count(distinct line_item_id) as line_items
from dsv1069.orders
GROUP BY 
date(paid_at)
LIMIT 100

--Query #2
--“Check your joins”. We are still trying to count orders per day. In this step join the
--sub table from the previous exercise to the dates rollup table so we can get a row for every
--date. Check that the join works by just running a “select *” query

SELECT *
from dsv1069.dates_rollup
left OUTER JOIN
(
select date(paid_at) as day, 
count(distinct invoice_id) as orders, 
count(distinct line_item_id) as line_items
from dsv1069.orders
GROUP BY 
date(paid_at)
) daily_orders
ON
daily_orders.day = dates_rollup.date
LIMIT 100

--Query #3
--“Clean up your Columns” In this step be sure to specify the columns you actually
--want to return, and if necessary do any aggregation needed to get a count of the orders made
--per day.

SELECT dates_rollup.date, 
COALESCE(SUM(orders),0) as orders,
COALESCE(SUM(items_ordered),0) as items_ordered
from dsv1069.dates_rollup
left OUTER JOIN
(
select date(paid_at) as day, 
count(distinct invoice_id) as orders, 
count(distinct line_item_id) as items_ordered
from dsv1069.orders
GROUP BY 
date(paid_at)
) daily_orders
ON
daily_orders.day = dates_rollup.date 
group by 
dates_rollup.date
LIMIT 100

--Query #4
--Weekly Rollup. Figure out which parts of the JOIN condition need to be edited
--create 7 day rolling orders table.
--Starter Code: Result from EX2 or EX3

SELECT *
from dsv1069.dates_rollup
left OUTER JOIN
(
select date(paid_at) as day, 
count(distinct invoice_id) as orders, 
count(distinct line_item_id) as items_ordered
from dsv1069.orders
GROUP BY 
date(paid_at)
) daily_orders
ON
dates_rollup.date >= daily_orders.day
AND
dates_rollup.d7_ago < daily_orders.day
LIMIT 100


--Query #5
--Column Cleanup. Finish creating the weekly rolling orders table, by performing
--any aggregation steps and naming your columns appropriately.
--Starter Code: Result form Ex4

SELECT dates_rollup.date, 
COALESCE(SUM(orders),0) as orders,
COALESCE(SUM(items_ordered),0) as items_ordered 
from dsv1069.dates_rollup
left OUTER JOIN
(
select date(paid_at) as day, 
count(distinct invoice_id) as orders, 
count(distinct line_item_id) as items_ordered
from dsv1069.orders
GROUP BY 
date(paid_at)
) daily_orders
ON
dates_rollup.date >= daily_orders.day
AND
dates_rollup.d7_ago < daily_orders.day
GROUP BY 
dates_rollup.date
LIMIT 100
