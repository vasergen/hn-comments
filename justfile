set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

default_question := "Extract books, blogs, articles, podcasts, talks, papers, tools or other resources that this user has recommended (or strongly endorsed) in their comments. Group by category: Books, Blogs, Articles/Posts, Podcasts/Talks, Tools, Other. Output clean GitHub-flavored markdown. Skip duplicates."

# Bytes per map chunk when comments.txt exceeds the single-shot threshold.
chunk_bytes := "500000"

# Files up to this size are sent to claude in one shot.
single_shot_threshold := "800000"

# Max concurrent map calls in the chunked path.
map_concurrency := "4"

# Claude model used for all analysis calls. Override: just analyze ... claude_model=...
claude_model := "haiku"

# Default recipe
_default:
    @just --list

# Fetch comments, commit, analyze, commit, push (one shot)
# Reuses users/<USERNAME>/comments.txt if it's less than 7 days old.
run USERNAME QUESTION=default_question:
    @if [ -f users/{{USERNAME}}/comments.txt ] && [ -n "$(find users/{{USERNAME}}/comments.txt -mtime -7 2>/dev/null)" ]; then \
      echo "Using cached users/{{USERNAME}}/comments.txt (< 7 days old)"; \
    else \
      just fetch {{USERNAME}}; \
      just commit {{USERNAME}} "Add HN comments for {{USERNAME}}"; \
    fi
    just analyze {{USERNAME}} {{ quote(QUESTION) }}
    just commit {{USERNAME}} "Add analysis for {{USERNAME}}"
    just push

# Fetch comments for a user into users/<USERNAME>/comments.txt
fetch USERNAME:
    mkdir -p users/{{USERNAME}}
    ./hn-comments {{USERNAME}} > users/{{USERNAME}}/comments.txt
    @wc -l users/{{USERNAME}}/comments.txt

# Run copilot on the saved comments with QUESTION, save to recommendations.md.
# Small files go through copilot in one shot; large files are map-reduced.
analyze USERNAME QUESTION=default_question:
    @test -f users/{{USERNAME}}/comments.txt || { echo "No comments file. Run: just fetch {{USERNAME}}" >&2; exit 1; }
    @size=$(wc -c < users/{{USERNAME}}/comments.txt); \
    echo "Analyzing comments for {{USERNAME}} ($size bytes)..."; \
    printf '# Analysis: %s\n\n**Question:** %s\n\n---\n\n' "{{USERNAME}}" {{ quote(QUESTION) }} > users/{{USERNAME}}/recommendations.md; \
    if [ "$size" -eq 0 ]; then \
      echo "(empty comments file — nothing to analyze)"; \
    elif [ "$size" -le {{single_shot_threshold}} ]; then \
      just _analyze_oneshot {{USERNAME}} {{ quote(QUESTION) }}; \
    else \
      just _analyze_chunked {{USERNAME}} {{ quote(QUESTION) }}; \
    fi
    @echo "Wrote users/{{USERNAME}}/recommendations.md"

# One-shot path: implementation lives in scripts/analyze_oneshot.sh.
_analyze_oneshot USERNAME QUESTION:
    ./scripts/analyze_oneshot.sh {{USERNAME}} {{ quote(QUESTION) }} {{claude_model}}

# Map-reduce path: implementation lives in scripts/analyze_chunked.sh.
_analyze_chunked USERNAME QUESTION:
    ./scripts/analyze_chunked.sh {{USERNAME}} {{ quote(QUESTION) }} {{claude_model}} {{chunk_bytes}} {{map_concurrency}}

# Remove map-reduce scratch dir for a user.
clean USERNAME:
    rm -rf users/{{USERNAME}}/.chunks

# Stage users/<USERNAME>/ and commit if there are changes
commit USERNAME MESSAGE:
    git add users/{{USERNAME}}/
    @if git diff --cached --quiet; then echo "Nothing to commit."; else git commit -m {{ quote(MESSAGE) }}; fi

# Push current branch to origin
push:
    git push
