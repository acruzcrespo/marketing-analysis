--Query #1
--Goal: Write a query to format the view_item event into a table with the appropriate columns
-- Secret Goal: figure out how to do it for multiple parameters

select event_id, event_time, user_id, platform, 
(CASE WHEN parameter_name = 'item_id'
then CAST(parameter_value AS INT)
else null END) AS item_id
from dsv1069.events
where event_name = 'view_item'
order by event_id
LIMIT 100

--Query #2 
--Goal: Write a query to format the view_item event into a table with the appropriate columns

SELECT event_id, event_time, user_id, platform,
(CASE WHEN parameter_name = 'item_id'
  THEN CAST(parameter_value AS INT) 
  ELSE NULL
  END) AS item_id,
  (CASE WHEN parameter_name = 'referrer'
  THEN parameter_value
  ELSE NULL
  END) AS referrer
from dsv1069.events
where event_name = 'view_item'
order by event_id
LIMIT 100

--Query #3
--Goal: Use the result from the previous exercise, add an aggregation and fixed the null values

SELECT event_id, event_time, user_id, platform,
  MAX(CASE WHEN parameter_name = 'item_id'
  THEN CAST(parameter_value AS INT) 
  ELSE NULL
  END) AS item_id,
  MAX(CASE WHEN parameter_name = 'referrer'
  THEN parameter_value
  ELSE NULL
  END) AS referrer
from dsv1069.events
where event_name = 'view_item'
group by event_id, event_time, user_id, platform
LIMIT 100
