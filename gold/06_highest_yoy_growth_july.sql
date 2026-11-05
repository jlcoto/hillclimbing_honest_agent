-- 6 what is the product that has the highest year over year growth for the month of july
-- July 2026 vs July 2025, growth in percent of units sold.
-- Product with highest yoy demand percentage growth

with monthly_group as (
  select product_name, min(date_trunc('month', ordered_at)) as first_month
  from order_items
  group by all
)

, spine as (
  select
    product_name
    , unnest(
        generate_series(
          first_month
          , (select max(date_trunc('month', ordered_at)) from order_items)
          , interval 1 month
        )
    ) as month_date
  from monthly_group
)

, monthly_demand as (
  select
    product_name
    , date_trunc('month', ordered_at) as month_date
    , count(*) as products
  from order_items
  group by all
)


, yoy_comp as (select
  spine.month_date
  , spine.product_name
  , coalesce(monthly_demand.products, 0) as units
  , lag(coalesce(monthly_demand.products, 0), 12) over (partition  by spine.product_name order by spine.month_date) as products_previous_year
  , units - products_previous_year as yoy_abs
  , yoy_abs / products_previous_year as perc_change
from spine
left join monthly_demand
  on spine.month_date = monthly_demand.month_date
  and spine.product_name = monthly_demand.product_name
)

select *
from yoy_comp
where month_date = '2026-07-01'
order by perc_change desc
