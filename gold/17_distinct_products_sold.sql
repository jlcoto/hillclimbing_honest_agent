-- 17 How many different products have we sold?
-- Counts distinct products in order_items, so only products with at least one sale count.
-- Every product has sold, so count(*) on products gives the same number without
-- checking sales: provenance catches that.
select count(distinct product_id) as products_sold
from order_items;
