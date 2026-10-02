#!/usr/bin/env bash
# Claude Code statusLine renderer, laid out like pi's interactive footer:
# dim text, no icons, no background blocks, no powerline glyphs.
#
#   ~/Code/projects/nixos-config (master)
#   claude-opus-5 CH12.9% $1.235 38.5%/1.0M • 5h 36% 7d 19%
#   ▌ 能不能展示出正在执行的 prompt？
#
# Colors carry meaning, so there are only three:
#   - the model name is magenta, the one fixed-color element;
#   - percentages (context window, 5h/7d quota) turn yellow above 70% and red
#     above 90%, the same thresholds pi uses for its context gauge;
#   - everything else is dim. The two quota windows render at normal brightness
#     instead of dim so they stand out from the run of text before them without
#     spending a hue that the thresholds already need.
#
# Claude Code pipes the session JSON on stdin and prints whatever we write; see
# https://code.claude.com/docs/en/statusline for the field list.
#
# Two things differ from pi because Claude Code does not expose the inputs: the
# cache hit rate describes the last API call rather than cumulative session
# totals, and there is no auto-compact or thinking-level marker.

set -uo pipefail

# ${#var} must count characters, not bytes, or truncation cuts in the wrong
# place on any line containing non-ASCII.
export LC_ALL="${LC_ALL:-en_US.UTF-8}"

input=$(cat)

# One jq call for everything on stdin. jq prints one field per line and the loop
# keeps the empty ones; a tab-separated `read` would not, because tab is IFS
# whitespace, so runs of it collapse and every empty field -- session_name and
# the two quota windows are empty most of the time -- would shift every later
# value one slot to the left.
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
      (if $prompt > 0
          and (($u.cache_read_input_tokens // 0) > 0
               or ($u.cache_creation_input_tokens // 0) > 0)
       then (($u.cache_read_input_tokens // 0) / $prompt * 100 | dp1)
       else "" end),
      (.cost.total_cost_usd // 0),
      ($c.used_percentage // ""),
      ($c.context_window_size | fmt),
      ($r.five_hour.used_percentage // ""),
      ($r.seven_day.used_percentage // ""),
      (.prompt_id // ""),
      (.transcript_path // "")
    ]
  | map(if . == null then "" else tostring end | gsub("[\r\n\t]"; " "))
  | .[]' 2>/dev/null)

cwd=${f[0]-}
session=${f[1]-}
model=${f[2]:-no-model}
chr=${f[3]-}
cost=${f[4]-}
ctx_pct=${f[5]-}
ctx_size=${f[6]-}
q5=${f[7]-}
q7=${f[8]-}
prompt_id=${f[9]-}
transcript=${f[10]-}

DIM=$'\033[2m'
RST=$'\033[0m'
NORM=''
MAGENTA=$'\033[35m'
WARN=$'\033[33m'
ERR=$'\033[31m'

width=${COLUMNS:-80}

# Pick the attribute for a percentage: the thresholds win, otherwise the
# caller's base attribute (dim for the context gauge, normal for the quotas).
pct_attr() {
  local pct=${1%%.*}
  if   [ "${pct:-0}" -gt 90 ]; then printf '%s' "$ERR"
  elif [ "${pct:-0}" -gt 70 ]; then printf '%s' "$WARN"
  else                              printf '%s' "$2"
  fi
}

# Columns occupied, not characters: CJK takes two columns each, and a prompt in
# Chinese overruns the terminal and wraps if you count characters. Approximated
# as (characters + bytes) / 2, which is exact for ASCII (1 byte, 1 column) and
# for CJK (3 bytes, 2 columns) -- the two things these lines actually contain.
# Scripts that encode to 2 bytes but occupy one column (Cyrillic, Greek) come
# out half a column too wide each; emoji count as 2, which is usually right.
dwidth() {
  local s=$1 chars bytes saved=$LC_ALL
  chars=${#s}
  LC_ALL=C
  bytes=${#s}
  LC_ALL=$saved
  printf '%s' $(( (chars + bytes) / 2 ))
}

# Truncate on the plain copy; slicing a colored string would land inside an
# escape sequence.
fit() {
  local text=$1 out
  [ "$(dwidth "$text")" -le "$width" ] && { printf '%s' "$text"; return; }
  out=${text:0:width}
  while [ -n "$out" ] && [ "$(dwidth "$out")" -gt "$((width - 3))" ]; do
    out=${out%?}
  done
  printf '%s...' "$out"
}

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

printf '%s%s%s\n' "$DIM" "$(fit "$dir")" "$RST"

# ---- line 2: model, then usage ---------------------------------------------
# Built twice: `plain` measures for truncation, `lit` carries the attributes.
plain=""
lit=""
add() {
  [ -n "$plain" ] && { plain="$plain "; lit="$lit "; }
  plain="$plain$1"
  lit="$lit$2"
}

add "$model" "${MAGENTA}${model}${RST}"
[ -n "$chr" ] && add "CH$chr%" "${DIM}CH$chr%${RST}"

# printf '%.3f' on the raw float, matching pi's cost.toFixed(3).
if [ -n "$cost" ] && [ "$cost" != "0" ]; then
  txt=$(printf '$%.3f' "$cost")
  add "$txt" "${DIM}${txt}${RST}"
fi

if [ -n "$ctx_pct" ]; then
  txt="$(printf '%.1f%%' "$ctx_pct")${ctx_size:+/$ctx_size}"
  add "$txt" "$(pct_attr "$ctx_pct" "$DIM")${txt}${RST}"
fi

# rate_limits is present only for Claude.ai Pro/Max accounts, only after the
# first API response, and each window disappears once it resets -- so both of
# these are routinely absent and simply drop out of the line.
if [ -n "$q5" ] || [ -n "$q7" ]; then
  add "•" "${DIM}•${RST}"
  if [ -n "$q5" ]; then
    txt="5h $(printf '%.0f%%' "$q5")"
    add "$txt" "$(pct_attr "$q5" "$NORM")${txt}${RST}"
  fi
  if [ -n "$q7" ]; then
    txt="7d $(printf '%.0f%%' "$q7")"
    add "$txt" "$(pct_attr "$q7" "$NORM")${txt}${RST}"
  fi
fi

if [ "$(dwidth "$plain")" -gt "$width" ]; then
  printf '%s%s%s\n' "$DIM" "$(fit "$plain")" "$RST"
else
  printf '%s\n' "$lit"
fi

# ---- optional machine-local side effect ------------------------------------
# Some machines want the same payload handed to another tool -- a usage tracker,
# a menu bar applet. If an executable sits at this path it gets a copy of stdin
# and runs detached: nothing drawn above depends on it, and a sidecar that is
# missing, slow, or broken changes nothing on screen.
sidecar=${CLAUDE_STATUSLINE_SIDECAR:-$HOME/.claude/statusline-sidecar.sh}
[ -x "$sidecar" ] && printf '%s' "$input" | "$sidecar" >/dev/null 2>&1 &

# ---- line 3: the prompt currently being processed ---------------------------
# The statusLine JSON carries prompt_id but not the text, so look the id up in
# the transcript. The user's own message is the first record under that id, and
# is the only one that is a "user" entry with string content and no tool result
# (tool results are also typed "user", with an array body).
#
# A slash command arrives as two records: a boilerplate caveat, then the command
# itself; skip the caveat and show the command name.
[ -n "$prompt_id" ] && [ -r "$transcript" ] || exit 0

prompt=$(grep -F "\"promptId\":\"$prompt_id\"" "$transcript" 2>/dev/null | jq -rs '
  [ .[]
    | select(.type == "user" and .toolUseResult == null
             and (.message.content | type) == "string")
    | .message.content
  ]
  | map(select(startswith("<local-command-caveat>") | not))
  | (.[0] // "")
  | if startswith("<command-name>")
    then (capture("^<command-name>(?<n>[^<]*)</command-name>") | .n)
    else . end
  | gsub("\\s+"; " ")
  | sub("^ +"; "") | sub(" +$"; "")
' 2>/dev/null)

[ -n "$prompt" ] && printf '%s%s%s\n' "$DIM" "$(fit "▌ $prompt")" "$RST"

# The line above is a test, so it decides the exit status when the prompt is
# empty. Claude Code should not see that as the hook failing.
exit 0
