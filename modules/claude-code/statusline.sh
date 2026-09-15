#!/usr/bin/env bash
# Claude Code statusLine renderer, laid out like pi's interactive footer:
# two lines of dim text, no icons, no background blocks, no powerline glyphs.
# The only colored values are the percentages (context window, 5h/7d quota),
# which turn yellow above 70% and red above 90%.
#
#   ~/Code/projects/nixos-config (master)
#   ↑15.5k ↓1.2k R2.0k W5.0k CH19.0% $1.235 38.5%/1.0M 5h 36% 7d 19%   claude-opus-5
#
# Claude Code pipes the session JSON on stdin and prints whatever we write; see
# https://code.claude.com/docs/en/statusline for the field list. Two things
# differ from pi on purpose, because Claude Code does not expose the inputs:
#
#   - ↑↓RW describe the *current context window* / last API call, not cumulative
#     session totals. pi tallies every assistant message; the statusLine JSON
#     only carries the most recent response.
#   - No "(auto)" auto-compact marker and no thinking-level suffix.
#
# Everything comes out of one jq call, so a render costs one fork for jq plus
# one for git. Keep it that way: this runs on every frame.

set -uo pipefail

# ${#var} must count characters, not bytes, or the arrows and the right-aligned
# model name drift apart by a few columns.
export LC_ALL="${LC_ALL:-en_US.UTF-8}"

input=$(cat)

# Token counts are formatted inside jq (same thresholds as pi's formatTokens)
# so we don't fork awk once per field. Zero-valued parts come back empty and
# get dropped below, which is also what pi does.
#
# jq prints one field per line and the loop keeps the empty ones. A
# tab-separated `read` would not: tab is IFS whitespace, so runs of it collapse,
# and session_name plus the two quota windows are empty most of the time, which
# would shift every later value one slot to the left.
f=()
while IFS= read -r line; do f+=("$line"); done < <(printf '%s' "$input" | jq -r '
  def dp1: (. * 10 | round) / 10 | tostring
           | if test("[.]") then . else . + ".0" end;
  def fmt: (. // 0) as $x
           | if   $x == 0        then ""
             elif $x < 1000      then ($x | floor | tostring)
             elif $x < 10000     then (($x / 1000) | dp1) + "k"
             elif $x < 1000000   then (($x / 1000) | round | tostring) + "k"
             elif $x < 10000000  then (($x / 1000000) | dp1) + "M"
             else                     (($x / 1000000) | round | tostring) + "M"
             end;

  (.context_window // {}) as $c
  | ($c.current_usage // {}) as $u
  | (.rate_limits // {}) as $r
  | (($u.input_tokens // 0)
     + ($u.cache_read_input_tokens // 0)
     + ($u.cache_creation_input_tokens // 0)) as $prompt

  | [ (.workspace.current_dir // .cwd // ""),
      (.session_name // ""),
      (.model.id // .model.display_name // "no-model"),
      ($c.total_input_tokens  | fmt),
      ($c.total_output_tokens | fmt),
      ($u.cache_read_input_tokens     | fmt),
      ($u.cache_creation_input_tokens | fmt),
      (if $prompt > 0
          and (($u.cache_read_input_tokens // 0) > 0
               or ($u.cache_creation_input_tokens // 0) > 0)
       then (($u.cache_read_input_tokens // 0) / $prompt * 100 | dp1)
       else "" end),
      (.cost.total_cost_usd // 0),
      ($c.used_percentage // ""),
      ($c.context_window_size | fmt),
      ($r.five_hour.used_percentage // ""),
      ($r.seven_day.used_percentage // "")
    ]
  | map(if . == null then "" else tostring end | gsub("[\r\n\t]"; " "))
  | .[]' 2>/dev/null)

cwd=${f[0]-}
session=${f[1]-}
model=${f[2]:-no-model}
up=${f[3]-}
down=${f[4]-}
cache_read=${f[5]-}
cache_write=${f[6]-}
chr=${f[7]-}
cost=${f[8]-}
ctx_pct=${f[9]-}
ctx_size=${f[10]-}
q5=${f[11]-}
q7=${f[12]-}

DIM=$'\033[2m'
RST=$'\033[0m'
WARN=$'\033[33m'
ERR=$'\033[31m'

# A colored span ends with a reset, which also clears the surrounding dim, so
# re-open dim afterwards. pi's footer.js works around the same thing.
tint() {
  local pct=${1%%.*} text=$2
  if   [ "${pct:-0}" -gt 90 ]; then printf '%s%s%s%s%s' "$RST" "$ERR"  "$text" "$RST" "$DIM"
  elif [ "${pct:-0}" -gt 70 ]; then printf '%s%s%s%s%s' "$RST" "$WARN" "$text" "$RST" "$DIM"
  else                              printf '%s' "$text"
  fi
}

width=${COLUMNS:-80}

# ---- line 1: cwd (branch) • session ----------------------------------------
case "$cwd" in
  "$HOME")   dir="~" ;;
  "$HOME"/*) dir="~${cwd#"$HOME"}" ;;
  *)         dir="$cwd" ;;
esac

# Guard on $cwd: `git -C ""` silently falls back to the process's own working
# directory, which would label an unknown cwd with this repo's branch.
branch=""
[ -n "$cwd" ] && branch=$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null)
[ -n "$branch" ] && dir="$dir ($branch)"
[ -n "$session" ] && dir="$dir • $session"

[ "${#dir}" -gt "$width" ] && dir="${dir:0:width-3}..."
printf '%s%s%s\n' "$DIM" "$dir" "$RST"

# ---- line 2: usage stats, model right-aligned ------------------------------
# Built twice: `plain` is measured for the padding, `lit` carries the colors.
plain=()
lit=()
add() { plain+=("$1"); lit+=("${2-$1}"); }

[ -n "$up" ]          && add "↑$up"
[ -n "$down" ]        && add "↓$down"
[ -n "$cache_read" ]  && add "R$cache_read"
[ -n "$cache_write" ] && add "W$cache_write"
[ -n "$chr" ]         && add "CH$chr%"

# printf '%.3f' on the raw float, matching pi's cost.toFixed(3).
if [ -n "$cost" ] && [ "$cost" != "0" ]; then
  add "$(printf '$%.3f' "$cost")"
fi

if [ -n "$ctx_pct" ]; then
  txt="$(printf '%.1f%%' "$ctx_pct")${ctx_size:+/$ctx_size}"
  add "$txt" "$(tint "$ctx_pct" "$txt")"
fi

# rate_limits is present only for Claude.ai Pro/Max accounts, only after the
# first API response, and each window disappears once it resets -- so both of
# these are routinely absent and simply drop out of the line.
if [ -n "$q5" ]; then
  txt="5h $(printf '%.0f%%' "$q5")"
  add "$txt" "$(tint "$q5" "$txt")"
fi
if [ -n "$q7" ]; then
  txt="7d $(printf '%.0f%%' "$q7")"
  add "$txt" "$(tint "$q7" "$txt")"
fi

left_plain="${plain[*]-}"
left_lit="${lit[*]-}"

# Overflowing the terminal wraps the line and pushes the transcript around, so
# cut it like pi does. The colored copy is dropped rather than sliced, because
# slicing it would land inside an escape sequence.
if [ "${#left_plain}" -gt "$width" ]; then
  left_plain="${left_plain:0:width-3}..."
  left_lit="$left_plain"
fi

if [ "$((${#left_plain} + 2 + ${#model}))" -le "$width" ]; then
  pad=$(printf '%*s' "$((width - ${#left_plain} - ${#model}))" '')
  printf '%s%s%s%s%s\n' "$DIM" "$left_lit" "$pad" "$model" "$RST"
else
  printf '%s%s%s\n' "$DIM" "$left_lit" "$RST"
fi
