-- SaveInstanceFetch - Recommended Usage (achmdfzn fork)
-- Load lewat prepass.luau supaya dapat cache decompile on-disk:
-- run kedua di game yang sama jauh lebih cepat & lebih sedikit bytecode
-- dikirim ke API pihak ketiga.

local prepass = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/achmdfzn/SaveInstanceFetch/main/prepass.luau", true))()

local Options = {
    -- Capture map
    SetStreaming = false,        -- true = force-load seluruh StreamingEnabled map dulu
    NeutralizeLighting = false,  -- true = save kebuka terang (siang), bukan gelap/berkabut
    ExportObj = false,           -- true = dump mesh ke .obj juga (buat recover mesh private)

    -- Diagnostik & keamanan hasil (murah, sangat membantu kalau ada yang gagal)
    CapabilityReport = true,     -- saveinstance-capabilities.txt: dukungan executor
    AssetManifest    = true,     -- saveinstance-assets.txt: semua asset ID yang dipakai game
    VerifySave       = true,     -- saveinstance-verify.txt: statistik script/union/meshpart
    ResumeSave       = true,     -- resume decompile kalau crash tengah jalan
}

local PrepassOptions = {
    PersistentCache = true,      -- cache decompile ke disk, skip API di run berikutnya
    RepoURL = "https://raw.githubusercontent.com/achmdfzn/SaveInstanceFetch/main/",
}

prepass(Options, PrepassOptions)

--[[ ============================================================
  Butuh yang lain? Tambahkan ke Options:

    FullUnionTerrainSupport = true   -- map StreamingEnabled: union mesh + terrain lengkap
    noscripts               = true   -- save struktur/map saja, skip decompile
    ExportObj = true, SetStreaming = true  -- recover mesh private ke .obj (Blender)

  Filter instance:
    IgnoreNamePatterns = {"^Camera$", "ZoneVisual$"}  -- skip by pola nama
    IgnoreTags         = {"EditorOnly"}               -- skip by tag CollectionService
    SaveOnlyTags       = {"SaveMe"}                    -- save HANYA yang bertag ini

  Reset cache decompile (kalau dicurigai basi):
    PrepassOptions.ClearCache = true
============================================================ ]]
