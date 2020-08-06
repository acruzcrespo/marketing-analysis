--Query #1
--Create the right subtable for recently viewed events using the view_item_events table.
-- from this 3 we are going to use row_number since we are working with event time, and we want
-- to see the distinct timestamps. 

SELECT user_id, 
  item_id,
  event_time,
  row_number() over (PARTITION by user_id order by event_time DESC) as view_number
  from dsv1069.view_item_events
LIMIT 100

--Query #2
--Join your tables together recent_views, users, items
--Starter Code: The result from Ex1

SELECT *
from 
( SELECT user_id, 
  item_id,
  event_id,
  row_number() over (PARTITION by user_id order by event_time DESC) as view_number
  from dsv1069.view_item_events
) recent_views 
JOIN
dsv1069.users
ON
users.id = recent_views.user_id
JOIN
dsv1069.items
ON
items.id = recent_views.item_id
LIMIT 100

--Query #3
-- Clean up your columns. The goal of all this is to return all of the information we’ll
--need to send users an email about the item they viewed more recently. Clean up this query
--outline from the outline in EX2 and pull only the columns you need. Make sure they are named
--appropriately so that another human can read and understand their contents.


SELECT users.id as user_id, 
users.email_address,
items.id as item_id, 
items.name as item_name,
items.category as item_category
from 
( SELECT user_id, 
  item_id,
  event_id,
  row_number() over (PARTITION by user_id order by event_time DESC) as view_number
  from dsv1069.view_item_events
) recent_views 
JOIN
dsv1069.users
ON
users.id = recent_views.user_id
JOIN
dsv1069.items
ON
items.id = recent_views.item_id
LIMIT 100

--Query #4
-- Consider any edge cases(add any extra filtering that would make this email better)
-- One thing I can do to make the email better is to check if users where merged or deleted

SELECT COALESCE(users.parent_user_id, users.id) as user_id, 
users.email_address,
items.id as item_id, 
items.name as item_name,
items.category as item_category
from 
( SELECT user_id, 
  item_id,
  event_id,
  row_number() over (PARTITION by user_id order by event_time DESC) as view_number
  from dsv1069.view_item_events
) recent_views 
JOIN
dsv1069.users
ON
users.id = recent_views.user_id
JOIN
dsv1069.items
ON
items.id = recent_views.item_id
WHERE
view_number = 1
AND
users.deleted_at IS NOT NULL
LIMIT 100

--Query #5
-- (bunch of joins) This is a rare case of a query, I want the promo email to be sent to active users, 
-- users that haven't bought the item, and users that have recently view the item.


SELECT COALESCE(users.parent_user_id, users.id) as user_id, 
users.email_address,
items.id as item_id, 
items.name as item_name,
items.category as item_category
from 
( SELECT user_id, 
  item_id,
  event_id,
  row_number() over (PARTITION by user_id order by event_time DESC) as view_number
  from dsv1069.view_item_events
) recent_views 
JOIN
dsv1069.users
ON
users.id = recent_views.user_id
JOIN
dsv1069.items
ON
items.id = recent_views.item_id
LEFT OUTER JOIN
dsv1069.orders
ON
orders.item_id = recent_views.user_id
AND
orders.item_id = recent_views.user_id
WHERE
view_number = 1
AND
users.deleted_at IS NOT NULL
AND
orders.item_id IS NULL
LIMIT 100
