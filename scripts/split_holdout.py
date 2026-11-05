"""Draw the holdout split: 10 of the evals, stratified, with a fixed seed.

Strata: ambiguous evals (the "ask for context" cases the guides fix) form their own
stratum; the rest are grouped by grading method. Each stratum gets a share of the 10
proportional to its size (largest remainder), then the evals are drawn at random.
Prints the chosen ids; tagging them `holdout` in both layers is a separate step.
Run from the repo root: uv run python scripts/split_holdout.py
"""

import random
from collections import defaultdict
from pathlib import Path

import yaml

SEED = 20261020
HOLDOUT_SIZE = 10


def load_evals(folder: Path) -> list[dict]:
    evals = []
    for path in sorted(folder.glob("*.yml")):
        for category in yaml.safe_load(path.read_text())["evals"]:
            default_method = category.get("grading", {}).get("method")
            for test in category["tests"]:
                method = test.get("grading", {}).get("method", default_method)
                tags = test.get("tags", [])
                stratum = "ambiguous" if "ambiguous" in tags else method
                evals.append({"id": test["id"], "stratum": stratum})
    return evals


def main() -> None:
    evals = load_evals(Path("evals/marts"))
    strata = defaultdict(list)
    for e in evals:
        strata[e["stratum"]].append(e["id"])

    exact = {s: HOLDOUT_SIZE * len(ids) / len(evals) for s, ids in strata.items()}
    share = {s: int(x) for s, x in exact.items()}
    for s in sorted(exact, key=lambda s: exact[s] - share[s], reverse=True)[: HOLDOUT_SIZE - sum(share.values())]:
        share[s] += 1

    rng = random.Random(SEED)
    holdout = []
    for s in sorted(strata):
        picked = rng.sample(sorted(strata[s]), share[s])
        print(f"{s}: {len(strata[s])} evals, {share[s]} held out: {', '.join(picked)}")
        holdout += picked
    print("\nholdout:", " ".join(sorted(holdout)))


if __name__ == "__main__":
    main()
