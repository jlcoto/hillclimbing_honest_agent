-- Builds warehouse/jaffle_marts.duckdb: the raw tables (schema raw) and dbt's marts
-- (schema marts) as plain tables, without staging views or MetricFlow's time spine.
-- Needs warehouse/climb.duckdb with dbt build done. Run from the repo root:
--   rm -f warehouse/jaffle_marts.duckdb && duckdb warehouse/jaffle_marts.duckdb -f scripts/build_marts_file.sql

attach 'warehouse/climb.duckdb' as src (read_only);
create schema raw;
create schema marts;
create table raw.raw_customers as select * from src.raw.raw_customers;
create table raw.raw_orders as select * from src.raw.raw_orders;
create table raw.raw_items as select * from src.raw.raw_items;
create table raw.raw_products as select * from src.raw.raw_products;
create table raw.raw_stores as select * from src.raw.raw_stores;
create table raw.raw_supplies as select * from src.raw.raw_supplies;
create table marts.orders as select * from src.main.orders;
create table marts.order_items as select * from src.main.order_items;
create table marts.customers as select * from src.main.customers;
create table marts.products as select * from src.main.products;
create table marts.locations as select * from src.main.locations;
create table marts.supplies as select * from src.main.supplies;
detach src;
