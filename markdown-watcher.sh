#!/usr/bin/env bash


inotifywait -m -e modify --quiet --format '%w%f' --include '.*\.md$' . | while read -r mdfile; do
    echo "Detected change in $mdfile"
    htmlfile="${mdfile%.md}.html"
    # Compile only the modified .dot to .svg
    # marked -w "$mdfile" -o "$htmlfile" --no-highlight
    # pandoc --standalone --embed-resource -c github-markdown.css -f gfm -t html example.md -o example.html
    pandoc --standalone \
      --from=gfm --to=html \
      -c github-markdown.css \
      "$mdfile" -o "$htmlfile"
    echo "Generated $htmlfile"
    # Open (or bring to front) only that single SVG
    firefox "$htmlfile" &
done
