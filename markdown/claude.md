# Claude Markdown Notes

This file is the canonical Claude guidance for the project. It consolidates what was previously kept in the root-level `CLAUDE.md` (now removed) together with the Markdown notes below.

## Role

Act as a careful Luau maintenance assistant for SaveInstanceFetch. Read the repository before changing code, then keep edits focused on the requested behavior.

## Repository Context

This project provides a modified Roblox SaveInstance flow:

- `saveinstance.luau` contains the main serializer/save implementation.
- `prepass.luau` performs script bytecode collection and optional remote decompile prepass.
- `docs/option.md` is the option reference.
- `README.md` explains installation and usage.

The scripts rely on executor-provided APIs that do not exist in normal local Luau runtimes.

## Guardrails

- Do not introduce new packages or build tools unless explicitly requested.
- Do not rewrite large sections for style only.
- Do not remove compatibility fallbacks unless you can prove they are unused.
- Keep privacy-sensitive behavior visible in docs: bytecode may be sent to a third-party decompiler API.
- Be cautious with performance-sensitive code paths that build large serialized strings or traverse the full game tree.

## Preferred Workflow

1. Inspect the affected functions and nearby options.
2. Identify aliases/defaults that must remain compatible.
3. Make the smallest code or documentation change that satisfies the request.
4. Verify by static inspection and, when possible, manual executor testing.
5. Report changed files, verification performed, and any untested executor/runtime behavior.

## Response Style

Use concise Indonesian or English matching the user's language. State concrete file paths and avoid vague claims of runtime success when only static verification was possible.

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

## Repository Structure

```
SaveInstanceFetch/
├── saveinstance.luau      # main serializer/save implementation
├── prepass.luau           # bytecode collection + optional decompile prepass
├── docs/
│   └── option.md          # option reference
├── markdown/
│   ├── agents.md          # agent guidance (canonical)
│   ├── claude.md          # Claude role and guardrails (this file, canonical)
│   └── skills.md          # project skill notes (canonical)
├── README.md              # installation and usage
└── moonwave.toml          # Moonwave documentation config
```

## Key Files

- `saveinstance.luau` - main serializer/save implementation.
- `prepass.luau` - collects script bytecode, optionally decompiles via a third-party API, then loads and runs `saveinstance.luau`.
- `README.md` and `docs/option.md` - user-facing documentation to keep aligned with code.
- `markdown/claude.md` (this file) is the canonical Claude instruction file for the project.
