# Claude Instructions for SaveInstanceFetch

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
