-- R0: load jaffle-shop's raw data (jafgen, 3 years) into climb.raw.
-- Amounts (subtotal, tax_paid, order_total, price, cost) are in cents, as jafgen writes them.
-- No comments on purpose: R0 is the raw tables only.

create database if not exists climb;
create schema if not exists climb.raw;
use schema climb.raw;

create or replace file format climb.raw.csv_header
    type = csv
    skip_header = 1
    field_optionally_enclosed_by = '"';

create or replace stage climb.raw.jaffle_files file_format = climb.raw.csv_header;

-- Upload the gzipped CSVs from data/raw/ (run from the repo root, with Snowflake CLI):
--   snow stage copy data/raw/ @climb.raw.jaffle_files --recursive
-- or in SQL from a client that supports put:
--   put file://data/raw/*.csv.gz @climb.raw.jaffle_files;

create or replace table climb.raw.raw_customers (
    id varchar,
    name varchar
);

create or replace table climb.raw.raw_orders (
    id varchar,
    customer varchar,
    ordered_at timestamp_ntz,
    store_id varchar,
    subtotal number,
    tax_paid number,
    order_total number
);

create or replace table climb.raw.raw_items (
    id varchar,
    order_id varchar,
    sku varchar
);

create or replace table climb.raw.raw_products (
    sku varchar,
    name varchar,
    type varchar,
    price number,
    description varchar
);

create or replace table climb.raw.raw_stores (
    id varchar,
    name varchar,
    opened_at timestamp_ntz,
    tax_rate number(6, 4)
);

create or replace table climb.raw.raw_supplies (
    id varchar,
    name varchar,
    cost number,
    perishable boolean,
    sku varchar
);

copy into climb.raw.raw_customers from @climb.raw.jaffle_files pattern = '.*raw_customers\\.csv(\\.gz)?';
copy into climb.raw.raw_orders from @climb.raw.jaffle_files pattern = '.*raw_orders\\.csv(\\.gz)?';
copy into climb.raw.raw_items from @climb.raw.jaffle_files pattern = '.*raw_items\\.csv(\\.gz)?';
copy into climb.raw.raw_products from @climb.raw.jaffle_files pattern = '.*raw_products\\.csv(\\.gz)?';
copy into climb.raw.raw_stores from @climb.raw.jaffle_files pattern = '.*raw_stores\\.csv(\\.gz)?';
copy into climb.raw.raw_supplies from @climb.raw.jaffle_files pattern = '.*raw_supplies\\.csv(\\.gz)?';

-- Shift the dates 1827 days (261 weeks) forward, as scripts/load_local.sql does: the
-- data then runs 2023-09-02 to 2026-08-31, with each date keeping its weekday.
update climb.raw.raw_orders set ordered_at = dateadd(day, 1827, ordered_at);
update climb.raw.raw_stores set opened_at = dateadd(day, 1827, opened_at);

-- The stage only holds the upload; drop it so the agent can't list or read the files.
drop stage climb.raw.jaffle_files;
drop file format climb.raw.csv_header;

-- Expected: customers 2586, orders 664401, items 985497, products 10, stores 6, supplies 65.
select 'raw_customers' as table_name, count(*) as row_count from climb.raw.raw_customers
union all select 'raw_orders', count(*) from climb.raw.raw_orders
union all select 'raw_items', count(*) from climb.raw.raw_items
union all select 'raw_products', count(*) from climb.raw.raw_products
union all select 'raw_stores', count(*) from climb.raw.raw_stores
union all select 'raw_supplies', count(*) from climb.raw.raw_supplies;
