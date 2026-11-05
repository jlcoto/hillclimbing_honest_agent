-- 16 How many customers have placed an order?
-- Counts distinct customers in orders, so only customers with at least one order count.
-- Every customer has ordered, so count(*) on customers gives the same number without
-- checking orders: provenance catches that.
select count(distinct customer_id) as customers_with_orders
from orders;
