# SaveInstanceFetch

> A smart SaveInstance tool that saves Roblox games the way they actually look — with working terrain, unions, media, script decompiling, and asset recovery.

## About

SaveInstanceFetch adalah fork dari [UniversalSynSaveInstance](https://github.com/luau/UniversalSynSaveInstance) yang fokus pada **akurasi visual** dan **kemudahan pemakaian**. Script ini menyimpan game Roblox lengkap dengan terrain, union mesh, decal/gambar/suara, dan script yang sudah di-decompile — bukan hanya struktur kosong.

**Kenapa pakai ini?**

- **Visual akurat** — terrain, union, meshpart, decal, sound semua ter-render benar di Studio
- **Cepat** — table buffer menggantikan string concatenation (fix O(n²) memory issue di game besar)
- **Aman** — resume decompile kalau crash, cache persisten biar run kedua lebih cepat
- **Recovery lengkap** — export mesh private ke `.obj`, download asset ke folder, daftar semua asset ID
- **Diagnostik** — laporan capability executor + verifikasi hasil save

## Packages

| File | Deskripsi |
|------|-----------|
| [`saveinstance.luau`](saveinstance.luau) | Script utama — handle save instance, terrain, union, decompile, export |
| [`prepass.luau`](prepass.luau) | Wrapper prepass — cache decompile ke disk, hook `decompile`, load saveinstance |
| [`docs/option.md`](docs/option.md) | Referensi lengkap semua opsi yang tersedia |

**Tidak perlu install dependency tambahan.** Cukup load langsung dari GitHub raw.

## Usage

Copy-paste snippet di bawah ke executor kamu. Ini preset rekomendasi yang sudah include laporan diagnostik, daftar aset, verifikasi, dan resume:

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

### Cara Pakai

1. Buka executor kamu (Xeno, Solara, Wave, Volt, dll)
2. Inject / attach ke Roblox
3. Paste snippet di atas ke console executor
4. Execute — tunggu sampai muncul `[saveinstance] Saved!`
5. Cek hasil di folder workspace executor:
   - `*.rbxlx` — file save (buka di Roblox Studio)
   - `saveinstance-capabilities.txt` — laporan dukungan executor
   - `saveinstance-verify.txt` — statistik hasil save
   - `saveinstance-assets.txt` — daftar semua asset ID
   - `saveinstance_assets/` — folder asset yang di-download (kalau `DownloadAssets = true`)

### Quick Switch

Tambahkan ke `Options` sesuai kebutuhan:

| Yang mau dilakukan | Tambahkan ini |
|--------------------|---------------|
| Map StreamingEnabled: union mesh + terrain lengkap | `FullUnionTerrainSupport = true` |
| Recover mesh private ke `.obj` (Blender) | `ExportObj = true, SetStreaming = true` |
| Download semua asset ke folder workspace | `AssetManifest = true, DownloadAssets = true` |
| Save struktur/map saja, skip decompile | `noscripts = true` |
| Skip instance by pola nama | `IgnoreNamePatterns = {"^Camera$"}` |
| Skip instance by tag CollectionService | `IgnoreTags = {"EditorOnly"}` |
| Save HANYA instance bertag tertentu | `SaveOnlyTags = {"SaveMe"}` |
| Reset cache decompile (kalau basi) | `PrepassOptions.ClearCache = true` |

Daftar opsi lengkap: [`docs/option.md`](docs/option.md).

## Features

- **Faster, lighter saves** — table buffer menggantikan string concatenation, memperbaiki growth O(n²) yang bikin "not enough memory" di game besar
- **Terrain, unions, & media** — SmoothGrid/PhysicsGrid, union MeshData2, decal/gambar/suara semua ter-render benar
- **Whole-map capture** — `SetStreaming` / `FullUnionTerrainSupport` force-load map StreamingEnabled sebelum save
- **Private mesh recovery** — `ExportObj` bake geometry MeshPart ke `.obj` world-space
- **Persistent decompile cache** — `PersistentCache` simpan hasil decompile di disk, skip API pihak ketiga di run berikutnya
- **Asset manifest** — `AssetManifest` daftar semua URI aset (`rbxassetid://`, `rbxasset://`, `http://`)
- **Asset downloader** — `DownloadAssets` otomatis download semua `rbxassetid://` ke folder workspace, deteksi tipe file dari magic bytes (PNG/OGG/mesh/rbxm), siap drag-drop ke Studio
- **Save verification** — `VerifySave` hitung script/union/meshpart yang ter-recover
- **Granular filtering** — `IgnoreNamePatterns`, `IgnoreTags`, `SaveOnlyTags`
- **Resume decompile** — `ResumeSave` checkpoint ke disk, lanjut dari titik terakhir kalau crash
- **Runtime option validation** — kalau tipe data option salah, script langsung `warn()` dengan pesan jelas sebelum save dimulai

## Release

Versi terbaru selalu ada di branch `main`. Tidak ada versioning formal — pull terbaru dari GitHub raw setiap kali untuk dapat perbaikan terkini.

```bash
git clone https://github.com/achmdfzn/SaveInstanceFetch.git
```

Atau load langsung tanpa clone:

```luau
loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/achmdfzn/SaveInstanceFetch/main/prepass.luau", true))()
```

### Changelog

| Tanggal | Perubahan |
|---------|-----------|
| 2026-07-15 | Hardening DownloadAssets: fix bug isfolder, HTTP timeout, retry transient, deadlock protection, backslash fallback |
| 2026-07-15 | Deteksi tipe file dari magic bytes, simpan dengan ekstensi benar (png/ogg/mesh/rbxm) |
| 2026-07-15 | Fix Content descriptor crash pada string `rbxassetid://` |
| 2026-07-15 | Tambah runtime option type validation |
| 2026-07-15 | Tambah `DownloadAssets` — download asset dari manifest ke disk |
| 2026-07-15 | Hapus orphan syntax block + fix indentasi |
| 2026-07-15 | Tambah `AssetManifest`, `VerifySave`, `ResumeSave`, tag/pattern filter |

## Executor Compatibility

| Executor | Terrain | Union Mesh | Scripts | Notes |
|----------|---------|------------|---------|-------|
| Synapse / Wave | Yes | Yes | Yes | Full support |
| Volt | Yes | Yes | Yes | Full support, has native decompiler |
| Xeno | No | No | Yes | No `gethiddenproperty` — terrain & union mesh tidak tersimpan |
| Solara | No | No | Yes | No `gethiddenproperty` — fallback ke bounding box |
| Fluxus | Yes | Partial | Yes | `gethiddenproperty` ada tapi bisa buggy |

> Cek `saveinstance-capabilities.txt` setelah run untuk tau dukungan executor kamu.

## Credits

- [luau](https://github.com/luau/UniversalSynSaveInstance) — Original USSI project
- [centerepic](https://gitlab.com/centerepic/ussiprepass) — USSI Prepass script
- [lua.expert](https://lua.expert) — Decompiler tool
- [RealSlimShady2000](https://github.com/RealSlimShady2000/SaveInstance420Edition) — SaveInstance 420 Edition base

## License

This project builds upon the work of the original USSI and USSI Prepass projects.
