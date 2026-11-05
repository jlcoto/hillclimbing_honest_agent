-- Loads data/raw/*.csv.gz into a DuckDB file, schema raw, with the same types as
-- snowflake/r0_load_raw.sql. Run from the repo root:
--   duckdb warehouse/jaffle_raw.duckdb -f scripts/load_local.sql   (raw tables only)
--   duckdb warehouse/climb.duckdb -f scripts/load_local.sql        (raw + dbt's marts, after dbt build)
-- Don't name the file raw.duckdb: its catalog would clash with the schema raw.
--
-- Dates are shifted 1827 days (261 weeks) forward, so the data runs 2023-09-02 to
-- 2026-08-31 instead of 2018-09-01 to 2021-08-30. Whole weeks keep each date's weekday
-- (orders drop on weekends). The CSVs keep jafgen's original dates; see data/README.md.

create schema if not exists raw;

create or replace table raw.raw_customers as
select * from read_csv('data/raw/raw_customers.csv.gz', header = true,
    columns = {'id': 'varchar', 'name': 'varchar'});

create or replace table raw.raw_orders as
select * replace (ordered_at + interval 1827 day as ordered_at) from read_csv('data/raw/raw_orders.csv.gz', header = true,
    columns = {'id': 'varchar', 'customer': 'varchar', 'ordered_at': 'timestamp', 'store_id': 'varchar',
               'subtotal': 'bigint', 'tax_paid': 'bigint', 'order_total': 'bigint'});

create or replace table raw.raw_items as
select * from read_csv('data/raw/raw_items.csv.gz', header = true,
    columns = {'id': 'varchar', 'order_id': 'varchar', 'sku': 'varchar'});

create or replace table raw.raw_products as
select * from read_csv('data/raw/raw_products.csv.gz', header = true,
    columns = {'sku': 'varchar', 'name': 'varchar', 'type': 'varchar', 'price': 'bigint', 'description': 'varchar'});

create or replace table raw.raw_stores as
select * replace (opened_at + interval 1827 day as opened_at) from read_csv('data/raw/raw_stores.csv.gz', header = true,
    columns = {'id': 'varchar', 'name': 'varchar', 'opened_at': 'timestamp', 'tax_rate': 'decimal(6, 4)'});

create or replace table raw.raw_supplies as
select * from read_csv('data/raw/raw_supplies.csv.gz', header = true,
    columns = {'id': 'varchar', 'name': 'varchar', 'cost': 'bigint', 'perishable': 'boolean', 'sku': 'varchar'});

select 'raw_customers' as table_name, count(*) as row_count from raw.raw_customers
union all select 'raw_orders', count(*) from raw.raw_orders
union all select 'raw_items', count(*) from raw.raw_items
union all select 'raw_products', count(*) from raw.raw_products
union all select 'raw_stores', count(*) from raw.raw_stores
union all select 'raw_supplies', count(*) from raw.raw_supplies;
