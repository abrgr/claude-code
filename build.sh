#!/bin/bash
set -euo pipefail

GCS_BUCKET="https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases"

# Get latest Claude Code version from the official release bucket
CLAUDE_VERSION=$(curl -fsSL "${GCS_BUCKET}/latest")
echo "Building with Claude Code version: ${CLAUDE_VERSION}"

docker build \
  --build-arg CLAUDE_VERSION="${CLAUDE_VERSION}" \
  -t "claude-code:${CLAUDE_VERSION}" \
  -t "claude-code:latest" \
  .
