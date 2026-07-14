# Agents Markdown Notes

## Scope

This file is the canonical agent guidance for the project. It consolidates what was previously kept in the root-level `AGENTS.md` (now removed) together with the Markdown notes below.

## Repository Summary

SaveInstanceFetch is a compact Roblox Luau repository. The main implementation is in `saveinstance.luau`, while `prepass.luau` handles bytecode/decompile preparation before calling the save flow.

## Agent Priorities

- Preserve current behavior and compatibility.
- Keep edits small.
- Avoid new dependencies.
- Document privacy-sensitive decompile behavior.
- Verify claims with code inspection or real executor testing.

## Files to Know

Code:

- `saveinstance.luau` - main serializer/save implementation.
- `prepass.luau` - bytecode collection and optional decompile prepass; loads and runs `saveinstance.luau`.

Documentation:

- `README.md` - installation, usage, presets, feature list.
- `docs/option.md` - full option reference.
- `moonwave.toml` - Moonwave documentation config.

Instruction files (all under `markdown/`, canonical):

- `markdown/agents.md` - agent guidance (this file).
- `markdown/claude.md` - Claude role and guardrails.
- `markdown/skills.md` - project skill definition and notes.

## Repository Structure

```
SaveInstanceFetch/
├── saveinstance.luau      # main serializer/save implementation
├── prepass.luau           # bytecode collection + optional decompile prepass
├── docs/
│   └── option.md          # option reference
├── markdown/
│   ├── agents.md          # agent guidance (this file, canonical)
│   ├── claude.md          # Claude role and guardrails (canonical)
│   └── skills.md          # project skill notes (canonical)
├── README.md              # installation and usage
└── moonwave.toml          # Moonwave documentation config
```

## Project Shape

SaveInstanceFetch is a Roblox Luau project that wraps and modifies UniversalSynSaveInstance behavior.
The repository is intentionally small:

- `saveinstance.luau` is the main save implementation.
- `prepass.luau` warms decompile/cache data through executor bytecode access and the lua.expert API.
- `README.md` is the user-facing quick start.
- `docs/option.md` documents save options for Moonwave/Docusaurus output.
- `moonwave.toml` configures generated documentation.

## Working Rules

- Keep changes small and reversible.
- Do not add dependencies unless the user explicitly asks.
- Prefer editing the Luau scripts directly instead of adding wrapper layers.
- Preserve existing option names, aliases, defaults, and executor compatibility behavior.
- Treat executor APIs such as `gethiddenproperty`, `getscriptbytecode`, `request`, `writefile`, and `loadstring` as environment-dependent.
- Avoid changing network endpoints, rate limits, or bytecode handling without calling out the privacy and compatibility impact.

## Important Risks

- `prepass.luau` can send script bytecode to `https://api.lua.expert/decompile`.
- `saveinstance.luau` reads hidden Roblox properties when executor support exists.
- Terrain and union serialization depend on hidden properties and fallback logic.
- Large games are sensitive to memory growth, string buffering, request concurrency, and file flush behavior.

## Verification

There is no local test harness in this repository. For code changes:

1. Run static searches/read-throughs for changed symbols and options.
2. Check that Luau syntax structure remains balanced.
3. Confirm README/docs still match the exposed defaults and behavior.
4. When possible, test manually in a compatible Roblox executor with a small place before using large games.

## Documentation Style

- Keep documentation practical and direct.
- Mention third-party API behavior when discussing decompile/prepass features.
- Use `luau` fenced code blocks for examples.
- Keep option names exactly as implemented.
