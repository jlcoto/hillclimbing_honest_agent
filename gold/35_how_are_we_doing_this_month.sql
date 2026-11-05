-- 35 How are we doing this month?
-- This month = August 2026, the last month of data; compared with July 2026. Pre-tax.
select
    date_trunc('month', ordered_at) as order_month,
    count(*) as orders,
    sum(subtotal) as revenue,
    count(distinct customer_id) as customers,
    round(avg(subtotal), 2) as avg_order_value
from orders
where ordered_at >= '2026-07-01'
group by order_month
order by order_month;
