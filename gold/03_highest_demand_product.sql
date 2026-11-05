-- 3 what is currently the product with the highest demand
-- "Currently" = the last 28 days of data, Aug 4-31 2026; demand = units sold.
-- The eval also accepts other stated windows: see evals/products.yml.
-- It is also accepted other timeframes as long as the agent is clear abotu what they mean by "currently"
select product_name, count(*) as units_sold
from marts.order_items
where ordered_at >= date '2026-08-31' - interval 27 day   -- Aug 4-31: 28 days
group by product_name
order by units_sold desc;
