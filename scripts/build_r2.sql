-- Builds warehouse/jaffle_r2.duckdb (R2): dbt's marts only, schema marts, without the raw
-- tables. Needs warehouse/jaffle_marts.duckdb (scripts/build_marts_file.sql). The comments
-- come from the marts' yml, with scripts/marts_comments.py. Run from the repo root:
--   rm -f warehouse/jaffle_r2.duckdb
--   duckdb warehouse/jaffle_r2.duckdb -f scripts/build_r2.sql
--   uv run python scripts/marts_comments.py | duckdb warehouse/jaffle_r2.duckdb

attach 'warehouse/jaffle_marts.duckdb' as src (read_only);
create schema marts;
create table marts.orders as select * from src.marts.orders;
create table marts.order_items as select * from src.marts.order_items;
create table marts.customers as select * from src.marts.customers;
create table marts.products as select * from src.marts.products;
create table marts.locations as select * from src.marts.locations;
create table marts.supplies as select * from src.marts.supplies;
detach src;
