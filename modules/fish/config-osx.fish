# Homebrew
export BREW_BIN="/opt/homebrew/bin"
export PATH="$BREW_BIN:$PATH"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

if test -d (brew --prefix)"/share/fish/completions"
    set -p fish_complete_path (brew --prefix)/share/fish/completions
end

if test -d (brew --prefix)"/share/fish/vendor_completions.d"
    set -p fish_complete_path (brew --prefix)/share/fish/vendor_completions.d
end

# Claude Code hook sounds (consumed by ~/.claude/settings.json).
# Full play command (player + file) so the hook is OS-agnostic.
export CLAUDE_SOUND_NOTIFY="afplay /System/Library/Sounds/Glass.aiff"
export CLAUDE_SOUND_STOP="afplay /System/Library/Sounds/Hero.aiff"