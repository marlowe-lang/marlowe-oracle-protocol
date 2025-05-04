#!/usr/bin/env bash

# Regenerate all the graphs
fd -g '*.dot' |while read -r dotfile; do
    echo "Generating $dotfile"
    svgfile="${dotfile%.dot}.svg"
    # Compile all .dot files to .svg
    dot -n2 -Tsvg:cairo -o "$svgfile" "$dotfile"
done

inotifywait -m -e modify --quiet --format '%w%f' --include '.*\.dot$' . | while read -r dotfile; do
    echo "Detected change in $dotfile"
    svgfile="${dotfile%.dot}.svg"
    # Compile only the modified .dot to .svg
    dot -n2 -Tsvg:cairo -o "$svgfile" "$dotfile"
    echo "Generated $svgfile"
    # Open (or bring to front) only that single SVG
    firefox "$svgfile" &
done
