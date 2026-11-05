-- 12 average order price by store for last year
-- Last year = 2025. Pre-tax subtotal, over all orders, including the $0 orders that
-- have no items. New Orleans opened in 2026 and Los Angeles has no orders.
select
    locations.location_name,
    count(*) as orders,
    round(avg(orders.subtotal), 2) as avg_order_value
from marts.orders
join marts.locations
    on locations.location_id = orders.location_id
where orders.ordered_at >= '2025-01-01'
  and orders.ordered_at <  '2026-01-01'
group by locations.location_name
order by locations.location_name;
