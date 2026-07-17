-- SaveInstanceFetch prepass loader.
-- Usage (USSI-style):
--   local Params = {
--       RepoURL = "https://raw.githubusercontent.com/achmdfzn/SaveInstanceFetch/main/",
--       Prepass = "prepass",
--   }
--   local prepass = loadstring(game:HttpGet(Params.RepoURL .. Params.Prepass .. ".luau", true), Params.Prepass)()
--   local Options = {}        -- saveinstance options; see docs/option.md
--   local PrepassOptions = {} -- optional; PersistentCache/RepoURL default sensibly
--   prepass(Options, PrepassOptions)

local Syn = type(syn) == "table" and syn or nil
local Http = type(http) == "table" and http or nil
local HttpRequest = request or http_request or (Syn and Syn.request) or (Http and Http.request)

local cloneref = cloneref or function(o) return o end

local game = cloneref(game)
local workspace = cloneref(workspace)

local HttpService = cloneref(game:GetService("HttpService"))
local RunService = cloneref(game:GetService("RunService"))
local GlobalEnv = getgenv and getgenv() or _G or shared

local CoreContainers = {}
for _, ServiceName in next, { "CoreGui", "CorePackages", "RobloxReplicatedStorage", "RobloxLocalReplicatedStorage" } do
    local Ok, Service = pcall(game.GetService, game, ServiceName)
    if Ok and Service then
        CoreContainers[#CoreContainers + 1] = cloneref(Service)
    end
end

local function IsCoreInstance(o)
    for _, Container in next, CoreContainers do
        local Ok, Res = pcall(function() return o == Container or o:IsDescendantOf(Container) end)
        if Ok and Res then return true end
    end
    local OkLocked, Locked = pcall(function() return o.RobloxLocked end)
    if OkLocked and Locked then return true end
    return false
end

local Config = {
    RequestsPerMinute = 1350,
    MaxInFlight = 30,
    RequestTimeout = 20,
    ApiUrl  = "https://api.lua.expert/decompile",
    RepoURL = "https://raw.githubusercontent.com/achmdfzn/SaveInstanceFetch/main/",
    ScriptName = "saveinstance",
    Verbose = true,
    PersistentCache = true, -- reuse decompiled scripts from disk across runs (skips repeat API calls)
    CacheDir = "saveinstance_decompile_cache", -- workspace folder used when PersistentCache is on
    ClearCache = false, -- wipe the on-disk cache before this run (use when cached results are stale)
    -- Update / resilience settings for the main saveinstance.luau source:
    CacheMainScript = true, -- keep the last good saveinstance.luau on disk and fall back to it if a download fails
    MainScriptCacheFile = "saveinstance_source_cache.luau", -- workspace file used when CacheMainScript is on
    CheckForUpdates = true, -- fetch version.txt from the repo and report when a newer version is available
    VersionFile = "version.txt", -- file at RepoURL that holds the current published version string
}

local function Base64Encode(Data)
    if base64_encode then return base64_encode(Data) end
    if base64encode then return base64encode(Data) end
    if type(crypt) == "table" then
        if crypt.base64encode then return crypt.base64encode(Data) end
        if crypt.base64 and crypt.base64.encode then return crypt.base64.encode(Data) end
    end
    local B = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    return ((Data:gsub(".", function(x)
        local R, Byte = "", x:byte()
        for i = 8, 1, -1 do
            R = R .. (Byte % 2 ^ i - Byte % 2 ^ (i - 1) > 0 and "1" or "0")
        end
        return R
    end) .. "0000"):gsub("%d%d%d?%d?%d?%d?", function(x)
        if #x < 6 then return "" end
        local C = 0
        for i = 1, 6 do
            C = C + (x:sub(i, i) == "1" and 2 ^ (6 - i) or 0)
        end
        return B:sub(C + 1, C + 1)
    end) .. ({ "", "==", "=" })[#Data % 3 + 1])
end

local Cache = {}
local NextSlot = 0

-- Persistent (on-disk) decompile cache. Optional: only used when the executor
-- exposes file APIs and Config.PersistentCache is enabled. Falls back silently
-- to the in-memory Cache above when unavailable.
local WriteFile = writefile
local ReadFile = readfile
local IsFile = isfile
local IsFolder = isfolder
local MakeFolder = makefolder

local DiskCache = {
    Enabled = false,
    Dir = nil,
    Reads = 0,
    Writes = 0,
}

-- Deterministic 32-bit FNV-1a hash rendered as hex, used for cache file names.
-- Uses bit32 (Luau) for the XOR step; the multiply is split across two 16-bit
-- halves to stay within exact double-precision integer range.
local Bxor = (bit32 and bit32.bxor) or function(a, b)
    local Result, Bit = 0, 1
    while a > 0 or b > 0 do
        local Abit, Bbit = a % 2, b % 2
        if Abit ~= Bbit then
            Result = Result + Bit
        end
        a = math.floor(a / 2)
        b = math.floor(b / 2)
        Bit = Bit * 2
    end
    return Result
end

local function HashBytecode(Data)
    local Hi, Lo = 0x811c, 0x9dc5
    for i = 1, #Data do
        Lo = Bxor(Lo, Data:byte(i))
        -- 32-bit FNV multiply by 16777619 (0x01000193), carried across two 16-bit halves
        local L = Lo * 0x0193
        local H = Hi * 0x0193 + Lo * 0x0100
        Lo = L % 0x10000
        Hi = (H + math.floor(L / 0x10000)) % 0x10000
    end
    return string.format("%04x%04x%d", Hi % 0x10000, Lo % 0x10000, #Data)
end

local DelFile = delfile
local DelFolder = delfolder
local ListFiles = listfiles

-- Remove previously cached decompile results. Prefers deleting the whole folder;
-- falls back to deleting individual files, then no-ops if neither API exists.
local function ClearDiskCache(Dir)
    local Removed = 0
    if DelFolder then
        local Ok = pcall(DelFolder, Dir)
        if Ok then
            if MakeFolder then pcall(MakeFolder, Dir) end
            return -1 -- signals "whole folder cleared"
        end
    end
    if ListFiles and DelFile then
        local OkList, Files = pcall(ListFiles, Dir)
        if OkList and type(Files) == "table" then
            for _, Path in next, Files do
                if pcall(DelFile, Path) then
                    Removed += 1
                end
            end
        end
    end
    return Removed
end

local function InitDiskCache()
    if not Config.PersistentCache then return end
    if not (WriteFile and ReadFile and IsFile) then
        if Config.Verbose then
            print("[prepass] persistent cache disabled: executor lacks writefile/readfile/isfile")
        end
        return
    end
    local Dir = tostring(Config.CacheDir or "saveinstance_decompile_cache")
    if IsFolder and MakeFolder then
        local OkExists, Exists = pcall(IsFolder, Dir)
        if not (OkExists and Exists) then
            pcall(MakeFolder, Dir)
        end
    end
    if Config.ClearCache then
        local Cleared = ClearDiskCache(Dir)
        if Config.Verbose then
            if Cleared == -1 then
                print("[prepass] cleared decompile cache folder before run")
            else
                print(("[prepass] cleared %d cached decompile file(s) before run"):format(Cleared))
            end
        end
    end
    DiskCache.Enabled = true
    DiskCache.Dir = Dir
end

local function DiskPath(Bytecode)
    return DiskCache.Dir .. "/" .. HashBytecode(Bytecode) .. ".luau"
end

local function DiskCacheGet(Bytecode)
    if not DiskCache.Enabled then return nil end
    local Path = DiskPath(Bytecode)
    local OkExists, Exists = pcall(IsFile, Path)
    if not (OkExists and Exists) then return nil end
    local OkRead, Body = pcall(ReadFile, Path)
    if OkRead and type(Body) == "string" and Body ~= "" then
        DiskCache.Reads += 1
        return Body
    end
    return nil
end

local function DiskCacheSet(Bytecode, Body)
    if not DiskCache.Enabled then return end
    if type(Body) ~= "string" or Body == "" then return end
    local Ok = pcall(WriteFile, DiskPath(Bytecode), Body)
    if Ok then
        DiskCache.Writes += 1
    end
end

local function AcquireRateSlot()
    local RequestsPerMinute = math.max(1, tonumber(Config.RequestsPerMinute) or 1350)
    local MinGap = 60 / RequestsPerMinute
    local Now = os.clock()
    local MySlot = NextSlot > Now and NextSlot or Now
    NextSlot = MySlot + MinGap
    local Delay = MySlot - Now
    if Delay > 0 then
        task.wait(Delay)
    end
end

local function DecompileViaAPI(Bytecode)
    AcquireRateSlot()
    local Settled, Result = false, nil
    task.spawn(function()
        local Ok, Res = pcall(HttpRequest, {
            Url = Config.ApiUrl,
            Method = "POST",
            Headers = { ["content-type"] = "application/json" },
            Body = HttpService:JSONEncode({ script = Base64Encode(Bytecode) }),
        })
        if not Settled then
            Settled = true
            Result = { Ok = Ok, Res = Res }
        end
    end)

    local RequestTimeout = math.max(1, tonumber(Config.RequestTimeout) or 20)
    local Deadline = os.clock() + RequestTimeout
    while not Settled and os.clock() < Deadline do
        task.wait(0.05)
    end

    if not Settled then
        Settled = true
        return false, "timeout"
    end

    if not Result.Ok then
        return false, tostring(Result.Res)
    end
    if not Result.Res or Result.Res.StatusCode ~= 200 then
        return false, Result.Res and Result.Res.Body or "no response"
    end
    return true, Result.Res.Body
end

local function RunPool(Items, Worker)
    local Total = #Items
    if Total == 0 then return end
    local NextIndex, Done = 1, 0

    local function StartNext()
        if NextIndex > Total then return end
        local i = NextIndex
        NextIndex += 1
        task.spawn(function()
            local Ok, Err = pcall(Worker, Items[i])
            if not Ok and Config.Verbose then
                warn("[prepass] worker failed: " .. tostring(Err))
            end
            Done += 1
            StartNext()
        end)
    end

    local MaxInFlight = math.max(1, tonumber(Config.MaxInFlight) or 30)
    for _ = 1, math.min(MaxInFlight, Total) do
        StartNext()
    end
    -- Wait for all workers, but cap the wait so a hung API request or crashed
    -- worker can't stall the prepass forever (30s grace per script, minimum 120s).
    local max_wait = math.max(120, Total * 30)
    local waited = 0
    while Done < Total do
        task.wait(0.5)
        waited += 0.5
        if waited >= max_wait then
            if Config.Verbose then
                warn(("[prepass] timed out after %.0fs (%d/%d done)"):format(waited, Done, Total))
            end
            break
        end
    end
end

local function ResolveName(o)
    local Ok, Name = pcall(function() return o:GetFullName() end)
    if Ok and type(Name) == "string" and Name ~= "" then
        return Name
    end
    local Ok2, Short = pcall(function() return o.Name end)
    return (Ok2 and type(Short) == "string" and Short ~= "" and Short) or "<unknown>"
end

local function GatherUniqueScripts()
    local Objs = {}
    local OkDesc, Descendants = pcall(game.GetDescendants, game)
    if not (OkDesc and type(Descendants) == "table") then
        Descendants = {}
        if Config.Verbose then
            warn("[prepass] game:GetDescendants() failed — no scripts gathered from descendant scan")
        end
    end
    for _, o in next, Descendants do
        local OkIs, IsLSC = pcall(function() return o:IsA("LuaSourceContainer") end)
        if OkIs and IsLSC and not IsCoreInstance(o) then
            local IsServer = o:IsA("Script") and (o.RunContext == Enum.RunContext.Legacy or o.RunContext == Enum.RunContext.Server)
            if not IsServer then
                Objs[#Objs + 1] = cloneref(o)
            end
        end
    end

    if getloadedmodules then
        local OkM, Mods = pcall(getloadedmodules)
        if OkM and type(Mods) == "table" then
            for _, m in next, Mods do
                if not IsCoreInstance(m) then
                    Objs[#Objs + 1] = cloneref(m)
                end
            end
        end
    end

    local Seen, Unique = {}, {}
    for _, o in next, Objs do
        local Ok, Bc = pcall(getscriptbytecode, o)
        if Ok and type(Bc) == "string" and Bc ~= "" and not Seen[Bc] then
            Seen[Bc] = true
            Unique[#Unique + 1] = { Bytecode = Bc, Name = ResolveName(o) }
        end
    end
    return Unique
end

local NoOpUi = { Update = function() end, Destroy = function() end }

local function CreateProgressUI(Total)
    if type(Drawing) ~= "table" and type(Drawing) ~= "userdata" then
        return NoOpUi
    end

    local State = { Done = 0, Dispatched = 0, Name = "" }
    local Objects = {}
    local Connection

    local Ok = pcall(function()
        local Camera = workspace.CurrentCamera and cloneref(workspace.CurrentCamera)
        local Viewport = (Camera and Camera.ViewportSize) or Vector2.new(1280, 720)
        local BarWidth, BarHeight = 420, 14
        local BarX = math.floor((Viewport.X - BarWidth) / 2)
        local BarY = 24

        local function Square(Color, Filled, Thickness)
            local S = Drawing.new("Square")
            S.Color = Color
            S.Filled = Filled
            S.Thickness = Thickness or 1
            S.Visible = true
            Objects[#Objects + 1] = S
            return S
        end

        local Bg = Square(Color3.fromRGB(20, 20, 20), true)
        Bg.Size = Vector2.new(BarWidth, BarHeight)
        Bg.Position = Vector2.new(BarX, BarY)
        Bg.Transparency = 0.85

        local DispatchedFill = Square(Color3.fromRGB(200, 160, 60), true)
        DispatchedFill.Size = Vector2.new(0, BarHeight)
        DispatchedFill.Position = Vector2.new(BarX, BarY)
        DispatchedFill.Transparency = 0.55

        local CompletedFill = Square(Color3.fromRGB(80, 180, 90), true)
        CompletedFill.Size = Vector2.new(0, BarHeight)
        CompletedFill.Position = Vector2.new(BarX, BarY)

        local Border = Square(Color3.fromRGB(220, 220, 220), false, 1)
        Border.Size = Vector2.new(BarWidth, BarHeight)
        Border.Position = Vector2.new(BarX, BarY)

        local function Text(Size, Color)
            local T = Drawing.new("Text")
            T.Size = Size
            T.Color = Color
            T.Center = true
            T.Outline = true
            T.Visible = true
            T.Text = ""
            Objects[#Objects + 1] = T
            return T
        end

        local Progress = Text(14, Color3.fromRGB(255, 255, 255))
        Progress.Position = Vector2.new(Viewport.X / 2, BarY + BarHeight + 4)
        Progress.Text = ("0 / %d"):format(Total)

        local Name = Text(13, Color3.fromRGB(200, 200, 200))
        Name.Position = Vector2.new(Viewport.X / 2, BarY + BarHeight + 22)

        Connection = RunService.RenderStepped:Connect(function()
            CompletedFill.Size = Vector2.new(BarWidth * (State.Done / Total), BarHeight)
            DispatchedFill.Size = Vector2.new(BarWidth * (State.Dispatched / Total), BarHeight)
            Progress.Text = ("%d / %d"):format(State.Done, Total)
            local Display = State.Name
            if #Display > 80 then
                Display = "..." .. Display:sub(-77)
            end
            Name.Text = Display
        end)
    end)

    if not Ok then
        if Connection then pcall(function() Connection:Disconnect() end) end
        for _, d in next, Objects do
            pcall(function() d:Remove() end)
        end
        return NoOpUi
    end

    return {
        Update = function(_, Done, Dispatched, ScriptName)
            State.Done = Done
            State.Dispatched = Dispatched
            if ScriptName then State.Name = ScriptName end
        end,
        Destroy = function()
            if Connection then pcall(function() Connection:Disconnect() end) end
            for _, d in next, Objects do
                pcall(function() d:Remove() end)
            end
        end,
    }
end

local function AssertPrepassCapabilities()
    assert(getscriptbytecode, "executor does not support getscriptbytecode")
    assert(HttpRequest, "executor does not support an http request function")
end

local function Prepass()
    AssertPrepassCapabilities()
    local Unique = GatherUniqueScripts()
    -- Honor MaxScripts in the manual prepass path too (built-in path maps it to
    -- PrepassMaxScripts). Without this, MaxScripts silently did nothing here.
    local Cap = tonumber(Config.MaxScripts)
    if Cap and Cap > 0 then
        for i = #Unique, Cap + 1, -1 do
            Unique[i] = nil
        end
    end
    local Total = #Unique
    if Config.Verbose then
        print(("[prepass] %d unique scripts"):format(Total))
    end
    if Total == 0 then return end

    local Ui = CreateProgressUI(Total)
    local OkCount, Completed, Dispatched = 0, 0, 0

    RunPool(Unique, function(Item)
        Dispatched += 1
        Ui:Update(Completed, Dispatched, Item.Name)
        if not Cache[Item.Bytecode] then
            local Disk = DiskCacheGet(Item.Bytecode)
            if Disk then
                Cache[Item.Bytecode] = Disk
                OkCount += 1
            else
                local Ok, Body = DecompileViaAPI(Item.Bytecode)
                if Ok then
                    Cache[Item.Bytecode] = Body
                    DiskCacheSet(Item.Bytecode, Body)
                    OkCount += 1
                end
            end
        end
        Completed += 1
        Ui:Update(Completed, Dispatched, Item.Name)
    end)

    Ui:Destroy()

    if Config.Verbose then
        if DiskCache.Enabled then
            print(("[prepass] cached %d / %d (disk hits %d, disk writes %d)"):format(OkCount, Total, DiskCache.Reads, DiskCache.Writes))
        else
            print(("[prepass] cached %d / %d"):format(OkCount, Total))
        end
    end
end

local HookInstalled = false
local function InstallDecompileHook()
    if HookInstalled then return end
    AssertPrepassCapabilities()
    HookInstalled = true

    local OldDecompile = GlobalEnv.decompile
    GlobalEnv.decompile = function(Scr)
        local Ok, Bc = pcall(getscriptbytecode, Scr)
        if Ok and type(Bc) == "string" and Bc ~= "" then
            local Hit = Cache[Bc]
            if Hit then
                return Hit
            end
            local Disk = DiskCacheGet(Bc)
            if Disk then
                Cache[Bc] = Disk
                return Disk
            end
        end

        if OldDecompile then
            return OldDecompile(Scr)
        end

        if Ok and type(Bc) == "string" and Bc ~= "" then
            local Good, Body = DecompileViaAPI(Bc)
            if Good then
                Cache[Bc] = Body
                DiskCacheSet(Bc, Body)
                return Body
            end
            -- On failure, Body holds the API error text ("timeout", HTTP error body, ...).
            -- Return a comment instead so the error string is never written as script source.
            return "-- decompile failed: " .. tostring(Body)
        end
        return "-- could not read script bytecode"
    end
end

-- Extract the module version string embedded in saveinstance.luau
-- (`local SAVEINSTANCE_VERSION = "x.y.z"`). Returns nil if not present.
local function ParseSourceVersion(Source)
    if type(Source) ~= "string" then return nil end
    return string.match(Source, 'SAVEINSTANCE_VERSION%s*=%s*"([^"]+)"')
end

-- Compare two dotted version strings (e.g. "1.2.0" vs "1.10.0") numerically.
-- Returns 1 if A > B, -1 if A < B, 0 if equal. Non-numeric segments compare as 0.
local function CompareVersions(A, B)
    local function Parts(V)
        local T = {}
        for N in string.gmatch(tostring(V), "%d+") do
            T[#T + 1] = tonumber(N)
        end
        return T
    end
    local Pa, Pb = Parts(A), Parts(B)
    local Len = math.max(#Pa, #Pb)
    for i = 1, Len do
        local Va, Vb = Pa[i] or 0, Pb[i] or 0
        if Va ~= Vb then
            return Va > Vb and 1 or -1
        end
    end
    return 0
end

-- Path used for the on-disk copy of the last successfully loaded main script.
local function MainScriptCachePath()
    return tostring(Config.MainScriptCacheFile or "saveinstance_source_cache.luau")
end

local function ReadMainScriptCache()
    if not (Config.CacheMainScript and ReadFile and IsFile) then return nil end
    local Path = MainScriptCachePath()
    local OkExists, Exists = pcall(IsFile, Path)
    if not (OkExists and Exists) then return nil end
    local OkRead, Body = pcall(ReadFile, Path)
    if OkRead and type(Body) == "string" and Body ~= "" then
        return Body
    end
    return nil
end

local function WriteMainScriptCache(Source)
    if not (Config.CacheMainScript and WriteFile) then return end
    if type(Source) ~= "string" or Source == "" then return end
    pcall(WriteFile, MainScriptCachePath(), Source)
end

-- Compare the loaded module version against version.txt in the repo and report
-- (log only) when a newer release is available. Best-effort: never throws.
local function CheckForUpdates(RepoURL, LocalVersion)
    if not Config.CheckForUpdates then return end
    if not LocalVersion then return end
    local VersionUrl = RepoURL .. tostring(Config.VersionFile or "version.txt")
    local Ok, Body = pcall(game.HttpGet, game, VersionUrl, true)
    if not (Ok and type(Body) == "string") then
        if Config.Verbose then
            print("[prepass] update check skipped: could not fetch " .. VersionUrl)
        end
        return
    end
    local Remote = string.match(Body, "%d[%d%.]*")
    if not Remote then return end
    local Cmp = CompareVersions(Remote, LocalVersion)
    if Config.Verbose then
        if Cmp > 0 then
            print(("[prepass] update available: v%s is out; you are running v%s"):format(Remote, LocalVersion))
        elseif Cmp < 0 then
            print(("[prepass] running v%s (ahead of published v%s)"):format(LocalVersion, Remote))
        else
            print(("[prepass] up to date (v%s)"):format(LocalVersion))
        end
    end
end

local function LoadSaveInstance(PrepassOptions)
    local RepoURL = PrepassOptions.RepoURL or Config.RepoURL
    local ScriptName = PrepassOptions.ScriptName or Config.ScriptName
    if string.sub(RepoURL, -1) ~= "/" then
        RepoURL ..= "/"
    end
    if string.sub(ScriptName, -5) == ".luau" then
        ScriptName = string.sub(ScriptName, 1, -6)
    end
    local Url = RepoURL .. ScriptName .. ".luau"

    local Source, Loader
    local Ok, Downloaded = pcall(game.HttpGet, game, Url, true)
    local FromCache = false
    if Ok and type(Downloaded) == "string" and Downloaded ~= "" then
        -- A download can "succeed" (HTTP 200) yet return a GitHub 404 page or a
        -- truncated body. Compile it first: only a source that actually compiles is
        -- trusted and cached, so a garbled download can't poison the fallback copy.
        Loader = loadstring(Downloaded, ScriptName)
        if Loader then
            Source = Downloaded
            WriteMainScriptCache(Source)
        else
            -- Bad body served with a success status: don't cache it, and fall back
            -- to the last good on-disk copy if we have one.
            local Cached = ReadMainScriptCache()
            if Cached then
                Source, FromCache = Cached, true
                Loader = loadstring(Source, ScriptName)
                if Config.Verbose then
                    warn("[prepass] downloaded source failed to compile; using cached " .. ScriptName)
                end
            elseif Config.Verbose then
                print("[prepass] downloaded source failed to compile and no cache is available")
            end
        end
    else
        -- Download failed outright: fall back to the last good on-disk copy if we have one.
        local Cached = ReadMainScriptCache()
        if Cached then
            Source, FromCache = Cached, true
            Loader = loadstring(Source, ScriptName)
            if Config.Verbose then
                warn("[prepass] download failed (" .. tostring(Downloaded) .. "); using cached " .. ScriptName)
            end
        end
    end
    assert(type(Source) == "string" and Source ~= "",
        "[prepass] failed to download " .. Url .. " and no usable cached copy is available")

    local LocalVersion = ParseSourceVersion(Source)
    if Config.Verbose and LocalVersion then
        print(("[prepass] loaded %s v%s%s"):format(ScriptName, LocalVersion, FromCache and " (from cache)" or ""))
    end
    -- Skip the update check when we're offline (already using cache) — the remote
    -- fetch would just fail too.
    if not FromCache then
        pcall(CheckForUpdates, RepoURL, LocalVersion)
    end

    assert(Loader, "[prepass] failed to compile " .. ScriptName)

    local SaveInstance = Loader()
    assert(type(SaveInstance) == "function", "[prepass] " .. ScriptName .. " did not return a function")
    return SaveInstance
end

return function(Options, PrepassOptions)
    Options = Options or {}
    PrepassOptions = PrepassOptions or {}
    for k, v in next, PrepassOptions do
        Config[k] = v
    end

    if PrepassOptions.UseSaveInstancePrepass then
        local MaxInFlight = math.max(1, tonumber(Config.MaxInFlight) or 30)
        local RequestsPerMinute = math.max(1, tonumber(Config.RequestsPerMinute) or 1350)
        Options.DecompilePrepass = Options.DecompilePrepass ~= false
        Options.PrepassConcurrency = Options.PrepassConcurrency or MaxInFlight
        Options.PrepassRateGap = Options.PrepassRateGap or (60 / RequestsPerMinute)
        Options.PrepassApiUrl = Options.PrepassApiUrl or Config.ApiUrl
        if PrepassOptions.MaxScripts and Options.PrepassMaxScripts == nil then
            Options.PrepassMaxScripts = PrepassOptions.MaxScripts
        end
        if Config.Verbose then
            print("[prepass] using saveinstance built-in DecompilePrepass")
        end
    else
        InitDiskCache()
        -- Degrade gracefully: if the executor lacks getscriptbytecode/HTTP, skip the
        -- decompile prepass entirely and still run saveinstance (scripts stay empty)
        -- instead of aborting the whole loader via AssertPrepassCapabilities.
        local CanPrepass = getscriptbytecode and HttpRequest
        if not PrepassOptions.SkipPrepass then
            if CanPrepass then
                InstallDecompileHook()
                Prepass()
            elseif Config.Verbose then
                print("[prepass] executor lacks getscriptbytecode/http; skipping decompile prepass and saving without decompiled scripts")
            end
        elseif CanPrepass then
            InstallDecompileHook()
        elseif Config.Verbose then
            print("[prepass] SkipPrepass enabled; decompile hook not installed because executor capability is missing")
        end
        if Config.Verbose and DiskCache.Enabled then
            print(("[prepass] persistent cache: %d read, %d written (dir: %s)"):format(DiskCache.Reads, DiskCache.Writes, tostring(DiskCache.Dir)))
        end
    end

    if PrepassOptions.SkipSaveInstance then
        return
    end

    local smartsaveinstance = LoadSaveInstance(PrepassOptions)
    return smartsaveinstance(Options)
end
