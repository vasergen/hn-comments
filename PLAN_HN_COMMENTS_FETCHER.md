# Plan: HN Comments Fetcher & Analyzer

## Summary
Build a small repository that, given an HN username, fetches all of that user's comments, stores them in a file, commits the result to git, then runs an analysis prompt (e.g. "list recommended books / blogs / articles") and stores the answer as a markdown file for later reading. The whole flow is driven by a single `just` command.

## Goal
One command:
```
just run USERNAME
```
…produces, under `users/<username>/`:
- `comments.json` — raw comments from HN
- `comments.md` — human-readable rendering (optional, nice to have)
- `recommendations.md` — analysis output (books/blogs/articles)
- a git commit containing all of the above

---

## Approach

### Fetching comments
Use the **Algolia HN Search API** — it supports filtering by author directly and is much simpler than walking the Firebase API:

```
https://hn.algolia.com/api/v1/search_by_date?tags=comment,author_<username>&hitsPerPage=1000
```

Paginate via `page=` until exhausted. Each hit has `comment_text`, `story_title`, `story_url`, `created_at`, `objectID` (use as permalink: `https://news.ycombinator.com/item?id=<objectID>`).

### Analysis (Q&A)
Use the **`claude` CLI in non-interactive mode** (`claude -p`) to ask the question over the saved comments file. Rationale:
- No SDK/API key wiring needed — reuses the user's existing Claude Code auth.
- Output is plain text/markdown, easy to write to a file.
- Keeps the script tiny.

Default question: *"Extract all books, blogs, articles, podcasts and other resources this user recommended in their comments. Group by category. For each, include the quote and a link to the HN comment."*

### Script language
**Python 3** (stdlib only — `urllib`, `json`, `pathlib`, `argparse`, `subprocess`). No dependency install step. One file: `scripts/fetch_and_analyze.py`.

### Orchestration
A `justfile` with one main recipe + a couple of helpers:
```
run USERNAME:        # fetch -> save -> analyze -> commit
fetch USERNAME:      # just the fetch step
analyze USERNAME:    # re-run analysis on existing comments
```

---

## Step-by-step implementation

1. **Repo scaffolding**
   - `.gitignore` (pyc, .venv, .DS_Store)
   - `README.md` — usage in 10 lines
   - `users/.gitkeep`

2. **`scripts/fetch_and_analyze.py`**
   - `argparse`: `--user`, `--question` (optional, has default), `--no-commit`, `--skip-fetch`
   - `fetch_comments(user)` — paginate Algolia until `nbPages` exhausted, return list of dicts
   - `save_json(path, data)` and `save_markdown(path, comments)` — markdown version groups by story
   - `analyze(comments_path, question)` — `subprocess.run(["claude", "-p", prompt], ...)`; prompt embeds the question and the path/contents of comments.md
   - `git_commit(user, paths)` — `git add` + `git commit -m "Add HN data for <user>"` (skip if nothing changed)
   - `main()` ties it together

3. **`justfile`**
   ```
   default: (run "")

   run USERNAME:
       python3 scripts/fetch_and_analyze.py --user {{USERNAME}}

   fetch USERNAME:
       python3 scripts/fetch_and_analyze.py --user {{USERNAME}} --skip-analyze

   analyze USERNAME QUESTION="default":
       python3 scripts/fetch_and_analyze.py --user {{USERNAME}} --skip-fetch --question {{QUESTION}}
   ```

4. **First smoke test**
   - Run `just run pg` (Paul Graham — well-known account, lots of comments) and confirm the three files appear and the commit lands.

---

## Decisions (confirmed)

1. **Analysis backend**: `claude -p` CLI — reuses existing auth, no SDK install.
2. **Question**: configurable with a default. Usage: `just run USERNAME` (uses default) or `just run USERNAME "your question"`. The question is saved alongside the answer.
3. **Fetch limit**: all comments. Warn (don't abort) when `nbHits > 5000`.
4. **Git**: auto-commit and auto-push to `origin` on the current branch.
5. **Markdown rendering**: generate both `comments.json` and `comments.md`; the markdown is what's fed to the analysis prompt.

## Out of scope
- Web UI / dashboard
- Cross-user aggregation
- Pushing to a remote (only local commits)
- Scheduled / recurring runs (can add later via `/loop` or cron)
- LLM provider abstraction
