# Agents Markdown Notes

## Scope

This file is the human-readable Markdown copy of the project agent guidance. The canonical root-level agent file is `AGENTS.md`.

## Repository Summary

SaveInstanceFetch is a compact Roblox Luau repository. The main implementation is in `saveinstance.luau`, while `prepass.luau` handles bytecode/decompile preparation before calling the save flow.

## Agent Priorities

- Preserve current behavior and compatibility.
- Keep edits small.
- Avoid new dependencies.
- Document privacy-sensitive decompile behavior.
- Verify claims with code inspection or real executor testing.

## Files to Know

- `saveinstance.luau`
- `prepass.luau`
- `README.md`
- `docs/option.md`
- `moonwave.toml`
