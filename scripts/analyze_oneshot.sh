#!/usr/bin/env bash
# Pipe a user's comments.txt into a single copilot call.
# Usage: analyze_oneshot.sh USERNAME QUESTION MODEL
set -euo pipefail

username="$1"
question="$2"
model="$3"

src="users/$username/comments.txt"
out="users/$username/recommendations.md"

sandbox=$(mktemp -d)
trap 'rm -rf "$sandbox"' EXIT

copilot \
  -C "$sandbox" \
  --model "$model" \
  --allow-all-tools \
  --no-custom-instructions \
  --disallow-temp-dir \
  -p "$question" \
  < "$src" \
  >> "$out"
