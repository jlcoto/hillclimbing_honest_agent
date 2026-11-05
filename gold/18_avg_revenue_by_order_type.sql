-- 18 What is the average revenue of orders with only food, only drinks, or both?
-- Per order, all time, pre-tax subtotal. The empty orders (no items) belong to none of
-- the groups and are left out.
select
    case
        when is_food_order and is_drink_order then 'both'
        when is_food_order then 'food only'
        when is_drink_order then 'drinks only'
    end as order_type,
    count(*) as orders,
    round(avg(subtotal), 2) as avg_order_value
from orders
where count_order_items > 0
group by order_type
order by avg_order_value desc;
