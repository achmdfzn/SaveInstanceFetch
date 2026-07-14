# SaveInstanceFetch Maintenance Skill

## Purpose

Use this skill when maintaining, documenting, or reviewing the SaveInstanceFetch repository.
It is tuned for Roblox Luau scripts that depend on executor-only APIs and external decompile services.

## When to Use

- Updating `saveinstance.luau` serialization behavior.
- Updating `prepass.luau` pre-decompile/cache behavior.
- Aligning README or Moonwave documentation with code defaults.
- Reviewing performance, compatibility, or privacy risks.

## Project Map

- `saveinstance.luau`: main UniversalSynSaveInstance-derived implementation.
- `prepass.luau`: bytecode collection, rate-limited remote decompile calls, and SaveInstance handoff.
- `docs/option.md`: user-facing option reference.
- `moonwave.toml`: documentation site metadata.
- `README.md`: quick start and feature summary.

## Workflow

1. Read the relevant file and search for the option/function names being changed.
2. Preserve compatibility with existing option names, aliases, defaults, and fallbacks.
3. Keep changes narrow; prefer modifying existing helpers over adding new abstractions.
4. Update docs when behavior, defaults, privacy impact, or setup changes.
5. Verify with static inspection and note when executor-only runtime testing was not performed.

## Review Checklist

- Hidden-property behavior still has safe fallbacks.
- Decompile API use is rate-limited and documented.
- Large string/file handling avoids avoidable memory spikes.
- Terrain, union, mesh, image, texture, and sound handling are not regressed.
- README examples remain valid Luau.

## Constraints

No local Roblox executor is assumed. Do not claim runtime validation unless it was actually performed in a compatible executor.
