# SaveInstanceFetch

A smart SaveInstance tool that correctly saves any Roblox games the way they look.

## Features

- **Faster, lighter saves** - Uses table buffer instead of repeated string concatenation, fixing the O(n²) growth that caused "not enough memory" on large games
- **Terrain support** - SmoothGrid and PhysicsGrid are serialized and render properly
- **Unions render correctly** - Re-enabled gethiddenproperty during save to read union's MeshData2
- **Part properties preserved** - Color and Size are saved using official Roblox CDN API dump
- **Media content supported** - Decals, images, and sounds are saved with proper Content DataType handling
- **Whole-map streaming capture** - `SetStreaming` force-loads StreamingEnabled maps before saving
- **Private mesh recovery path** - `ExportObj` can bake MeshPart geometry into a world-space `.obj` file
- **Cleaner saved scenes** - `NeutralizeLighting` can reset dark/foggy lighting before save
- **Debuggable decompile flow** - `Debug`, `DecompilePrepass`, and `PrepassMaxScripts` expose diagnostics and safer API pacing

## Installation

Load the prepass script directly from GitHub:

```lua
local prepass = loadstring(game:HttpGet("https://raw.githubusercontent.com/achmdfzn/SaveInstanceFetch/main/prepass.luau", true))()
```

## Usage

```lua
local prepass = loadstring(game:HttpGet("https://raw.githubusercontent.com/achmdfzn/SaveInstanceFetch/main/prepass.luau", true))()

local Options = {} -- Full list @ https://luau.github.io/UniversalSynSaveInstance/api/SynSaveInstance

local PrepassOptions = {
    RequestsPerMinute = 1350,
    MaxInFlight       = 30,
    ApiUrl            = "https://api.lua.expert/decompile",
    Verbose           = true,
    SkipPrepass       = false, -- skip cache warm-up, go straight to USSI
    SkipSaveInstance  = false, -- run only the prepass, don't call USSI
}

prepass(Options, PrepassOptions)
```

## Configuration Options

### PrepassOptions

- **RequestsPerMinute** - Maximum number of API requests per minute (default: 1350)
- **MaxInFlight** - Maximum concurrent requests (default: 30)
- **ApiUrl** - Decompiler API endpoint (default: "https://api.lua.expert/decompile")
- **Verbose** - Enable detailed logging (default: true)
- **SkipPrepass** - Skip cache warm-up and go straight to USSI (default: false)
- **SkipSaveInstance** - Run only the prepass without calling USSI (default: false)

## What's Different from the Original

This version improves upon the original USSI implementation with several key enhancements:

1. **Memory optimization** - Fixed O(n²) string concatenation issue
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
