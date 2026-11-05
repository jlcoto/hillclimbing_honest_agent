# Methodology notes

Facts for the post's methodology section: how the data was made and prepared. Notes,
not post text.

## The data

- jaffle-shop's raw data, generated on 2026-10-19 with jafgen 0.4.14: `uvx jafgen 3`
  (3 years). jafgen has no seed, so the files are generated once and committed
  (`data/raw/`, checksums in `data/SHA256SUMS`). Every gold answer comes from them.
- Rows: 664,401 orders, 985,497 order items, 2,586 customers, 6 stores, 10 products,
  65 supply rows. `raw_tweets` left out: the dbt project doesn't use it.
- Amounts are in cents in raw; dbt's staging models turn them into dollars.

## The date shift

- jafgen dates its data from 2018-09-01 to 2021-08-30. Agents read relative questions
  ("last month") against today's date, so 2021 data gives them nothing to find.
- The load scripts move `raw_orders.ordered_at` and `raw_stores.opened_at` forward by
  1827 days, so the warehouse holds 2023-09-02 to 2026-08-31. The committed files keep
  the original dates.
- 1827 days is 261 whole weeks, which keeps every date's weekday. That matters: the
  data has about 118k orders on each weekday and about 36k on Saturdays and Sundays.
  A shift of whole years would put the weekend dip on weekdays.
- Ending on 2026-08-31 makes August 2026 the last complete month, and the gold answers
  never change. The data is about 7 weeks behind the runs (October 2026), like a
  warehouse that stopped loading. Shifting to end on the run date was ruled out: the
  meaning of "last month" would change with every month that passes, and so would the
  gold answers.
- The shift changes nothing else: every order keeps its amounts, items, customer and
  order number (checked row by row against the unshifted build).

## Transformations

- dbt-labs/jaffle-shop at commit 5beb145b00f5465ec759cfcdd9745e858818cf95, built with
  dbt 2.0.0rc9 on DuckDB. Gold answers come from its marts (`orders`, `order_items`,
  `customers`, `products`, `locations`, `supplies`).

## Limits of the data

jafgen's data is clean and regular in ways real data isn't. Found while writing the
evals (checked on the marts and the raw tables, 2026-10-19 and 2026-10-20):

- **No time of day in the marts:** the raw tables keep it (jafgen writes a timestamp, the
  load scripts keep it, and all 664,401 raw orders have one), but dbt's staging cuts it to
  the date (`stg_orders`: `date_trunc('day', ordered_at)`, still named `ordered_at`;
  `stg_locations`: `opened_date`). From the marts on, every `ordered_at` is at midnight:
  questions about hours, or the first or last order of a day, have no answer there. In
  the marts the first day (2023-09-02) already has all 10 products, so "the first product
  ever sold" is undefined. In raw the first order is clear (2023-09-02 08:00, one order),
  but it holds two products (mel-bun, flame impala), so it's still a tie. Corrected
  2026-11-01 (the note said the data itself had no time of day).
- **Each customer orders from one store only:** 0 of 2586 customers ordered from more
  than one location.
- **New customers arrive almost only in a store's first year or so.** Last new customer:
  Brooklyn 2025-06-28, Chicago 2026-04-30, San Francisco 2026-05-11 (Philadelphia got a
  single one in July 2026). So acquisition falls overall (July 2025: 112 new customers,
  July 2026: 30), and per-store year-over-year comparisons are mostly 0 against 0 or
  drops of 100%.
- **Almost no churn:** 2585 of 2586 customers ordered in 2026. Retention questions come
  out near 100%.
- **`customer_type` is a lifetime label:** 2581 returning, 5 new. It can't answer "new
  customers this month".
- **Prices never change and there are no discounts.** List price equals the price
  charged, and `subtotal` equals the sum of item prices.
- **Every product sells at every store**, from the opening day on, and every customer
  and product appears in the orders. Catalog tables and sales give the same counts.
- **Tax is floored per order:** recomputing it as subtotal x rate comes out up to about
  0.6% too high per store.
- **5030 orders (0.76%) have no items and $0.** In the marts their item columns
  (`count_order_items`, `order_items_subtotal`, `order_cost`, `is_food_order`,
  `is_drink_order`) are NULL, not 0.
- **Store margins are nearly identical** (79.28% to 79.35%): same products and prices
  everywhere, only the product mix differs.
- **Los Angeles opens 2026-09-13, after the data ends:** it's in `locations` but has no
  orders.
- **Few, clean tables:** 6 raw tables with clear names. Even R0 is easy compared with a
  real warehouse.

Effects on the evals: some questions only work as honesty questions (the right answer is
"none" or "the data can't tell"), and some shortcuts give the right number for the wrong
reason (counting catalog tables instead of sales), which provenance checks. An agent may
also lose points by doubting results that are unrealistic but correct (0%, 100%).
