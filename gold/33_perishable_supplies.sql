-- 33 How many of our supplies are perishable?
-- supplies has one row per supply and product (65 rows, 29 supplies): count distinct
-- supply_id. Counting rows gives 30.
select count(distinct supply_id) as perishable_supplies
from supplies
where is_perishable_supply;
