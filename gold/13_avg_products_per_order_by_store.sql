-- 13 average number of products per ticket and store
-- All time. Products = units (two of the same product count 2). The 5030 orders with
-- no items ($0) are left out: count_order_items is NULL on them and avg skips NULLs.
-- Counting them as 0 gives about 0.01 less per store. Los Angeles has no orders.
select
    locations.location_name,
    count(orders.count_order_items) as orders_with_items,
    round(avg(orders.count_order_items), 2) as avg_products_per_order
from marts.orders
join marts.locations
    on locations.location_id = orders.location_id
group by locations.location_name
order by avg_products_per_order desc;
