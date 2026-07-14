# SaveInstanceFetch Agent Guide

The canonical agent guidance for this project lives in [`markdown/agents.md`](markdown/agents.md).
Read that file before making changes.

Quick reminders (see `markdown/agents.md` for the full version):

- Keep changes small and reversible; prefer editing the Luau scripts directly.
- Do not add dependencies unless explicitly asked.
- Preserve option names, aliases, defaults, and executor compatibility behavior.
- `prepass.luau` can send script bytecode to a third-party decompiler API — call out privacy impact.
- No local test harness exists; verify statically and test in a real executor when possible.
