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
- **Asset manifest** - `AssetManifest` collects every `rbxassetid://`, `rbxasset://`, and `http://` URI into a companion list so you can recover all textures, sounds, meshes, decals, and animations
- **Granular filtering** - `IgnoreNamePatterns`, `IgnoreTags`, and `SaveOnlyTags` let you skip or isolate instances by name pattern or `CollectionService` tag
- **Save verification** - `VerifySave` writes a report counting scripts decompiled, unions with mesh data, and MeshParts recovered so you know how complete the save was
- **Resume decompile** - `ResumeSave` checkpoints the decompile cache to disk periodically so if the game crashes mid-save, the next run resumes from where it left off

## Installation

Load the prepass script directly from GitHub:

```lua
local prepass = loadstring(game:HttpGet("https://raw.githubusercontent.com/achmdfzn/SaveInstanceFetch/main/prepass.luau", true))()
```

## Usage

Copy-paste snippet di bawah ini ke executor kamu. Ini adalah **preset default** yang paling sering dipakai — sudah include laporan capability, daftar aset, dan verifikasi hasil save.

```luau
local prepass = loadstring(game:HttpGet("https://raw.githubusercontent.com/achmdfzn/SaveInstanceFetch/main/prepass.luau", true))()

local Options = {
    CapabilityReport = true,      -- laporan capability executor (saveinstance-capabilities.txt)
    AssetManifest = true,         -- daftar semua asset ID yang dipakai game (saveinstance-assets.txt)
    VerifySave = true,            -- statistik hasil save: script, union, meshpart (saveinstance-verify.txt)
    -- Full list @ https://luau.github.io/UniversalSynSaveInstance/api/SynSaveInstance
}

local PrepassOptions = {
    RequestsPerMinute = 1350,
    MaxInFlight = 30,
    RequestTimeout = 20,
    ApiUrl = "https://api.lua.expert/decompile",
    Verbose = true,
    SkipPrepass = false,          -- true = langsung save tanpa cache warm-up
    SkipSaveInstance = false,     -- true = hanya decompile, tidak save
    UseSaveInstancePrepass = false,
    PersistentCache = true,       -- cache decompile ke disk, skip API di run berikutnya
    CacheDir = "saveinstance_decompile_cache",
    ClearCache = false,           -- true = hapus cache lama, decompile ulang semua
    RepoURL = "https://raw.githubusercontent.com/achmdfzn/SaveInstanceFetch/main/",
    ScriptName = "saveinstance",
}

prepass(Options, PrepassOptions)
```

### Alternatif cepat

Ganti atau tambahkan key di `Options` / `PrepassOptions` sesuai kebutuhan:

| Yang mau dilakukan | Tambahkan ini |
|-------------------|---------------|
| Ganti ke built-in decompile parallel (tanpa hook) | `PrepassOptions.UseSaveInstancePrepass = true` |
| Resume decompile kalau crash tengah jalan | `Options.ResumeSave = true` |
| Export geometry MeshPart private ke `.obj` (Blender) | `Options.ExportObj = true` + `Options.SetStreaming = true` |
| Full union + terrain untuk map StreamingEnabled | `Options.FullUnionTerrainSupport = true` |
| Skip decompile (hanya struktur) | `Options.noscripts = true` |

> 💡 Semua opsi `Options` bisa digabung dalam satu table. Contoh lengkap ada di bagian **Recommended Presets** di bawah.


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

Capture everything with verification and asset catalog:

```luau
local Options = {
    FullUnionTerrainSupport = true,
    AssetManifest = true,
    VerifySave = true,
    ExportObj = true,
}
```

Resume a crashed save (only the decompile phase resumes):

```luau
local Options = {
    ResumeSave = true,
}
```

Filter by name pattern or CollectionService tag:

```luau
local Options = {
    IgnoreNamePatterns = {"^Camera$", "ZoneVisual$"},
    IgnoreTags = {"EditorOnly", "ZoneBorder"},
    -- SaveOnlyTags = {"SaveMe"}, -- uncomment to save ONLY tagged instances
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
