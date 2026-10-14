#!/usr/bin/env bash
# Purpose: check whether a service container declared by the workflow is
#   reachable from the job, trying the candidate addresses in order
#   (MIL-001 task 8).
# Needs:   bash 4+, curl.
# Usage:   check-service.sh <url> [<url>...]
# Inputs:  WAIT_SECONDS (default 30) is how long to wait for each address.
# Changes: nothing; it only sends GET requests.
# Exit:    0 an address answered, 1 none answered, 2 usage error.
set -euo pipefail

readonly DEFAULT_WAIT_SECONDS=30

try_url() {
  local url="$1" waited=0 wait_seconds="${WAIT_SECONDS:-$DEFAULT_WAIT_SECONDS}"
  while ((waited < wait_seconds)); do
    if curl --silent --fail --max-time 3 --output /dev/null "$url"; then
      return 0
    fi
    sleep 2
    waited=$((waited + 2))
  done
  return 1
}

main() {
  if [[ $# -lt 1 ]]; then
    echo "usage: check-service.sh <url> [<url>...]" >&2
    exit 2
  fi
  local url
  for url in "$@"; do
    echo "trying $url"
    if try_url "$url"; then
      echo "result: the service answered at $url"
      return 0
    fi
    echo "no answer at $url"
  done
  echo "error: no candidate address answered; service containers are not usable" \
    "as configured" >&2
  return 1
}

main "$@"
