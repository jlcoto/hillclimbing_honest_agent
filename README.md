# agent-climb

A hillclimbing experiment on a data agent, rung by rung, using
[The Honest Agent](https://github.com/jlcoto/the_honest_agent) and the Jaffle Shop data.
This repo is the accompanying material of the hillclimbing series on The Data Lead. Start
with [part 1](https://blog.thegroundlayer.io/p/hillclimbing-evals-data-agents), which
introduces hillclimbing.

This branch is **rung 0 (R0)**: the agent queries the raw tables, with no documentation.
The baseline on honest-agent 0.4.0 passed 11, 11 and 12 of 25 evals.

## What's here

| Path | What it holds |
|---|---|
| `data/` | The raw data, generated once with jafgen, and its checksums |
| `evals/raw/`, `evals/marts/` | The 35 evals: same questions and answers, for each layer |
| `gold/` | The SQL behind each expected answer |
| `scripts/` | Loading the data, the holdout split, and checks |
| `docs/methodology_notes.md` | How the data was made, and its limits |
| `honest_agent_config.yml` | One target per setup; `r0` is the baseline |

## Follow along

You need [uv](https://docs.astral.sh/uv/), the
[DuckDB CLI](https://duckdb.org/docs/installation/), a MotherDuck account and an
Anthropic API key. Three runs of the 25 evals cost us about $0.50.

**1. Install the dependencies:**

```bash
uv sync
```

**2. Build the raw tables** in a local DuckDB file:

```bash
mkdir -p warehouse
duckdb warehouse/jaffle_raw.duckdb -f scripts/load_local.sql
```

**3. Copy them to MotherDuck** as a database named `climb`. This needs a token that can
write, in `MOTHERDUCK_TOKEN`:

```bash
duckdb -c "attach 'md:'; create or replace database climb from 'warehouse/jaffle_raw.duckdb';"
```

**4. Create a `.env` file.** The agent only reads, so use a read-only token here. The
[MotherDuck guide](https://thehonestagent.dev/docs/connect/motherduck/) explains how to
get one.

```
ANTHROPIC_API_KEY=...
MOTHERDUCK_MCP_URL=https://api.motherduck.com/mcp
MOTHERDUCK_MCP_TOKEN=...
```

**5. Run the evals** (each run is paid) and view the report:

```bash
uv run honest-agent run --target r0 --exclude tag:holdout
uv run honest-agent report
uv run honest-agent serve --out honest_agent_report
```

Keep `--exclude tag:holdout` on every run. The 10 holdout evals are only for the end of
the climb, and looking at them earlier defeats their purpose.

Agents and judges aren't deterministic, so your numbers will differ a bit from ours.

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
