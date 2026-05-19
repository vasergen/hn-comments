# Plan: Chunked `analyze` for large comments files

## Summary
The current `analyze` recipe pipes the entire `users/<USERNAME>/comments.txt` into a single `copilot -p` invocation. This breaks for large files — `tptacek/comments.txt` is ~38MB (72k records), `ChrisArchitect` is ~4MB, both well past Copilot CLI's context window. Goal: make `analyze` robust for arbitrarily large comment files while preserving current behavior for small ones.

## Chosen approach: map-reduce at record boundaries

1. **Split** `comments.txt` into chunks at the record separator (`========================================================================`) so no comment is cut in half. Each chunk is sized under a configurable byte budget (default ~200 KB).
2. **Map**: run `copilot -p "<map prompt derived from QUESTION>"` on every chunk, appending raw extractions to a temporary `partials.md`.
3. **Reduce**: run `copilot -p "<reduce prompt>"` on `partials.md` to merge, deduplicate, and format as GitHub-flavored markdown — written to `recommendations.md`.
4. **Fast path**: if the source file is below a single-shot threshold (default 500 KB), skip chunking and use the current one-shot path. Preserves today's behavior for `WillAdams`, `tiffanyh`, `codegeek`.
5. **Recursive reduce**: if `partials.md` itself exceeds the budget (likely for `tptacek`), run the reduce in two passes — chunk-then-reduce on `partials.md`, then a final pass.

**Rationale**: map-reduce is the standard pattern for context-bounded extraction; pre-filtering by keyword (e.g. grep for "recommend", URLs) risks dropping real signal and ties the recipe to one specific QUESTION. Map-reduce stays question-agnostic.

## Implementation steps

1. **Add tuning variables** at the top of [justfile](justfile):
   - `chunk_bytes := "200000"` — target bytes per chunk
   - `single_shot_threshold := "500000"` — below this, skip chunking
   - Both overridable from CLI via `just analyze ... chunk_bytes=...`.

2. **Refactor `analyze`** ([justfile:24-29](justfile#L24-L29)) into a dispatcher:
   - `wc -c` the input
   - If `≤ single_shot_threshold` → call private `_analyze_oneshot`
   - Else → call private `_analyze_chunked`

3. **Add `_analyze_oneshot USERNAME QUESTION`** — the current body of `analyze` extracted verbatim.

4. **Add `_analyze_chunked USERNAME QUESTION`**:
   - Create `users/<USER>/.chunks/` workspace (clear if present)
   - Use `awk` with `RS='========================================================================\n'` to write chunks `chunk_0001.txt`, `chunk_0002.txt`, … keeping each under `chunk_bytes` and re-emitting the separator at the head of every record
   - Loop over chunks; for each, run `copilot -p "<MAP_PROMPT>"` with stdin = chunk, append to `.chunks/partials.md`. Echo progress: `[i/N]`.
   - If `wc -c partials.md > chunk_bytes * 4`, recursively chunk `partials.md` and run a mid-reduce pass into `partials2.md`; otherwise skip.
   - Final reduce: `copilot -p "<REDUCE_PROMPT>"` with stdin = partials, append to `recommendations.md`.
   - On success, keep `.chunks/` (gitignored) for debugging; document a `clean` recipe.

5. **Prompt construction** (inside the recipe, as plain bash strings):
   - `MAP_PROMPT`: `"You are extracting raw items for this question: <QUESTION>. From the comments below, output ONLY a flat list (one item per line) of candidates, each tagged like [BOOK], [BLOG], [ARTICLE], [PODCAST], [TALK], [PAPER], [TOOL], [OTHER]. Include title, author/URL if present. No prose, no headers, no duplicates within this chunk."`
   - `REDUCE_PROMPT`: `"Below is a flat list of items extracted from many comment chunks for the question: <QUESTION>. Merge, deduplicate (case-insensitive, fuzzy match on titles), and produce final clean GitHub-flavored markdown grouped by category: Books, Blogs, Articles/Posts, Podcasts/Talks, Papers, Tools, Other. Drop tags. No commentary."`

6. **Update `.gitignore`** to exclude `users/*/.chunks/`.

7. **Add `clean USERNAME` recipe** to remove `.chunks/` for a user.

8. **Smoke-test path**: re-run `just analyze WillAdams` (small — should take the fast path, output unchanged) and `just analyze ChrisArchitect` (medium — exercises chunking). Defer `tptacek` until the medium case looks right.

## Risks & open questions

- **Copilot context limit is a guess.** 200 KB ≈ 50k tokens is conservative for GPT-4-class models, but the real ceiling for `copilot -p` isn't documented here. May need to tune `chunk_bytes` after the first run. → Make it overridable from CLI.
- **Cost/time for tptacek.** 38 MB / 200 KB ≈ 190 map calls + reduce(s). This could take many minutes and consume real Copilot quota. Consider gating very large runs behind a confirmation or an explicit `just analyze-big`. → Decision needed.
- **Quality loss from map-reduce.** Cross-chunk dedup depends on the reduce pass catching variants ("SICP" vs "Structure and Interpretation…"). Acceptable for v1; can refine the reduce prompt later.
- **Parallelism.** Could run map calls with `xargs -P` to cut wall time, but unclear if Copilot CLI rate-limits or shares session state. → Start serial; add parallelism only if needed.
- **Custom QUESTION mismatch.** The default question fits the [BOOK]/[BLOG]/… tagging scheme. A different QUESTION (e.g. "summarize this user's stance on cryptocurrency") would not. → Acceptable since the user already accepts `QUESTION` as default; document that chunked mode tunes prompts toward the default extraction task. Alternatively, parameterize tags. Open question.
- **Empty files** (e.g. current `dredmorbius`): already handled by the existing guard at [justfile:25](justfile#L25); preserve it.

## Out of scope

- Replacing `copilot` with a different model/CLI
- Heuristic pre-filtering of comments before LLM
- Parallel map invocations
- Caching map outputs across re-runs (could add a content-hash cache later)
- Changing the default QUESTION
