-- 14 what is the product with the highest profit margin, and what percentage of each
-- store's revenue does it represent?
-- Profit margin = (price - cost) / price, cost = the sum of all of a product's supplies
-- (each product carries the full cost of shared supplies). All time, pre-tax revenue.
-- Run after `use marts;`.

with product_costs as (
    select product_id, sum(supply_cost) as unit_cost
    from supplies
    group by product_id
),

product_margins as (
    select
        products.product_id,
        products.product_name,
        (products.product_price - product_costs.unit_cost) / products.product_price as profit_margin
    from products
    inner join product_costs
        on product_costs.product_id = products.product_id
),

top_product as (
    select product_id, product_name, profit_margin
    from product_margins
    order by profit_margin desc
    limit 1
),

store_revenue as (
    select
        locations.location_name,
        sum(order_items.product_price) as revenue,
        sum(order_items.product_price) filter (
            where order_items.product_id = (select product_id from top_product)
        ) as top_product_revenue
    from order_items
    inner join orders
        on orders.order_id = order_items.order_id
    inner join locations
        on locations.location_id = orders.location_id
    group by locations.location_name
)

select
    (select product_name from top_product) as product_name,
    round(100 * (select profit_margin from top_product), 1) as profit_margin_pct,
    store_revenue.location_name,
    store_revenue.revenue,
    store_revenue.top_product_revenue,
    round(100 * store_revenue.top_product_revenue / store_revenue.revenue, 2) as pct_of_store_revenue
from store_revenue
order by store_revenue.location_name;
