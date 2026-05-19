#!/usr/bin/env bash
# Map-reduce a large comments.txt through copilot.
# Splits the file at the record separator ('=' x 72), runs a map call per
# chunk, optionally mid-reduces, then a final reduce into recommendations.md.
#
# Each copilot call runs in an isolated empty sandbox dir with file tools
# effectively neutralized — the only input is the stdin chunk we pipe in.
#
# Usage: analyze_chunked.sh USERNAME QUESTION MODEL CHUNK_BYTES
set -euo pipefail

username="$1"
question="$2"
model="$3"
chunk_bytes="$4"

user_dir="users/$username"
work="$user_dir/.chunks"
src="$user_dir/comments.txt"
out="$user_dir/recommendations.md"

rm -rf "$work"
mkdir -p "$work"

sandbox=$(mktemp -d)
trap 'rm -rf "$sandbox"' EXIT

copilot_call() {
  local prompt="$1"
  copilot \
    -C "$sandbox" \
    --model "$model" \
    --allow-all-tools \
    --no-custom-instructions \
    --disallow-temp-dir \
    -p "$prompt"
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
echo "Split into $total chunks (~${chunk_bytes} bytes each)."

map_prompt="You are extracting raw items for this question: ${question}
From the comments below, output ONLY a flat list, one item per line, each tagged with one of: [BOOK], [BLOG], [ARTICLE], [PODCAST], [TALK], [PAPER], [TOOL], [OTHER]. Include title and author or URL when present. No prose, no headers, no duplicates within this chunk."

partials="$work/partials.md"
: > "$partials"
i=0
for chunk in "${chunks[@]}"; do
  i=$((i + 1))
  echo "[$i/$total] map: $(basename "$chunk")"
  copilot_call "$map_prompt" < "$chunk" >> "$partials"
  printf '\n' >> "$partials"
done

# If partials are themselves too large, mid-reduce them in chunks first.
psize=$(wc -c < "$partials")
mid_limit=$(( chunk_bytes * 4 ))
if [ "$psize" -gt "$mid_limit" ]; then
  echo "Partials are $psize bytes — running mid-reduce pass."
  mid_dir="$work/mid"
  mkdir -p "$mid_dir"
  split -C "$chunk_bytes" -d -a 4 "$partials" "$mid_dir/part_"
  mid_out="$work/partials2.md"
  : > "$mid_out"
  mid_chunks=("$mid_dir"/part_*)
  mid_total=${#mid_chunks[@]}
  mid_prompt="Merge and deduplicate the tagged items below. Keep the same one-per-line tagged format ([BOOK], [BLOG], …). No prose."
  j=0
  for part in "${mid_chunks[@]}"; do
    j=$((j + 1))
    echo "[$j/$mid_total] mid-reduce: $(basename "$part")"
    copilot_call "$mid_prompt" < "$part" >> "$mid_out"
    printf '\n' >> "$mid_out"
  done
  partials="$mid_out"
fi

reduce_prompt="Below is a flat list of items extracted from many comment chunks for the question: ${question}
Merge, deduplicate (case-insensitive, tolerate minor title variants), and produce final clean GitHub-flavored markdown grouped by category: Books, Blogs, Articles/Posts, Podcasts/Talks, Papers, Tools, Other. Drop the [TAG] prefixes. No commentary."

echo "Reducing into final recommendations..."
copilot_call "$reduce_prompt" < "$partials" >> "$out"
