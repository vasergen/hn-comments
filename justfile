set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

default_question := "Extract books, blogs, articles, podcasts, talks, papers, tools or other resources that this user has recommended (or strongly endorsed) in their comments. Group by category: Books, Blogs, Articles/Posts, Podcasts/Talks, Tools, Other. Output clean GitHub-flavored markdown. Skip duplicates."

# Bytes per map chunk when comments.txt exceeds the single-shot threshold.
chunk_bytes := "200000"

# Files up to this size are sent to copilot in one shot (current behavior).
single_shot_threshold := "500000"

# Copilot model used for all analysis calls. Override: just analyze ... copilot_model=...
copilot_model := "gpt-5.2"

# Default recipe
_default:
    @just --list

# Fetch comments, commit, analyze, commit, push (one shot)
run USERNAME QUESTION=default_question:
    just fetch {{USERNAME}}
    just commit {{USERNAME}} "Add HN comments for {{USERNAME}}"
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
    ./scripts/analyze_oneshot.sh {{USERNAME}} {{ quote(QUESTION) }} {{copilot_model}}

# Map-reduce path: implementation lives in scripts/analyze_chunked.sh.
_analyze_chunked USERNAME QUESTION:
    ./scripts/analyze_chunked.sh {{USERNAME}} {{ quote(QUESTION) }} {{copilot_model}} {{chunk_bytes}}

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
