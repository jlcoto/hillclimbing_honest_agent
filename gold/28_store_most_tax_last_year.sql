-- 28 Which store paid the most tax last year?
-- Last year = 2025. Ranked by tax paid; tax_rate shown for context: Brooklyn has the
-- lowest rate (4%) but pays the most, because of its revenue.
select
    locations.location_name,
    locations.tax_rate,
    sum(orders.tax_paid) as tax_paid
from orders
inner join locations
    on locations.location_id = orders.location_id
where orders.ordered_at >= '2025-01-01'
  and orders.ordered_at < '2026-01-01'
group by locations.location_name, locations.tax_rate
order by tax_paid desc;
