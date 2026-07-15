---
sidebar_position: 2
---

# Options Reference

Every option is **optional** and **case-insensitive** - pass them in the table you give to
`synsaveinstance({ ... })`. Grouped by what they do. For the raw, exhaustive list see the
[SynSaveInstance API](../api/SynSaveInstance).

```lua
synsaveinstance({
    SetStreaming = true,
    NeutralizeLighting = true,
})
```

## Most common

| Option       | Default       | What it does                                                                                           |
| ------------ | ------------- | ------------------------------------------------------------------------------------------------------ |
| `mode`       | `"optimized"` | `"full"`, `"optimized"`, or `"scripts"`. `"optimized"` is smallest; use `"full"` for maximum fidelity. |
| `noscripts`  | `false`       | Skip decompiling - save the map & structure only (scripts kept as empty instances).                    |
| `SafeMode`   | `false`       | Kicks you from the game right before saving (anti-detection).                                          |
| `ShowStatus` | `true`        | Show the on-screen progress bar.                                                                       |
| `Debug`            | `false`       | Write `saveinstance-debug.txt` (executor, capabilities, stats) - send it for troubleshooting.           |
| `CapabilityReport` | `false`       | Write `saveinstance-capabilities.txt` with executor support and likely save limitations.                |
| `VerifySave`       | `false`       | Write `saveinstance-verify.txt` counting scripts decompiled, unions with mesh, and MeshParts recovered. |
| `FilePath`         | _(auto)_      | Output file name (no extension). Defaults to `place <id> <name>`.                                      |
| `Callback`         | `false`       | Receive the serialized string in a function instead of writing a file.                                 |

## Map streaming - capture the whole map

Big **StreamingEnabled** maps only load chunks near you. These force-load the entire map first.

| Option                 | Default        | What it does                                                                                 |
| ---------------------- | -------------- | -------------------------------------------------------------------------------------------- |
| `FullUnionTerrainSupport` | `false`        | Enable the full union mesh + streamed terrain profile. Forces `SetStreaming`, keeps hidden-property reads enabled, disables union-to-part fallback, and raises terrain settle time unless overridden. |
| `SetStreaming`         | `false`        | **Force-load the whole StreamingEnabled map** before saving (alias: `Streaming`).            |
| `StreamingAreaSize`    | `10000`        | Side length (studs) of the swept area. Raise for maps wider than 10k studs.                  |
| `StreamingConcurrency` | `false` (auto) | Requests in flight at once. Auto-scales to map size; set a number to force.                  |
| `StreamingMaxTime`     | `false` (auto) | Overall time cap for the sweep. Auto-scales (60s-15m); never hangs.                          |
| `StreamingTimeout`     | `20`           | Timeout for each `RequestStreamAroundAsync` request.                                         |
| `StreamingChunkWait`   | `12`           | Max seconds to wait for one chunk (stability detection returns sooner).                      |
| `StreamingSettleTime`  | `5`            | Wait after the sweep for terrain/background loads to finish (fixes floating-island terrain). |
| `StreamingRadius`      | `1024`         | Per-request radius (auto-uses the game's `StreamingTargetRadius`).                           |
| `StreamingSlices`      | `2`            | Vertical layers per grid cell; raise for tall maps.                                          |

## Visuals & mesh recovery

| Option               | Default  | What it does                                                                                                                                                                     |
| -------------------- | -------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `NeutralizeLighting` | `false`  | Reset Lighting/Atmosphere/effects to clean midday so the place opens **bright**, not dark/foggy.                                                                                 |
| `ExportObj`          | `false`  | Also bake all MeshPart geometry to a world-space `.obj` (opens in Blender) — the only way to recover **private** meshes that Studio can't re-download. Best with `SetStreaming`. |
| `AssetManifest`      | `false`  | Write `saveinstance-assets.txt` listing all `rbxassetid://`, `rbxasset://`, and `http://` URIs referenced by Content/ContentId properties in the save.                           |
| `TreatUnionsAsParts` | `false`1 | Convert Unions to plain Parts (for executors that can't read union mesh data). 1`true` on Solara.                                                                                |

## Decompiling scripts

If your executor has no decompiler, scripts fall back to the free **lua.expert** API automatically.

> The `prepass.luau` wrapper can additionally keep an on-disk decompile cache (`PersistentCache` / `CacheDir`) so repeat runs reuse previous results and re-send far less bytecode to the third-party API. See the PrepassOptions section in the README.

| Option               | Default                    | What it does                                                                                                                                    |
| -------------------- | -------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| `DecompilePrepass`   | `false`                    | **Decompile every script in parallel** via lua.expert _before_ saving - big speedup on script-heavy games. Sends bytecode to a third-party API. |
| `PrepassConcurrency` | `24`                       | Parallel decompile requests during the prepass.                                                                                                 |
| `PrepassRateGap`     | `0.12`                     | Min seconds between API requests (lower = faster if the API allows).                                                                            |
| `PrepassApiUrl`      | `api.lua.expert/decompile` | Decompile API endpoint.                                                                                                                         |
| `PrepassMaxScripts`          | `6000`                     | Skip full prepass above this many unique client scripts and fall back to on-demand decompile.                                                    |
| `timeout`                    | `10`                       | Per-script decompile timeout in seconds (alias: `DecompileTimeout`).                                                                            |
| `SaveBytecode`               | `false`                    | Also embed each script's bytecode in the output.                                                                                                |
| `DecompileJobless`           | `false`                    | Only include already-decompiled code; decompile nothing new.                                                                                    |
| `ResumeSave`                 | `false`                    | Persist the decompile cache to disk during prepass and reload it on the next run (resumes after a crash).                                       |
| `ResumeCacheDir`             | `"saveinstance_resume_cache"` | Folder used to store the resume checkpoint JSON.                                                                                             |
| `ResumeCheckpointInterval`   | `200`                      | How many scripts decompiled between disk flushes (0 = flush only at the end).                                                                   |

## Choosing what to save

| Option                    | Default                   | What it does                                                                             |
| ------------------------- | ------------------------- | ---------------------------------------------------------------------------------------- |
| `Object`                  | `false`                   | Save a specific instance (e.g. `game.Workspace`) as `.rbxmx` instead of the whole place. |
| `IsModel`                 | `false`                   | Force model (`.rbxmx`) vs place (`.rbxlx`) output.                                       |
| `IgnoreList`              | `{CoreGui, CorePackages}` | Instances/classes to skip (and their descendants).                                       |
| `IgnoreNamePatterns`      | `{}`                      | Array of Lua patterns matched against `instance.Name`; matched instances are skipped.    |
| `IgnoreTags`              | `{}`                      | Array of CollectionService tags; instances carrying ANY of these tags are skipped.       |
| `SaveOnlyTags`            | `{}`                      | Array of CollectionService tags; ONLY instances with at least ONE of these tags are saved. Empty = disabled. |
| `ExtraInstances`          | `{}`                      | Save only these instances (use with an invalid `mode`).                                  |
| `IgnoreProperties`        | `{}`                      | Skip specific properties by name.                                                        |
| `IgnoreDefaultProperties` | `true`                    | Omit properties equal to their class default (smaller files).                            |
| `IgnoreNotArchivable`     | `true`                    | Save instances even if `Archivable = false`.                                             |
| `NilInstances`            | `false`                   | Also save instances parented to `nil`.                                                   |

## Player isolation

| Option                        | Default | What it does                                                               |
| ----------------------------- | ------- | -------------------------------------------------------------------------- |
| `RemovePlayerCharacters`      | `true`  | Skip player characters entirely.                                           |
| `IsolateLocalPlayer`          | `false` | Save your player's children into a separate folder (not as a live Player). |
| `IsolateLocalPlayerCharacter` | `false` | Same, for your character.                                                  |
| `IsolateStarterPlayer`        | `false` | Clear StarterPlayer and folder-ize the saved starter player.               |
| `IsolatePlayers`              | `false` | Save players but hidden (viewable only in the file text).                  |

## Stability & crash fixes (advanced / risky)

Try these only if a save crashes or corrupts.

| Option                       | Default | What it does                                                                     |
| ---------------------------- | ------- | -------------------------------------------------------------------------------- |
| `IgnoreSpecialProperties`    | `false` | Skip `gethiddenproperty` calls (helps crashes, but **breaks Unions/Terrain**).   |
| `IgnoreSharedStrings`        | `true`  | Drop SharedStrings (crash fix). Union geometry is whitelisted so it still saves. |
| `UseUGCValidationService`    | `true`  | Set `false` to never use `UGCValidationService` as a hidden-property fallback.   |
| `AlternativeWritefile`       | `true`  | Write the file in segments (helps write-time crashes).                           |
| `IgnoreDefaultPlayerScripts` | `true`  | Skip PlayerModule/RbxCharacterSounds (crash fix on some executors).              |
| `SaveCacheInterval`          | `~57k`  | How often (bytes) to flush to file - lower = safer but slower.                   |

> Full machine-generated reference (types, aliases, every field): **[SynSaveInstance API →](../api/SynSaveInstance)**
