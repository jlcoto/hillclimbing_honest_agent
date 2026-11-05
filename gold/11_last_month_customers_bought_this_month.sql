-- 11 How many of our last month customers have made a purchase this month
-- The data ends 2026-08-31, so this month = August 2026 and last month = July 2026.
with customer_months as (
    select
        customer_id,
        bool_or(ordered_at >= '2026-07-01' and ordered_at < '2026-08-01') as ordered_last_month,
        bool_or(ordered_at >= '2026-08-01' and ordered_at < '2026-09-01') as ordered_this_month
    from marts.orders
    group by customer_id
)

select
    count(*) filter (where ordered_last_month) as customers_last_month,
    count(*) filter (where ordered_last_month and ordered_this_month) as bought_again_this_month
from customer_months;
