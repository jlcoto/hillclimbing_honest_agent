# agent-climb

A hillclimbing experiment on a data agent, rung by rung, using
[The Honest Agent](https://github.com/jlcoto/the_honest_agent) and the Jaffle Shop data.
This repo is the accompanying material of the hillclimbing series on The Data Lead. Start
with [part 1](https://blog.thegroundlayer.io/p/hillclimbing-evals-data-agents), which
introduces hillclimbing.

This branch is **rung 3 (R3)**: the marts of R2 without `customers.customer_type`, plus a
guide with our definitions, loaded as a private MotherDuck guide. On honest-agent 0.4.0 it
passed 25, 25 and 25 of 25 evals.
[Part 3](https://blog.thegroundlayer.io/p/hillclimbing-evals-improve-data-agent) of the series
walks through it.

## The branches

Each set of changes in the series has its own branch. The branches build on each other:
`rung-2` holds everything in `rung-1`, plus the marts.

| Branch | Change | Evals passed in 3 runs |
|---|---|---|
| `rung-0` | The raw tables, no documentation | 11, 11 and 12 of 25 |
| `rung-1` | Descriptions of the raw tables, as database comments | 13, 14 and 14 of 25 |
| `rung-2` | dbt's marts and their descriptions, instead of the raw tables | 15, 14 and 17 of 25 |
| `rung-3` | The marts without `customers.customer_type`, plus a guide | 25, 25 and 25 of 25 |

To reproduce a change, check out its branch and follow its README. Each README has the
build steps for that change only.

```bash
git checkout rung-2
```

To see what a change added, compare its branch with the one before:

```bash
git diff rung-1 rung-2
```

Every branch builds the same `climb` database on MotherDuck, so only one change is there
at a time. The guide from `rung-3` stays in your MotherDuck account until you delete it:
delete it before you run another branch (see the README of `rung-3`).

## What's here

| Path | What it holds |
|---|---|
| `data/` | The raw data, generated once with jafgen, and its checksums |
| `evals/raw/`, `evals/marts/` | The 35 evals: same questions and answers, for each layer |
| `dbt/r1_sources.yml` | The descriptions of the raw tables, written for R1 |
| `guides/jaffle_shop.md` | The guide the agent reads in R3 |
| `gold/` | The SQL behind each expected answer |
| `scripts/` | Loading the data, building each change, the holdout split, and checks |
| `docs/methodology_notes.md` | How the data was made, and its limits |
| `honest_agent_config.yml` | One target per setup; `r3` is this branch |

## Follow along

You need [uv](https://docs.astral.sh/uv/), the
[DuckDB CLI](https://duckdb.org/docs/installation/), a MotherDuck account and an
Anthropic API key. Three runs of the 25 evals cost us about $0.50.

**1. Install the dependencies:**

```bash
uv sync
```

**2. Build the marts** in local DuckDB files. This fetches dbt's jaffle-shop project, runs
it on the raw tables and keeps only the marts, with the descriptions from their yml as
comments. The last two lines drop `customers.customer_type`:

```bash
mkdir -p warehouse
sh scripts/fetch_jaffle_shop.sh
duckdb warehouse/climb.duckdb -f scripts/load_local.sql
(cd dbt/jaffle-shop && uv run --project ../.. dbt deps --profiles-dir .. && uv run --project ../.. dbt build --profiles-dir ..)
duckdb warehouse/jaffle_marts.duckdb -f scripts/build_marts_file.sql
duckdb warehouse/jaffle_r2.duckdb -f scripts/build_r2.sql
uv run python scripts/marts_comments.py | duckdb warehouse/jaffle_r2.duckdb
cp warehouse/jaffle_r2.duckdb warehouse/jaffle_r3.duckdb
duckdb warehouse/jaffle_r3.duckdb -f scripts/build_r3.sql
```

**3. Copy them to MotherDuck** as a database named `climb`. This needs a token that can
write, in `MOTHERDUCK_TOKEN`:

```bash
duckdb -c "attach 'md:'; create or replace database climb from 'warehouse/jaffle_r3.duckdb';"
```

**4. Create a `.env` file.** The agent only reads, so use a read-only token here. The
[MotherDuck guide](https://thehonestagent.dev/docs/connect/motherduck/) explains how to
get one.

```
ANTHROPIC_API_KEY=...
MOTHERDUCK_MCP_URL=https://api.motherduck.com/mcp
MOTHERDUCK_MCP_TOKEN=...
```

**5. Create the guide** in your MotherDuck account, from `guides/jaffle_shop.md`.
MotherDuck creates guides only through an agent or an MCP client, so the script calls the
hosted MCP server with the token in `.env`. That token is enough to write guides, so the
agent could change the guide too: check `tools_used` in the results for guide tools after
each run.

```bash
uv run --env-file .env python scripts/guide.py create
```

**6. Run the evals** (each run is paid) and view the report:

```bash
uv run honest-agent run --target r3 --exclude tag:holdout
uv run honest-agent report
uv run honest-agent serve --out honest_agent_report
```

Keep `--exclude tag:holdout` on every run. The 10 holdout evals are only for the end of
the climb, and looking at them earlier defeats their purpose.

Agents and judges aren't deterministic, so your numbers will differ a bit from ours.

**Before you run another branch, delete the guide.** It isn't part of `climb`, so
rebuilding the database leaves it in place. Its uuid is in the output of `create` and
`list`:

```bash
uv run --env-file .env python scripts/guide.py list
uv run --env-file .env python scripts/guide.py delete <uuid>
```

## The data

The files are jaffle-shop's raw data, generated with
[jafgen](https://github.com/dbt-labs/jaffle-shop-generator). It has no seed, so don't
regenerate them: every expected answer comes from these exact files. The load scripts shift
the dates 1827 days forward, so the warehouse runs from 2023-09-02 to 2026-08-31.

The evals treat August 2026 as "this month" and July 2026 as "last month", whatever the
date of your run.

The expected answers were computed on the marts of
[dbt-labs/jaffle-shop](https://github.com/dbt-labs/jaffle-shop). That project isn't
included here, because it has no license file. `scripts/fetch_jaffle_shop.sh` fetches the
commit we used, if you want to rebuild them.

## License

[MIT](LICENSE). The raw data comes from jafgen (Apache 2.0).
