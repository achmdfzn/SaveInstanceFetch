# SaveInstanceFetch

A smart SaveInstance tool that correctly saves any Roblox games the way they look.

## Features

- **Faster, lighter saves** - Uses table buffer instead of repeated string concatenation, fixing the O(n^2) growth that caused "not enough memory" on large games
- **Terrain support** - SmoothGrid and PhysicsGrid are serialized and render properly
- **Unions render correctly** - Re-enabled gethiddenproperty during save to read union's MeshData2
- **Part properties preserved** - Color and Size are saved using official Roblox CDN API dump
- **Media content supported** - Decals, images, and sounds are saved with proper Content DataType handling
- **Whole-map streaming capture** - `SetStreaming` and `FullUnionTerrainSupport` force-load StreamingEnabled maps before saving
- **Private mesh recovery path** - `ExportObj` can bake MeshPart geometry into a world-space `.obj` file
- **Cleaner saved scenes** - `NeutralizeLighting` can reset dark/foggy lighting before save
- **Debuggable decompile flow** - `Debug`, `CapabilityReport`, `DecompilePrepass`, and `PrepassMaxScripts` expose diagnostics and safer API pacing
- **Persistent decompile cache** - `PersistentCache` stores decompiled scripts on disk so repeat saves of the same game reuse them and skip the third-party API, cutting run time and data sent externally

## Installation

Load the prepass script directly from GitHub:

```lua
local prepass = loadstring(game:HttpGet("https://raw.githubusercontent.com/achmdfzn/SaveInstanceFetch/main/prepass.luau", true))()
```

## Usage

Recommended wrapper usage keeps the legacy prepass cache hook enabled, then loads this repository's `saveinstance.luau`.

```luau
local prepass = loadstring(game:HttpGet("https://raw.githubusercontent.com/achmdfzn/SaveInstanceFetch/main/prepass.luau", true))()

local Options = {
    CapabilityReport = true, -- writes saveinstance-capabilities.txt for executor diagnostics
    -- Full list @ https://luau.github.io/UniversalSynSaveInstance/api/SynSaveInstance
}

local PrepassOptions = {
    RequestsPerMinute = 1350,
    MaxInFlight = 30,
    RequestTimeout = 20,
    ApiUrl = "https://api.lua.expert/decompile",
    Verbose = true,
    SkipPrepass = false, -- skip cache warm-up, go straight to saveinstance
    SkipSaveInstance = false, -- run only the prepass, don't call saveinstance
    UseSaveInstancePrepass = false, -- set true to use saveinstance's built-in DecompilePrepass instead
    PersistentCache = true, -- reuse decompiled scripts from disk across runs (skips repeat API calls)
    CacheDir = "saveinstance_decompile_cache", -- workspace folder for the persistent cache
    ClearCache = false, -- wipe the cache before this run to force a fresh decompile
    RepoURL = "https://raw.githubusercontent.com/achmdfzn/SaveInstanceFetch/main/",
    ScriptName = "saveinstance",
}

prepass(Options, PrepassOptions)
```

To use the newer built-in `DecompilePrepass` from `saveinstance.luau` instead of the legacy hook, set:

```luau
local PrepassOptions = {
    UseSaveInstancePrepass = true,
}
```


## Recommended Presets

Use these inside the `Options` table when you need a focused run.

Diagnostic run for executor issues:

```luau
local Options = {
    CapabilityReport = true,
    Debug = true,
}
```

Full union + terrain capture for StreamingEnabled maps:

```luau
local Options = {
    FullUnionTerrainSupport = true,
    NeutralizeLighting = true,
}
```

Structure-only save when decompile is failing or too slow:

```luau
local Options = {
    noscripts = true,
    CapabilityReport = true,
}
```

## Configuration Options

### Save Options

- **FullUnionTerrainSupport** - Enable full union mesh + streamed terrain capture profile; turns on `SetStreaming`, keeps hidden-property reads enabled, disables union-to-part fallback, and raises terrain settle time unless you override it (default: false)
- **CapabilityReport** - Write `saveinstance-capabilities.txt` with executor support, selected options, decompile API results, and likely save limitations (default: false)
- **Debug** - Write the larger `saveinstance-debug.txt` run log for troubleshooting (default: false)

### PrepassOptions

- **RequestsPerMinute** - Maximum number of API requests per minute (default: 1350)
- **MaxInFlight** - Maximum concurrent requests (default: 30)
- **ApiUrl** - Decompiler API endpoint (default: "https://api.lua.expert/decompile")
- **RequestTimeout** - Per-request decompile API timeout in seconds (default: 20)
- **Verbose** - Enable detailed logging (default: true)
- **SkipPrepass** - Skip cache warm-up and go straight to USSI (default: false)
- **SkipSaveInstance** - Run only the prepass without calling USSI (default: false)
- **UseSaveInstancePrepass** - Use `saveinstance.luau`'s built-in `DecompilePrepass` instead of the legacy prepass hook (default: false)
- **PersistentCache** - Save decompiled scripts to disk and reuse them on later runs, so repeat saves of the same game skip the decompile API entirely. Requires an executor with `writefile`/`readfile`/`isfile`; falls back to in-memory caching if unavailable (default: true)
- **CacheDir** - Workspace folder name used for the persistent cache (default: `saveinstance_decompile_cache`)
- **ClearCache** - Delete the persistent cache folder before the run, forcing a fresh decompile of every script. Useful when your executor's decompiler has improved or the cache is suspected stale. Requires `delfile`/`delfolder` support (default: false)
- **RepoURL** - Override the repository URL used to load `saveinstance.luau` (default: this repository)
- **ScriptName** - Override the loaded script name without changing the wrapper (default: `saveinstance`)

## What's Different from the Original

This version improves upon the original USSI implementation with several key enhancements:

1. **Memory optimization** - Fixed O(n^2) string concatenation issue
2. **Enhanced terrain support** - Proper serialization of SmoothGrid and PhysicsGrid
3. **Union mesh preservation** - Correct handling of MeshData2 with fallback to visible bounding-box
4. **Accurate part rendering** - Uses official Roblox API dump for Color3uint8 and size members
5. **Complete media support** - Handles Image, Texture, and SoundId content types

## Credits

- [luau](https://github.com/luau/UniversalSynSaveInstance) - Original USSI project
- [centerepic](https://gitlab.com/centerepic/ussiprepass) - USSI Prepass script
- [lua.expert](https://lua.expert) - Decompiler tool

## License

This project builds upon the work of the original USSI and USSI Prepass projects.
