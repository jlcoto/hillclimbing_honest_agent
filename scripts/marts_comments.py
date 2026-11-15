"""Prints the descriptions in the yml of jaffle-shop's marts as DuckDB comments on the
tables in schema marts (R2). The agent reads database comments, never the yml. Run from
the repo root and pipe it into the database:

  uv run python scripts/marts_comments.py | duckdb warehouse/jaffle_r2.duckdb
"""

from pathlib import Path

import yaml

MARTS = Path("dbt/jaffle-shop/models/marts")
TABLES = ["orders", "order_items", "customers", "products", "locations", "supplies"]


def quote(text: str) -> str:
    return "'" + " ".join(text.split()).replace("'", "''") + "'"


for path in sorted(MARTS.glob("*.yml")):
    for model in yaml.safe_load(path.read_text()).get("models", []):
        if model["name"] not in TABLES:
            continue
        if model.get("description"):
            print(f'comment on table marts."{model["name"]}" is {quote(model["description"])};')
        for column in model.get("columns", []):
            if column.get("description"):
                print(f'comment on column marts."{model["name"]}"."{column["name"]}" is {quote(column["description"])};')
