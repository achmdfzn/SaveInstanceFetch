# SaveInstanceFetch Agent Guide

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
