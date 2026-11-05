-- 23 What's the percentage of customers that have gone to more than one location?
-- Every customer has ordered from exactly one store, so the answer is 0%.
with customer_locations as (
    select customer_id, count(distinct location_id) as locations
    from orders
    group by customer_id
)

select
    count(*) as customers,
    count(*) filter (where locations > 1) as multi_location_customers,
    round(100 * count(*) filter (where locations > 1) / count(*), 2) as pct_multi_location
from customer_locations;
