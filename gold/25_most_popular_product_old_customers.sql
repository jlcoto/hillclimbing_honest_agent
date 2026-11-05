-- 25 What is the most popular product with old clients in the last 3 months?
-- Old clients = first order more than a year before the end of the data (before
-- 2025-09-01): 1798 customers. Popular = units they bought in June to August 2026.
-- The definition of old clients goes in a guide later.
with old_customers as (
    select customer_id
    from customers
    where first_ordered_at < '2025-09-01'
)

select
    order_items.product_name,
    count(*) as units
from order_items
inner join orders
    on orders.order_id = order_items.order_id
where orders.customer_id in (select customer_id from old_customers)
  and order_items.ordered_at >= '2026-06-01'
  and order_items.ordered_at < '2026-09-01'
group by order_items.product_name
order by units desc;
