# SaveInstanceFetch

> A smart SaveInstance tool that saves Roblox games the way they actually look — working terrain, unions, media, decompiled scripts, and asset recovery.

Fork of [UniversalSynSaveInstance](https://github.com/luao/UniversalSynSaveInstance) focused on **visual accuracy** and **ease of use**. No extra dependencies — load straight from GitHub raw.

## Usage

Paste this into your executor:

```luau
local Params = {
    RepoURL = "https://raw.githubusercontent.com/achmdfzn/SaveInstanceFetch/main/",
    Prepass = "prepass",
}
local prepass = loadstring(game:HttpGet(Params.RepoURL .. Params.Prepass .. ".luau", true), Params.Prepass)()

local Options = {}        -- saveinstance options — see docs/option.md
local PrepassOptions = {} -- optional — PersistentCache and RepoURL default sensibly

prepass(Options, PrepassOptions)
```

Wait until you see `[saveinstance] Saved!`, then check your executor's workspace folder:

- `*.rbxlx` — the save file (open in Roblox Studio)
- `saveinstance_assets/` — downloaded assets, ready to drag-drop into Studio (when `DownloadAssets = true`)
- `saveinstance-capabilities.txt` / `saveinstance-verify.txt` / `saveinstance-assets.txt` — diagnostics

> **Privacy note:** when an executor lacks a native decompiler, scripts are decompiled via the third-party **lua.expert** API — script bytecode is sent off-device. Set `noscripts = true` to skip decompiling entirely.

## Common tweaks

| Goal | Add to `Options` |
|------|------------------|
| Full union mesh + terrain on StreamingEnabled maps | `FullUnionTerrainSupport = true` |
| Recover private meshes to `.obj` (Blender / Studio) | `ExportObj = true, SetStreaming = true` |
| Save the map only, skip decompile | `noscripts = true` |
| Skip instances by name / tag | `IgnoreNamePatterns = {"^Camera$"}` / `IgnoreTags = {"EditorOnly"}` |
| Save ONLY tagged instances | `SaveOnlyTags = {"SaveMe"}` |
| Reset a stale decompile cache | `PrepassOptions.ClearCache = true` |

Full option reference: [`docs/option.md`](docs/option.md).

## Executor compatibility

| Executor | Terrain | Union Mesh | Scripts |
|----------|:-:|:-:|:-:|
| Synapse / Wave | Yes | Yes | Yes |
| Volt | Yes | Yes | Yes (native decompiler) |
| Fluxus | Yes | Partial | Yes |
| Xeno / Solara | No | No | Yes |

> No `gethiddenproperty` (Xeno/Solara) means terrain & union mesh can't be saved. Check `saveinstance-capabilities.txt` after a run for your executor's support.

## Files

- [`saveinstance.luau`](saveinstance.luau) — main serializer (terrain, unions, decompile, export)
- [`prepass.luau`](prepass.luau) — wrapper: caches decompile to disk, hooks `decompile`, loads saveinstance
- [`docs/option.md`](docs/option.md) — full option reference

## Credits

Builds on [UniversalSynSaveInstance](https://github.com/luao/UniversalSynSaveInstance), [USSI Prepass](https://gitlab.com/centerepic/ussiprepass), [lua.expert](https://lua.expert), and [SaveInstance 420 Edition](https://github.com/RealSlimShady2000/SaveInstance420Edition).
