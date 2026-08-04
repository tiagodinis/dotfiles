#!/usr/bin/env bash
# Print the current platform: mac | linux | win | unknown
case "$(uname -s)" in
  Darwin)           echo "mac" ;;
  Linux)            echo "linux" ;;
  MINGW*|MSYS*|CYGWIN*) echo "win" ;;
  *)                echo "unknown" ;;
esac
