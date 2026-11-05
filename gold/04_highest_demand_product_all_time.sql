-- 4 what is the product with the highest demand
-- No period in the question = all of the data; demand = units sold.
select product_name, count(*) as units_sold
from marts.order_items
group by product_name
order by units_sold desc;
