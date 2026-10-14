#!/usr/bin/env bash
# Purpose: check that a mock provider can run as a plain process inside the job,
#   with no container: start a local HTTP server, call it, stop it. This is the
#   fallback in ADR-0001 (MIL-001 task 8).
# Needs:   bash 4+, python3, curl.
# Usage:   check-in-process-server.sh [port]   (default port: 8099)
# Changes: a temporary directory, removed on exit; one local listener.
# Exit:    0 the server answered, 1 a check failed, 2 usage error.
set -euo pipefail

readonly DEFAULT_PORT=8099
readonly MAX_WAIT_SECONDS=10
SERVER_PID=""
WORK_DIR=""

cleanup() {
  if [[ -n "$SERVER_PID" ]]; then
    kill "$SERVER_PID" 2>/dev/null || true # already stopped is fine
  fi
  if [[ -n "$WORK_DIR" ]]; then
    rm -rf "$WORK_DIR"
  fi
}

die() {
  echo "error: $*" >&2
  exit 1
}

main() {
  if [[ $# -gt 1 ]]; then
    echo "usage: check-in-process-server.sh [port]" >&2
    exit 2
  fi
  local port="${1:-$DEFAULT_PORT}"
  command -v python3 >/dev/null 2>&1 || die "python3 is not on PATH"
  command -v curl >/dev/null 2>&1 || die "curl is not on PATH"

  trap cleanup EXIT
  WORK_DIR="$(mktemp -d)"
  echo "mock-provider-ok" >"$WORK_DIR/ping.txt"
  python3 -m http.server "$port" --bind 127.0.0.1 --directory "$WORK_DIR"     >/dev/null 2>&1 &
  SERVER_PID=$!

  local body="" waited=0
  while ((waited < MAX_WAIT_SECONDS)); do
    if body="$(curl --silent --fail --max-time 2       "http://127.0.0.1:${port}/ping.txt")"; then
      break
    fi
    sleep 1
    waited=$((waited + 1))
  done
  [[ "$body" == "mock-provider-ok" ]] ||
    die "the in-process server did not answer on port $port"
  echo "result: an in-process mock server works in this job"
}

main "$@"
