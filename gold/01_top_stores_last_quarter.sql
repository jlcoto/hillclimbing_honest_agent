-- 1 Give me the top 3 stores with highest revenue in the last quarter and their revenue
select location_name, coalesce(sum(orders.subtotal), 0) as total_revenue
from locations
left join orders on locations.location_id = orders.location_id
and date_trunc('month', ordered_at) between '2026-04-01' and '2026-06-01'
group by all
order by 2 desc
limit 3;
