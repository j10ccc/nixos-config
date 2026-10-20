#!/usr/bin/env python3
"""Render a Markdown summary of per-host package version changes.

Usage: package-diff.py OLD.json NEW.json
Both files are the output of package-versions.sh.
"""

import json
import sys

MARKER = "<!-- package-versions -->"
# GitHub caps PR bodies at 65536 characters; leave room for the rest.
MAX_LEN = 50000


def host_section(host, old, new):
    rows = []
    for name in sorted(old.keys() | new.keys(), key=str.lower):
        before, after = old.get(name), new.get(name)
        if before == after:
            continue
        if before is None:
            rows.append(f"| {name} | — | `{after}` (added) |")
        elif after is None:
            rows.append(f"| {name} | `{before}` | — (removed) |")
        else:
            rows.append(f"| {name} | `{before}` | `{after}` |")
    if not rows:
        return f"**{host}**: no package version changes.\n"
    return "\n".join(
        [
            "<details open>",
            f"<summary><b>{host}</b>: {len(rows)} change(s)</summary>",
            "",
            "| Package | Old | New |",
            "| --- | --- | --- |",
            *rows,
            "",
            "</details>",
            "",
        ]
    )


def main():
    with open(sys.argv[1]) as f:
        old = json.load(f)
    with open(sys.argv[2]) as f:
        new = json.load(f)

    out = [MARKER, "## Package version changes", ""]
    for host in sorted(old.keys() | new.keys()):
        out.append(host_section(host, old.get(host, {}), new.get(host, {})))
    text = "\n".join(out)
    if len(text) > MAX_LEN:
        text = text[:MAX_LEN] + "\n\n_(truncated)_\n"
    print(text)


if __name__ == "__main__":
    main()
