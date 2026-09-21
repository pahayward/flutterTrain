#!/usr/bin/env bash
# Verify every runnable ```go block in courseware via the yaegi engine.
# Usage: tools/verify_go_examples.sh [optional md file/glob...]
set -euo pipefail
cd "$(dirname "$0")/.."
FILES="${*:-$(find courseware/golang -name '*.md' | sort)}"
# checkcontent runs from app/go, so make every path absolute first.
ABS=""
for f in $FILES; do
  case "$f" in
    /*) ABS="$ABS $f" ;;
    *) ABS="$ABS $PWD/$f" ;;
  esac
done
# shellcheck disable=SC2086
(cd app/go && go run ./cmd/checkcontent $ABS)
