"""Writes the descriptions in dbt's __sources.yml as DuckDB comments on the raw tables, so
the agent sees them (R1). dbt's persist_docs only covers models, not sources, and the agent
reads database comments, never the yml. Run from the repo root:

  uv run python scripts/apply_comments.py warehouse/jaffle_r1.duckdb   # a local file
  uv run python scripts/apply_comments.py md:climb_r1                  # MotherDuck (MOTHERDUCK_TOKEN)
  uv run python scripts/apply_comments.py <db> --dry-run               # print the SQL only
  uv run python scripts/apply_comments.py <db> --clear                 # remove the comments

Every table and column in the yml must exist in the database, and every column of those
tables must be in the yml: a typo or a missing column stops the script before it writes.
Running it again overwrites the comments.
"""

import argparse
import sys
from pathlib import Path

import duckdb
import yaml

SOURCES = Path("dbt/jaffle-shop/models/staging/__sources.yml")


def quote(text: str | None) -> str:
    return "null" if text is None else "'" + text.replace("'", "''") + "'"


def statements(source: dict, clear: bool) -> list[str]:
    schema = source["schema"]
    sql = []
    for table in source["tables"]:
        name = f"{schema}.{table['name']}"
        sql.append(f"comment on table {name} is {quote(None if clear else table.get('description'))};")
        for column in table.get("columns", []):
            text = None if clear else column.get("description")
            sql.append(f"comment on column {name}.{column['name']} is {quote(text)};")
    return sql


def check(con: duckdb.DuckDBPyConnection, source: dict) -> list[str]:
    """Differences between the yml and the database, empty when they match."""
    problems = []
    for table in source["tables"]:
        found = {
            row[0]
            for row in con.execute(
                "select column_name from duckdb_columns() "
                "where schema_name = ? and table_name = ? and database_name = current_database()",
                [source["schema"], table["name"]],
            ).fetchall()
        }
        if not found:
            problems.append(f"table {source['schema']}.{table['name']} not in the database")
            continue
        described = {column["name"] for column in table.get("columns", [])}
        problems += [f"{table['name']}.{c}: in the yml, not in the database" for c in sorted(described - found)]
        problems += [f"{table['name']}.{c}: in the database, not in the yml" for c in sorted(found - described)]
        problems += [
            f"{table['name']}.{column['name']}: empty description"
            for column in table.get("columns", [])
            if not column.get("description")
        ]
    return problems


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("database", help="a DuckDB file or md:<database>")
    parser.add_argument("--dry-run", action="store_true", help="print the SQL, don't write")
    parser.add_argument("--clear", action="store_true", help="set every comment to null")
    args = parser.parse_args()

    (source,) = yaml.safe_load(SOURCES.read_text())["sources"]
    sql = statements(source, args.clear)
    if args.dry_run:
        print("\n".join(sql))
        return 0

    con = duckdb.connect(args.database)
    if not args.clear and (problems := check(con, source)):
        print("Not written; the yml and the database differ:", *problems, sep="\n  ", file=sys.stderr)
        return 1
    for statement in sql:
        con.execute(statement)

    written = con.execute(
        "select count(*) filter (where comment is not null), count(*) from duckdb_columns() "
        "where schema_name = ? and database_name = current_database()",
        [source["schema"]],
    ).fetchone()
    print(f"{args.database}: {written[0]} of {written[1]} columns in {source['schema']} have a comment.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
