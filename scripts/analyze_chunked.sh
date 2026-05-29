#!/usr/bin/env bash
# Map-reduce a large comments.txt through a selectable LLM backend.
# Splits the file at the record separator ('=' x 72), runs map calls in
# parallel per chunk, then a single reduce into recommendations.md.
#
# Usage: analyze_chunked.sh USERNAME QUESTION BACKEND MODEL CHUNK_BYTES CONCURRENCY
set -euo pipefail

username="$1"
question="$2"
backend="$3"
model="$4"
chunk_bytes="$5"
concurrency="$6"

user_dir="users/$username"
work="$user_dir/.chunks"
src="$user_dir/comments.txt"
out="$user_dir/recommendations.md"

rm -rf "$work"
mkdir -p "$work"

use_model() {
  local value="$1"
  if [[ -z "$value" || "$value" == "default" ]]; then
    return 1
  fi
  return 0
}

llm_call() {
  local prompt="$1"
  local input_file="${2:-}"
  case "$backend" in
    claude)
      if use_model "$model"; then
        if [[ -n "$input_file" ]]; then
          claude \
            -p "$prompt" \
            --model "$model" \
            --no-session-persistence \
            --tools "" \
            < "$input_file"
        else
          claude \
            -p "$prompt" \
            --model "$model" \
            --no-session-persistence \
            --tools ""
        fi
      else
        if [[ -n "$input_file" ]]; then
          claude \
            -p "$prompt" \
            --no-session-persistence \
            --tools "" \
            < "$input_file"
        else
          claude \
            -p "$prompt" \
            --no-session-persistence \
            --tools ""
        fi
      fi
      ;;
    copilot)
      if use_model "$model"; then
        if [[ -n "$input_file" ]]; then
          copilot \
            --prompt "$prompt" \
            --model "$model" \
            --output-format text \
            --silent \
            --no-ask-user \
            --available-tools= \
            --disable-builtin-mcps \
            --allow-all-paths \
            < "$input_file"
        else
          copilot \
            --prompt "$prompt" \
            --model "$model" \
            --output-format text \
            --silent \
            --no-ask-user \
            --available-tools= \
            --disable-builtin-mcps \
            --allow-all-paths
        fi
      else
        if [[ -n "$input_file" ]]; then
          copilot \
            --prompt "$prompt" \
            --output-format text \
            --silent \
            --no-ask-user \
            --available-tools= \
            --disable-builtin-mcps \
            --allow-all-paths \
            < "$input_file"
        else
          copilot \
            --prompt "$prompt" \
            --output-format text \
            --silent \
            --no-ask-user \
            --available-tools= \
            --disable-builtin-mcps \
            --allow-all-paths
        fi
      fi
      ;;
    *)
      echo "Unknown backend '$backend' (expected 'claude' or 'copilot')" >&2
      exit 1
      ;;
  esac
}

# Split at the record separator into byte-bounded chunks.
awk -v limit="$chunk_bytes" -v outdir="$work" '
  BEGIN {
    RS = "========================================================================\n"
    n = 1; bytes = 0
    out = sprintf("%s/chunk_%04d.txt", outdir, n)
  }
  NR == 1 && $0 == "" { next }
  {
    rec = "========================================================================\n" $0
    rlen = length(rec)
    if (bytes > 0 && bytes + rlen > limit) {
      n++; bytes = 0
      out = sprintf("%s/chunk_%04d.txt", outdir, n)
    }
    printf "%s", rec > out
    bytes += rlen
  }
' "$src"

chunks=("$work"/chunk_*.txt)
total=${#chunks[@]}
echo "Split into $total chunks (~${chunk_bytes} bytes each). Mapping with concurrency=$concurrency."

map_prompt="You are extracting raw items for this question: ${question}
The HN comments are provided as an attached text file. Output ONLY a flat list, one item per line, each tagged with one of: [BOOK], [BLOG], [ARTICLE], [PODCAST], [TALK], [PAPER], [TOOL], [OTHER]. Include title and author or URL when present. No prose, no headers, no duplicates within this chunk."

# Run map calls in parallel; each writes to its own .out file so the
# final concatenation preserves chunk order regardless of finish order.
running=0
i=0
for chunk in "${chunks[@]}"; do
  i=$((i + 1))
  (
    echo "[$i/$total] map: $(basename "$chunk")"
    llm_call "$map_prompt" "$chunk" > "$chunk.out"
  ) &
  running=$((running + 1))
  if (( running >= concurrency )); then
    wait -n
    running=$((running - 1))
  fi
done
wait

partials="$work/partials.md"
: > "$partials"
for chunk in "${chunks[@]}"; do
  cat "$chunk.out" >> "$partials"
  printf '\n' >> "$partials"
done

reduce_prompt="Below is a flat list of items extracted from many comment chunks for the question: ${question}
The extracted items are provided as an attached text file. Merge, deduplicate (case-insensitive, tolerate minor title variants), and produce final clean GitHub-flavored markdown grouped by category: Books, Blogs, Articles/Posts, Podcasts/Talks, Papers, Tools, Other. Drop the [TAG] prefixes. No commentary."

echo "Reducing into final recommendations..."
llm_call "$reduce_prompt" "$partials" >> "$out"
