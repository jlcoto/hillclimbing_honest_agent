-- 2 Which store has the biggest revenue decrease last month
with revenue_store_month as (
select locations.location_name
  , date_trunc('month', ordered_at) as order_month
  , coalesce(sum(subtotal), 0) as revenue_month
from locations
left join orders on locations.location_id = orders.location_id
group by all
)

, perc_change_mom as (
select *
  , coalesce(lag(revenue_month) over (partition  by location_name order by order_month), 0) as previous_revenue
  , (revenue_month - previous_revenue) as overall_change
  , (revenue_month - previous_revenue)/previous_revenue as perc_change_mom
from revenue_store_month
)

select *
from perc_change_mom
where order_month = '2026-07-01'
order by overall_change
