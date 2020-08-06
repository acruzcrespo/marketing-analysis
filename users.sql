--Query #1
-- We’ll be using the users table to answer the question “How many new users are
--added each day?“. Start by making sure you understand the columns in the table.

select date(created_at) AS day, count(*) AS users
from dsv1069.users
group by date(created_at)
LIMIT 100

--Query #2
-- Consider the following query. Is this the right way to count merged or deleted
--users? If all of our users were deleted tomorrow what would the result look like?

SELECT date(created_at) as day, count(*) as users
FROM dsv1069.users
WHERE deleted_at ISNULL
and (id <> parent_user_id OR parent_user_id ISNULL)
group by date(created_at)
LIMIT 100

--Query #3
--Count the number of users deleted each day. Then count the number of users
--removed due to merging in a similar way. Starter Code: (Use the result from #2 as a guide)

select date(deleted_at) AS day, count(*) AS deleted_users
from dsv1069.users
WHERE deleted_at IS NOT NULL 
group by date(deleted_at)
LIMIT 100

--Query #4
--Use the pieces you’ve built as subtables and create a table that has a column for
--the date, the number of users created, the number of users deleted and the number of users
--merged that day

SELECT new.day, new.new_added_users, deleted.deleted_users, merged.merged_users,
(new.new_added_users - deleted.deleted_users - merged.merged_users) AS net_added_users
FROM 
(select date(created_at) AS day, 
count(*) AS new_added_users
from dsv1069.users
group by date(created_at)
) new
LEFT JOIN 
(select date(deleted_at) as day, 
count(*) as deleted_users
from dsv1069.users
where deleted_at is not NULL
group by date(deleted_at)
) deleted
ON deleted.day = new.day
LEFT Join 
(select date(merged_at) as day, 
count(*) as merged_users
from dsv1069.users
where 
id <> parent_user_id
and 
parent_user_id is not NULL
group by date(merged_at)
) merged
ON merged.day = new.day
LIMIT 100

--Query #5
--Refine your query from #5 to have informative column names and so that null columns return 0.

SELECT new.day, new.new_added_users, COALESCE(deleted.deleted_users,0) as deleted_users, 
COALESCE(merged.merged_users,0) as merged_users,
(new.new_added_users - COALESCE(deleted.deleted_users,0) - COALESCE(merged.merged_users,0)) 
AS net_added_users
FROM 
(select date(created_at) AS day, 
count(*) AS new_added_users
from dsv1069.users
group by date(created_at)
) new
LEFT JOIN 
(select date(deleted_at) as day, 
count(*) as deleted_users
from dsv1069.users
where deleted_at is not NULL
group by date(deleted_at)
) deleted
ON deleted.day = new.day
LEFT Join 
(select date(merged_at) as day, 
count(*) as merged_users
from dsv1069.users
where 
id <> parent_user_id
and 
parent_user_id is not NULL
group by date(merged_at)
) merged
ON merged.day = new.day
LIMIT 100

--Query #6
--What if there were days where no users were created, but some users were deleted or merged.
--Does the previous query still work? No, it doesn’t. Use the dates_rollup as a backbone for this
--query, so that we won’t miss any dates.

SELECT new.day, new.new_added_users, COALESCE(deleted.deleted_users,0) as deleted_users, 
COALESCE(merged.merged_users,0) as merged_users,
(new.new_added_users - COALESCE(deleted.deleted_users,0) - COALESCE(merged.merged_users,0)) 
AS net_added_users
FROM 
(select date(created_at) AS day, 
count(*) AS new_added_users
from dsv1069.users
group by date(created_at)
) new
LEFT JOIN 
(select date(deleted_at) as day, 
count(*) as deleted_users
from dsv1069.users
where deleted_at is not NULL
group by date(deleted_at)
) deleted
ON deleted.day = new.day
LEFT Join 
(select date(merged_at) as day, 
count(*) as merged_users
from dsv1069.users
where 
id <> parent_user_id
and 
parent_user_id is not NULL
group by date(merged_at)
) merged
ON merged.day = new.day
LIMIT 100
