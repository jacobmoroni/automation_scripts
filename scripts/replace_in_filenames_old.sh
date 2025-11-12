#!/bin/bash

# Check for correct number of arguments
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <directory> <old_substring> <new_substring>"
    exit 1
fi

dir="$1"
old_sub="$2"
new_sub="$3"

# Check that the directory exists
if [ ! -d "$dir" ]; then
    echo "Error: Directory '$dir' not found."
    exit 1
fi

echo "replacing {$old_sub} with {$new_sub}"
# Loop through matching files
for file in "$dir"/*"$old_sub"*; do
    echo $file
    # Skip if no files match
    [ -e "$file" ] || continue

    # Extract directory and filename
    base=$(basename "$file")
    newname="${base//$old_sub/$new_sub}"
    echo "NAME: $base -> $newname"
    # Only rename if different
    if [ "$base" != "$newname" ]; then
        echo "moving $file to $newname"
        mv -v "$file" "$dir/$newname"
    fi
done

