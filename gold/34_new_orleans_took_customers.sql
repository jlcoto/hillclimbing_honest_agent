-- 34 Did opening New Orleans take customers away from our other stores?
-- No: New Orleans' customers never ordered anywhere else, before or after it opened.
with new_orleans_customers as (
    select distinct orders.customer_id
    from orders
    inner join locations
        on locations.location_id = orders.location_id
    where locations.location_name = 'New Orleans'
)

select
    count(distinct new_orleans_customers.customer_id) as new_orleans_customers,
    count(distinct orders.customer_id) filter (
        where locations.location_name <> 'New Orleans'
    ) as also_ordered_elsewhere
from new_orleans_customers
inner join orders
    on orders.customer_id = new_orleans_customers.customer_id
inner join locations
    on locations.location_id = orders.location_id;
