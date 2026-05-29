#!/usr/bin/env bash
# Pipe a user's comments.txt into a single LLM call.
# Usage: analyze_oneshot.sh USERNAME QUESTION BACKEND MODEL
set -euo pipefail

username="$1"
question="$2"
backend="$3"
model="$4"

src="users/$username/comments.txt"
out="users/$username/recommendations.md"

use_model() {
  local value="$1"
  if [[ -z "$value" || "$value" == "default" ]]; then
    return 1
  fi
  return 0
}

case "$backend" in
  claude)
    if use_model "$model"; then
      claude \
        -p "$question" \
        --model "$model" \
        --no-session-persistence \
        --tools "" \
        < "$src" \
        >> "$out"
    else
      claude \
        -p "$question" \
        --no-session-persistence \
        --tools "" \
        < "$src" \
        >> "$out"
    fi
    ;;
  copilot)
    if use_model "$model"; then
      copilot \
        --prompt "$question" \
        --model "$model" \
        --output-format text \
        --silent \
        --no-ask-user \
        --available-tools= \
        --disable-builtin-mcps \
        --allow-all-paths \
        < "$src" \
        >> "$out"
    else
      copilot \
        --prompt "$question" \
        --output-format text \
        --silent \
        --no-ask-user \
        --available-tools= \
        --disable-builtin-mcps \
        --allow-all-paths \
        < "$src" \
        >> "$out"
    fi
    ;;
  *)
    echo "Unknown backend '$backend' (expected 'claude' or 'copilot')" >&2
    exit 1
    ;;
esac
