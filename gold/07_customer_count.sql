-- 7 How many customers do we have?
-- Customers are rows of customers (one per customer_id); names aren't unique.
select count(*) as customers
from marts.customers;
