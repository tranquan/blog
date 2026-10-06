# blog

Personal knowledge base built with [MkDocs Material](https://squidfunk.github.io/mkdocs-material/).  
Live at: **https://tranquan.github.io/blog/**

## Stack

- MkDocs + Material — static site generator
- Python 3.12, managed by [uv](https://docs.astral.sh/uv/)
- Deployed to GitHub Pages on every push to `main`

## Get started

**Prerequisites:** [uv](https://docs.astral.sh/uv/getting-started/installation/)

```bash
# Install dependencies
uv sync --locked

# Run local dev server (live reload)
uv run mkdocs serve
# → http://127.0.0.1:8000
```

## Content

```
content/
├── articles/   # Long-form technical deep-dives
├── blog/       # Personal posts
├── collections/# Curated lists and tools
└── notes/      # Quick tips and snippets
```

- `draft/` — work in progress; not published
- Move a file from `draft/` to the right folder in `content/` when it's ready

## Deploy

Push to `main` — GitHub Actions builds and deploys automatically.

To deploy manually:

```bash
./scripts/publish.sh
```

> Requires a clean working tree (no uncommitted changes in `content/` or `mkdocs.yml`).

## Deploy setup (first time)

The workflow pushes built HTML to a `gh-pages` branch. After the first push:

1. Go to **Settings → Pages** in the GitHub repo
2. Set source to **Deploy from a branch** → `gh-pages` / `/ (root)`
