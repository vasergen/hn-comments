set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

default_question := "Extract books, blogs, articles, podcasts, talks, papers, tools or other resources that this user has recommended (or strongly endorsed) in their comments. Group by category: Books, Blogs, Articles/Posts, Podcasts/Talks, Tools, Other. Output clean GitHub-flavored markdown. Skip duplicates."

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

# Run claude -p on the saved comments with QUESTION, save to recommendations.md
analyze USERNAME QUESTION=default_question:
    @test -f users/{{USERNAME}}/comments.txt || { echo "No comments file. Run: just fetch {{USERNAME}}" >&2; exit 1; }
    @echo "Analyzing comments for {{USERNAME}}..."
    @printf '# Analysis: %s\n\n**Question:** %s\n\n---\n\n' "{{USERNAME}}" {{ quote(QUESTION) }} > users/{{USERNAME}}/recommendations.md
    claude -p {{ quote(QUESTION) }} < users/{{USERNAME}}/comments.txt >> users/{{USERNAME}}/recommendations.md
    @echo "Wrote users/{{USERNAME}}/recommendations.md"

# Stage users/<USERNAME>/ and commit if there are changes
commit USERNAME MESSAGE:
    git add users/{{USERNAME}}/
    @if git diff --cached --quiet; then echo "Nothing to commit."; else git commit -m {{ quote(MESSAGE) }}; fi

# Push current branch to origin
push:
    git push
