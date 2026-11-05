-- 24 What is the most popular product with the new clients?
-- New clients = customers whose first order was in the last 3 months of data, June to
-- August 2026 (the data ends 2026-08-31): 93 customers. Popular = units they bought.
-- The definition of new clients goes in a guide later.
with new_customers as (
    select customer_id
    from customers
    where first_ordered_at >= '2026-06-01'
      and first_ordered_at < '2026-09-01'
)

select
    order_items.product_name,
    count(*) as units
from order_items
inner join orders
    on orders.order_id = order_items.order_id
where orders.customer_id in (select customer_id from new_customers)
group by order_items.product_name
order by units desc;
