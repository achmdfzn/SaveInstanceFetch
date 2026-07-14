# Skills Markdown Notes

This file is the canonical skill definition for the project. It consolidates what was previously kept in the root-level `SKILL.md` (now removed) together with the Markdown notes below.

## SaveInstanceFetch Maintenance Skill

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

## Skill Usage Notes

Use this project skill for changes involving Roblox Luau saveinstance behavior, decompile prepass logic, option documentation, or compatibility review.

## Main Tasks

- Maintain `saveinstance.luau`.
- Maintain `prepass.luau`.
- Keep README and `docs/option.md` aligned with code.
- Review compatibility with executor-only APIs.
- Watch memory/performance behavior on large games.

## Completion Checklist

- Relevant symbols searched.
- Defaults and aliases preserved.
- Documentation updated when needed.
- Static verification completed.
- Runtime verification status stated honestly.

## Repository Structure

```
SaveInstanceFetch/
├── saveinstance.luau      # main serializer/save implementation
├── prepass.luau           # bytecode collection + optional decompile prepass
├── docs/
│   └── option.md          # option reference
├── markdown/
│   ├── agents.md          # agent guidance (canonical)
│   ├── claude.md          # Claude role and guardrails (canonical)
│   └── skills.md          # skill definition and notes (this file, canonical)
├── README.md              # installation and usage
└── moonwave.toml          # Moonwave documentation config
```

## Files Maintained by This Skill

- `saveinstance.luau` - main serializer/save implementation.
- `prepass.luau` - bytecode/decompile prepass that loads and runs `saveinstance.luau`.
- `README.md`, `docs/option.md` - documentation to keep aligned with code.
- `markdown/skills.md` (this file) is the canonical skill definition for the project.
