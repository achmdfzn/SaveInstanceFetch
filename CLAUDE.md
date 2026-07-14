# Claude Instructions for SaveInstanceFetch

The canonical Claude guidance for this project lives in [`markdown/claude.md`](markdown/claude.md).
Read that file before making changes.

Quick reminders (see `markdown/claude.md` for the full version):

- Read the affected code before editing; keep changes small and focused.
- Do not add dependencies or rewrite large sections for style only.
- Preserve option names, aliases, defaults, and executor compatibility fallbacks.
- Keep privacy-sensitive behavior visible: bytecode may be sent to a third-party decompiler API.
- Verify by static inspection and state honestly when only static testing was possible.
