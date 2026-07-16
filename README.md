# SaveInstanceFetch

> A smart SaveInstance tool that saves Roblox games the way they actually look — with working terrain, unions, media, script decompiling, and asset recovery.

## About

SaveInstanceFetch is a fork of [UniversalSynSaveInstance](https://github.com/luao/UniversalSynSaveInstance) focused on **visual accuracy** and **ease of use**. It saves Roblox games complete with terrain, union mesh, decals/images/sounds, and decompiled scripts — not just an empty structure.

**Why use this?**

- **Accurate visuals** — terrain, unions, mesh parts, decals, and sounds all render correctly in Studio
- **Fast** — table buffer replaces string concatenation (fixes O(n²) memory issue on large games)
- **Safe** — resume decompile on crash, persistent cache makes the second run faster
- **Full recovery** — export private meshes to `.obj`, download assets to a folder, list all asset IDs
- **Diagnostic** — executor capability report + save verification

## Packages

| File | Description |
|------|-------------|
| [`saveinstance.luau`](saveinstance.luau) | Main script — handles save instance, terrain, unions, decompile, export |
| [`prepass.luau`](prepass.luau) | Prepass wrapper — caches decompile to disk, hooks `decompile`, loads saveinstance |
| [`docs/option.md`](docs/option.md) | Full reference for all available options |

**No extra dependencies needed.** Load directly from GitHub raw.

## Usage

Copy-paste this snippet into your executor:

```luau
local prepass = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/achmdfzn/SaveInstanceFetch/main/prepass.luau", true))()

local Options = {
    SetStreaming       = false, -- force-load the whole StreamingEnabled map first (set true for big maps)
    NeutralizeLighting = false, -- reset Lighting to clean midday so the place opens bright, not dark/foggy
    ExportObj          = false, -- also bake MeshPart geometry to .obj (recovers private meshes; pair with SetStreaming)
    CapabilityReport   = true,  -- write saveinstance-capabilities.txt (executor support + likely limitations)
    AssetManifest      = true,  -- write saveinstance-assets.txt listing every asset URI in the save
    DownloadAssets     = true,  -- download every rbxassetid:// asset into saveinstance_assets/ (needs AssetManifest)
    VerifySave         = true,  -- write saveinstance-verify.txt counting recovered scripts/unions/meshparts
    ResumeSave         = true,  -- checkpoint the decompile cache to disk so a crash mid-save can resume
    AntiIdle           = true,  -- disable the Idled kick so a long save doesn't get you kicked for inactivity
}

local PrepassOptions = {
    PersistentCache = true,     -- keep the decompile cache on disk so repeat runs skip the third-party API
    RepoURL = "https://raw.githubusercontent.com/achmdfzn/SaveInstanceFetch/main/",
}

prepass(Options, PrepassOptions)
```

> **Privacy note:** when an executor lacks a native decompiler, scripts are decompiled via the third-party **lua.expert** API — script bytecode is sent off-device. Set `noscripts = true` to skip decompiling entirely.

### How to use

1. Open your executor (Xeno, Solara, Wave, Volt, etc.)
2. Inject / attach to Roblox
3. Paste the snippet above into the executor console
4. Execute — wait until you see `[saveinstance] Saved!`
5. Check the output in your executor's workspace folder:
   - `*.rbxlx` — save file (open in Roblox Studio)
   - `saveinstance-capabilities.txt` — executor support report
   - `saveinstance-verify.txt` — save statistics
   - `saveinstance-assets.txt` — list of all asset IDs
   - `saveinstance_assets/` — downloaded assets (when `DownloadAssets = true`)

### Downloaded assets (`saveinstance_assets/`)

Files are saved with the correct extension based on magic bytes detection:

| Extension | Studio drag-drop? | How to use |
|-----------|:-:|------------|
| `.png` `.jpg` `.bmp` | Yes | Drag into viewport → creates Decal |
| `.ogg` | Yes | Drag into viewport → creates Sound |
| `.rbxm` | Yes | Drag into viewport → inserts model |
| `.obj` | Yes | Drag into viewport → imports as MeshPart (converted from `.mesh`) |
| `.mesh` | No | Conversion failed — Roblox internal format, kept as backup |
| `.bin` | No | Unknown type — rename to inspect |

**Mesh → OBJ conversion:** By default (`DownloadAssetsConvertMesh = true`), downloaded `.mesh` files are automatically converted to `.obj` — a format Studio and Blender can import. The converter supports all Roblox mesh format versions (v1 text, v2/v3 text, v4/v5 binary). If conversion fails, the raw `.mesh` is kept as a fallback.

**About `.mesh` files:** Roblox Studio cannot import `.mesh` files directly — it's Roblox's internal binary mesh format. When you open the `.rbxlx` save in Studio with internet, MeshParts with `MeshId = rbxassetid://ID` load from the Roblox CDN automatically.

For **private mesh recovery** (meshes Studio can't re-download from CDN), use `ExportObj = true` — it bakes all MeshPart geometry to `.obj` via `AssetService:CreateEditableMeshAsync`, even for meshes that can't be downloaded.

### Quick Switch

Add these to `Options` as needed:

| Goal | Add this |
|------|----------|
| Full union mesh + terrain on StreamingEnabled maps | `FullUnionTerrainSupport = true` |
| Recover private meshes to `.obj` (Blender / Studio import) | `ExportObj = true, SetStreaming = true` |
| Save structure/map only, skip decompile | `noscripts = true` |
| Skip instances by name pattern | `IgnoreNamePatterns = {"^Camera$"}` |
| Skip instances by CollectionService tag | `IgnoreTags = {"EditorOnly"}` |
| Save ONLY instances with certain tags | `SaveOnlyTags = {"SaveMe"}` |
| Reset decompile cache (if stale) | `PrepassOptions.ClearCache = true` |

Full options list: [`docs/option.md`](docs/option.md).

## Features

- **Faster, lighter saves** — table buffer replaces string concatenation, fixing the O(n²) growth that causes "not enough memory" on large games
- **Terrain, unions, & media** — SmoothGrid/PhysicsGrid, union MeshData2, decals/images/sounds all render correctly
- **Whole-map capture** — `SetStreaming` / `FullUnionTerrainSupport` force-loads StreamingEnabled maps before saving
- **Bright lighting on open** — `NeutralizeLighting` resets Lighting/Atmosphere/effects to clean midday so the place isn't dark/foggy in Studio
- **Executor capability report** — `CapabilityReport` writes `saveinstance-capabilities.txt` describing executor support and likely save limitations
- **Idle-kick protection** — `AntiIdle` disables the Idled connection so a long save doesn't kick you for inactivity (on by default)
- **Private mesh recovery** — `ExportObj` bakes MeshPart geometry into world-space `.obj`
- **Persistent decompile cache** — `PersistentCache` stores decompile results on disk, skipping third-party API on subsequent runs
- **Asset manifest** — `AssetManifest` lists all asset URIs (`rbxassetid://`, `rbxasset://`, `http://`)
- **Asset downloader** — `DownloadAssets` fetches all `rbxassetid://` assets to a workspace folder, detects file type from magic bytes (PNG/OGG/mesh/rbxm), follows CDN redirects, and converts `.mesh` to `.obj` (Studio-importable) — ready to drag-drop into Studio
- **Save verification** — `VerifySave` counts recovered scripts/unions/meshparts
- **Granular filtering** — `IgnoreNamePatterns`, `IgnoreTags`, `SaveOnlyTags`
- **Resume decompile** — `ResumeSave` checkpoints to disk, resumes from the last point on crash
- **Runtime option validation** — warns with a clear message if an option has the wrong type before saving starts

## Release

The latest version is always on the `main` branch. No formal versioning — pull from GitHub raw each time to get the latest fixes.

```bash
git clone https://github.com/achmdfzn/SaveInstanceFetch.git
```

Or load directly without cloning:

```luau
loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/achmdfzn/SaveInstanceFetch/main/prepass.luau", true))()
```

### Changelog

| Date | Change |
|------|--------|
| 2026-07-16 | Fix `bit32.byteswap` polyfill mask constants (corrupted Base64/hashlib output on executors like Fluxus) |
| 2026-07-16 | Document recommended usage options inline; add NeutralizeLighting/CapabilityReport/AntiIdle to features |
| 2026-07-16 | Convert `.mesh` to `.obj` during DownloadAssets (Studio-importable); supports v1–v5 mesh formats |
| 2026-07-15 | Fix DownloadAssets: follow 302 redirect to CDN, HTTP failure diagnostics |
| 2026-07-15 | Harden DownloadAssets: fix isfolder bug, retry transient errors, deadlock protection, backslash fallback |
| 2026-07-15 | Detect file type from magic bytes, save with correct extension (png/ogg/mesh/rbxm) |
| 2026-07-15 | Fix Content descriptor crash on string `rbxassetid://` |
| 2026-07-15 | Add runtime option type validation |
| 2026-07-15 | Add `DownloadAssets` — download assets from manifest to disk |
| 2026-07-15 | Remove orphan syntax block + fix indentation |
| 2026-07-15 | Add `AssetManifest`, `VerifySave`, `ResumeSave`, tag/pattern filtering |

## Executor Compatibility

| Executor | Terrain | Union Mesh | Scripts | Notes |
|----------|---------|------------|---------|-------|
| Synapse / Wave | Yes | Yes | Yes | Full support |
| Volt | Yes | Yes | Yes | Full support, has native decompiler |
| Xeno | No | No | Yes | No `gethiddenproperty` — terrain & union mesh not saved |
| Solara | No | No | Yes | No `gethiddenproperty` — falls back to bounding box |
| Fluxus | Yes | Partial | Yes | `gethiddenproperty` exists but can be buggy |

> Check `saveinstance-capabilities.txt` after a run to see your executor's support.

## Credits

- [luau](https://github.com/luao/UniversalSynSaveInstance) — Original USSI project
- [centerepic](https://gitlab.com/centerepic/ussiprepass) — USSI Prepass script
- [lua.expert](https://lua.expert) — Decompiler tool
- [RealSlimShady2000](https://github.com/RealSlimShady2000/SaveInstance420Edition) — SaveInstance 420 Edition base

## License

This project builds upon the work of the original USSI and USSI Prepass projects.
