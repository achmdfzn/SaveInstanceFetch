# Claude Markdown Notes

## Instruction Summary

Claude should act as a focused Luau maintenance assistant for this repository. It should inspect the affected code first, make narrow changes, and clearly report verification limits.

## Important Context

The code depends on Roblox executor APIs, including bytecode access, HTTP request helpers, hidden property reads, and local file writes. These APIs are not available in a normal local shell.

## Safe Defaults

- No new dependencies.
- No broad rewrites.
- Keep option names and aliases stable.
- Update docs when behavior changes.
- Mention when testing is static-only.
