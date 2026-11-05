-- 15 How many active stores do we have?
-- Active = has at least one order. Los Angeles is in locations but opens 2026-09-13,
-- after the data ends, so it has no orders. Counting locations gives 6; filtering
-- locations on opened_at up to 2026-08-31 also gives 5, but without checking sales.
select count(distinct location_id) as active_stores
from orders;
