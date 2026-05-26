#!/usr/bin/env bash
# Pipe a user's comments.txt into a single claude call.
# Usage: analyze_oneshot.sh USERNAME QUESTION MODEL
set -euo pipefail

username="$1"
question="$2"
model="$3"

src="users/$username/comments.txt"
out="users/$username/recommendations.md"

claude \
  -p "$question" \
  --model "$model" \
  --no-session-persistence \
  --tools "" \
  < "$src" \
  >> "$out"
