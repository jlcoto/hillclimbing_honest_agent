"""Checks that evals/raw/ and evals/marts/ hold the same evals: same files, ids, prompts,
gold answers, grading and thresholds. Only provenance.expected_sources may differ, since
each layer has its own tables. Run from the repo root: uv run python scripts/check_evals_sync.py
"""

import sys
from pathlib import Path

import yaml

FOLDERS = [Path("evals/raw"), Path("evals/marts")]


def load(folder: Path) -> dict:
    """{(file, category, id): test} with expected_sources taken out."""
    tests = {}
    for path in sorted(folder.glob("*.yml")):
        doc = yaml.safe_load(path.read_text())
        for category in doc["evals"]:
            settings = {k: v for k, v in category.items() if k != "tests"}
            settings.get("provenance", {}).pop("expected_sources", None)
            for test in category["tests"]:
                test = dict(test)
                test.get("provenance", {}).pop("expected_sources", None)
                tests[(path.name, category["category"], test["id"])] = (settings, test)
    return tests


def main() -> int:
    first, *others = FOLDERS
    reference = load(first)
    problems = []
    for folder in others:
        tests = load(folder)
        for key in sorted(reference.keys() - tests.keys()):
            problems.append(f"{folder}: missing {key[2]} ({key[0]})")
        for key in sorted(tests.keys() - reference.keys()):
            problems.append(f"{folder}: {key[2]} ({key[0]}) isn't in {first}")
        for key in sorted(reference.keys() & tests.keys()):
            if reference[key] != tests[key]:
                problems.append(f"{folder}: {key[2]} ({key[0]}) differs from {first} beyond expected_sources")
    for problem in problems:
        print(problem)
    print("in sync" if not problems else f"{len(problems)} difference(s)")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
