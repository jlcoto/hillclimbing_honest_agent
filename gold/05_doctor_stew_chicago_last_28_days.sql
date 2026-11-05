-- 5 how many doctor stew were sold in Chicago in the last 28 days?
-- Last 28 days of data = Aug 4-31 2026; "sold" = units (order items), not orders.
select count(*) as units_sold
from marts.order_items
join marts.orders
    on orders.order_id = order_items.order_id
join marts.locations
    on locations.location_id = orders.location_id
where locations.location_name = 'Chicago'
  and order_items.product_name = 'doctor stew'
  and order_items.ordered_at >= date '2026-08-31' - interval 27 day;   -- Aug 4-31
