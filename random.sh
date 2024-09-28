#!/bin/bash
set -euo pipefail

file="$(dirname $0)/content/random/$(date +%F).md"
if [ ! -f "$file" ]; then
    echo "* " >$file
fi

(${VISUAL:-${EDITOR:-vi}} "${file}" &) || (xdg-open "${file}" &)
