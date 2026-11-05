-- 31 Which store had the highest revenue in its second 30 days after opening (days 31 to 60)?
-- The opening day is day 1, so days 31 to 60 run from opened_date + 30 days up to (not
-- including) opened_date + 60 days. Pre-tax.
select
    locations.location_name,
    sum(orders.subtotal) as revenue_days_31_to_60
from orders
inner join locations
    on locations.location_id = orders.location_id
where orders.ordered_at >= locations.opened_date + interval 30 day
  and orders.ordered_at < locations.opened_date + interval 60 day
group by locations.location_name
order by revenue_days_31_to_60 desc;
