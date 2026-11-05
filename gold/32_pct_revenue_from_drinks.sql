-- 32 What percentage of our revenue comes from drinks?
-- All time, pre-tax: revenue of drink items over revenue of all items. Drinks are 76.71%
-- of units but cheaper, so 60.59% of revenue.
select round(100 * sum(product_price) filter (where is_drink_item) / sum(product_price), 2) as pct_revenue_drinks
from order_items;
