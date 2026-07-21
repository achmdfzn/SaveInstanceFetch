# SaveInstanceFetch

> A smart SaveInstance tool that saves Roblox games the way they actually look — working terrain, unions, media, decompiled scripts, and asset recovery.

Fork of [UniversalSynSaveInstance](https://github.com/luao/UniversalSynSaveInstance) focused on **visual accuracy** and **ease of use**. No extra dependencies — load straight from GitHub raw.

## Usage

Paste this into your executor:

```luau
--!nocheck
local Params = {
    RepoURL = "https://raw.githubusercontent.com/achmdfzn/SaveInstanceFetch/main/",
    Prepass = "prepass",
}

local Loader = loadstring(game:HttpGet(Params.RepoURL .. Params.Prepass .. ".luau", true), Params.Prepass)
assert(Loader, "[SaveInstanceFetch] failed to compile prepass loader (check your connection / RepoURL)")
local prepass = Loader()

local Options = {}        -- saveinstance options — see docs/option.md
local PrepassOptions = {} -- optional — PersistentCache and RepoURL default sensibly

prepass(Options, PrepassOptions)
```

> The two `[Error]` lines your editor shows (`could be nil` on `loadstring`, `Unknown global 'game'`) are just the type-checker not knowing the executor environment — the script runs fine. The `--!nocheck` header silences them, and the `assert` turns a failed download into a clear message instead of a `nil` call crash.

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
| Pin to a specific version | `PrepassOptions.PinVersion = "1.5.0"` |
| Load from the dev channel | `PrepassOptions.Channel = "dev"` |
| Force a fresh download (skip update check) | `PrepassOptions.CheckForUpdates = false` |

Full option reference: [`docs/option.md`](docs/option.md).

## PrepassOptions

The second argument to `prepass(Options, PrepassOptions)` controls the loader itself — downloading, caching, update checks, and version pinning. All are optional and default sensibly.

| Option | Default | Description |
|--------|---------|-------------|
| `RepoURL` | `raw.githubusercontent.com/achmdfzn/SaveInstanceFetch/main/` | Base URL the loader fetches `saveinstance.luau`, `version.txt`, and `CHANGELOG.md` from. |
| `ScriptName` | `"saveinstance"` | Name of the main script to load from `RepoURL`. |
| `Channel` | `nil` | Repo branch to load from (e.g. `"main"`, `"dev"`). Built on top of `RepoBase`. |
| `Ref` | `nil` | Explicit branch/tag to load from; overrides `Channel`. |
| `PinVersion` | `nil` | Refuse to run unless the loaded version matches (e.g. `"1.5.0"`). Guards against unexpected `main` changes. |
| `PersistentCache` | `true` | Reuse decompiled scripts from disk across runs (skips repeat API calls). |
| `CacheDir` | `"saveinstance_decompile_cache"` | Workspace folder for the decompile cache. |
| `ClearCache` | `false` | Wipe the decompile cache before this run. |
| `CacheMainScript` | `true` | Keep the last good `saveinstance.luau` on disk and fall back to it if a download fails or returns a bad body. |
| `MainScriptCacheFile` | `"saveinstance_source_cache.luau"` | Workspace file for the main-script fallback copy. |
| `CheckForUpdates` | `true` | Fetch `version.txt` and log when a newer version is published. |
| `ShowChangelog` | `true` | When an update is found, print the top of the remote `CHANGELOG.md`. |
| `VerifyHash` | `true` | If `version.txt` publishes a hash, verify the downloaded source matches before running it. |

### Prepass behavior toggles

These control *how* the decompile prepass runs, separate from the loader/cache settings above.

| Option | Default | Description |
|--------|---------|-------------|
| `UseSaveInstancePrepass` | `false` | Use `saveinstance.luau`'s built-in `DecompilePrepass` instead of the loader's own hook-based prepass. Wires `PrepassConcurrency`, `PrepassRateGap`, and `PrepassApiUrl` from the loader's rate settings. |
| `MaxScripts` | `nil` | Cap the number of scripts to decompile (maps to `Options.PrepassMaxScripts`). Only applied when `UseSaveInstancePrepass = true`. |
| `SkipPrepass` | `false` | Skip the decompile prepass entirely — no scripts are decompiled, but saveinstance still runs (scripts stay empty). |
| `SkipSaveInstance` | `false` | Run the prepass only and return without invoking saveinstance. Useful for warming the decompile cache. |
| `MaxInFlight` | `8` | How many decompile requests run at once. Kept low so mobile / low-RAM executors don't run out of memory. Raise it (e.g. `20`) on a strong PC executor for more speed. |
| `RequestsPerMinute` | `600` | Rate cap for decompile requests. Lower it if the API rate-limits you; raise it for speed on a fast connection. |

## Troubleshooting

**The executor force-closes / crashes mid-save.** This is almost always the decompile prepass using too much memory by running many HTTP requests at once — most common on mobile and low-RAM executors. The defaults (`MaxInFlight = 8`, `RequestsPerMinute = 600`) are already conservative, but if it still crashes, lower them further and/or cap how many scripts are decompiled:

```luau
local PrepassOptions = {
    MaxInFlight = 3,        -- fewer simultaneous requests = less memory
    RequestsPerMinute = 300,
    MaxScripts = 200,       -- decompile at most 200 scripts
}
```

To skip decompiling entirely (map/assets only — lightest possible run), set `Options.noscripts = true` or `PrepassOptions.SkipPrepass = true`.

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
- [`prepass.luau`](prepass.luau) — loader/wrapper: caches decompile to disk, hooks `decompile`, verifies + loads saveinstance
- [`docs/option.md`](docs/option.md) — full option reference
- [`version.txt`](version.txt) — current published version (checked by the loader for updates)
- [`CHANGELOG.md`](CHANGELOG.md) — what changed per release
- [`ROADMAP.md`](ROADMAP.md) — planned work
- [`moonwave.toml`](moonwave.toml) — Moonwave documentation config

## Credits

Builds on [UniversalSynSaveInstance](https://github.com/luao/UniversalSynSaveInstance), [USSI Prepass](https://gitlab.com/centerepic/ussiprepass), [lua.expert](https://lua.expert), and [SaveInstance 420 Edition](https://github.com/RealSlimShady2000/SaveInstance420Edition).
