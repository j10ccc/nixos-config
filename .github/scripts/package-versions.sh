#!/usr/bin/env bash
# Print every host's package versions as JSON: { <Host>: { <pname>: <version> } }.
# Usage: package-versions.sh [extra nix eval args...]
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
apply="$(cat "$here/package-versions.nix")"

{
  nix eval --json ".#darwinConfigurations" --apply "$apply" "$@"
  nix eval --json ".#homeConfigurations" --apply "$apply" "$@"
} | jq -s 'add'
