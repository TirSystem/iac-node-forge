#!/usr/bin/env bash
# Purpose: print what the CI runner offers, so the test strategy in ADR-0001
#   can decide how the mock provider runs in CI (MIL-001 task 8).
# Needs:   bash 4+, coreutils. Optional: docker, podman, python3, curl.
# Inputs:  none. Reads only an allow-list of environment variables.
# Changes: nothing outside its own output; no token or secret is printed.
# Exit:    0 always; this script reports, it does not judge.
set -euo pipefail

print_header() {
  printf '\n== %s ==\n' "$1"
}

print_tool() {
  local tool="$1"
  if command -v "$tool" >/dev/null 2>&1; then
    printf '%s: %s\n' "$tool" "$(command -v "$tool")"
  else
    printf '%s: not found\n' "$tool"
  fi
}

main() {
  print_header "Host"
  uname -a
  id
  if [[ -r /etc/os-release ]]; then
    grep -E '^(PRETTY_NAME|VERSION_ID)=' /etc/os-release
  fi

  print_header "Runner environment (allow-list)"
  local name
  for name in RUNNER_NAME RUNNER_OS RUNNER_ARCH GITEA_ACTIONS \
    GITHUB_ACTIONS GITHUB_SERVER_URL GITHUB_REPOSITORY GITHUB_EVENT_NAME; do
    printf '%s=%s\n' "$name" "${!name:-<unset>}"
  done

  print_header "Tools"
  for name in docker podman python3 curl git; do
    print_tool "$name"
  done
  if command -v python3 >/dev/null 2>&1; then
    python3 --version
  fi

  print_header "Container runtime socket"
  if [[ -S /var/run/docker.sock ]]; then
    echo "/var/run/docker.sock: present"
  else
    echo "/var/run/docker.sock: absent"
  fi
  printf 'DOCKER_HOST=%s\n' "${DOCKER_HOST:-<unset>}"

  print_header "Inside a container?"
  if [[ -f /.dockerenv ]]; then
    echo "/.dockerenv: present (job runs inside a container)"
  else
    echo "/.dockerenv: absent (job runs on the host)"
  fi
}

main "$@"
