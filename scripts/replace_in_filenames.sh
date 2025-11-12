#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <directory> <old_substring> <new_substring>"
  echo "Example: $0 ./ ': Kingkiller Chronicle, Book 1 [B002UZMLXM]' ''"
  exit 1
fi

dir="$1"
old="$2"
new="$3"

if [ ! -d "$dir" ]; then
  echo "Error: directory '$dir' does not exist." >&2
  exit 2
fi

# Only operate on files at top-level of the directory. Change -maxdepth if you want recursion.
while IFS= read -r -d '' file; do
  base="$(basename -- "$file")"

  # check if filename contains the literal substring
  if [[ "$base" == *"$old"* ]]; then
    newbase="${base//"$old"/"$new"}"

    # skip if nothing changed
    if [ "$newbase" = "$base" ]; then
      continue
    fi

    src="$file"
    dst="$dir/$newbase"

    # avoid clobbering existing file
    if [ -e "$dst" ]; then
      echo "Skipping (target exists):"
      echo "  $src"
      echo "  -> $dst"
      continue
    fi

    # show and perform move
    printf 'Renaming:\n  %q\n->%q\n\n' "$src" "$dst"
    mv -v -- "$src" "$dst"
  fi
done < <(find "$dir" -maxdepth 1 -type f -print0)

