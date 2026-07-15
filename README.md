# SaveInstanceFetch

A smart SaveInstance tool that saves Roblox games the way they actually look — with working terrain, unions, media, and script decompiling.

## Usage

Copy-paste ini ke executor kamu. Ini preset yang direkomendasikan: load lewat `prepass.luau` supaya dapat cache decompile on-disk (run kedua di game yang sama jauh lebih cepat), plus laporan diagnostik dan resume kalau crash.

```luau
local prepass = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/achmdfzn/SaveInstanceFetch/main/prepass.luau", true))()

local Options = {
    -- Capture map
    SetStreaming = false,        -- true = force-load seluruh StreamingEnabled map dulu
    NeutralizeLighting = false,  -- true = save kebuka terang (siang), bukan gelap/berkabut
    ExportObj = false,           -- true = dump mesh ke .obj juga (buat recover mesh private)

    -- Diagnostik & keamanan hasil
    CapabilityReport = true,     -- saveinstance-capabilities.txt: dukungan executor
    AssetManifest    = true,     -- saveinstance-assets.txt: semua asset ID yang dipakai game
    VerifySave       = true,     -- saveinstance-verify.txt: statistik script/union/meshpart
    ResumeSave       = true,     -- resume decompile kalau crash tengah jalan
    AntiIdle         = true,     -- cegah kick idle saat save panjang (map besar)
}

local PrepassOptions = {
    PersistentCache = true,      -- cache decompile ke disk, skip API di run berikutnya
    RepoURL = "https://raw.githubusercontent.com/achmdfzn/SaveInstanceFetch/main/",
}

prepass(Options, PrepassOptions)
```

### Butuh yang lain?

Tambahkan ke `Options` sesuai kebutuhan:

| Yang mau dilakukan | Tambahkan ini |
|--------------------|---------------|
| Map StreamingEnabled: union mesh + terrain lengkap | `FullUnionTerrainSupport = true` |
| Recover mesh private ke `.obj` (Blender) | `ExportObj = true, SetStreaming = true` |
| Save struktur/map saja, skip decompile | `noscripts = true` |
| Skip instance by pola nama | `IgnoreNamePatterns = {"^Camera$"}` |
| Skip instance by tag CollectionService | `IgnoreTags = {"EditorOnly"}` |
| Save HANYA instance bertag tertentu | `SaveOnlyTags = {"SaveMe"}` |
| Download semua asset ke folder workspace | `AssetManifest = true, DownloadAssets = true` |
| Reset cache decompile (kalau basi) | `PrepassOptions.ClearCache = true` |

Daftar opsi lengkap: [`docs/option.md`](docs/option.md).

## Features

- **Runtime option validation** — kalau tipe data option salah (misal `SetStreaming = "true"` string), script langsung `warn()` dengan pesan jelas sebelum save dimulai
- **Faster, lighter saves** — table buffer menggantikan string concatenation, memperbaiki growth O(n^2) yang bikin "not enough memory" di game besar
- **Terrain, unions, & media** — SmoothGrid/PhysicsGrid, union MeshData2, decal/gambar/suara semua ter-render benar
- **Whole-map capture** — `SetStreaming` / `FullUnionTerrainSupport` force-load map StreamingEnabled sebelum save
- **Private mesh recovery** — `ExportObj` bake geometry MeshPart ke `.obj` world-space
- **Persistent decompile cache** — `PersistentCache` simpan hasil decompile di disk, skip API pihak ketiga di run berikutnya
- **Asset manifest & verifikasi** — `AssetManifest` daftar semua URI aset, `VerifySave` hitung script/union/meshpart yang ter-recover
- **Asset downloader** — `DownloadAssets` otomatis download semua `rbxassetid://` dari manifest ke folder workspace, siap drag-drop ke Studio
- **Granular filtering** — `IgnoreNamePatterns`, `IgnoreTags`, `SaveOnlyTags`
- **Resume decompile** — `ResumeSave` checkpoint ke disk, lanjut dari titik terakhir kalau crash

## Credits

- [luau](https://github.com/luau/UniversalSynSaveInstance) — Original USSI project
- [centerepic](https://gitlab.com/centerepic/ussiprepass) — USSI Prepass script
- [lua.expert](https://lua.expert) — Decompiler tool

## License

Builds upon the original USSI and USSI Prepass projects.
