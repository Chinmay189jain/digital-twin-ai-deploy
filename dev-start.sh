#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$ROOT_DIR/digital-twin-ai-backend"
FRONTEND_DIR="$ROOT_DIR/digital-twin-ai-frontend"

if [[ ! -d "$BACKEND_DIR" ]]; then
  echo "Missing folder: $BACKEND_DIR" >&2
  exit 1
fi

if [[ ! -d "$FRONTEND_DIR" ]]; then
  echo "Missing folder: $FRONTEND_DIR" >&2
  exit 1
fi

(
  cd "$BACKEND_DIR"
  ./mvnw spring-boot:run
) &
BACKEND_PID=$!

(
  cd "$FRONTEND_DIR"
  npm start
) &
FRONTEND_PID=$!

cleanup() {
  kill "$BACKEND_PID" "$FRONTEND_PID" 2>/dev/null || true
}

trap cleanup INT TERM EXIT
wait
