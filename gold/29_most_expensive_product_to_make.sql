-- 29 Which product is most expensive to make?
-- Cost to make = the sum of a product's supplies, per unit. the krautback 3.66, flame
-- impala 3.43. Total supply cost over all sales gives chai and mighty (264747.00).
with product_costs as (
    select product_id, sum(supply_cost) as unit_cost
    from supplies
    group by product_id
)

select
    products.product_name,
    product_costs.unit_cost
from products
inner join product_costs
    on product_costs.product_id = products.product_id
order by product_costs.unit_cost desc;
