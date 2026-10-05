# Site Agent Context

## Stack
- MkDocs + Material for MkDocs
- Python 3.12 managed by uv (no pip). Deps in `pyproject.toml`, locked in `uv.lock`
- Keep `mkdocs<2`: MkDocs 2.0 drops the plugin system
- Deployed to GitHub Pages: push to `main` (GitHub Actions) or `./scripts/publish.sh`
- Local preview: `uv run mkdocs serve`

## Source directory
`content/` — MkDocs `docs_dir` is set to `content/` (avoids conflict with MkDocs' default `site/` output dir)

## Content structure
```
content/
├── index.md
├── blog/posts/       # Personal writing, showcases
├── articles/         # Long-form technical deep-dives
├── collections/      # Curated reading lists, awesome libs/tools
└── notes/            # Quick tips, snippets
```

## Writing framework
Apply Diátaxis where it makes sense:
- **Explanation** — why something works a certain way
- **How-to** — solving a specific problem
- **Reference** — lookup tables, config, API surface
- **Tutorial** — step-by-step learning

For single-page articles, Diátaxis applies as section structure within the page, not separate files.

## Not published
Anything outside `content/` is not built or deployed.

- `draft/` — work-in-progress articles, move to `content/` when ready to publish
- `internal/` — agent context, prompts, private notes
- `.ai-workspace/` — gitignored scratch space for AI agents

## Skills
- `q-research` (`.claude/skills/`) — researches a topic and writes a cited draft to `draft/`, with a "Last updated" line under the title and a source link on each paragraph that uses a source

## Plugins
- `blog` — posts with RSS, dates, tags
- `tags` — cross-section tagging
- `search`
