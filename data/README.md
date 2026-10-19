# Data

`raw/` is jaffle-shop's raw data, generated once on 2026-10-19 with
[jafgen](https://github.com/dbt-labs/jaffle-shop-generator) 0.4.14:

```bash
uvx jafgen 3
```

jafgen has no seed, so a new run gives different numbers. Every gold answer is
computed from these exact files: don't regenerate them.

The files are gzipped (`gzip -n -9`) to stay under GitHub's file size limits;
Snowflake and DuckDB read `.csv.gz` directly. `SHA256SUMS` holds the checksums
of the uncompressed CSVs: `gunzip -k raw/*.gz && cd raw && shasum -a 256 -c ../SHA256SUMS`.

Left out: `raw_tweets.csv`, which jafgen also writes but the
[dbt-labs/jaffle-shop](https://github.com/dbt-labs/jaffle-shop) project doesn't use.

| File | Rows |
|---|---|
| raw_customers.csv.gz | 2,586 |
| raw_orders.csv.gz | 664,401 |
| raw_items.csv.gz | 985,497 |
| raw_products.csv.gz | 10 |
| raw_stores.csv.gz | 6 |
| raw_supplies.csv.gz | 65 |

Orders run from 2018-09-01 to 2021-08-30. Amounts are in cents.
