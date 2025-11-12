#!/bin/bash

# Exit on error
set -e

# --- Usage ---
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <input_directory> <speed_factor>"
    echo "Example: $0 ./music 1.6"
    exit 1
fi

input_dir="$1"
speed="$2"
output_dir="${input_dir%/}/sped_up"

# Check if input directory exists
if [ ! -d "$input_dir" ]; then
    echo "Error: Directory '$input_dir' does not exist."
    exit 1
fi

# Create output directory
mkdir -p "$output_dir"

echo "Input directory:  $input_dir"
echo "Output directory: $output_dir"
echo "Speed factor:     $speed"
echo

# Loop through all mp3 files in the input directory
shopt -s nullglob
for file in "$input_dir"/*.mp3; do
    filename=$(basename "$file")
    output_file="$output_dir/$filename"

    echo "Processing '$filename'..."

    # Build the atempo filter (supports chaining for speeds >2.0)
    if (( $(echo "$speed <= 2.0" | bc -l) )); then
        filter="atempo=${speed}"
    else
        remaining_speed=$speed
        filter=""
        while (( $(echo "$remaining_speed > 2.0" | bc -l) )); do
            filter="${filter}atempo=2.0,"
            remaining_speed=$(echo "$remaining_speed / 2.0" | bc -l)
        done
        filter="${filter}atempo=${remaining_speed}"
    fi

    # Run ffmpeg command
    ffmpeg -hide_banner -loglevel error -i "$file" -filter:a "$filter" -vn "$output_file" -y

    echo " -> Saved as '$output_file'"
done

echo
echo "✅ All MP3s processed and saved in '$output_dir/'"

