-- 19 What's the percentage of beverage only orders from the total orders?
-- Beverage only = drinks and no food. Denominator: all orders, including the 5030 empty
-- ones (75.60%). Over orders with items only: 76.17%. Orders with any drink: 97.30%.
select
    round(100 * count(*) filter (where is_drink_order and not is_food_order) / count(*), 2)
        as pct_beverage_only_orders
from orders;
