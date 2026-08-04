#!/usr/bin/env bash
# Shared flag parsing + dry-run helper for the bootstrap scripts.
# Sourced by the root bootstrap.sh, scripts/mac/bootstrap.sh and
# scripts/linux/bootstrap.sh so the same flags work however it is invoked.

# Parse --dry-run/-n, --yes/-y and --help/-h from "$@".
# Sets and exports DRY_RUN / ASSUME_YES; prints $BOOTSTRAP_USAGE for --help.
bootstrap_parse_args() {
  DRY_RUN=0
  ASSUME_YES=0
  local arg
  for arg in "$@"; do
    case "$arg" in
      --dry-run|-n) DRY_RUN=1 ;;
      --yes|-y)     ASSUME_YES=1 ;;
      -h|--help)
        printf '%s\n' "${BOOTSTRAP_USAGE:-usage: bootstrap.sh [--dry-run] [--yes]}"
        exit 0 ;;
      *)
        printf '❌ unknown option: %s\n' "$arg" >&2
        exit 1 ;;
    esac
  done
  export DRY_RUN ASSUME_YES
}

# Run a command, or just print it when DRY_RUN=1.
bootstrap_run() {
  if [ "${DRY_RUN:-0}" = 1 ]; then
    printf '   [dry-run] %s\n' "$*"
  else
    "$@"
  fi
}
