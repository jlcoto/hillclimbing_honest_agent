-- 27 How much tax did we collect last year?
-- Last year = 2025. tax_paid is what each order actually paid (floored per order).
-- Recomputing as subtotal x tax_rate gives 148997.19 (0.26% too high).
select sum(tax_paid) as tax_collected
from orders
where ordered_at >= '2025-01-01'
  and ordered_at < '2026-01-01';
