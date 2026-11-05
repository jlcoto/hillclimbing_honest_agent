-- 30 Which month of the year has the highest revenue? Is it the same every year? Only
-- consider complete years.
-- Complete years: 2024 and 2025 (the data runs 2023-09-02 to 2026-08-31). Pre-tax.
with monthly_revenue as (
    select
        year(ordered_at) as order_year,
        monthname(ordered_at) as order_month,
        sum(subtotal) as revenue
    from orders
    where ordered_at >= '2024-01-01'
      and ordered_at < '2026-01-01'
    group by order_year, order_month
)

select order_year, order_month, revenue
from monthly_revenue
order by order_year, revenue desc;
