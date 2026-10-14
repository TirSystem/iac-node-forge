#!/usr/bin/env bash
# Purpose: check whether a job can use Docker: CLI present, daemon reachable,
#   an image can be pulled and a container run (MIL-001 task 8).
# Needs:   bash 4+, docker CLI, network access to the image registry.
# Usage:   check-docker.sh [image]   (default image: alpine:3.20)
# Changes: pulls one small image and runs one throw-away container.
# Exit:    0 Docker works, 1 a check failed, 2 usage error.
set -euo pipefail

readonly DEFAULT_IMAGE="alpine:3.20"
readonly RUN_TIMEOUT_SECONDS=120

die() {
  echo "error: $*" >&2
  exit 1
}

main() {
  if [[ $# -gt 1 ]]; then
    echo "usage: check-docker.sh [image]" >&2
    exit 2
  fi
  local image="${1:-$DEFAULT_IMAGE}"

  command -v docker >/dev/null 2>&1 ||
    die "the docker CLI is not on PATH; Docker is not available to this job"
  echo "docker CLI: $(command -v docker)"

  docker version --format '{{.Server.Version}}' >/dev/null 2>&1 ||
    die "the Docker daemon is not reachable; mount the socket or use the in-process mock"
  echo "docker daemon: $(docker version --format '{{.Server.Version}}')"

  timeout "$RUN_TIMEOUT_SECONDS" docker run --rm "$image" echo "container ran" ||
    die "could not run image $image within ${RUN_TIMEOUT_SECONDS}s"
  echo "result: Docker is usable from this job"
}

main "$@"
