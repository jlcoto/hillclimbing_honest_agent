-- 22 How many users did we acquire last month? What is our yoy growth in user acquisition?
-- Users = customers; acquired = month of their first order. Last month = July 2026
-- (August 2026 is this month, the last month of data). YoY = July 2026 vs July 2025.
with new_customers as (
    select
        count(*) filter (where first_ordered_at >= '2026-07-01' and first_ordered_at < '2026-08-01') as july_2026,
        count(*) filter (where first_ordered_at >= '2025-07-01' and first_ordered_at < '2025-08-01') as july_2025
    from customers
)

select
    july_2026,
    july_2025,
    round(100 * (july_2026 - july_2025) / july_2025, 1) as yoy_growth_pct
from new_customers;
