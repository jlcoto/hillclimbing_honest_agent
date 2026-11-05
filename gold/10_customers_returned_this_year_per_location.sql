-- 10 Share of last year's customers who returned this year per location
-- Last year = 2025, this year = 2026 (data through 2026-08-31). A store's customers from
-- last year = customers with a 2025 order there; returned = they ordered there in 2026.
-- Every customer orders from one store only, so "returned to any store" gives the same.
with customer_store_years as (
    select
        orders.customer_id,
        locations.location_name,
        bool_or(year(orders.ordered_at) = 2025) as ordered_last_year,
        bool_or(year(orders.ordered_at) = 2026) as ordered_this_year
    from marts.orders
    join marts.locations
        on locations.location_id = orders.location_id
    group by all
)

select
    location_name,
    count(*) filter (where ordered_last_year) as customers_last_year,
    count(*) filter (where ordered_last_year and ordered_this_year) as returned_this_year,
    round(100.0 * returned_this_year / nullif(customers_last_year, 0), 2) as pct_returned
from customer_store_years
group by location_name
order by location_name;
