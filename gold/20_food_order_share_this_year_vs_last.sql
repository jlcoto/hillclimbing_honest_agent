-- 20 Has the share of orders that include food increased this year compared to last year?
-- Same period in both years: January to August (the data ends 2026-08-31).
-- Full year 2025 (23.81%) against 2026 to date gives a decrease: the wrong comparison.
select
    year(ordered_at) as order_year,
    count(*) as orders,
    count(*) filter (where is_food_order) as food_orders,
    round(100 * count(*) filter (where is_food_order) / count(*), 2) as pct_food_orders
from orders
where ordered_at >= '2025-01-01'
  and month(ordered_at) <= 8
group by order_year
order by order_year;
