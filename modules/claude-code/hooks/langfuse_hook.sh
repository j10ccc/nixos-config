#!/usr/bin/env bash
# Wrapper for the Langfuse hook. Sources credentials from a file outside nix
# (so secrets don't end up in the world-readable nix store or in git), then
# execs the Python hook. The Python script reads its JSON payload from stdin.
#
# Drop your secrets at ~/.claude/secrets/langfuse.env (chmod 600), e.g.:
#
#   export TRACE_TO_LANGFUSE=true
#   export LANGFUSE_PUBLIC_KEY=pk-lf-xxx
#   export LANGFUSE_SECRET_KEY=sk-lf-xxx
#   export LANGFUSE_BASE_URL=http://<langfuse-host>:<port>
#
# If TRACE_TO_LANGFUSE is not "true" on this host (toggle off, or no secrets
# file at all), the wrapper exits 0 before paying the Python startup +
# langfuse-SDK import cost.

set -u

SECRETS="${HOME}/.claude/secrets/langfuse.env"
if [ -r "$SECRETS" ]; then
  # shellcheck disable=SC1090
  . "$SECRETS"
fi

[ "${TRACE_TO_LANGFUSE:-}" = "true" ] || exit 0

exec python3 "${HOME}/.claude/hooks/langfuse_hook.py"
