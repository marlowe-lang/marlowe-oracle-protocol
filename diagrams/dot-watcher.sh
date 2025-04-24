#!/usr/bin/env bash

inotifywait -m -e modify --quiet --format '%w%f' --include '.*\.dot$' . | while read -r dotfile; do
    echo "Detected change in $dotfile"
    svgfile="${dotfile%.dot}.svg"
    # Compile only the modified .dot to .svg
    dot -n2 -Tsvg:cairo -o "$svgfile" "$dotfile"
    echo "Generated $svgfile"
    # Open (or bring to front) only that single SVG
    firefox "$svgfile" &
done
