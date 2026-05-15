# hn-comments

Fetch a HackerNews user's comments, ask Claude to extract any books / blogs / articles / podcasts they recommended, and commit the result.

## Requirements
- [just](https://github.com/casey/just)
- `python3` (stdlib only)
- [`claude`](https://docs.claude.com/en/docs/claude-code) CLI in `$PATH`
- `git` with push access to this repo

## Usage

```sh
just run USERNAME                     # default question (extract recommendations)
just run USERNAME "your question..."   # ask anything else
```

Outputs land in `users/<USERNAME>/`:
- `comments.txt` — every non-deleted comment, newest first
- `recommendations.md` — Claude's answer

Two commits are created (`Add HN comments for X`, `Add analysis for X`) and pushed to `origin`.

## Sub-recipes

```sh
just fetch USERNAME      # only fetch + save
just analyze USERNAME    # rerun analysis on existing comments.txt
just analyze USERNAME "different question"
just commit USERNAME "msg"
just push
```

## Notes
- The fetch script uses the official HN Firebase API with 50 parallel workers; expect ~30s for a typical user, longer for prolific ones (pg, tptacek, etc.).
- For very prolific users, `comments.txt` can be many MB and the analysis prompt will be large — make sure your `claude` session is on a model with enough context.
