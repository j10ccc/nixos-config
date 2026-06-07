# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"

# misc
export COLORTERM=truecolor

# Claude Code hook sounds (consumed by ~/.claude/settings.json).
# Full play command (player + file) so the hook is OS-agnostic.
export CLAUDE_SOUND_NOTIFY="pw-play /usr/share/sounds/freedesktop/stereo/message.oga"
export CLAUDE_SOUND_STOP="pw-play /usr/share/sounds/freedesktop/stereo/complete.oga"
