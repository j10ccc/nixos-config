#!/usr/bin/env bash
# Claude Code statusLine renderer. Input fields: https://code.claude.com/docs/en/statusline

set -uo pipefail

# ${#var} must count characters, not bytes.
export LC_ALL="${LC_ALL:-en_US.UTF-8}"

input=$(cat)

# One field per line, not tab-separated: `read` collapses runs of tabs, so empty
# fields would shift every later value.
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

pct_attr() {
  local pct=${1%%.*}
  if   [ "${pct:-0}" -gt 90 ]; then printf '%s' "$ERR"
  elif [ "${pct:-0}" -gt 70 ]; then printf '%s' "$WARN"
  else                              printf '%s' "$2"
  fi
}

# Display columns ≈ (chars + bytes) / 2: exact for ASCII and CJK, so Chinese
# prompts don't overrun the line and wrap.
dwidth() {
  local s=$1 chars bytes saved=$LC_ALL
  chars=${#s}
  LC_ALL=C
  bytes=${#s}
  LC_ALL=$saved
  printf '%s' $(( (chars + bytes) / 2 ))
}

# Only ever called on uncolored text: slicing would cut escape sequences.
fit() {
  local text=$1 out
  [ "$(dwidth "$text")" -le "$width" ] && { printf '%s' "$text"; return; }
  out=${text:0:width}
  while [ -n "$out" ] && [ "$(dwidth "$out")" -gt "$((width - 3))" ]; do
    out=${out%?}
  done
  printf '%s...' "$out"
}

case "$cwd" in
  "$HOME")   dir="~" ;;
  "$HOME"/*) dir="~${cwd#"$HOME"}" ;;
  *)         dir="$cwd" ;;
esac

# `git -C ""` falls back to the script's own cwd and would report the wrong branch.
branch=""
[ -n "$cwd" ] && branch=$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null)
[ -n "$branch" ] && dir="$dir ($branch)"
[ -n "$session" ] && dir="$dir • $session"

printf '%s%s%s\n' "$DIM" "$(fit "$dir")" "$RST"

plain=""
lit=""
add() {
  [ -n "$plain" ] && { plain="$plain "; lit="$lit "; }
  plain="$plain$1"
  lit="$lit$2"
}

add "$model" "${MAGENTA}${model}${RST}"
[ -n "$chr" ] && add "CH$chr%" "${DIM}CH$chr%${RST}"

if [ -n "$cost" ] && [ "$cost" != "0" ]; then
  txt=$(printf '$%.3f' "$cost")
  add "$txt" "${DIM}${txt}${RST}"
fi

if [ -n "$ctx_pct" ]; then
  txt="$(printf '%.1f%%' "$ctx_pct")${ctx_size:+/$ctx_size}"
  add "$txt" "$(pct_attr "$ctx_pct" "$DIM")${txt}${RST}"
fi

# Quotas use normal brightness rather than a color so they stand out without
# clashing with the yellow/red thresholds.
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

# Detached so a slow or broken sidecar can never affect rendering.
sidecar=${CLAUDE_STATUSLINE_SIDECAR:-$HOME/.claude/statusline-sidecar.sh}
[ -x "$sidecar" ] && printf '%s' "$input" | "$sidecar" >/dev/null 2>&1 &

# The payload has prompt_id but not the prompt text, so read it from the transcript.
[ -n "$prompt_id" ] && [ -r "$transcript" ] || exit 0

# Tool results are also "user" records (with array content); slash commands are
# preceded by a caveat record.
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

[ -n "$prompt" ] && printf '%s%s%s\n' "$DIM" "$(fit "⏎ $prompt")" "$RST"

# Otherwise the failed test above becomes the exit status and looks like a hook error.
exit 0
