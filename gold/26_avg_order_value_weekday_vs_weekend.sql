-- 26 What's the absolute difference in average order price between a weekday (Mon-Fri) and
-- the weekend (Sat-Sun)?
-- Pre-tax subtotal, all time, all orders: the empty orders have subtotal 0 and count.
-- isodow: Monday = 1 ... Sunday = 7. Weekday 8.93, weekend 23.41.
select
    round(avg(subtotal) filter (where isodow(ordered_at) <= 5), 2) as avg_weekday,
    round(avg(subtotal) filter (where isodow(ordered_at) >= 6), 2) as avg_weekend,
    round(avg(subtotal) filter (where isodow(ordered_at) >= 6)
        - avg(subtotal) filter (where isodow(ordered_at) <= 5), 2) as difference
from orders;
