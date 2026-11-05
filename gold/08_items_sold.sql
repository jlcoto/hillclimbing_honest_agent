-- 8 How many items have we sold?
-- Items = order items (one row per item sold), over all of the data.
select count(*) as items_sold
from marts.order_items;
