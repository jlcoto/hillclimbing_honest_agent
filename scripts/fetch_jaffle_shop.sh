#!/bin/sh
# Fetches dbt-labs/jaffle-shop at the commit this experiment uses into dbt/jaffle-shop.
# Not vendored: the repo has no license file, so we point to it instead of copying it.
set -e
commit=5beb145b00f5465ec759cfcdd9745e858818cf95
dir="$(dirname "$0")/../dbt/jaffle-shop"
if [ ! -d "$dir/.git" ]; then
    git clone -q https://github.com/dbt-labs/jaffle-shop.git "$dir"
fi
git -C "$dir" fetch -q origin "$commit"
git -C "$dir" checkout -q "$commit"
echo "jaffle-shop at $(git -C "$dir" rev-parse --short HEAD)"
