#!/usr/bin/env bash
# Build the site and push it to the gh-pages branch.
set -euo pipefail

cd "$(dirname "$0")/.."

if ! command -v uv >/dev/null; then
  echo "uv not found. Install it: https://docs.astral.sh/uv/" >&2
  exit 1
fi

# gh-deploy builds from the working tree, so uncommitted edits would go live.
if [ -n "$(git status --porcelain -- content mkdocs.yml)" ]; then
  echo "Uncommitted changes in content/ or mkdocs.yml. Commit them first." >&2
  exit 1
fi

uv run --locked mkdocs gh-deploy --force --strict
