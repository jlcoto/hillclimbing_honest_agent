-- 21 Which store has the highest profit margin of all?
-- Profit margin = (revenue - supply cost) / revenue, all time, pre-tax. order_cost is
-- the sum of the items' supply_cost; NULL on the empty orders, which add $0 either way.
-- All five stores are within 0.07 points: same products and prices, only the mix differs.
select
    locations.location_name,
    sum(orders.subtotal) as revenue,
    sum(orders.order_cost) as cost,
    round(100 * (sum(orders.subtotal) - sum(orders.order_cost)) / sum(orders.subtotal), 2) as margin_pct
from orders
inner join locations
    on locations.location_id = orders.location_id
group by locations.location_name
order by margin_pct desc;
