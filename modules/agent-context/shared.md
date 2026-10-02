# Global agent conventions

The body every coding agent gets, whichever one is running. Each agent reads a
different path, so `mk-context.nix` concatenates this file plus that agent's own
extras into the file it actually looks at:

| Agent | Path |
| --- | --- |
| Claude Code | `~/.claude/CLAUDE.md` |
| pi | `~/.pi/agent/AGENTS.md` |

Only rules that hold across agents belong here. Tool names, hooks and directory
taboos differ per agent — those go in that agent's extra. Anything true of one
repository goes in that repository's own `AGENTS.md`: a file in the home
directory applies to every repo, and there is no way to scope it.

## Comments in code: default none

`Default to writing no comments. Never write a multi-paragraph docstring.` The
newer models match the surrounding comment density instead, so a repo already
full of noise clones itself. Keep this repo clean so the feedback loop stays
short.

- Default: no comments.
- Only write a comment if deleting it would lose information the code cannot
express — a `why`, a constraint, or a non-obvious tradeoff. Never restate the
next line, narrate what the code used to do, or paste chat history / library
docs / change history.
- One short line max. No multi-paragraph docstring unless a public API genuinely
needs the contract spelled out.
- When editing an existing file, match down to the surrounding style, not up to
it: if the file is over-commented, thin those comments rather than adding more
of the same.

The decision is the comment: if it is explainable from the code or from
the discussion you already had, leave it out. Long comment blocks are a sign
the reasoning should have been a commit message or a doc page, not a code
comment.

## Report in plain language, with evidence

Assume the reader did not watch the intermediate steps. Todos, scratch notes and
messages between subagents may be compressed; the part where the user has to
decide, review or approve is written for someone who was not there.

- **No invented terminology.** Coinages that look like real jargon — 归户 / 死门 /
  对拍 / 全绿 in Chinese, the dense metaphor-stacked register in English — are
  banned from user-facing output. If a standard phrase exists, use it: "all 15
  tests pass", not "全绿".
- **No metaphors standing in for engineering objects.** Not "the skin", not "the
  ledger", not "it bites". Name the file, the module, the rule.
- **Every claim carries evidence**: the command that ran, its output, which files
  changed, how to reproduce. `exit 0` is not "task done", a green build is not
  "goal met", a successful tool call is not "the change took effect". No evidence
  means not done.
- **If the cause is unknown, say the cause is unknown.** Do not supply a
  plausible-sounding story in its place.
- **"Your call" does not replace giving options.** When a decision is genuinely
  the user's, list the choices, what each one costs, and a recommendation —
  otherwise they are signing off on something they cannot read.
- **Do not let a coinage survive a round.** If the user echoes one back, do not
  adopt it. If you coined one last turn, switch to standard phrasing this turn.
  Rewrite subagent output into structured results rather than inheriting its
  wording.

This is a rule rather than a style note because the failure mode is
self-reinforcing. Long runs are scored on whether the task finished, never on
whether the report was understood; meanwhile each turn's shorthand goes back into
the context window as the most recent sample of how to write, so a private
dialect compounds until nothing in the final report is checkable. Asking for
"plainer language" does not work — the coinages already read as plain to whoever
wrote them. The coining itself has to be banned by name.
