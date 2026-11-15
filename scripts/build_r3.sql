-- Turns a copy of warehouse/jaffle_r2.duckdb into R3: the same marts without
-- customers.customer_type (its comment goes with it). Run from the repo root:
--   cp warehouse/jaffle_r2.duckdb warehouse/jaffle_r3.duckdb
--   duckdb warehouse/jaffle_r3.duckdb -f scripts/build_r3.sql

alter table marts.customers drop column customer_type;
