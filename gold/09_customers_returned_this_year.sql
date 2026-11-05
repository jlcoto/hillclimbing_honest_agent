-- 9 how many customers from last year have returned this year (returned_this_year)
-- Last year = 2025, this year = 2026 (data through 2026-08-31). Customers from last year =
-- customers with an order in 2025; returned = they also ordered in 2026.
with customer_years as (
    select
        customer_id,
        bool_or(year(ordered_at) = 2025) as ordered_last_year,
        bool_or(year(ordered_at) = 2026) as ordered_this_year
    from marts.orders
    group by customer_id
)

select
    count(*) filter (where ordered_last_year) as customers_last_year,
    count(*) filter (where ordered_last_year and ordered_this_year) as returned_this_year,
    round(100.0 * returned_this_year / customers_last_year, 2) as pct_returned
from customer_years;
