-- archived

--!native
--!optimize 2
--!divine-intellect
-- discord.robloxscripts.com
-- SaveInstance 420 Edition | https://github.com/achmdfzn/SaveInstanceFetch
-- Docs: https://github.com/achmdfzn/SaveInstanceFetch

local realcheck = true
local imagonnaaddmorecheck, _ = pcall(function()
	gethiddenproperty(workspace.Terrain, "SmoothGrid")
end)

if not imagonnaaddmorecheck then
	realcheck = false
end

local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local table = table
local string = string
local math = math
local tonumber = tonumber
local function to_base64(data)
	local result, bit_table = {}, {}
	for i = 1, #data do
		local byte = data:byte(i)
		local bits = {}
		for j = 7, 0, -1 do
			bits[#bits + 1] = (math.floor(byte / (2 ^ j)) % 2 == 1) and '1' or '0'
		end
		bit_table[#bit_table + 1] = table.concat(bits)
	end

	local bit_string = table.concat(bit_table)
	bit_string = bit_string .. string.rep('0', (6 - #bit_string % 6) % 6)

	for i = 1, #bit_string, 6 do
		local chunk = bit_string:sub(i, i + 5)
		local index = tonumber(chunk, 2) + 1
		result[#result + 1] = b:sub(index, index)
	end

	local padding = (#data % 3 == 1 and '==') or (#data % 3 == 2 and '=' or '')
	return table.concat(result) .. padding
end

if gethiddenproperty and realcheck then
	getgenv().gethiddenpropertygethiddenproperty = gethiddenproperty

	-- Dump the raw terrain grids now. They are base64-encoded later (after `base64encode` is set up)
	-- with the FAST encoder. The pure-Lua to_base64 used to run here and FROZE the client on big maps,
	-- where SmoothGrid/PhysicsGrid are multiple megabytes.
	local smoothgrid_raw = gethiddenpropertygethiddenproperty(workspace.Terrain, "SmoothGrid")
	local physicsgrid_raw = gethiddenpropertygethiddenproperty(workspace.Terrain, "PhysicsGrid")
	if type(smoothgrid_raw) == "string" and type(physicsgrid_raw) == "string" then
		writefile("SmoothGrid.txt", smoothgrid_raw)
		writefile("PhysicsGrid.txt", physicsgrid_raw)
	else
		realcheck = false -- executor can't actually read terrain grids; skip terrain so writefile(nil) doesn't throw
	end
end

local function string_find(s, pattern)
	return string.find(s, pattern, nil, true)
end

local function ArrayToDict(t, hydridMode, valueOverride, typeStrict)
	local tmp = {}

	if hydridMode then
		for any1, any2 in t do
			if type(any1) == "number" then
				tmp[any2] = valueOverride or true
			elseif type(any2) == "table" then
				tmp[any1] = ArrayToDict(any2, hydridMode) -- any1 is Class, any2 is Name
			else
				tmp[any1] = any2
			end
		end
	else
		for _, key in t do
			if not typeStrict or typeStrict and type(key) == typeStrict then
				tmp[key] = true
			end
		end
	end

	return tmp
end

local global_container
do
	local filename = "UniversalMethodFinder"

	local finder
	finder, global_container = loadstring(
		game:HttpGet("https://raw.githubusercontent.com/luau/SomeHub/main/" .. filename .. ".luau", true),
		filename
	)()

	finder({
		-- readbinarystring = 'string.find(...,"bin",nil,true)', -- ! Could match some unwanted stuff (getbinaryindex)
		-- request = 'string.find(...,"request",nil,true) and not string.find(...,"internal",nil,true)',
		base64encode = 'local a={...}local b=a[1]local function c(a,b)return string.find(a,b,nil,true)end;return c(b,"encode")and(c(b,"base64")or c(string.lower(tostring(a[2])),"base64"))',
		-- cloneref = 'string.find(...,"clone",nil,true) and string.find(...,"ref",nil,true)',
		-- decompile = '(string.find(...,"decomp",nil,true) and string.sub(...,#...) ~= "s")',
		gethiddenproperty = 'string.find(...,"get",nil,true) and string.find(...,"h",nil,true) and string.find(...,"prop",nil,true) and string.sub(...,#...) ~= "s"',
		gethui = 'string.find(...,"get",nil,true) and string.find(...,"h",nil,true) and string.find(...,"ui",nil,true)',
		getcon = 'string.find(...,"get",nil,true) and (string.find(...,"conn",nil,true) or string.find(...,"sig",nil,true)) and string.sub(...,#(...))=="s"',
		getnilinstances = 'string.find(...,"nil",nil,true) and string.find(...,"get",nil,true) and string.sub(...,#...) == "s"', -- ! Could match some unwanted stuff
		getscriptbytecode = 'string.find(...,"get",nil,true) and string.find(...,"bytecode",nil,true)', --  or string.find(...,"dump",nil,true) and string.find(...,"string",nil,true) due to Fluxus (dumpstring returns a function)
		hash = 'local a={...}local b=a[1]local function c(a,b)return string.find(a,b,nil,true)end;return c(b,"hash")and c(string.lower(tostring(a[2])),"crypt")',
		protectgui = 'string.find(...,"protect",nil,true) and string.find(...,"ui",nil,true) and not string.find(...,"un",nil,true)',
		setthreadidentity = 'string.find(...,"identity",nil,true) and string.find(...,"set",nil,true)',
	}, true, 10)
end

local identify_executor = identifyexecutor or getexecutorname or whatexecutor

local EXECUTOR_NAME = identify_executor and identify_executor() or ""

-- local cloneref = global_container.cloneref
local gethiddenproperty = global_container.gethiddenproperty

-- These should be universal enough
local appendfile = appendfile
local readfile = readfile
local writefile = writefile

local getscriptbytecode = global_container.getscriptbytecode -- * A lot of assumptions are made based on whether this function is defined or not. So in certain edge cases, like if the executor defines "decompile" or "getscripthash" function yet doesn't define this function there might be loss of functionality of the saveinstance. Although that would be very rare and weird
local base64encode = global_container.base64encode
local sha384

local service = setmetatable({}, {
	__index = function(self, serviceName)
		local o, s = pcall(Instance.new, serviceName)
		local Service = o and s
			or game:GetService(serviceName)
			or settings():GetService(serviceName)
			or UserSettings():GetService(serviceName)

		-- if cloneref then
		-- 	Service = cloneref(Service)
		-- end
		if Service then
			self[serviceName] = Service
		end
		return Service
	end,
})

local gethiddenproperty_fallback
do -- * Load Region of Déjà Vu
	local UGCValidationService -- = service.UGCValidationService

	gethiddenproperty_fallback = function(instance, propertyName)
		if not UGCValidationService then
			UGCValidationService = service.UGCValidationService
		end
		return UGCValidationService:GetPropertyValue(instance, propertyName) -- TODO Sadly there's no way to tell whether value is actually nil or the function just couldn't read it (always returns nil for "Class" category properties)
		-- TODO `category ~= "Class"` causes WeldConstraint Part1Internal to be read as nil and not get unfiltered. Currently, there are no properties of category "Class" that match the following: NotScriptable, can be read with gethiddenproperty_fallback accurately (it always outputs nil for "Class" category, making that check useless anyway) & don't have a NotScriptableFix.
	end
	if gethiddenproperty then
		local o, r = pcall(gethiddenproperty, workspace, "StreamOutBehavior")
		if not o or r ~= nil and typeof(r) ~= "EnumItem" then -- * Tests if gethiddenproperty is broken
			gethiddenproperty = nil
		else
			o, r = pcall(gethiddenproperty, Instance.new("AnimationRigData", Instance.new("Folder")), "parent") -- * Tests how it reacts to property overlap (shadowing) due to AnimationRigData.parent; expected BinaryString

			if o and r ~= nil and type(r) ~= "string" then
				gethiddenproperty = nil
			end
		end
	end
	local function benchmark(f1, f2, ...)
		local ranking = table.create(2)
		for i, f in { f1, f2 } do
			local start = os.clock()
			for _ = 1, 50 do
				f(...)
			end
			ranking[i] = { t = os.clock() - start, f = f }
		end
		table.sort(ranking, function(a, b)
			return a.t < b.t
		end)
		return ranking[1].f
	end

	local test_str = string.rep("\1\0\0\0\1\2\3\4\5\6\7", 50)

	do
		if not bit32.byteswap or not pcall(bit32.byteswap, 1) then -- Because Fluxus is missing byteswap
			bit32 = table.clone(bit32)

			local function tobit(num)
				num %= (bit32.bxor(num, 32))
				if 0x80000000 < num then
					num -= bit32.bxor(num, 32)
				end
				return num
			end

			bit32.byteswap = function(num)
				local BYTE_SIZE = 8
				local MAX_BYTE_VALUE = 255

				num %= bit32.bxor(2, 32)

				local a = bit32.band(num, MAX_BYTE_VALUE)
				num = bit32.rshift(num, BYTE_SIZE)

				local b = bit32.band(num, MAX_BYTE_VALUE)
				num = bit32.rshift(num, BYTE_SIZE)

				local c = bit32.band(num, MAX_BYTE_VALUE)
				num = bit32.rshift(num, BYTE_SIZE)

				local d = bit32.band(num, MAX_BYTE_VALUE)
				num = tobit(bit32.lshift(bit32.lshift(bit32.lshift(a, BYTE_SIZE) + b, BYTE_SIZE) + c, BYTE_SIZE) + d)
				return num
			end

			table.freeze(bit32)
		end

		-- TODO Remove later
		if EXECUTOR_NAME == "Delta" then
			base64encode = nil
		end

		-- Credits @Reselim
		local reselim_base64encode
		pcall(function()
			local b64_enc_buf = loadstring(
				game:HttpGet("https://raw.githubusercontent.com/Reselim/Base64/master/Base64.lua", true),
				"Base64"
			)().encode
			reselim_base64encode = function(raw)
				return buffer.tostring(b64_enc_buf(buffer.fromstring(raw)))
			end
		end)

		-- * Tests if base64encode exists and works properly then benchmark it
		if base64encode and base64encode("\1\0\0\0\1") == "AQAAAAE=" then
			if reselim_base64encode then
				base64encode = benchmark(base64encode, reselim_base64encode, test_str)
			end
		else
			base64encode = reselim_base64encode
		end

		assert(base64encode, "base64encode not found")
	end

	do
		local hash = global_container.hash

		if hash then
			sha384 = function(data)
				return hash(data, "sha384")
			end
		end

		local filename = "RequireOnlineModule"

		-- Credits @boatbomber
		local hashlib_sha384
		pcall(function()
			hashlib_sha384 = loadstring(
				game:HttpGet("https://raw.githubusercontent.com/luau/SomeHub/main/" .. filename .. ".luau", true),
				filename
			)()(4544052033).sha384
		end)

		-- * Tests if sha384 exists then benchmark it
		if hashlib_sha384 then
			if sha384 then
				sha384 = benchmark(sha384, hashlib_sha384, test_str)
			else
				sha384 = hashlib_sha384
			end
		end

		assert(sha384, "sha384 hash function not found")
	end
end

-- Encode the terrain grids (dumped near the top) with the fast base64encode set up just above.
-- (Doing this here instead of with the pure-Lua to_base64 at load is what stops big maps freezing.)
if realcheck then
	local terrain_ok = pcall(function()
		getfenv().physicsgrid = base64encode(readfile("PhysicsGrid.txt"))
		getfenv().smoothgrid = base64encode(readfile("SmoothGrid.txt"))
	end)
	if not terrain_ok then
		realcheck = false
	end
end

-- local custom_decompiler

-- if getscriptbytecode then
-- end

local SharedStrings = {}
local SharedString_identifiers = setmetatable({
	identifier = 1e15, -- 1 quadrillion, up to 9.(9) quadrillion, in theory this shouldn't ever run out and be enough for all sharedstrings ever imaginable
	-- TODO: worst case, add fallback to str randomizer once numbers run out : )
}, {
	__index = function(self, str)
		local Identifier = base64encode(tostring(self.identifier)) -- tostring is only needed for built-in base64encode, Reselim's doesn't need it as buffers autoconvert
		self.identifier += 1

		self[str] = Identifier -- ? The value of the md5 attribute is a Base64-encoded key. <SharedString> type elements use this key to refer to the value of the string. The value is the text content, which is Base64-encoded. Historically, the key was the MD5 hash of the string value. However, this is not required; the key can be any value that will uniquely identify the shared string. Roblox currently uses BLAKE2b truncated to 16 bytes..
		return Identifier
	end,
})

-- ? Union/CSG geometry lives in these SharedString properties (added in client 553).
-- ? They MUST be saved even when IgnoreSharedStrings is on, otherwise UnionOperations
-- ? load with no mesh/child data and Studio only draws their bounding box.
-- Union/MeshPart geometry & collision blobs that are SharedString-typed and MUST survive IgnoreSharedStrings:
-- MeshData2 = render mesh (makes the union visible), ChildData2 = source operands (NotReplicated, client never has it),
-- PhysicalConfigData = modern collision config (replicated, client HAS it) — without it newer-baked unions can lose collision.
local KeepSharedStrings = ArrayToDict({ "MeshData2", "ChildData2", "PhysicalConfigData" })

-- Debug logging (enabled by the `Debug` option). Lines are collected here and written to
-- "saveinstance-debug.txt" in the executor's workspace at the end of a save, so the user can share
-- it for diagnosis. Call dbg(...) from anywhere; it's a no-op unless Debug is on.
local debug_enabled = false
local debug_log = {}
local debug_clock0 = 0
local _api_ok, _api_fail, _api_first_fail = 0, 0, nil -- lua.expert decompile outcome counters (across prepass + on-demand)

-- AssetManifest: global state filled by the Content/ContentId descriptors during property serialization.
-- Enabled when the AssetManifest option is true; written to disk at the end of the save.
local asset_manifest_enabled = false
local asset_manifest_set = {}

-- VerifySave: per-run statistics collected during traversal and written at the end.
local verify_stats_enabled = false
local verify_stats = {
	scripts_total = 0,
	scripts_decompiled = 0,
	scripts_failed = 0,
	unions_total = 0,
	unions_mesh_ok = 0,
	unions_mesh_missing = 0,
	meshparts_total = 0,
	meshparts_data_ok = 0,
	meshparts_data_missing = 0,
	instances_total = 0,
}

local function dbg(...)
	if not debug_enabled then
		return
	end
	local n = select("#", ...)
	local parts = table.create(n)
	for i = 1, n do
		parts[i] = tostring((select(i, ...)))
	end
	debug_log[#debug_log + 1] = string.format("[%7.2f] %s", os.clock() - debug_clock0, table.concat(parts, " "))
end

local inherited_properties = {}
local default_instances = {}
local referents, ref_size = {}, 0 -- ? Roblox encodes all <Item> elements with a referent attribute. Each value is generated by starting with the prefix RBX, followed by a UUID version 4, with - characters removed, and all characters converted to uppercase.

local function __BIT(...) -- * Credits to Friend (you know yourself)
	local Value = 0

	for i, bit in { ... } do
		if bit then
			Value += 2 ^ (i - 1)
		end
	end

	return Value
end

local function GetRef(instance)
	local ref = referents[instance]
	if not ref then
		ref = ref_size
		referents[instance] = ref
		ref_size += 1
	end
	return ref
end

local function index(self, index_name)
	return self[index_name]
end

local FULL_VERSION

if not pcall(function()
	FULL_VERSION = version()
end) then
	if not pcall(function()
		FULL_VERSION = settings():GetService("DebugSettings").RobloxVersion
	end) then
		if not pcall(function()
			FULL_VERSION = service.RunService:GetRobloxVersion()
		end) then
			FULL_VERSION = "UNKNOWN"
		end
	end
end

local CLIENT_VERSION = tonumber(string.match(FULL_VERSION, "%d+%.(%d+)")) or 9e9

local attr_Type_IDs = {
	string = 0x02,
	boolean = 0x03,
	-- int32 = 0x04,
	-- float = 0x05,
	number = 0x06,
	-- Array = 0x07,
	-- Dictionary = 0x08,
	UDim = 0x09,
	UDim2 = 0x0A,
	Ray = 0x0B,
	Faces = 0x0C,
	Axes = 0x0D,
	BrickColor = 0x0E,
	Color3 = 0x0F,
	Vector2 = 0x10,
	Vector3 = 0x11,
	Vector2int16 = 0x12,
	Vector3int16 = 0x13,
	CFrame = 0x14,
	EnumItem = 0x15,
	NumberSequence = 0x17,
	NumberSequenceKeypoint = 0x18,
	ColorSequence = 0x19,
	ColorSequenceKeypoint = 0x1A,
	NumberRange = 0x1B,
	Rect = 0x1C,
	PhysicalProperties = 0x1D,
	Region3 = 0x1F,
	Region3int16 = 0x20,
	Font = 0x21,
}
local CFrame_Rotation_IDs = {
	["\0\0\128\63\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\63\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\63"] = 0x02,
	["\0\0\128\63\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\191\0\0\0\0\0\0\128\63\0\0\0\0"] = 0x03,
	["\0\0\128\63\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\191\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\191"] = 0x05,
	["\0\0\128\63\0\0\0\0\0\0\0\128\0\0\0\0\0\0\0\0\0\0\128\63\0\0\0\0\0\0\128\191\0\0\0\0"] = 0x06,
	["\0\0\0\0\0\0\128\63\0\0\0\0\0\0\128\63\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\191"] = 0x07,
	["\0\0\0\0\0\0\0\0\0\0\128\63\0\0\128\63\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\63\0\0\0\0"] = 0x09,
	["\0\0\0\0\0\0\128\191\0\0\0\0\0\0\128\63\0\0\0\0\0\0\0\128\0\0\0\0\0\0\0\0\0\0\128\63"] = 0x0a,
	["\0\0\0\0\0\0\0\0\0\0\128\191\0\0\128\63\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\191\0\0\0\0"] = 0x0c,
	["\0\0\0\0\0\0\128\63\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\63\0\0\128\63\0\0\0\0\0\0\0\0"] = 0x0d,
	["\0\0\0\0\0\0\0\0\0\0\128\191\0\0\0\0\0\0\128\63\0\0\0\0\0\0\128\63\0\0\0\0\0\0\0\0"] = 0x0e,
	["\0\0\0\0\0\0\128\191\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\191\0\0\128\63\0\0\0\0\0\0\0\0"] = 0x10,
	["\0\0\0\0\0\0\0\0\0\0\128\63\0\0\0\0\0\0\128\191\0\0\0\0\0\0\128\63\0\0\0\0\0\0\0\128"] = 0x11,
	["\0\0\128\191\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\63\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\191"] = 0x14,
	["\0\0\128\191\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\63\0\0\0\0\0\0\128\63\0\0\0\128"] = 0x15,
	["\0\0\128\191\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\191\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\63"] = 0x17,
	["\0\0\128\191\0\0\0\0\0\0\0\128\0\0\0\0\0\0\0\0\0\0\128\191\0\0\0\0\0\0\128\191\0\0\0\128"] = 0x18,
	["\0\0\0\0\0\0\128\63\0\0\0\128\0\0\128\191\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\63"] = 0x19,
	["\0\0\0\0\0\0\0\0\0\0\128\191\0\0\128\191\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\63\0\0\0\0"] = 0x1b,
	["\0\0\0\0\0\0\128\191\0\0\0\128\0\0\128\191\0\0\0\0\0\0\0\128\0\0\0\0\0\0\0\0\0\0\128\191"] = 0x1c,
	["\0\0\0\0\0\0\0\0\0\0\128\63\0\0\128\191\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\191\0\0\0\0"] = 0x1e,
	["\0\0\0\0\0\0\128\63\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\191\0\0\128\191\0\0\0\0\0\0\0\0"] = 0x1f,
	["\0\0\0\0\0\0\0\0\0\0\128\63\0\0\0\0\0\0\128\63\0\0\0\128\0\0\128\191\0\0\0\0\0\0\0\0"] = 0x20,
	["\0\0\0\0\0\0\128\191\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\63\0\0\128\191\0\0\0\0\0\0\0\0"] = 0x22,
	["\0\0\0\0\0\0\0\0\0\0\128\191\0\0\0\0\0\0\128\191\0\0\0\128\0\0\128\191\0\0\0\0\0\0\0\128"] = 0x23,
}
local Binary_Descriptors
Binary_Descriptors = {
	__SEQUENCE = function(raw, valueFormatter, keypointSize, Envelope)
		local Keypoints = raw.Keypoints
		local Keypoints_n = #Keypoints

		local len = 4 + (keypointSize or 12) * Keypoints_n
		local b = buffer.create(len)
		local offset = 0

		buffer.writeu32(b, offset, Keypoints_n)
		offset += 4

		for _, keypoint in Keypoints do
			buffer.writef32(b, offset, Envelope or keypoint.Envelope)
			offset += 4
			buffer.writef32(b, offset, keypoint.Time)
			offset += 4

			local Value = keypoint.Value
			if valueFormatter then
				offset += valueFormatter(Value, b, offset)
			else
				buffer.writef32(b, offset, Value)
				offset += 4
			end
		end

		return b, len
	end,
	--------------------------------------------------------------
	--------------------------------------------------------------
	--------------------------------------------------------------
	["string"] = function(raw)
		local raw_len = #raw
		local len = 4 + raw_len

		local b = buffer.create(len)

		buffer.writeu32(b, 0, raw_len)
		buffer.writestring(b, 4, raw)

		return b, len
	end,
	["boolean"] = function(raw)
		local b = buffer.create(1)

		buffer.writeu8(b, 0, raw and 1 or 0)

		return b, 1
	end,
	["number"] = function(raw) -- double
		local b = buffer.create(8)

		buffer.writef64(b, 0, raw)

		return b, 8
	end,
	["UDim"] = function(raw)
		local b = buffer.create(8)

		buffer.writef32(b, 0, raw.Scale)
		buffer.writei32(b, 4, raw.Offset)

		return b, 8
	end,
	["UDim2"] = function(raw)
		local b = buffer.create(16)

		local UDim__descriptor = Binary_Descriptors.UDim
		local X = UDim__descriptor(raw.X)
		buffer.copy(b, 0, X)
		local Y = UDim__descriptor(raw.Y)
		buffer.copy(b, 8, Y)

		return b, 16
	end,
	["Ray"] = function(raw)
		local b = buffer.create(24)

		local Vector3__descriptor = Binary_Descriptors.Vector3
		local Origin = Vector3__descriptor(raw.Origin)
		buffer.copy(b, 0, Origin)
		local Direction = Vector3__descriptor(raw.Direction)
		buffer.copy(b, 12, Direction)

		return b, 24
	end,
	["Faces"] = function(raw)
		local b = buffer.create(4)

		buffer.writeu32(b, 0, __BIT(raw.Right, raw.Top, raw.Back, raw.Left, raw.Bottom, raw.Front))

		return b, 4
	end,
	["Axes"] = function(raw)
		local b = buffer.create(4)

		buffer.writeu32(b, 0, __BIT(raw.X, raw.Y, raw.Z))

		return b, 4
	end,
	["BrickColor"] = function(raw)
		local b = buffer.create(4)

		buffer.writeu32(b, 0, raw.Number)

		return b, 4
	end,
	["Color3"] = function(raw)
		local b = buffer.create(12)

		buffer.writef32(b, 0, raw.R)
		buffer.writef32(b, 4, raw.G)
		buffer.writef32(b, 8, raw.B)

		return b, 12
	end,
	["Vector2"] = function(raw)
		local b = buffer.create(8)

		buffer.writef32(b, 0, raw.X)
		buffer.writef32(b, 4, raw.Y)

		return b, 8
	end,
	["Vector3"] = function(raw)
		local b = buffer.create(12)

		buffer.writef32(b, 0, raw.X)
		buffer.writef32(b, 4, raw.Y)
		buffer.writef32(b, 8, raw.Z)

		return b, 12
	end,
	["Vector2int16"] = function(raw)
		local b = buffer.create(4)

		buffer.writei16(b, 0, raw.X)
		buffer.writei16(b, 2, raw.Y)

		return b, 4
	end,
	["Vector3int16"] = function(raw)
		local b = buffer.create(6)

		buffer.writei16(b, 0, raw.X)
		buffer.writei16(b, 2, raw.Y)
		buffer.writei16(b, 4, raw.Z)

		return b, 6
	end,
	["CFrame"] = function(raw)
		local X, Y, Z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = raw:GetComponents()

		local rotation_ID = CFrame_Rotation_IDs[string.pack("<fffffffff", R00, R01, R02, R10, R11, R12, R20, R21, R22)]

		local len = rotation_ID and 13 or 49
		local b = buffer.create(len)

		-- ? TODO cleaner but slower ?
		-- local write_vector3 = Descriptors.Vector3
		-- local pos = write_vector3(raw.Position)
		-- buffer.copy(b, 0, pos)

		buffer.writef32(b, 0, X)
		buffer.writef32(b, 4, Y)
		buffer.writef32(b, 8, Z)

		if rotation_ID then
			buffer.writeu8(b, 12, rotation_ID)
		else
			buffer.writeu8(b, 12, 0x0)

			-- ? TODO cleaner but slower ?
			-- buffer.copy(b, 13, write_vector3(raw.XVector)) -- R00, R10, R20
			-- buffer.copy(b, 13 + 12, write_vector3(raw.YVector)) -- R01, R11, R21
			-- buffer.copy(b, 13 + 24, write_vector3(raw.ZVector)) -- R02, R12, R22

			buffer.writef32(b, 13, R00)
			buffer.writef32(b, 17, R01)
			buffer.writef32(b, 21, R02)

			buffer.writef32(b, 25, R10)
			buffer.writef32(b, 29, R11)
			buffer.writef32(b, 33, R12)

			buffer.writef32(b, 37, R20)
			buffer.writef32(b, 41, R21)
			buffer.writef32(b, 45, R22)
		end

		return b, len
	end,
	["EnumItem"] = function(raw)
		local b_Name, Name_size = Binary_Descriptors.string(tostring(raw.EnumType))

		local len = Name_size + 4
		local b = buffer.create(len)

		buffer.copy(b, 0, b_Name)
		buffer.writeu32(b, Name_size, raw.Value)

		return b, len
	end,
	["NumberSequence"] = nil,
	-- ["NumberSequenceKeypoint"] = nil, -- TODO Only impl. if necessary because NumberSequence will reference this therefore slowing down itself
	["ColorSequence"] = function(raw)
		return Binary_Descriptors.__SEQUENCE(raw, function(color3, b, offset)
			buffer.copy(b, offset, Binary_Descriptors.Color3(color3))
			return 12
		end, 20, 0)
	end,
	-- ["ColorSequenceKeypoint"] = nil, -- TODO Only impl. if necessary because ColorSequence will reference this therefore slowing down itself
	["NumberRange"] = function(raw)
		local b = buffer.create(8)

		buffer.writef32(b, 0, raw.Min)
		buffer.writef32(b, 4, raw.Max)

		return b, 8
	end,
	["Rect"] = function(raw)
		local b = buffer.create(16)

		local Vector2__descriptor = Binary_Descriptors.Vector2
		local Min = Vector2__descriptor(raw.Min)
		buffer.copy(b, 0, Min)
		local Max = Vector2__descriptor(raw.Max)
		buffer.copy(b, 8, Max)

		return b, 16
	end,
	["PhysicalProperties"] = function(raw) -- ? Not sure yet (https://github.com/RobloxAPI/spec/blob/master/properties/drafts/AttributesSerializeFull.md#physicalproperties)
		local len = 1
		if raw then
			len += 24
		end
		local b = buffer.create(len)

		buffer.writeu8(b, 0, raw and 3 or 0) -- 3 means it has set CustomPhysicalProperties & has set AcousticAbsorption, normally this would be __COUNT_BITS but AcousticAbsorption has been enabled by default; -- * PhysicalProperties.new(0,0,0).AcousticAbsorption could be used as default value to compare AcousticAbsorption against to determine whether it has been set or not

		if raw then
			buffer.writef32(b, 1, raw.Density)
			buffer.writef32(b, 5, raw.Friction)
			buffer.writef32(b, 9, raw.Elasticity)
			buffer.writef32(b, 13, raw.FrictionWeight)
			buffer.writef32(b, 17, raw.ElasticityWeight)
			buffer.writef32(b, 21, raw.AcousticAbsorption)
		end

		return b, len
	end,
	["Region3"] = function(raw)
		local b = buffer.create(24)

		local Vector3__descriptor = Binary_Descriptors.Vector3
		local Min = Vector3__descriptor(raw.Min)
		buffer.copy(b, 0, Min)
		local Max = Vector3__descriptor(raw.Max)
		buffer.copy(b, 12, Max)

		return b, 24
	end,
	["Region3int16"] = function(raw)
		local b = buffer.create(12)

		local Vector3int16__descriptor = Binary_Descriptors.Vector3int16
		local Min = Vector3int16__descriptor(raw.Min)
		buffer.copy(b, 0, Min)
		local Max = Vector3int16__descriptor(raw.Max)
		buffer.copy(b, 6, Max)

		return b, 12
	end,
	["Font"] = 636 < CLIENT_VERSION and function(raw)
		local string__descriptor = Binary_Descriptors.string

		local b_Family, Family_size = string__descriptor(raw.Family)
		local b_CachedFaceId, CachedFaceId_size = string__descriptor("")

		local len = 3 + Family_size + CachedFaceId_size
		local b = buffer.create(len)

		local ok_w, weight = pcall(index, raw, "Weight")
		local ok_s, style = pcall(index, raw, "Style")

		buffer.writeu16(b, 0, ok_w and weight.Value or 0)
		buffer.writeu8(b, 2, ok_s and style.Value or 0)

		buffer.copy(b, 3, b_Family)
		buffer.copy(b, 3 + Family_size, b_CachedFaceId)

		return b, len
	end or function(raw)
		local string__descriptor = Binary_Descriptors.string

		local b_Family, Family_size = string__descriptor(raw.Family)
		local b_CachedFaceId, CachedFaceId_size = string__descriptor("")

		local len = 3 + Family_size + CachedFaceId_size
		local b = buffer.create(len)

		local FontString = tostring(raw)

		local EmptyWeight = string_find(FontString, "Weight = ,")
		local EmptyStyle = string_find(FontString, "Style =  }")

		buffer.writeu16(b, 0, EmptyWeight and 0 or raw.Weight.Value)
		buffer.writeu8(b, 2, EmptyStyle and 0 or raw.Style.Value)

		buffer.copy(b, 3, b_Family)
		buffer.copy(b, 3 + Family_size, b_CachedFaceId)

		return b, len
	end,
}
do
	Binary_Descriptors.NumberSequence = Binary_Descriptors.__SEQUENCE
end

local ESCAPES_PATTERN = "[&<>\"'\0\1-\9\11-\12\14-\31\127-\255]" -- * The safe way is to escape all five characters in text. However, the three characters " ' and > needn't be escaped in text
-- %z (\0 aka NULL) might not be needed as Roblox automatically converts it to space everywhere it seems like
-- Characters from: https://create.roblox.com/docs/en-us/ui/rich-text#escape-forms
-- * EscapesPattern should be ordered from most common to least common characters for sake of speed
-- * Might wanna use their numerical codes instead of named codes for reduced file size (Could be an Option)
-- TODO Maybe we should invert the pattern to only allow certain characters (future-proof)
local ESCAPES = {
	["&"] = "&amp;", -- 38
	["<"] = "&lt;", -- 60
	[">"] = "&gt;", -- 62
	['"'] = "&#34;", --  quot
	["'"] = "&#39;", -- apos
	["\0"] = "",
}

for rangeStart, rangeEnd in string.gmatch(ESCAPES_PATTERN, "(.)%-(.)") do
	for charCode = string.byte(rangeStart), string.byte(rangeEnd) do
		ESCAPES[string.char(charCode)] = "&#" .. charCode .. ";"
	end
end

local XML_Descriptors
XML_Descriptors = {
	__CDATA = function(raw) -- ? Normally Roblox doesn't use CDATA unless the string has newline characters (\n); We rather CDATA everything for sake of speed
		return "<![CDATA[" .. raw .. "]]>"
	end,
	__ENUM = function(raw)
		return raw.Value, "token"
	end,
	__NORMALIZE_NUMBER = function(raw)
		if raw ~= raw then
			return "NAN"
		elseif raw == math.huge then
			return "INF"
		elseif raw == -math.huge then
			return "-INF"
		end

		return raw
	end,
	__NORMALIZE_RANGE = function(raw)
		return raw ~= raw and "0" or raw -- Normally we should return "-nan(ind)" instead of "0" but this adds more compatibility
	end,
	__MINMAX = function(min, max, descriptor)
		return "<min>" .. descriptor(min) .. "</min><max>" .. descriptor(max) .. "</max>"
	end,
	__PROTECTEDSTRING = function(raw) -- ? its purpose is to "protect" data from being treated as ordinary character data during processing;
		return string_find(raw, "]]>") and string.gsub(raw, ESCAPES_PATTERN, ESCAPES) or XML_Descriptors.__CDATA(raw)
	end,
	__SEQUENCE = function(raw, valueFormatter)
		-- The value is the text content, formatted as a space-separated list of floating point numbers.
		-- tostring(raw) also works (but way slower rn)
		local __NORMALIZE_RANGE = XML_Descriptors.__NORMALIZE_RANGE

		local sequence = ""

		for _, keypoint in raw.Keypoints do
			local Value = keypoint.Value

			sequence ..= keypoint.Time .. " " .. (valueFormatter and valueFormatter(Value) or __NORMALIZE_RANGE(Value) .. " " .. __NORMALIZE_RANGE(
				keypoint.Envelope
				) .. " ") -- ? Trailing whitespace is only needed for lune compatibility
		end

		return sequence
	end,
	__VECTOR = function(X, Y, Z) -- Each element is a <float>
		local Value = "<X>" .. X .. "</X><Y>" .. Y .. "</Y>" -- There is no Vector without at least two Coordinates.. (Vector1, at least on Roblox)

		if Z then
			Value ..= "<Z>" .. Z .. "</Z>"
		end

		return Value
	end,
	--------------------------------------------------------------
	--------------------------------------------------------------
	--------------------------------------------------------------
	Axes = function(raw)
		-- The text of this element is formatted as an integer between 0 and 7

		return "<axes>" .. __BIT(raw.X, raw.Y, raw.Z) .. "</axes>"
	end,

	-- ? Roblox uses CDATA only for these (try to prove this wrong): CollisionGroupData, SmoothGrid, MaterialColors, PhysicsGrid
	-- ! Assuming all base64 encoded strings won't have newlines

	-- ! 7/7/24
	-- ! Electron v3 'gethiddenproperty' automatically base64 encodes BinaryString values

	BinaryString = function(raw)
		return raw == "" and "" or base64encode(raw)
	end,

	BrickColor = function(raw)
		return raw.Number -- * Roblox encodes the tags as "int", but this is not required for Roblox to properly decode the type. For better compatibility, it is preferred that third-party implementations encode and decode "BrickColor" tags instead. Could also use "int" or "Color3uint8"
	end,
	CFrame = function(raw)
		local X, Y, Z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = raw:GetComponents()
		return XML_Descriptors.__VECTOR(X, Y, Z)
			.. "<R00>"
			.. R00
			.. "</R00><R01>"
			.. R01
			.. "</R01><R02>"
			.. R02
			.. "</R02><R10>"
			.. R10
			.. "</R10><R11>"
			.. R11
			.. "</R11><R12>"
			.. R12
			.. "</R12><R20>"
			.. R20
			.. "</R20><R21>"
			.. R21
			.. "</R21><R22>"
			.. R22
			.. "</R22>",
		"CoordinateFrame"
	end,
	Color3 = function(raw) -- Each element is a <float>
		return "<R>" .. raw.R .. "</R><G>" .. raw.G .. "</G><B>" .. raw.B .. "</B>" -- ? It is recommended that Color3 is encoded with elements instead of text.
	end,
	Color3uint8 = function(raw)
		-- https://github.com/rojo-rbx/rbx-dom/blob/master/docs/xml.md#color3uint8
		-- ? It is recommended that Color3uint8 is encoded with text instead of elements.

		return 0xFF000000
			+ (math.floor(raw.R * 255) * 0x10000)
			+ (math.floor(raw.G * 255) * 0x100)
			+ math.floor(raw.B * 255)
		-- return bit32.bor(
		-- 	bit32.bor(bit32.bor(bit32.lshift(0xFF, 24), bit32.lshift(0xFF * raw.R, 16)), bit32.lshift(0xFF * raw.G, 8)),
		-- 	0xFF * raw.B
		-- )

		-- return tonumber(string.format("0xFF%02X%02X%02X",raw.R*255,raw.G*255,raw.B*255))
	end,
	ColorSequence = function(raw)
		-- The value is the text content, formatted as a space-separated list of FLOATing point numbers.

		return XML_Descriptors.__SEQUENCE(raw, function(color3)
			local __NORMALIZE_RANGE = XML_Descriptors.__NORMALIZE_RANGE

			return __NORMALIZE_RANGE(color3.R)
				.. " "
				.. __NORMALIZE_RANGE(color3.G)
				.. " "
				.. __NORMALIZE_RANGE(color3.B)
				.. " 0 "
		end)
	end,
			Content = function(raw)
				local SourceType = raw.SourceType
				return SourceType == Enum.ContentSourceType.None and "<null></null>"
					or SourceType == Enum.ContentSourceType.Uri and "<uri>" .. XML_Descriptors.string(raw.Uri) .. "</uri>"
					or SourceType == Enum.ContentSourceType.Object and "<Ref>" .. GetRef(raw.Object)
					.. "</Ref>" -- TODO Not sure, run tests
			end,
			ContentId = function(raw)
				-- On newer clients, Content-typed props (Image, Texture, SoundId, MeshContent, ...) may read as
				-- a Content userdata instead of a string. Extract its URI so they still serialize.
				if type(raw) ~= "string" then
					local ok, uri = pcall(function()
						return (raw.SourceType == Enum.ContentSourceType.Uri) and raw.Uri or ""
					end)
					raw = (ok and uri) or ""
				end
				return raw == "" and "<null></null>" or "<url>" .. XML_Descriptors.string(raw) .. "</url>", "Content" -- TODO Remove "Content" str once Roblox fully releases Content DataType
			end,
		CoordinateFrame = function(raw)
			return "<CFrame>" .. XML_Descriptors.CFrame(raw) .. "</CFrame>"
		end,
		-- DateTime = function(raw) return raw.UnixTimestampMillis end, -- ? Not sure
	Faces = function(raw)
		-- The text of this element is formatted as an integer between 0 and 63
		return "<faces>" .. __BIT(raw.Right, raw.Top, raw.Back, raw.Left, raw.Bottom, raw.Front) .. "</faces>"
	end,
	Font = 636 < CLIENT_VERSION
		and function(raw)
			-- TODO (OPTIONAL ELEMENT): Figure out how to determine (ContentId) <CachedFaceId><url>rbxasset://fonts/GothamSSm-Medium.otf</url></CachedFaceId>
				--[[
		? game:GetService("TextService"):GetFontMemoryData()
		? rbxasset://fonts/families/{Enum.Font.BuilderSans.Name}.json
		]]

			local ok_w, weight = pcall(index, raw, "Weight")
			local ok_s, style = pcall(index, raw, "Style")

			return "<Family>"
			.. XML_Descriptors.ContentId(raw.Family)
			.. "</Family><Weight>"
			.. (ok_w and XML_Descriptors.__ENUM(weight) or "")
			.. "</Weight><Style>"
			.. (ok_s and style.Name or "") -- Weird but this field accepts .Name of enum instead..
			.. "</Style>"
		end
		or function(raw)
			local FontString = tostring(raw) -- TODO: Temporary fix

			local EmptyWeight = string_find(FontString, "Weight = ,")
			local EmptyStyle = string_find(FontString, "Style =  }")

			return "<Family>"
			.. XML_Descriptors.ContentId(raw.Family)
			.. "</Family><Weight>"
			.. (EmptyWeight and "" or XML_Descriptors.__ENUM(raw.Weight))
			.. "</Weight><Style>"
			.. (EmptyStyle and "" or raw.Style.Name) -- Weird but this field accepts .Name of enum instead..
			.. "</Style>"
		end,
	NumberRange = function(raw) -- tostring(raw) also works
		-- The value is the text content, formatted as a space-separated list of floating point numbers.
		local __NORMALIZE_RANGE = XML_Descriptors.__NORMALIZE_RANGE

		return __NORMALIZE_RANGE(raw.Min) .. " " .. __NORMALIZE_RANGE(raw.Max) --[[.. " "]] -- ! This might be required for compatibility; __NORMALIZE_RANGE is not needed here but it fixes the issue where "nan 10" value would reset to "0 0"
	end,
	NumberSequence = nil,
	-- NumberSequence = Descriptors.__SEQUENCE,

	-- Path2DControlPoint = function(raw)  -- ? Not sure
	-- 	local udim2 = XML_Descriptors.UDim2
	-- 	return "<Position>"
	-- 		.. udim2(raw.Position)
	-- 		.. "</Position>"
	-- 		.. "<LeftTangent>"
	-- 		.. udim2(raw.LeftTangent)
	-- 		.. "</LeftTangent>"
	-- 		.. "<RightTangent>"
	-- 		.. udim2(raw.RightTangent)
	-- 		.. "</RightTangent>"
	-- end,

	PhysicalProperties = function(raw)
		--[[
			Contains at least one CustomPhysics element, which is interpreted according to the bool type. If this value is true, then the tag also contains an element for each component of the PhysicalProperties:

			Density
			Friction
			Elasticity
			FrictionWeight
			ElasticityWeight

			The value of each component is represented by the text content formatted as a 32-bit floating point number (see float)
		]]

		local CustomPhysics = "<CustomPhysics>" .. XML_Descriptors.bool(raw and true or false) .. "</CustomPhysics>"

		return raw
			and CustomPhysics .. "<Density>" .. raw.Density .. "</Density><Friction>" .. raw.Friction .. "</Friction><Elasticity>" .. raw.Elasticity .. "</Elasticity><FrictionWeight>" .. raw.FrictionWeight .. "</FrictionWeight><ElasticityWeight>" .. raw.ElasticityWeight .. "</ElasticityWeight><AcousticAbsorption>" .. raw.AcousticAbsorption .. "</AcousticAbsorption>"
			or CustomPhysics
	end,
	-- ProtectedString = function(raw) return tostring(raw), "ProtectedString" end,
	Ray = function(raw)
		local vector3 = XML_Descriptors.Vector3

		return "<origin>" .. vector3(raw.Origin) .. "</origin><direction>" .. vector3(raw.Direction) .. "</direction>"
	end,
	Rect = function(raw)
		return XML_Descriptors.__MINMAX(raw.Min, raw.Max, XML_Descriptors.Vector2), "Rect2D"
	end,
	Region3 = function(raw) -- ? Not sure yet (/Network/Replicator.cpp#L1306)
		local Translation = raw.CFrame.Position
		local HalfSize = raw.Size * 0.5

		return XML_Descriptors.__MINMAX(
			Translation - HalfSize, -- /App/util/Region3.cpp#L38
			Translation + HalfSize, -- /App/util/Region3.cpp#L42
			XML_Descriptors.Vector3
		)
	end,
	Region3int16 = function(raw) -- ? Not sure yet (/App/v8tree/EnumProperty.cpp#L346)
		return XML_Descriptors.__MINMAX(raw.Min, raw.Max, XML_Descriptors.Vector3int16)
	end,
	SharedString = function(raw)
		raw = raw == "" and "" or base64encode(raw)

		local Identifier = SharedString_identifiers[raw]

		if SharedStrings[Identifier] == nil then
			SharedStrings[Identifier] = raw
		end

		return Identifier
	end,
	SecurityCapabilities = nil,
	-- SystemAddress = function(raw) return raw end, -- PeerId?  -- ? Not sure
	-- TweenInfo = function(raw) -- ? Not sure
	-- 	local normalize_num = XML_Descriptors.__NORMALIZE_NUMBER
	-- 	local enum = XML_Descriptors.__ENUM

	-- 	return "<Time>"
	-- 		.. normalize_num(raw.Time)
	-- 		.. "</Time><DelayTime>"
	-- 		.. normalize_num(raw.DelayTime)
	-- 		.. "</DelayTime><RepeatCount>"
	-- 		.. normalize_num(raw.RepeatCount)
	-- 		.. "</RepeatCount><Reverses>"
	-- 		.. XML_Descriptors.bool(raw.Reverses)
	-- 		.. "</Reverses><EasingDirection>"
	-- 		.. enum(raw.EasingDirection)
	-- 		.. "</EasingDirection><EasingStyle>"
	-- 		.. enum(raw.EasingStyle)
	-- 		.. "</EasingStyle>"
	-- end,
	UDim = function(raw)
		--[[
			S: Represents the Scale component. Interpreted as a <float>.
			O: Represents the Offset component. Interpreted as an <int>.
		]]

		return "<S>" .. raw.Scale .. "</S><O>" .. raw.Offset .. "</O>"
	end,
	UDim2 = function(raw)
		--[[
			XS: Represents the X.Scale component. Interpreted as a <float>.
			XO: Represents the X.Offset component. Interpreted as an <int>.
			YS: Represents the Y.Scale component. Interpreted as a <float>.
			YO: Represents the Y.Offset component. Interpreted as an <int>.
		]]

		local X, Y = raw.X, raw.Y

		return "<XS>"
			.. X.Scale
			.. "</XS><XO>"
			.. X.Offset
			.. "</XO><YS>"
			.. Y.Scale
			.. "</YS><YO>"
			.. Y.Offset
			.. "</YO>"
	end,

	-- UniqueId = function(raw) -- ? Not sure  -- ? No idea if this even needs a Descriptor
	-- 	--[[
	-- 		UniqueId properties might be random everytime Studio saves a place file
	-- 		and don't have a use right now outside of packages, which SSI doesn't
	-- 		account for anyway. They generate diff noise, so we shouldn't serialize
	-- 		them until we have to.
	-- 	]]
	-- 	-- https://github.com/MaximumADHD/Roblox-Client-Tracker/blob/roblox/LuaPackages/Packages/_Index/ApolloClientTesting/ApolloClientTesting/utilities/common/makeUniqueId.lua#L62
	-- 	return ""
	-- end,

	Vector2 = function(raw)
		--[[
			X: Represents the X component. Interpreted as a <float>.
			Y: Represents the Y component. Interpreted as a <float>.
		]]
		return XML_Descriptors.__VECTOR(raw.X, raw.Y)
	end,
	Vector2int16 = nil,
	-- Vector2int16 = Descriptors.Vector2, -- except as <int>
	Vector3 = function(raw)
		--[[
			X: Represents the X component. Interpreted as a <float>.
			Y: Represents the Y component. Interpreted as a <float>.
			Z: Represents the Z component. Interpreted as a <float>.
		]]
		return XML_Descriptors.__VECTOR(raw.X, raw.Y, raw.Z)
	end,
	Vector3int16 = nil,
	-- Vector3int16 = Descriptors.Vector3, -- except as <int>\
	bool = function(raw)
		return raw and "true" or "false"
	end,
	double = nil, -- Float64
	float = nil, -- Float32
	int = nil, -- Int32
	int64 = nil, -- Int64 (long)
	string = function(raw)
		return (raw == nil or raw == "") and ""
			or string_find(raw, "]]>") and string.gsub(raw, ESCAPES_PATTERN, ESCAPES)
			or XML_Descriptors.__CDATA(string.gsub(raw, "\0", ""))
	end,

	--------------------------------------------------------------
	-----------%localappdata%/Roblox/GlobalSettings_13.xml--------
	--------------------------------------------------------------
	-- QDir = function(raw) -- ? Not sure
	-- 	return raw
	-- end,
	-- QFont = function(raw) -- ? Not sure
	-- 	return raw
	-- end,
}

do
	local BASE_CAPABILITIES
	pcall(function()
		BASE_CAPABILITIES = SecurityCapabilities.new()
	end)
	if BASE_CAPABILITIES then
		local CAPABILITY_BITS = {
			Plugin = 2 ^ 0, ----------------  0
			LocalUser = 2 ^ 1, -------------  1
			WritePlayer = 2 ^ 2, -----------  2
			RobloxScript = 2 ^ 3, ----------  3
			RobloxEngine = 2 ^ 4, ----------  4
			NotAccessible = 2 ^ 5, ---------  5
			RunClientScript = 2 ^ 8, -------  8
			RunServerScript = 2 ^ 9, -------  9
			AccessOutsideWrite = 2 ^ 11, ---  11 (0xb)
			Unassigned = 2 ^ 15, -----------  15 (0xf)
			AssetRequire = 2 ^ 16, ---------  16 (0x10)
			LoadString = 2 ^ 17, -----------  17 (0x11)
			ScriptGlobals = 2 ^ 18, --------  18 (0x12)
			CreateInstances = 2 ^ 19, ------  19 (0x13)
			Basic = 2 ^ 20, ----------------  20 (0x14)
			Audio = 2 ^ 21, ----------------  21 (0x15)
			DataStore = 2 ^ 22, ------------  22 (0x16)
			Network = 2 ^ 23, --------------  23 (0x17)
			Physics = 2 ^ 24, --------------  24 (0x18)
			UI = 2 ^ 25, -------------------  25 (0x19)
			CSG = 2 ^ 26, ------------------  26 (0x1a)
			Chat = 2 ^ 27, -----------------  27 (0x1b)
			Animation = 2 ^ 28, ------------  28 (0x1c)
			Avatar = 2 ^ 29, ---------------  29 (0x1d)
			Input = 2 ^ 30, ----------------  30 (0x1e)
			Environment = 2 ^ 31, ----------  31 (0x1f)
			RemoteEvent = 2 ^ 32, ----------  32 (0x20)
			LegacySound = 2 ^ 33, ----------  33 (0x21)
			Players = 2 ^ 34, --------------  34 (0x22)
			CapabilityControl = 2 ^ 35, ----  35 (0x23)
			InternalTest = 2 ^ 60, ---------  60 (0x3c), Related to TestingGameScript
			PluginOrOpenCloud = 2 ^ 61, ----  61 (0x3d)
			Assistant = 2 ^ 62, ------------  62 (0x3e)
			-- Restricted = 2 ^ 63, -----------  for negative (highest bit for signed integers)
		}

		XML_Descriptors.SecurityCapabilities = function(raw)
			-- TODO tostring & string.split aren't ideal but this is the only way until the feature is out of the experimental phase

			if raw == BASE_CAPABILITIES then
				return 0
			end

			local result = 0

			for _, flag in string.split(tostring(raw), " | ") do
				local bit = CAPABILITY_BITS[flag]
				if bit then
					result += bit
				end
			end

			return result
		end
	end
end

for descriptorName, redirectName in
	{
		NumberSequence = "__SEQUENCE",
		Vector2int16 = "Vector2",
		Vector3int16 = "Vector3",
		double = "__NORMALIZE_NUMBER",
		float = "__NORMALIZE_NUMBER",
		int = "__NORMALIZE_NUMBER",
		int64 = "__NORMALIZE_NUMBER",
	}
do
	XML_Descriptors[descriptorName] = XML_Descriptors[redirectName]
end
if CLIENT_VERSION < math.huge then -- math.huge because unknown yet
	-- ! For sake of compatibility with older clients, Roblox currently does this too but it WILL probably change in the future so keep track of that. ONCE ROBLOX MOVES AWAY FROM THIS, MAKE SURE TO KEEP SUPPORT FOR VERY OLD CLIENTS; 645 <= CLIENT Ver < ??? (ver when roblox moves away), THIS IS COMPLICATED SO PROBABLY NO SUPPORT, JUST USE OLDER VER OF USSI; NEWEST CLIENTS
	XML_Descriptors.Content = XML_Descriptors.ContentId
end

local ClassList, FetchAPI

do
	local ClassPropertyExceptions = {
		Whitelist = { TriangleMeshPart = ArrayToDict({ "CollisionFidelity" }) },
		Blacklist = {
			LuaSourceContainer = ArrayToDict({ "ScriptGuid" }),
			Instance = ArrayToDict({ "UniqueId", "HistoryId" }),
		},
	}

	local NotScriptableFixes = { --[[
		For more info:
		- https://github.com/luau/UniversalSynSaveInstance/blob/main/Tools/NotScriptable-Related/Potentially%20Missing%20Properties%20Dumper/Potentially%20Missing%20Properties%20Dumper.luau
		- https://github.com/luau/UniversalSynSaveInstance/blob/main/Tools/NotScriptable-Related/NotScriptable%20Dumper/NotScriptable%20Dumper.py
		]]
		Instance = {
			AttributesSerialize = function(instance)
				-- * There are certain restrictions for names of attributes
				-- https://create.roblox.com/docs/reference/engine/classes/Instance#SetAttribute
				-- But it seems like even if those are present, Studio still opens the file just fine
				-- So there is no need to check for them currently

				-- TODO: merge sequence Descriptors and some other descriptors where possible (check xml descriptors)
				-- ? Return early for empty tags (this proved equally as fast when done using counter/next)

				local attrs = instance:GetAttributes()

				if not next(attrs) then
					return ""
				end

				local attrs_n = 0
				local buffer_size = 4
				local attrs_sorted = {}
				local attrs_formatted = table.clone(attrs)
				for attr, val in attrs do
					attrs_n += 1
					attrs_sorted[attrs_n] = attr

					local Type = typeof(val)

					local Descriptor = Binary_Descriptors[Type]
					local attr_size

					attrs_formatted[attr], attr_size = Descriptor(val)

					buffer_size += 5 + #attr + attr_size
				end

				table.sort(attrs_sorted)

				local b = buffer.create(buffer_size)

				local offset = 0

				buffer.writeu32(b, offset, attrs_n)
				offset += 4

				local string__descriptor = Binary_Descriptors.string
				for _, attr in attrs_sorted do
					local b_Name, Name_size = string__descriptor(attr)

					buffer.copy(b, offset, b_Name)
					offset += Name_size

					buffer.writeu8(b, offset, attr_Type_IDs[typeof(attrs[attr])])
					offset += 1

					local bb = attrs_formatted[attr]

					buffer.copy(b, offset, bb)
					offset += buffer.len(bb)
				end

				return buffer.tostring(b)
			end,
			DefinesCapabilities = "Sandboxed",
			Tags = function(instance)
				-- https://github.com/RobloxAPI/spec/blob/master/properties/Tags.md

				local tags = instance:GetTags()

				if #tags == 0 then
					return ""
				end

				return table.concat(tags, "\0")
			end,
		},

		-- AuroraScript = { -- Class not released yet
		-- 	AuroraScriptBindingsSerialize = function(instance)
		-- 		local bindings = service.AuroraScriptService:getInstancesForBehavior(instance)
		-- 		if #bindings == 0 then
		-- 			return ""
		-- 		end
		-- 		local refs = table.create(#bindings)
		-- 		for i, binding in bindings do
		-- 			refs[i] = GetRef(binding)
		-- 		end
		-- 		return table.concat(refs, "\0")
		-- 	end,
		-- },
		DebuggerBreakpoint = { line = "Line" }, -- ? This shouldn't appear in live games (try to prove this wrong)
		BallSocketConstraint = { MaxFrictionTorqueXml = "MaxFrictionTorque" },
		BasePart = {
			Color3uint8 = "Color",
			MaterialVariantSerialized = "MaterialVariant",
			size = "Size",
		},
		DoubleConstrainedValue = { value = "Value" },
		IntConstrainedValue = { value = "Value" },

		-- CustomEvent = {PersistedCurrentValue=function(instance) -- * Class is Deprecated and :SetValue doesn't seem to affect GetCurrentValue anymore
		-- 	local Receiver  = instance:GetAttachedReceivers()[1]
		-- 	if Receiver then
		-- 		return Receiver:GetCurrentValue()
		-- 	else
		-- 		error("No Receiver", 2)
		-- 	end
		-- end},
		Terrain = {
			AcquisitionMethod = "LastUsedModificationMethod", -- ? Not sure
			MaterialColors = function(instance) -- https://github.com/RobloxAPI/spec/blob/master/properties/MaterialColors.md
				local TERRAIN_MATERIAL_COLORS =
					{ --https://github.com/rojo-rbx/rbx-dom/blob/master/rbx_dom_lua/src/customProperties.lua#L5
						Enum.Material.Grass,
						Enum.Material.Slate,
						Enum.Material.Concrete,
						Enum.Material.Brick,
						Enum.Material.Sand,
						Enum.Material.WoodPlanks,
						Enum.Material.Rock,
						Enum.Material.Glacier,
						Enum.Material.Snow,
						Enum.Material.Sandstone,
						Enum.Material.Mud,
						Enum.Material.Basalt,
						Enum.Material.Ground,
						Enum.Material.CrackedLava,
						Enum.Material.Asphalt,
						Enum.Material.Cobblestone,
						Enum.Material.Ice,
						Enum.Material.LeafyGrass,
						Enum.Material.Salt,
						Enum.Material.Limestone,
						Enum.Material.Pavement,
					}

				local b = buffer.create(69) -- 69 bytes: 6 reserved + 63 for colors (21 materials * 3 components)
				local offset = 6 -- 6 reserved bytes

				local RGB_components = { "R", "G", "B" }

				for _, material in TERRAIN_MATERIAL_COLORS do
					local color = instance:GetMaterialColor(material)
					for _, component in RGB_components do
						buffer.writeu8(b, offset, math.floor(color[component] * 255)) -- ? math.floor seems unneeded but it makes it faster
						offset += 1
					end
				end

				return buffer.tostring(b)
			end,
		},
		TriangleMeshPart = {
			FluidFidelityInternal = "FluidFidelity",
		},
		MeshPart = { InitialSize = "MeshSize" },
		PartOperation = { InitialSize = "MeshSize" },
		Part = { shape = "Shape" },
		TrussPart = { style = "Style" },
		FormFactorPart = {
			formFactorRaw = "FormFactor",
		},
		Fire = { heat_xml = "Heat", size_xml = "Size" },
		Humanoid = { Health_XML = "Health" },
		HumanoidDescription = {
			EmotesDataInternal = function(instance)
				local emotes_data = ""
				for name, ids in instance:GetEmotes() do
					emotes_data ..= name .. "^" .. table.concat(ids, "^") .. "^\\"
				end
				return emotes_data
			end,
			EquippedEmotesDataInternal = function(instance)
				local equipped_emotes_data = ""
				for _, emote in instance:GetEquippedEmotes() do
					equipped_emotes_data ..= emote.Slot .. "^" .. emote.Name .. "\\"
				end
				return equipped_emotes_data
			end,
		},
		LocalizationTable = {
			Contents = function(instance)
				return instance:GetContents() --service.HttpService:JSONEncode(instance:GetEntries())
			end,
		},
		MaterialService = { Use2022MaterialsXml = "Use2022Materials" },

		Model = {
			ScaleFactor = function(instance)
				return instance:GetScale()
			end,
			WorldPivotData = "WorldPivot", -- TODO This doesn't accurately represent whether optional type property is present or not (it's never nil), gethiddenproperty or gethiddenproperty_fallback is preferred
		},
		PackageLink = { PackageIdSerialize = "PackageId", VersionIdSerialize = "VersionNumber" },
		Players = { MaxPlayersInternal = "MaxPlayers", PreferredPlayersInternal = "PreferredPlayers" }, -- ? Only needed for execs that lack LocalUserSecurity (Level 2, 5, 9), even so, it's a pretty useless information as it can be viewed elsewhere

		StarterPlayer = {
			AvatarJointUpgrade_SerializedRollout = "AvatarJointUpgrade", -- RobloxScriptSecurity
			-- LoadCharacterLayeredClothing = "LoadCharacterLayeredClothing ",-- * Both NotScriptable
		},
		Smoke = { size_xml = "Size", opacity_xml = "Opacity", riseVelocity_xml = "RiseVelocity" },
		Sound = {
			xmlRead_MaxDistance_3 = "RollOffMaxDistance", -- * Also MaxDistance
		},
		-- ViewportFrame = { -- * Pointless because these reflect CurrentCamera's properties
		-- 	CameraCFrame = function(instance) -- *
		-- 		local CurrentCamera = instance.CurrentCamera
		-- 		if CurrentCamera then
		-- 			return CurrentCamera.CFrame
		-- 		else
		-- 			error("No CurrentCamera", 2)
		-- 		end
		-- 	end,
		-- 	-- CameraFieldOfView =
		-- },
		WeldConstraint = {
			Part0Internal = "Part0",
			Part1Internal = "Part1",
			-- State = function(instance)
			-- 	-- If untouched then default state is 3 (default true)
			-- 	return instance.Enabled and 1 or 0
			-- end,
		},
		Workspace = {
			-- SignalBehavior2 = "SignalBehavior", -- * Both NotScriptable
			CollisionGroupData = function()
				local collision_groups = game:GetService("PhysicsService"):GetRegisteredCollisionGroups()

				local col_groups_n = #collision_groups

				if col_groups_n == 0 then
					return "\1\0"
				end

				local buffer_size = 2 -- Initial size

				for _, group in collision_groups do
					buffer_size += 7 + #group.name
				end

				local b = buffer.create(buffer_size)

				local offset = 0

				buffer.writeu8(b, offset, 1) -- ? [CONSTANT] Version byte (likely)
				offset += 1
				buffer.writeu8(b, offset, col_groups_n) -- Group count
				offset += 1

				for i, group in collision_groups do
					local name, id, mask = group.name, i - 1, group.mask
					local name_len = #name

					buffer.writeu8(b, offset, id) -- ID
					offset += 1

					buffer.writeu8(b, offset, 4) -- ? [CONSTANT] Not sure what this is (also not sure about u8, could be i8)
					offset += 1

					buffer.writei32(b, offset, mask) -- Mask value as signed 32-bit integer
					offset += 4

					buffer.writeu8(b, offset, name_len) -- Name length
					offset += 1
					buffer.writestring(b, offset, name) -- Name
					offset += name_len
				end

				return buffer.tostring(b)
			end,
		},
	}

	FetchAPI = function()
		-- Credits @MaximumADHD

		local FILE_NAME = "API_DUMP.json"

		local API_Dump

		local Max_SecurityCapabilities = SecurityCapabilities.new(unpack(Enum.SecurityCapability:GetEnumItems()))
		local filter = { Security = Max_SecurityCapabilities, ExcludeDisplay = true, ExcludeInherited = true }

		-- ! exact version match is preferred, mismatched dump versions might result in saveinstance trying to save properties that your client doesn't have yet
		local APIDUMP_FETCHERS = {
			[1] = function()
				local res = readfile(FILE_NAME)
				if res and res ~= "" then
					return service.HttpService:JSONDecode(res)[FULL_VERSION]
				end
			end,
			[2] = function() -- version-history.json -> exact_match -> zbeta -> LIVE -> sibling major matches
				local client_version_str = tostring(CLIENT_VERSION)
				local dump
				local matching_versions, matched, is_matched, exact_match = {}, {}
				local function process_line(line, noinsert)
					local file_version, patch_commit, version_hash =
						string.match(line, '"%d+%.(%d+)%.([^"]+)": "(version%-[^"]+)')
					if file_version == client_version_str then
						is_matched = true
						if version_hash and not matched[version_hash] then -- ! this might cause issues if different file_versions point to the same version_hash (never happened)
							matched[version_hash] = true
							if not noinsert then -- to avoid fetching duplicates
								table.insert(matching_versions, version_hash) -- ? Retain the order (by latest)
							end
							if string.sub(FULL_VERSION, -#patch_commit) == patch_commit then
								return version_hash -- exact match
							end
						end
					elseif is_matched then
						return false -- stop iteration
					end
				end

				-- ! Assumes Normal dumps never include Default; Full dumps always do.
				local function isFullDump(classes)
					for _, class in classes do
						for _, member in class.Members do
							if member.MemberType == "Property" then
								return member.Default ~= nil
							end
						end
					end
					return false -- no properties found at all; treat as inconclusive/not full
				end

				local function tryFetchDump(url)
					local ok, decoded = pcall(function()
						local raw = game:HttpGet(url, true)
						return service.HttpService:JSONDecode(raw)
					end)
					return ok and decoded.Classes or nil
				end

				local function fetchFullApiDump(hash)
					-- Primary: Roblox CDN (only WindowsStudio64 hashes seem supported here)
					local decoded = tryFetchDump("https://setup.rbxcdn.com/" .. hash .. "-Full-API-Dump.json")
					if decoded and isFullDump(decoded) then
						return decoded
					end

					-- Fallback: our own archived full dumps, in case Roblox's endpoint
					-- silently returned a normal dump instead of a full one (or 404'd).
					decoded = tryFetchDump(
						"https://raw.githubusercontent.com/setup-rbxcdn/roblox-full-api-dumps/refs/heads/main/full-dumps/"
							.. hash
							.. "-Full-API-Dump.json"
					)
					if decoded and isFullDump(decoded) then -- isFullDump check is useless here but why not
						return decoded
					end

					return nil
				end

				do
					local o, r = pcall(
						game.HttpGet,
						game,
						"https://raw.githubusercontent.com/setup-rbxcdn/setup-rbxcdn.github.io/refs/heads/main/version-history/Windows/Studio64.json",
						true
					)
					if o then
						local version_history = string.split(r, "\n")
						version_history[#version_history] = nil -- the "}"
						-- 1. version-history pass (bottom-up)
						for i = #version_history, 2, -1 do -- 2 to avoid "{"
							local res = process_line(version_history[i])
							if res == false then
								break
							elseif res then
								exact_match = res
							end
						end
					end
				end
				do -- ? this might happen when user is on a new version but Roblox-Client-Tracker hasn't updated version-history.json yet
					local function fallback_channel(channel)
						local ok, res = pcall(function()
							return service.HttpService:JSONDecode(
								game:HttpGet(
									"https://clientsettingscdn.roblox.com/v2/client-version/WindowsStudio64"
										.. (channel and "/channel/" .. channel or ""),
									true
								)
							)
						end)
						if not ok then
							return
						end
						if res.version and res.clientVersionUpload then -- just in case
							local line = '"' .. res.version .. '": "' .. res.clientVersionUpload
							return process_line(line, true)
						end
					end
					if not exact_match then
						exact_match = fallback_channel("zbeta") or fallback_channel() -- LIVE
					end
				end
				if exact_match then
					dump = fetchFullApiDump(exact_match)
				end
				if not dump then
					for _, version_hash in matching_versions do -- TODO ideally match nearest by Commit segment of version(), new>old
						dump = fetchFullApiDump(version_hash)
						if dump then
							break
						end
					end
				end
				return dump
			end,
			[3] = function()
				-- ! Some executors (like Xeno) error on ReflectionService.GetClasses due to their ProxyService
				-- TODO At the time of writing this is missing a way to confirm NotCreatable & NotScriptable
				-- also is missing some classes like UserGameSettings, not that important though as none of them appear under DataModel
				local classes, classes_size = {}, 1

				for _, api_class in service.ReflectionService:GetClasses(filter) do
					local members, members_size = {}, 1
					local className = api_class.Name

					local class = {
						Name = className,
						Members = members,
						Superclass = api_class.Superclass or "<<<ROOT>>>",
					}
					local permits = api_class.Permits

					local tags = {}
					if api_class.Service then
						table.insert(tags, "Service")
					elseif permits and permits["GetService"] then
						table.insert(tags, "Service")
					elseif not permits or not permits["New"] then -- Some services can be Instance.new so it's better to include them
						table.insert(tags, "NotCreatable")
					end

					if #tags ~= 0 then
						class.Tags = tags
					end

					local o, r = pcall(
						service.ReflectionService.GetPropertiesOfClass,
						service.ReflectionService,
						className,
						filter
					) -- ? Might produce errors (ex. RolloutValidation) therefore pcall
					if o then
						for _, property in r do
							local propertyName = property.Name

							local valueType = property.Type
							local valueType_Name = valueType.EngineType

							local category = valueType.Category

							local member_tags = {}

							if not next(property.Permits) then
								table.insert(member_tags, "NotScriptable")
							end

							if valueType_Name == "Enum" then
								category, valueType_Name = "Enum", valueType.EnumType
							elseif valueType_Name == "RefType" then
								category, valueType_Name = "Class", valueType.InstanceType
							else
								local renames = {
									CoordinateFrame = "CFrame",
									Rect2D = "Rect",
									Vector3Int16 = "Vector3int16",
									Vector2Int16 = "Vector2int16",
									Region3Int16 = "Region3int16",
								}
								valueType_Name = renames[valueType_Name] or valueType_Name
							end

							-- property.Display.DeprecationMessage can be used to track Deprecated tag (not always though)

							local member = {
								Name = propertyName,
								MemberType = "Property",
								ValueType = { Name = valueType_Name, Category = category },
								Serialization = { CanLoad = property.Serialized, CanSave = property.Serialized },
								-- Default = Member.Default,
								-- Special = Special,
								-- Tags = MemberTags,
							}

							if #member_tags ~= 0 then
								member.Tags = member_tags
							end

							members[members_size] = member
							members_size += 1
						end
						-- else
						-- warn("Missing", className, r)
					end
					classes[classes_size] = class
					classes_size += 1
				end

				return classes
			end,
			[4] = function()
				return service.HttpService:JSONDecode(
					game:HttpGet(
						"https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/Mini-API-Dump.json",
						true
					)
				).Classes
			end,
		}

		for i, fetcher in APIDUMP_FETCHERS do
			local o, r = pcall(fetcher)
			if o and r then
				API_Dump = r
				if i == 2 then -- relies on [2] being the same
					if writefile then
						local ok, err =
							pcall(writefile, FILE_NAME, service.HttpService:JSONEncode({ [FULL_VERSION] = API_Dump }))
						if not ok then
							warn("[DEBUG] DUMP writefile error", err)
						end
					end
				end
				break
			elseif r ~= false and 2 < i then
				warn("[DEBUG] Failed to get", FULL_VERSION, "version API Dump, trying fallbacks..")
				warn("[DEBUG] Method number:", i, "Reason:", r)
			end
		end

		local classList = {}
		local tmp_classDict = {}

		local ClassesWhitelist, ClassesBlacklist = ClassPropertyExceptions.Whitelist, ClassPropertyExceptions.Blacklist

		local API_Dump_Decoded = API_Dump

		-- First pass (prep)
		for _, API_Class in API_Dump_Decoded do
			local ClassName = API_Class.Name
			local props = {}

			for _, Member in API_Class.Members do
				local MemberType = Member.MemberType
				if MemberType == "Property" or MemberType == "Function" then
					props[Member.Name] = {
						ValueType = MemberType == "Property" and Member.ValueType.Name,
						MemberType = MemberType,
						-- Serialization = Member.Serialization,
					}
				end
			end

			tmp_classDict[ClassName] = props
		end

		-- Second pass (actual)
		for _, API_Class in API_Dump_Decoded do
			local ClassProperties, ClassProperties_size = {}, 1
			local Class = {
				Properties = ClassProperties,
				Superclass = API_Class.Superclass,
				-- Tags = {},
				NotCreatable = nil,
			}

			local ClassName = API_Class.Name
			local ClassTags = API_Class.Tags

			if ClassTags then
				local Tags = ArrayToDict(ClassTags, nil, nil, "string")
				-- Class.Tags = Tags -- or {}
				Class.NotCreatable = Tags.NotCreatable
				Class.Service = Tags.Service
			end

			local NotScriptableFixClass = NotScriptableFixes[ClassName]

			-- ? Check 96ea8b2a755e55a78aedb55a7de7e83980e11077 commit - If a NotScriptableFix is needed that relies on another NotScriptable Property (which doesn't really make sense in the first place)

			local ClassWhitelist, ClassBlacklist = ClassesWhitelist[ClassName], ClassesBlacklist[ClassName]

			local ContentProperties
			for _, Member in API_Class.Members do
				if Member.MemberType == "Property" then
					local Serialization = Member.Serialization

					if Serialization.CanLoad then -- If Roblox doesn't save it why should we; If Roblox doesn't load it we don't need to save it
						--[[
							-- ! CanSave replaces "Tags.Deprecated" check because there are some old properties which are deprecated yet have CanSave.
							Example: Humanoid.Health is CanSave false due to Humanoid.Health_XML being CanSave true (obsolete properties basically) - in this case both of them will Load. (aka PropertyPatches)
							CanSave being on same level as CanLoad also fixes potential issues with overlapping properties like Color, Color3 & Color3uint8 of BasePart, out of which only Color3uint8 should save
							This also fixes everything in IgnoreClassProperties automatically without need to hardcode :)
							A very simple fix for many problems that saveinstance scripts encounter!
						--]]
						local PropertyName = Member.Name

						local ValueType = Member.ValueType
						local ValueType_Name = ValueType.Name

						if ValueType_Name == "Content" or ValueType_Name == "AssetContentMap" then -- TODO Can Skip this if our dump was fetched from ReflectionService (make it explicit), currently ReflectionService dump isn't written to file
							-- ? This filters out Content DataType properties that Roblox doesn't serialize (even if they have CanSave/CanLoad true), takes less space, time & prevents potential property conflicts (Content vs ContentId)
							if not ContentProperties then
								ContentProperties = {}

								local o, properties = pcall(
									service.ReflectionService.GetPropertiesOfClass,
									service.ReflectionService,
									ClassName,
									filter
								) -- ? Might produce errors (ex. RolloutValidation) therefore pcall
								if o then
									for _, property in properties do -- * might as well check all properties, not just Content type
										ContentProperties[property.Name] = property.Serialized
									end
								end
							end
							if ContentProperties[PropertyName] ~= nil then
								Serialization.CanSave = ContentProperties[PropertyName]
							end
						end

						if
							(Serialization.CanSave or ClassWhitelist and ClassWhitelist[PropertyName])
							and not (ClassBlacklist and ClassBlacklist[PropertyName])
						then
							local MemberTags = Member.Tags

							local Special, PreferredDescriptorName

							if MemberTags then
								for _, tag in MemberTags do
									if type(tag) == "table" then
										PreferredDescriptorName = tag.PreferredDescriptorName
										if PreferredDescriptorName and Special then
											break
										end
									elseif tag == "NotScriptable" then
										Special = true
										if PreferredDescriptorName then
											break
										end
									end
								end
							end

							local preferredDescriptorProp
							if PreferredDescriptorName then
								preferredDescriptorProp = tmp_classDict[ClassName][PreferredDescriptorName]

								if -- Prevents type mismatch
									preferredDescriptorProp == nil
									or (
										preferredDescriptorProp.MemberType == "Property"
										and ValueType_Name ~= preferredDescriptorProp.ValueType
									)
								then -- For ex. (if they were notscriptable) CollisionGroupId (int) -> CollisionGroup (string)
									PreferredDescriptorName = nil
								end
							end

							-- if not Special then
							local Property = {
								Name = PropertyName,
								Category = ValueType.Category,
								-- Default = Member.Default,
								-- Tags = MemberTags,
								ValueType = ValueType_Name,

								Special = Special,

								CanRead = nil,
							}

							if string.sub(ValueType_Name, 1, 8) == "Optional" then
								-- Extract the string after "Optional"
								Property.Optional = string.sub(ValueType_Name, 9)
							end

							local NotScriptableFix = NotScriptableFixClass and NotScriptableFixClass[PropertyName]
							local accessFunc = PreferredDescriptorName
								and (
									preferredDescriptorProp.MemberType == "Property"
										and function(instance)
											return instance[PreferredDescriptorName]
										end
									or function(instance) -- Assume MemberType is "Function"
										return instance[PreferredDescriptorName](instance)
									end
								)

							Property.Fallback = NotScriptableFix
									and (type(NotScriptableFix) == "function" and NotScriptableFix or accessFunc and function(
										instance
									)
										local o, r = pcall(accessFunc, instance)
										if o then
											return r
										end
										return instance[NotScriptableFix]
									end or function(instance)
										return instance[NotScriptableFix]
									end)
								or accessFunc

							ClassProperties[ClassProperties_size] = Property
							ClassProperties_size += 1

							-- end
						end
					end
				end
			end

			classList[ClassName] = Class
		end

		return classList
	end
end

local GLOBAL_ENV = getgenv and getgenv() or _G or shared

--[=[
    @class SynSaveInstance
    Represents the options for saving instances with custom settings using the synsaveinstance function.
]=]

--- @interface CustomOptions table
--- * Structure of the main CustomOptions table.
--- * Note: Options are case-insensitive, meaning you could type `NilInstances` option as `nilInStaNces` and it would still be valid.
--- @within SynSaveInstance
--- @field __DEBUG_MODE boolean -- This will print debug logs to console about unusual scenarios. Recommended to enable if you wish to help us improve our products and find bugs / issues with it! ___Default:___ false
--- @field ReadMe boolean --___Default:___ true
--- @field SafeMode boolean -- Kicks you before Saving, which prevents you from being detected in any game. ___Default:___ false
--- @field ShutdownWhenDone boolean -- Shuts the game down after saveinstance is finished. ___Default:___ false
--- @field AntiIdle boolean -- Prevents the 20-minute-Idle Kick. ___Default:___ true
--- Anonymous {boolean|table{UserId = string, Name = string}} -- * **RISKY:** Cleans the file of any info related to your account like: Name, UserId. This is useful for some games that might store that info in GUIs or other Instances. Might potentially mess up parts of strings that contain characters that match your Name or parts of numbers that match your UserId. Can also be a table with UserId & Name keys. ___Default:___ false
--- @field ShowStatus boolean -- ___Default:___ true
--- @field Callback function -- If set, the serialized data will be sent to the callback function instead of to file. ___Default:___ false
--- @field mode string -- Valid modes: full, optimized, scripts. Change this to invalid mode like "invalid" if you only want ExtraInstances. "optimized" mode is **NOT** supported with *@Object* option. ___Default:___ `"optimized"`
--- @field noscripts boolean -- ___Aliases:___ `Decompile`. ___Default:___ false
--- @field scriptcache boolean -- ___Default:___ true
--- @field decomptype string -- * Deprecated. ___Default:___ Uses your executor's decompiler, if available.
--- @field timeout number -- If the decompilation run time exceeds this value it gets cancelled. Set to -1 to disable timeout (unreliable). ***Aliases***: `DecompileTimeout`. ___Default:___ 10
--- @field DecompileJobless boolean -- Includes already decompiled code in the output. No new scripts are decompiled. ___Default:___ false
--- @field SaveBytecode boolean -- Includes bytecode in the output. Useful if you wish to be able to decompile it yourself later. ___Default:___ false
--- .DecompileIgnore {Instance | Instance.ClassName | [Instance.ClassName] = {Instance.Name}} -- * Ignores match & it's descendants by default. To Ignore only the instance itself set the value to `= false`. Examples: "Chat", - Matches any instance with "Chat" ClassName, Players = {"MyPlayerName"} - Matches "Players" Class AND "MyPlayerName" Name ONLY, `workspace` - matches Instance by reference, `[workspace] = false` - matches Instance by reference and only ignores the instance itself and not it's descendants. ___Default:___ {TextChatService}
--- .IgnoreList {Instance | Instance.ClassName | [Instance.ClassName] = {Instance.Name}} -- Structure is similar to **@DecompileIgnore** except `= false` meaning save the instance but ignore it's descendants. ___Default:___ {CoreGui, CorePackages}
--- .ExtraInstances {Instance} -- If used with any invalid mode (like "invalidmode") it will only save these instances. ___Default:___ {}
--- @field IgnoreProperties table -- Ignores properties by Name. ___Default:___ {}
--- @field SaveCacheInterval number -- The less the value the more often it saves, but that would mean less performance due to constantly saving. ___Default:___ 0x1600 * 10
--- @field FilePath string -- Must only contain the name of the file, no file extension. ___Default:___ false
--- @field Object Instance -- * If provided, saves as .rbxmx (Model file) instead. If Object is game, it will be saved as a .rbxl file. **MUST BE AN INSTANCE REFERENCE, FOR EXAMPLE - *game.Workspace***. `"optimized"` mode is **NOT** supported with this option. If IsModel is set to false then Object specified here will be saved as a place file. ___Default:___ false
--- @field IsModel boolean -- If Object is specified then sets to true automatically, unless you set it to false. ___Default:___ false
--- @field NilInstances boolean -- Save instances that aren't Parented (Parented to nil). ___Default:___ false
--- .NilInstancesFixes {[Instance.ClassName] = function} -- * This can cause some Classes to be fixed even though they might not need the fix (better be safe than sorry though). For example, Bones inherit from Attachment if we dont define them in the NilInstancesFixes then this will catch them anyways. **TO AVOID THIS BEHAVIOR USE THIS EXAMPLE:** {ClassName_That_Doesnt_Need_Fix = false}. ___Default:___ {Animator = function, AdPortal = function, BaseWrap = function, Attachment = function}
--- @field IgnoreDefaultProperties boolean -- Ignores default properties during saving.  ___Default:___ true
--- @field IgnoreNotArchivable boolean -- Ignores the Archivable property and saves Non-Archivable instances. ___Default:___ true
--- @field IgnorePropertiesOfNotScriptsOnScriptsMode boolean -- Ignores property of every instance that is not a script in "scripts" mode. ___Default:___ false
--- @field IgnoreSpecialProperties boolean -- Prevents calls to `gethiddenproperty` and uses fallback methods instead. This also helps with crashes. If your file is corrupted after saving, you can try turning this on. ___Default:___ false
--- @field UseUGCValidationService boolean -- * When `false`, the script never uses `UGCValidationService:GetPropertyValue` as a hidden-property fallback (some executors flag or lack it). `gethiddenproperty` is still used; only the UGC fallback is disabled. ___Default:___ true
--- @field IsolateLocalPlayer boolean -- Saves Children of LocalPlayer as separate folder and prevents any instance of ClassName Player with .Name identical to LocalPlayer.Name from saving. ___Default:___ false
--- @field IsolateStarterPlayer boolean -- If enabled, StarterPlayer will be cleared and the saved starter player will be placed into folders. ___Default:___ false
--- @field IsolateLocalPlayerCharacter boolean -- Saves Children of LocalPlayer.Character as separate folder and prevents any instance of ClassName Player with .Name identical to LocalPlayer.Name from saving. ___Default:___ false
--- @field RemovePlayerCharacters boolean -- Ignore player characters while saving. (Enables SaveNotCreatable automatically). ___Default:___ true
--- @field SaveNotCreatable boolean -- * Includes non-serializable instances as Folder objects (Name is misleading as this is mostly a fix for certain NilInstances and isn't always related to NotCreatable). ___Default:___ false
--- .NotCreatableFixes table<Instance.ClassName> -- * {"Player"} is the same as {Player = "Folder"}; Format like {SpawnLocation = "Part"} is only to be used when SpawnLocation inherits from "Part" AND "Part" is Creatable. ___Default:___ { "", "Player", "PlayerScripts", "PlayerGui", "TouchTransmitter" }
--- @field IsolatePlayers boolean -- * This option does save players, it's just they won't show up in Studio and can only be viewed through the place file code (in text editor). More info at https://github.com/luau/UniversalSynSaveInstance/issues/2. ___Default:___ false
--- @field AlternativeWritefile boolean -- * Splits file content string into segments and writes them using appendfile. This might help with crashes when it starts writing to file. Though there is a risk of appendfile working incorrectly on some executors. ___Default:___ true
--- @field IgnoreDefaultPlayerScripts boolean -- * **RISKY: Ignores Default PlayerScripts like PlayerModule & RbxCharacterSounds. Prevents crashes on certain Executors. ___Default:___ true
--- @field IgnoreSharedStrings boolean -- * **RISKY: FIXES CRASHES (TEMPORARY, TESTED ON ROEXEC ONLY). FEEL FREE TO DISABLE THIS TO SEE IF IT WORKS FOR YOU**. ___Default:___ true
--- @field SharedStringOverwrite boolean -- * **RISKY:** if the process is not finished aka crashed then none of the affected values will be available. SharedStrings can also be used for ValueTypes that aren't `SharedString`, this behavior is not documented anywhere but makes sense (Could create issues though, due to _potential_ ValueType mix-up, only works on certain types which are all base64 encoded so far). Reason: Allows for potential smaller file size (can also be bigger in some cases). ___Default:___ false
--- @field TreatUnionsAsParts boolean -- * **RISKY:** Converts all UnionOperations to Parts. Useful if your Executor isn't able to save (read) Unions, because otherwise they will be invisible. ___Default:___ false (except Solara)
--- @field FullUnionTerrainSupport boolean -- * Convenience profile for full-fidelity maps: enables `SetStreaming`, keeps hidden-property union/terrain reads enabled, disables `TreatUnionsAsParts`, and uses a longer terrain settle time unless overridden. ___Default:___ false
--- @field SetStreaming boolean -- * Before saving, force-loads an entire `StreamingEnabled` map into memory so saveinstance captures the WHOLE map instead of only the chunks near you. Pins loaded content (`ModelStreamingMode = Persistent`) so nothing streams back out, then sweeps a grid with `RequestStreamAroundAsync`. Can be slow and laggy on large maps. ___Aliases:___ `Streaming`. ___Default:___ false
--- @field StreamingAreaSize number -- * Side length (studs) of the square area swept around your starting position when `SetStreaming` is on. ___Default:___ 10000
--- @field StreamingRadius number -- * Per-request stream radius. Auto-uses the game's `StreamingTargetRadius` when readable. ___Default:___ 1024
--- @field StreamingTimeout number -- * Seconds to wait per `RequestStreamAroundAsync` request. ___Default:___ 20
--- @field StreamingConcurrency number|boolean -- * How many stream requests are kept in flight at once (higher = faster, more load). `false` = auto-scale to the grid size. ___Default:___ false (auto)
--- @field StreamingSlices number -- * Vertical layers swept per grid cell; raise for tall maps. ___Default:___ 2
--- @field StreamingMaxTime number|boolean -- * Overall seconds cap for the streaming sweep. It gives up on stuck/empty chunks (common on ocean-heavy maps where `RequestStreamAroundAsync` hangs) and proceeds. `false` = auto-scale to the grid size (bigger maps get a longer cap, 60s–15m). Set a number to force it. ___Default:___ false (auto)
--- @field StreamingChunkWait number -- * Max seconds to wait for one chunk to finish loading. The sweep waits until a region stops gaining parts (stability detection), capped here — dense regions load fully, empty ones return fast. ___Default:___ 12
--- @field StreamingSettleTime number -- * Seconds to wait after the streaming sweep for in-flight background terrain/loads to finish before saving. Also caps the post-sweep terrain-stabilization poll (waits until SmoothGrid stops growing) so terrain fills in instead of leaving floating islands. ___Default:___ 5
--- @field NeutralizeLighting boolean -- * Reset `Lighting` (ClockTime/Fog/Ambient), `Atmosphere`, post-effects (ColorCorrection/Bloom/Blur/SunRays/DoF) and clouds to clean midday right before saving, so the place opens BRIGHT instead of inheriting the game's dark/foggy/night atmosphere (the "all grey on the camera" look). `false` keeps the game's real lighting. ___Default:___ false
--- @field ExportObj boolean -- * Also write a world-space `.obj` of all MeshPart geometry next to the save. Geometry is recovered with `AssetService:CreateEditableMeshAsync`, which works even for PRIVATE game meshes that Studio can't re-download (those save as grey boxes). The `.obj` (with per-part vertex colors) opens in Blender or Studio's 3D importer. MeshParts can't be made to render inside the place file itself, so this is the only way to recover their visuals. Best paired with `SetStreaming` (load the whole map first). World-space baking duplicates reused meshes, so big maps produce large files. ___Default:___ false
--- @field Debug boolean -- * Writes a detailed run log to `saveinstance-debug.txt` in the executor workspace (executor, capabilities, options, streaming/prepass/decompile stats, save result). Share it for diagnosis. ___Default:___ false
--- @field CapabilityReport boolean -- * Writes a short compatibility report to `saveinstance-capabilities.txt` with executor support and likely save limitations. Useful when a save fails or looks incomplete. ___Default:___ false
--- @field DecompilePrepass boolean -- * **RISKY:** Before saving, decompiles every client script in parallel via an external API (`api.lua.expert`) and pre-fills the decompile cache, so the save's decompile step is near-instant. Big speedup on script-heavy games. Sends script bytecode to a third-party API; needs `getscriptbytecode` + an HTTP request function. ___Default:___ false
--- @field PrepassConcurrency number -- * Parallel decompile requests kept in flight during the prepass. ___Default:___ 24
--- @field PrepassRateGap number -- * Minimum seconds between decompile-API requests (lua.expert rejects unthrottled bursts). Lower = faster if the API allows. ___Default:___ 0.12
--- @field PrepassApiUrl string -- * Endpoint used by the decompile prepass. ___Default:___ "https://api.lua.expert/decompile"
--- @field PrepassMaxScripts number -- * Upper bound for `DecompilePrepass`. If the game has more than this many client scripts, the prepass is skipped and scripts decompile on-demand during the save instead. The gather is cheap, the workers are throttled (reading thousands of scripts' bytecode no longer bursts/crashes), and decompiles are API-rate-limited, so this just avoids an absurdly long prepass on games so large the prepass would risk destabilizing an already memory-heavy client (e.g. Grow a Garden 2 with 25k+ scripts); those fall back to the stable on-demand decompile. ___Default:___ 6000

--- @interface OptionsAliases
--- @within SynSaveInstance
--- Aliases for the [SynSaveInstance.CustomOptions table].
--- @field FilePath string -- FileName
--- @field IgnoreDefaultProperties string -- IgnoreDefaultProps
--- @field SaveNotCreatable string -- SaveNonCreatable
--- @field IsolatePlayers string -- SavePlayers
--- @field scriptcache string -- DecompileJobless
--- @field timeout string -- DecompileTimeout
--- @field IgnoreNotArchivable string -- IgnoreArchivable
--- @field RemovePlayerCharacters string -- INVERSE SavePlayerCharacters

--[=[
	@function saveinstance
	Saves instances with specified options. Example:
	```lua
	local Params = {
		RepoURL = "https://raw.githubusercontent.com/RealSlimShady2000/SaveInstance420Edition/main/",
		SSI = "saveinstance",
	}

	local synsaveinstance = loadstring(game:HttpGet(Params.RepoURL .. Params.SSI .. ".luau", true), Params.SSI)()

	local CustomOptions = { SafeMode = true, timeout = 15, SaveBytecode = true }

	synsaveinstance(CustomOptions)
	```
	@within SynSaveInstance
	@yields
	@param Parameter_1 variant<table, table<Instance>> -- Can either be [SynSaveInstance.CustomOptions table] or a filled with instances ({Instance}), (then it will be treated as ExtraInstances with an invalid mode and IsModel will be true).
	@param Parameter_2 table -- [OPTIONAL] If present, then Parameter_2 will be assumed to be [SynSaveInstance.CustomOptions table]. And then if the Parameter_1 is an Instance, then it will be assumed to be [SynSaveInstance.CustomOptions table].Object. If Parameter_1 is a table filled with instances ({Instance}), then it will be assumed to be [SynSaveInstance.CustomOptions table].ExtraInstances and IsModel will be true). This exists for sake compatibility with `saveinstance(game, {})`
]=]

-- Waits until the region around `point` stops gaining parts (i.e. it has finished streaming in), or
-- until maxWait. More thorough than a fixed wait: dense regions get the time they actually need,
-- while empty/ocean regions return quickly. Used per chunk so the sweep captures full content.
local function wait_region_loaded(point, radius, maxWait)
	local function count()
		local ok, parts = pcall(workspace.GetPartBoundsInRadius, workspace, point, radius)
		return (ok and parts) and #parts or 0
	end
	local last, stableFor, elapsed = count(), 0, 0
	local minObserve = 1.5 -- observe at least this long so we don't bail before loading even starts
	while elapsed < maxWait do
		task.wait(0.35)
		elapsed += 0.35
		local now = count()
		if now > last then
			last, stableFor = now, 0
		else
			stableFor += 0.35
		end
		if elapsed >= minObserve and stableFor >= 1 then -- no new parts for ~1s → region is loaded
			break
		end
	end
end

-- Force-loads an entire StreamingEnabled map into memory before saving, so saveinstance captures
-- the whole map instead of only the chunks near the player (inspired by centerepic's Streamer7).
-- It pins loaded content (ModelStreamingMode = Persistent) so it can't stream back out, then fans
-- out Player:RequestStreamAroundAsync over a grid with bounded concurrency. RequestStreamAroundAsync
-- yields until each region is loaded, which is far faster than the original teleport-then-poll loop.
-- Headless; calls report(done, total) for progress. Returns true, or false + reason if it can't run.
local function StreamEntireMap(O, report)
	if not workspace.StreamingEnabled then
		return false, "StreamingEnabled is off (nothing to stream)"
	end

	local LocalPlayer = service.Players.LocalPlayer
	if not LocalPlayer then
		return false, "No LocalPlayer (cannot stream)"
	end

	-- Keep loaded content resident while we sweep: LowMemory only streams out under real memory
	-- pressure (Opportunistic would evict chunks behind us even without pressure — that's the
	-- "content gained then lost" gaps). Note: ModelStreamingMode=Persistent below is largely
	-- server-authoritative and may be a no-op from a client thread, so StreamOutBehavior is the real
	-- client-side retention lever; we keep the Persistent pin as best-effort (executors run elevated).
	pcall(function()
		if sethiddenproperty then
			sethiddenproperty(workspace, "StreamOutBehavior", Enum.StreamOutBehavior.LowMemory)
		end
	end)
	local function pin(obj)
		if obj:IsA("Model") then
			pcall(function()
				obj.ModelStreamingMode = Enum.ModelStreamingMode.Persistent
			end)
		end
	end
	local pinConn = workspace.DescendantAdded:Connect(pin)
	do
		local pinned = 0
		for _, descendant in workspace:GetDescendants() do
			pin(descendant)
			pinned += 1
			if pinned % 4000 == 0 then
				task.wait() -- yield so pinning a huge workspace doesn't freeze the frame
			end
		end
	end

	-- Streaming radius (prefer the live target radius) and a grid over the configured area
	local radius = tonumber(O.StreamingRadius) or 1024
	pcall(function()
		radius = gethiddenproperty(workspace, "StreamingTargetRadius") or radius
	end)
	radius = math.max(tonumber(radius) or 1024, 64)

	local half = (tonumber(O.StreamingAreaSize) or 10000) / 2
	local step = radius -- one request per radius covers the area without gaps
	local slices = math.max(1, tonumber(O.StreamingSlices) or 2)
	local timeout = tonumber(O.StreamingTimeout) or 20

	local origin = Vector3.new(0, 50, 0)
	pcall(function() -- guarded so a GetPivot error can't leak the pinConn below / kill the save
		local character = LocalPlayer.Character
		if character then
			origin = character:GetPivot().Position
		end
	end)

	local points = {}
	for x = origin.X - half, origin.X + half, step do
		for z = origin.Z - half, origin.Z + half, step do
			for slice = 0, slices - 1 do
				local yOffset = (slice - math.floor((slices - 1) / 2)) * (radius * 0.8)
				points[#points + 1] = Vector3.new(x, origin.Y + yOffset, z)
				if #points % 2000 == 0 then
					task.wait() -- yield so a huge grid (small streaming radius) doesn't freeze the frame
				end
			end
		end
	end

	local total = #points
	if total == 0 then
		pinConn:Disconnect()
		return true
	end

	-- Fan out RequestStreamAroundAsync with bounded cooperative concurrency (each call yields
	-- until its region is loaded). Lua coroutines don't preempt mid-statement, so the shared
	-- counters below are safe without locks.
	-- Auto-scale concurrency + the time budget to the grid size when they aren't explicitly set:
	-- small maps finish fast, while big / ocean-heavy maps get more workers and a longer cap so the
	-- sweep isn't cut off before the real content loads. (Both are still overridable.)
	local concurrency = math.clamp(tonumber(O.StreamingConcurrency) or (math.floor(total / 40) + 8), 1, 24)
	-- MAX seconds to wait for ONE chunk to finish loading. We wait for the region to actually stop
	-- gaining parts (stability), capped here — so dense regions load fully while empty ones return fast.
	local chunkWait = math.clamp(tonumber(O.StreamingChunkWait) or 12, 2, math.max(timeout, 30))
	-- Auto budget ≈ worst case (every chunk hits the cap) at this concurrency, clamped 90s–20m. Stability
	-- detection finishes most chunks far sooner, so in practice the sweep ends well before this ceiling.
	local maxTime = tonumber(O.StreamingMaxTime) or math.clamp(math.ceil(total / concurrency) * chunkWait, 90, 1200)
	local streamStart = os.clock()
	local nextIndex, done, activeWorkers = 0, 0, concurrency
	dbg("[stream] grid:", total, "chunks | radius:", radius, "| auto concurrency:", concurrency, "| auto maxTime:", math.floor(maxTime) .. "s")

	for _ = 1, concurrency do
		task.spawn(function()
			pcall(function() -- guard: a throw here must NOT skip `activeWorkers -= 1`, or the wait below hangs forever
				while true do
					if os.clock() - streamStart > maxTime then
						return -- overall streaming time budget reached; proceed with whatever loaded
					end
					nextIndex += 1
					local point = points[nextIndex]
					if not point then
						return
					end
					-- Fire the stream request (fire-and-forget); the engine loads the region in the background.
					task.spawn(function()
						pcall(function()
							LocalPlayer:RequestStreamAroundAsync(point, timeout)
						end)
					end)
					-- Wait until the region stops gaining parts (loaded) or chunkWait: dense regions load fully,
					-- empty/ocean ones return fast. Avoids blocking on the often-hanging RequestStreamAroundAsync.
					wait_region_loaded(point, radius, chunkWait)
					done += 1
					if report then
						local elapsed = os.clock() - streamStart
						local eta -- estimate from the average rate so far, capped by the remaining time budget
						if done > 0 and elapsed > 0.5 then
							eta = math.max(0, math.min((total - done) * (elapsed / done), maxTime - elapsed))
						end
						report(done, total, eta)
					end
				end
			end)
			activeWorkers -= 1
		end)
	end

	-- Lightly drive the character across the grid so player-centric streaming reinforces the sweep
	task.spawn(function()
		local stride = math.max(1, math.floor(total / 24))
		local i = 1
		while activeWorkers > 0 do
			local point = points[i]
			if point then
				pcall(function()
					local char = LocalPlayer.Character
					if char then
						char:PivotTo(CFrame.new(point))
					end
				end)
			end
			i += stride
			if i > total then
				i = 1
			end
			task.wait(0.15)
		end
	end)

	while activeWorkers > 0 do
		task.wait(0.1)
	end

	-- Settle: let any still-in-flight background loads finish before we stop pinning + save.
	local settleTime = math.clamp(tonumber(O.StreamingSettleTime) or 3, 0, 60)
	if settleTime > 0 then
		dbg("[stream] settling", settleTime .. "s for in-flight loads")
		if report then
			report(done, total, settleTime)
		end
		task.wait(settleTime)
	end

	pinConn:Disconnect()
	pcall(function() -- return the character home
		local char = LocalPlayer.Character
		if char then
			char:PivotTo(CFrame.new(origin))
		end
	end)
	local streamElapsed = os.clock() - streamStart
	dbg("[stream] finished:", done, "/", total, "chunks in", string.format("%.1fs", streamElapsed), "| budget hit:", streamElapsed >= maxTime - 1)
	return true
end

-- Decompilation prepass: decompiles every client script in PARALLEL via an external API and
-- pre-fills the decompile cache (ldeccache, keyed by sha384(bytecode) exactly like ldecompile),
-- so the save's per-script decompile becomes an instant cache hit. Inspired by centerepic/ussiprepass.
-- Needs getscriptbytecode + an HTTP request function. Reports progress via report(done, total).
-- Rate gate: the external decompile API rejects (and briefly blocks) unthrottled bursts, so space
-- every request by at least `min_gap` seconds. Shared across the parallel prepass AND on-demand
-- calls via the module-level slot. (This is the fix for "decompiler didn't work".)
local _api_next_slot = 0
local _api_warned = false -- so we log the first lua.expert failure once (with the reason) instead of spamming
local function acquire_api_slot(min_gap)
	min_gap = min_gap or 0.12
	local now = os.clock()
	local slot = (_api_next_slot > now) and _api_next_slot or now
	_api_next_slot = slot + min_gap
	if slot > now then
		task.wait(slot - now)
	end
end

local function get_http_request()
	local Syn = type(syn) == "table" and syn or nil
	local Http = type(http) == "table" and http or nil
	return request or http_request or (Syn and Syn.request) or (Http and Http.request)
end

-- Decompiles bytecode via an external HTTP API (default lua.expert). Returns the source, or nil.
-- Shared by DecompilePrepass and by the auto-fallback decompiler (executors without their own).
local function decompile_via_api(bc, apiUrl, min_gap)
	local HttpRequest = get_http_request()
	if not (HttpRequest and base64encode) then
		return nil
	end
	apiUrl = apiUrl or "https://api.lua.expert/decompile"
	acquire_api_slot(min_gap) -- throttle so the API doesn't reject the burst
	-- Call request DIRECTLY (NOT inside task.spawn). Some executors' `request` misbehaves when called
	-- from a spawned thread; calling it directly matches the known-working reference. request has its
	-- own internal HTTP timeout, so we don't add one.
	local ok, res = pcall(HttpRequest, {
		Url = apiUrl,
		Method = "POST",
		Headers = { ["content-type"] = "application/json" },
		Body = service.HttpService:JSONEncode({ script = base64encode(bc) }),
	})
	if not ok or type(res) ~= "table" or res.StatusCode ~= 200 then
		_api_fail += 1
		local detail = ok and ("HTTP " .. tostring(res and res.StatusCode) .. " - " .. tostring(res and res.Body))
			or ("error: " .. tostring(res))
		_api_first_fail = _api_first_fail or detail
		if not _api_warned then -- log the FIRST failure (status/body) so the reason is visible, without spamming
			_api_warned = true
			warn("[saveinstance] lua.expert decompile request failed (" .. detail .. ")")
		end
		return nil
	end
	_api_ok += 1
	return res.Body
end

-- helpers for ResumeSave (persist ldeccache to disk so a later run can resume after a crash)
local resume_cache_dir = "saveinstance_resume_cache"
local function get_resume_cache_path(CacheDir)
	return (CacheDir or resume_cache_dir) .. "/resume_" .. tostring(game.PlaceId) .. ".json"
end
local function load_resume_cache(CacheTable, CacheDir)
	if not (readfile and isfile) then
		return
	end
	local path = get_resume_cache_path(CacheDir)
	local ok, data = pcall(readfile, path)
	if ok and data and data ~= "" then
		local ok2, decoded = pcall(function()
			return service.HttpService:JSONDecode(data)
		end)
		if ok2 and type(decoded) == "table" then
			for k, v in decoded do
				if type(v) == "string" and v ~= "" then
					CacheTable[k] = v
				end
			end
			print("[saveinstance] ResumeSave: loaded " .. (next(decoded) and "checkpoint" or "empty") .. " from disk")
		else
			print("[saveinstance] ResumeSave: existing checkpoint is corrupt, starting fresh")
		end
	end
end
local function flush_resume_cache(CacheTable, CacheDir)
	if not (writefile and makefolder) then
		return
	end
	local dir = CacheDir or resume_cache_dir
	if isfolder and not pcall(isfolder, dir) then
		pcall(makefolder, dir)
	end
	local path = get_resume_cache_path(dir)
	pcall(writefile, path, service.HttpService:JSONEncode(CacheTable))
end

local function RunDecompilePrepass(ldeccache, O, report)
	local HttpRequest = get_http_request()
	-- Prefer the executor's OWN decompiler if it has one (Volt now ships one) - no external API,
	-- no rate limit, no lua.expert. Fall back to lua.expert only when there is no native decompiler.
	local nativeDecompile = decompile or (getgenv and getgenv().decompile)
	if not (getscriptbytecode and sha384) then
		return false, "needs getscriptbytecode + a hash function"
	end
	if not nativeDecompile and not (HttpRequest and base64encode) then
		return false, "needs a native decompiler, or a supported HTTP request function for the lua.expert fallback"
	end

	local apiUrl = O.PrepassApiUrl or "https://api.lua.expert/decompile"
	local concurrency = math.max(1, tonumber(O.PrepassConcurrency) or 24)
	local rateGap = tonumber(O.PrepassRateGap) or 0.12

	-- Gather unique client scripts (skip server scripts we can't read; dedupe by bytecode hash)
	-- Safety cap: pre-decompiling every script in a HUGE game (e.g. Grow a Garden 2) OOM-crashes the
	-- client. If there are more than this many unique scripts, skip the prepass and let them decompile
	-- on-demand during the save (incremental, far lighter). Raise PrepassMaxScripts to override.
	local maxScripts = math.max(0, tonumber(O.PrepassMaxScripts) or 2500)
	local seen, jobs, overCap = {}, {}, false
	local function consider(o)
		local okIsA, isLSC = pcall(function()
			return o:IsA("LuaSourceContainer")
		end)
		if not (okIsA and isLSC) then
			return
		end
		if o:IsA("Script") then
			local rc = o.RunContext
			if rc == Enum.RunContext.Server or rc == Enum.RunContext.Legacy then
				return -- server scripts cannot be decompiled client-side
			end
		end
				-- getscriptbytecode + dedup HERE, serially on the main thread - exactly like the proven
		-- upstream ussiprepass. We keep only UNIQUE bytecode; running getscriptbytecode serially
		-- (NOT concurrently in the workers) is what keeps huge games (Grow a Garden 2) stable.
		local ok, bc = pcall(getscriptbytecode, o)
		if ok and type(bc) == "string" and bc ~= "" and not seen[bc] then
			seen[bc] = true
			local key = sha384(bc)
			if ldeccache[key] == nil then
				jobs[#jobs + 1] = { script = o, bc = (nativeDecompile and nil) or bc, key = key }
				if maxScripts > 0 and #jobs > maxScripts then
					overCap = true
				end
			end
		end
	end

	do
		local scanned = 0
		for _, o in game:GetDescendants() do
			if overCap then
				break
			end
			pcall(consider, o)
			scanned += 1
			if scanned % 500 == 0 then
				task.wait() -- yield; getscriptbytecode per script is heavy on big games
			end
		end
	end
	if not overCap and getloadedmodules then
		local ok, mods = pcall(getloadedmodules)
		if ok and type(mods) == "table" then
			for _, m in mods do
				if overCap then
					break
				end
				pcall(consider, m)
			end
		end
	end

	local total = #jobs
	if overCap then
		print(string.format(
			"[saveinstance] Prepass SKIPPED — this game has more than %d unique client scripts; pre-decompiling that many via the rate-limited API would take too long. Scripts will still decompile on-demand during the save. Raise PrepassMaxScripts to force it, or use noscripts = true for a structure-only save.",
			maxScripts
		))
		return false, "too many scripts (> " .. maxScripts .. "); using on-demand decompile instead"
	end
	print("[saveinstance] Prepass: gathered " .. total .. " unique client scripts to decompile")
	if total == 0 then
		return true
	end

	-- Bounded cooperative concurrency (Lua coroutines don't preempt mid-statement, so the
	-- shared counters are safe without locks).
	local nextIndex, done, active = 0, 0, math.min(concurrency, total)
	local prepassStart = os.clock()
	for _ = 1, active do
		task.spawn(function()
			pcall(function() -- guard: a throw here must NOT skip `active -= 1`, or the wait below hangs forever
				while true do
					nextIndex += 1
					local job = jobs[nextIndex]
					if not job then
						return
					end
					-- Workers ONLY do the HTTP decompile (getscriptbytecode + dedup already happened serially
					-- in the gather). No concurrent getscriptbytecode = stable on huge games.
					local body
						if nativeDecompile then
							-- the executor's own decompiler (Volt etc.) - no external API. Synchronous/CPU-heavy,
							-- so yield every few scripts so it does not freeze.
							local okd, r = pcall(nativeDecompile, job.script)
							if okd and type(r) == "string" then body = r end
							if nextIndex % 8 == 0 then task.wait() end
						else
							body = decompile_via_api(job.bc, apiUrl, rateGap)
						end
						if body and body ~= "" then
							ldeccache[job.key] = (string.gsub(body, "\0", "\\0"))
						end
						done += 1
						if O.ResumeSave then
							local interval = math.max(1, tonumber(O.ResumeCheckpointInterval) or 200)
							if done % interval == 0 then
								flush_resume_cache(ldeccache, resume_cache_dir)
							end
						end
						if report then
						local elapsed = os.clock() - prepassStart
						local eta
						if done > 0 and elapsed > 0.5 then
							eta = (total - done) * (elapsed / done)
						end
						report(done, total, eta)
					end
				end
			end)
			active -= 1
		end)
	end
	while active > 0 do
		task.wait(0.1)
	end
	dbg("[prepass] scripts:", total, "| decompiled OK:", _api_ok, "| failed:", _api_fail, "| in", string.format("%.1fs", os.clock() - prepassStart))
	if _api_first_fail then
		dbg("[prepass] first API failure:", _api_first_fail)
	end
	if O.ResumeSave then
		flush_resume_cache(ldeccache, resume_cache_dir)
	end
	return true
end

-- Reports executor capabilities that affect the save so the user knows up front WHY a save might
-- be incomplete (e.g. no gethiddenproperty => Unions/Terrain won't save). Warns to the console.
local function report_executor_support(O)
	local missing = {}
	if not gethiddenproperty then
		missing[#missing + 1] = "gethiddenproperty  ->  Unions, Terrain & other hidden/special properties will NOT save correctly"
	elseif O.IgnoreSpecialProperties then
		missing[#missing + 1] = "gethiddenproperty is DISABLED here (IgnoreSpecialProperties, for stability)  ->  Unions save as bounding-box Parts, not full mesh"
	end
	if not getscriptbytecode then
		missing[#missing + 1] = "getscriptbytecode  ->  script caching disabled"
	end
	if not decompile and not O.noscripts then
		if get_http_request() and base64encode and getscriptbytecode then
			print("[saveinstance] No executor decompiler - falling back to the lua.expert API to decompile scripts.")
		else
			missing[#missing + 1] = "decompile (no API fallback: needs supported HTTP request function)  ->  scripts will not be decompiled"
		end
	end
	if O.SetStreaming and not sethiddenproperty then
		missing[#missing + 1] = "sethiddenproperty  ->  SetStreaming can't fully pin streamed content (may be less reliable)"
	end
	if O.FullUnionTerrainSupport and not gethiddenproperty then
		missing[#missing + 1] = "FullUnionTerrainSupport needs gethiddenproperty for union mesh and terrain grids"
	end
	if O.DecompilePrepass and not get_http_request() then
		missing[#missing + 1] = "HTTP request function  ->  DecompilePrepass can't reach the decompile API (it will be skipped)"
	end
	if #missing == 0 then
		return
	end
	warn("[saveinstance] Executor '" .. (EXECUTOR_NAME ~= "" and EXECUTOR_NAME or "Unknown") .. "' - some capabilities are unavailable; the save may be incomplete:")
	for _, m in missing do
		warn("   - " .. m)
	end
	return missing
end

local function write_verify_report(O, save_ok, elapsed)
	local lines = {
		"SaveInstanceFetch save verification",
		"place_id: " .. tostring(game.PlaceId),
		"save_ok: " .. tostring(save_ok),
		"elapsed: " .. string.format("%.2fs", elapsed or 0),
		"",
		"scripts:",
		"- total encountered: " .. tostring(verify_stats.scripts_total),
		"- decompiled ok: " .. tostring(verify_stats.scripts_decompiled),
		"- failed/placeholder: " .. tostring(verify_stats.scripts_failed),
		"",
		"unions (PartOperation):",
		"- total encountered: " .. tostring(verify_stats.unions_total),
		"- mesh ok: " .. tostring(verify_stats.unions_mesh_ok),
		"- mesh missing: " .. tostring(verify_stats.unions_mesh_missing),
		"",
		"meshparts:",
		"- total encountered: " .. tostring(verify_stats.meshparts_total),
		"- meshid present: " .. tostring(verify_stats.meshparts_data_ok),
		"- meshid empty: " .. tostring(verify_stats.meshparts_data_missing),
		"",
		"instances_total: " .. tostring(verify_stats.instances_total),
	}

	if O.noscripts then
		lines[#lines + 1] = ""
		lines[#lines + 1] = "Note: noscripts=true — script counts reflect captured containers, not decompiled sources."
	end

	local wrote = writefile and pcall(writefile, "saveinstance-verify.txt", table.concat(lines, "\n"))
	print("[saveinstance] Verify report " .. (wrote and "written to saveinstance-verify.txt" or "could not be written"))
end

local function write_capability_report(O, missing, save_ok, elapsed, save_err)
	local lines = {
		"SaveInstanceFetch capability report",
		"executor: " .. (EXECUTOR_NAME ~= "" and EXECUTOR_NAME or "Unknown"),
		"place_id: " .. tostring(game.PlaceId),
		"client_version: " .. tostring(FULL_VERSION),
		"save_ok: " .. tostring(save_ok),
		"elapsed: " .. string.format("%.2fs", elapsed or 0),
		"",
		"capabilities:",
		"- gethiddenproperty: " .. tostring(gethiddenproperty ~= nil),
		"- sethiddenproperty: " .. tostring(sethiddenproperty ~= nil),
		"- getscriptbytecode: " .. tostring(getscriptbytecode ~= nil),
		"- decompile: " .. tostring(decompile ~= nil or GLOBAL_ENV.decompile ~= nil),
		"- http_request: " .. tostring(get_http_request() ~= nil),
		"- base64encode: " .. tostring(base64encode ~= nil),
		"- writefile: " .. tostring(writefile ~= nil),
		"- getloadedmodules: " .. tostring(getloadedmodules ~= nil),
		"- sha384: " .. tostring(sha384 ~= nil),
		"",
		"selected_options:",
		"- mode: " .. tostring(O.mode),
		"- noscripts: " .. tostring(O.noscripts),
		"- FullUnionTerrainSupport: " .. tostring(O.FullUnionTerrainSupport),
		"- SetStreaming: " .. tostring(O.SetStreaming),
		"- StreamingSettleTime: " .. tostring(O.StreamingSettleTime),
		"- IgnoreSpecialProperties: " .. tostring(O.IgnoreSpecialProperties),
		"- TreatUnionsAsParts: " .. tostring(O.TreatUnionsAsParts),
		"- DecompilePrepass: " .. tostring(O.DecompilePrepass),
		"- PrepassMaxScripts: " .. tostring(O.PrepassMaxScripts),
		"",
		"decompile_api:",
		"- ok: " .. tostring(_api_ok),
		"- failed: " .. tostring(_api_fail),
		"- first_failure: " .. tostring(_api_first_fail or ""),
		"",
		"limitations:",
	}

	missing = missing or {}
	if #missing == 0 then
		lines[#lines + 1] = "- none detected before save"
	else
		for _, item in missing do
			lines[#lines + 1] = "- " .. tostring(item)
		end
	end
	if not save_ok and save_err then
		lines[#lines + 1] = ""
		lines[#lines + 1] = "save_error:"
		lines[#lines + 1] = tostring(save_err)
	end

	local wrote = writefile and pcall(writefile, "saveinstance-capabilities.txt", table.concat(lines, "\n"))
	print("[saveinstance] Capability report " .. (wrote and "written to saveinstance-capabilities.txt" or "could not be written"))
end
-- NeutralizeLighting: reset Lighting to clean midday so the saved place opens BRIGHT instead of
-- inheriting the game's dark/foggy/night atmosphere (the "all grey on the camera" look). Modifies
-- the live Lighting right before the save captures it. Off by default (keeps faithful lighting).
local function neutralize_lighting()
	pcall(function()
		local L = service.Lighting
		L.ClockTime = 14
		L.Brightness = 3
		L.ExposureCompensation = 0
		L.EnvironmentDiffuseScale = 1
		L.EnvironmentSpecularScale = 1
		L.Ambient = Color3.fromRGB(70, 70, 70)
		L.OutdoorAmbient = Color3.fromRGB(140, 140, 140)
		L.ColorShift_Top = Color3.fromRGB(0, 0, 0)
		L.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
		L.FogStart = 0
		L.FogEnd = 1e6
		L.FogColor = Color3.fromRGB(192, 192, 192)
		L.GlobalShadows = true -- modern bright template look (raw default is false)
	end)
	-- Atmosphere (haze/glare) and post-effects are the main causes of the grey wash — clear them too.
	-- `:IsA("PostEffect")` catches every effect class (ColorCorrection/Bloom/Blur/SunRays/DoF AND the
	-- newer ColorGradingEffect), and any future ones, automatically.
	pcall(function()
		for _, e in ipairs(service.Lighting:GetDescendants()) do
			if e:IsA("Atmosphere") then
				e.Density = 0 -- 0.3 still leaves visible distance haze; 0 is fully clear
				e.Haze = 0
				e.Glare = 0
				e.Offset = 0
			elseif e:IsA("PostEffect") then
				e.Enabled = false
			end
		end
	end)
	-- post-effects can also be parented under the camera
	pcall(function()
		local cam = workspace.CurrentCamera
		if cam then
			for _, e in ipairs(cam:GetChildren()) do
				if e:IsA("PostEffect") then
					e.Enabled = false
				end
			end
		end
	end)
	pcall(function()
		local clouds = workspace.Terrain:FindFirstChildOfClass("Clouds")
		if clouds then
			clouds.Enabled = false -- more reliable than Density=0 (which can leave faint wisps)
		end
	end)
end

-- After the streaming sweep, terrain keeps loading in the background. Poll SmoothGrid's size until it
-- stops growing (or maxWait) so the re-capture grabs the FULL terrain instead of floating-island gaps.
local function wait_terrain_loaded(terrainGHP, maxWait)
	local lastSize, stable = -1, 0
	local deadline = os.clock() + maxWait
	while os.clock() < deadline do
		local ok, grid = pcall(terrainGHP, workspace.Terrain, "SmoothGrid")
		local sz = (ok and type(grid) == "string") and #grid or 0
		if sz > 0 and sz == lastSize then
			stable += 1
			if stable >= 2 then
				break
			end
		else
			stable = 0
		end
		lastSize = sz
		task.wait(1)
	end
	return lastSize
end

-- ExportObj: bake every MeshPart's geometry into a single world-space .obj (with per-part vertex
-- colors). The geometry is recovered via AssetService:CreateEditableMeshAsync, which works even for
-- the PRIVATE game meshes that Studio can't re-download (those render as grey boxes in a normal save).
-- This is the only way to recover the VISUAL geometry of private MeshParts — they can't go back into
-- a Studio place (MeshParts have no inline geometry field), but the .obj opens in Blender / Studio's
-- 3D importer. NOTE: world-space baking duplicates each reused mesh, so big maps make big files.
-- Pair with SetStreaming so the whole map is loaded first. Returns true, stats | false, reason.
local function export_map_obj(root, objName, report)
	local AS = service.AssetService or game:GetService("AssetService")
	local ContentLib = Content
	if not (AS and AS.CreateEditableMeshAsync and ContentLib and ContentLib.fromUri) then
		return false, "needs AssetService:CreateEditableMeshAsync + Content.fromUri (not available here)"
	end
	if not writefile then
		return false, "no writefile"
	end

	local parts = {}
	for _, d in ipairs(root:GetDescendants()) do
		if d:IsA("MeshPart") and d.MeshId ~= "" then
			parts[#parts + 1] = d
		end
	end
	local total = #parts
	if total == 0 then
		return false, "no MeshParts to export"
	end

	-- Unique-mesh geometry cache: each mesh's vertices/triangles read once, reused for every instance.
	local geoCache = {}
	local function getGeo(meshId)
		local cached = geoCache[meshId]
		if cached ~= nil then
			return cached
		end
		local ok, em = pcall(function()
			return AS:CreateEditableMeshAsync(ContentLib.fromUri(meshId))
		end)
		if not ok or not em then
			geoCache[meshId] = false
			return false
		end
		local idMap, pos = {}, {}
		local mn = Vector3.new(1e9, 1e9, 1e9)
		local mx = -mn
		for i, vid in ipairs(em:GetVertices()) do
			idMap[vid] = i
			local p = em:GetPosition(vid)
			pos[i] = p
			mn = Vector3.new(math.min(mn.X, p.X), math.min(mn.Y, p.Y), math.min(mn.Z, p.Z))
			mx = Vector3.new(math.max(mx.X, p.X), math.max(mx.Y, p.Y), math.max(mx.Z, p.Z))
		end
		local tris = {}
		for _, fid in ipairs(em:GetFaces()) do
			local fv = em:GetFaceVertices(fid) -- returns a {v1,v2,v3} table, NOT 3 return values
			if fv[1] and idMap[fv[1]] and idMap[fv[2]] and idMap[fv[3]] then
				tris[#tris + 1] = { idMap[fv[1]], idMap[fv[2]], idMap[fv[3]] }
			end
		end
		local g = { pos = pos, tris = tris, bbox = (mx - mn), center = (mn + mx) / 2 }
		geoCache[meshId] = g
		return g
	end

	local canAppend = appendfile ~= nil
	pcall(function()
		if delfile and isfile and isfile(objName) then
			delfile(objName)
		end
	end)
	writefile(objName, "# Roblox map export by USSI (Robloxscripts.com) -- world-space geometry + per-part vertex colors\n")
	local buf, vOff, written, skipped, processed = {}, 0, 0, 0, 0
	local function flush()
		if #buf == 0 then
			return
		end
		local s = table.concat(buf)
		if canAppend then
			appendfile(objName, s)
		else
			writefile(objName, ((isfile and isfile(objName)) and readfile(objName) or "") .. s)
		end
		buf = {}
	end

	for _, mp in ipairs(parts) do
		processed += 1
		local g = getGeo(mp.MeshId)
		if g and #g.pos > 0 and #g.tris > 0 then
			local bb, sz = g.bbox, mp.Size
			local sx = bb.X > 1e-5 and sz.X / bb.X or 1
			local sy = bb.Y > 1e-5 and sz.Y / bb.Y or 1
			local szc = bb.Z > 1e-5 and sz.Z / bb.Z or 1
			local cf, col = mp.CFrame, mp.Color
			buf[#buf + 1] = "o " .. ((mp.Name ~= "" and mp.Name) or "MeshPart") .. "_" .. written .. "\n"
			for _, p in ipairs(g.pos) do
				local lc = p - g.center
				local w = cf:PointToWorldSpace(Vector3.new(lc.X * sx, lc.Y * sy, lc.Z * szc))
				buf[#buf + 1] = string.format("v %.2f %.2f %.2f %.3f %.3f %.3f\n", w.X, w.Y, w.Z, col.R, col.G, col.B)
			end
			for _, tr in ipairs(g.tris) do
				buf[#buf + 1] = string.format("f %d %d %d\n", tr[1] + vOff, tr[2] + vOff, tr[3] + vOff)
			end
			vOff += #g.pos
			written += 1
		else
			skipped += 1
		end
		if processed % 300 == 0 then
			flush()
			if report then
				report(processed, total)
			end
			task.wait() -- yield so a big map doesn't freeze the client
		end
	end
	flush()
	if report then
		report(total, total)
	end
	local uniq = 0
	for _, v in pairs(geoCache) do
		if v then
			uniq += 1
		end
	end
	return true, { meshParts = total, written = written, skipped = skipped, uniqueMeshes = uniq, verts = vOff }
end

local function fmt_eta(sec)
	sec = math.max(0, math.ceil(sec))
	if sec >= 60 then
		return string.format("%dm %ds", math.floor(sec / 60), sec % 60)
	end
	return sec .. "s"
end

local function synsaveinstance(CustomOptions, CustomOptions2)
	if GLOBAL_ENV.USSI then
		return
	end
	GLOBAL_ENV.USSI = true
	do
		local setthreadidentity = global_container.setthreadidentity
		if setthreadidentity then
			pcall(setthreadidentity, 8) -- ? Arceus X Fix
		end
	end

	if not ClassList then
		local ok, result = pcall(FetchAPI)
		if ok and result then
			ClassList = result
		else
			warn('Failed to load the API Dump')
			warn(result)
			GLOBAL_ENV.USSI = nil
			return
		end
	end

	local currentparts, currentsize, totalsize, chunks = {}, 0, 0, table.create(1) -- ! currentparts holds string pieces that get concatenated once per chunk (avoids the O(n^2) growth of `..=` that caused "not enough memory")
	local savebuffer, savebuffer_size = {}, 1
	local header =
		'<!-- Saved by USSI modded by Sashenka --><roblox version="4">'

	local StatusText
	local ProgressFill -- * Progress-bar fill frame (created in the ShowStatus block below)
	local saved_count, total_count = 0, 0 -- * Instances serialized vs. estimated total, for the progress bar

	local OPTIONS = {
		mode = "optimized",
		noscripts = false,
		scriptcache = true,
		-- decomptype = "",
		timeout = 10,
		-- * New:
		__DEBUG_MODE = false,

		-- Binary = false, -- true in syn newer versions (false in our case because no binary support yet), Description: Saves everything in Binary Mode (rbxl/rbxm).
		Callback = false,
		--Clipboard/CopyToClipboard = false, -- Description: If set to true, the serialized data will be set to the clipboard, which can be later pasted into studio easily. Useful for saving models.
		-- MaxThreads = 3 -- Description: The number of decompilation threads that can run at once. More threads means it can decompile for scripts at a time.
		-- DisableCompression = false, --Description: Disables compression in the binary output

		DecompileJobless = false,
		DecompileIgnore = { -- * Clean these up (merged Old Syn and New Syn)
			-- "Chat",
			"TextChatService",
			ModuleScript = nil,
		},
		IgnoreDefaultPlayerScripts = EXECUTOR_NAME ~= "Wave" and true,
		SaveBytecode = false,

		IgnoreProperties = {},

		-- * Pattern-based and tag-based filtering (kept separate from IgnoreList so they don't conflict with its instance/class matching)
		IgnoreNamePatterns = {}, -- Array of Lua patterns/globs matched against instance.Name
		IgnoreTags = {},         -- Array of CollectionService tag names; instances carrying ANY of these tags are skipped
		SaveOnlyTags = {},       -- Array of CollectionService tag names; ONLY instances carrying at least ONE of these tags are saved (ignored when empty)

		IgnoreList = { "CoreGui", "CorePackages" },

		ExtraInstances = {},
		NilInstances = false,
		NilInstancesFixes = {},

		SaveCacheInterval = 0x1600 * 10,
		ShowStatus = true,
		SafeMode = false,
		ShutdownWhenDone = false,
		AntiIdle = true,
		Anonymous = false,
		ReadMe = true,
		FilePath = false,
		Object = false,
		IsModel = false,

		IgnoreDefaultProperties = true,
		IgnoreNotArchivable = true,
		IgnorePropertiesOfNotScriptsOnScriptsMode = false,
		IgnoreSpecialProperties = ArrayToDict({ "Fluxus", "Delta", "Solara" })[EXECUTOR_NAME] or false, -- ! Please submit more Executors that crash on gethiddenproperty (with this disabled basically)
		UseUGCValidationService = true, -- * When false, never use UGCValidationService as a hidden-property fallback (some executors flag/lack it). gethiddenproperty is still used.

		IsolateLocalPlayer = false, --  #service.StarterGui:GetChildren() == 0
		IsolateLocalPlayerCharacter = false,
		IsolatePlayers = false,
		IsolateStarterPlayer = false,
		RemovePlayerCharacters = true,

		SaveNotCreatable = false,
		NotCreatableFixes = {
			-- "CloudLocalizationTable",
			-- "InputObject",
			-- "LodDataEntity",
			-- "Path",
			-- "Translator",
			"", -- * FilteredSelection
			"AnimationTrack",
			"Player",
			"PlayerGui",
			"PlayerScripts",
			"PlayerMouse",
			"ScreenshotHud",
			"StudioData",
			"TextSource",
			"TouchTransmitter",
		},

		-- ! Risky

		IgnoreSharedStrings = EXECUTOR_NAME ~= "Wave" and true,
		SharedStringOverwrite = false,
		TreatUnionsAsParts = not gethiddenproperty or ArrayToDict({ "Fluxus", "Delta", "Solara" })[EXECUTOR_NAME] or false, -- * Executors that can't read union mesh (no/broken gethiddenproperty, or those where special props are ignored for stability) fall back to a visible Part (bounding box) instead of an invisible union. Executors with working gethiddenproperty save the full union mesh.
		FullUnionTerrainSupport = false, -- convenience profile: full union mesh + full streamed terrain capture
		AlternativeWritefile = not ArrayToDict({ "WRD", "Xeno", "Zorara" })[EXECUTOR_NAME],

		-- * Detailed debug log written to saveinstance-debug.txt in the executor workspace (share it for diagnosis)
		Debug = false,
		CapabilityReport = false, -- write saveinstance-capabilities.txt with executor support and likely limitations
		VerifySave = false,       -- write saveinstance-verify.txt comparing saved content to the live game (scripts decompiled, unions with mesh, MeshParts recovered)

		-- * ResumeSave: persist the in-memory decompile cache (ldeccache) to disk periodically
		-- so a later run can resume decompiling from where it left off if the game crashes mid-save.
		-- Only the decompile phase is resumed; the XML serialization phase is NOT resumed.
		ResumeSave = false,
		ResumeCacheDir = "saveinstance_resume_cache",
		ResumeCheckpointInterval = 200, -- flush cache to disk every N scripts (0 = only at the end)

		-- * Map streaming: force-load a StreamingEnabled map before saving so the WHOLE map is captured (not just chunks near you)
		SetStreaming = false,
		StreamingAreaSize = 10000, -- studs (square) swept around your start position
		StreamingRadius = 1024, -- per-request radius; auto-uses the game's StreamingTargetRadius when readable
		StreamingTimeout = 20, -- seconds per RequestStreamAroundAsync request
		StreamingConcurrency = false, -- requests in flight at once; false = AUTO-scale to the map/grid size
		StreamingSlices = 2, -- vertical layers (raise for tall maps)
		StreamingMaxTime = false, -- overall seconds cap for the streaming sweep; false = AUTO-scale to the grid size (bigger maps get a longer cap). Set a number to force it.
		StreamingChunkWait = 12, -- max seconds to wait for ONE chunk to finish loading; the sweep waits until a region stops gaining parts (stability), so it usually returns sooner. Raise for very dense maps.
		StreamingSettleTime = 5, -- seconds to wait after the sweep for in-flight background terrain/loads to finish before saving (also caps the post-sweep terrain-stabilization wait)

		-- * NeutralizeLighting: reset Lighting/Atmosphere/post-effects to clean midday so the saved place opens BRIGHT instead of dark/foggy/night (the "all grey on the camera" look). Default false keeps the game's real lighting.
		NeutralizeLighting = false,

		-- * ExportObj: also write a world-space .obj of all MeshPart geometry (recovered via EditableMesh) next to the save, so PRIVATE meshes that show as grey boxes in Studio can be recovered/viewed in Blender. Pair with SetStreaming. Large on big maps.
		ExportObj = false,

		-- * AssetManifest: collect every rbxassetid://, rbxasset://, and http:// URI referenced by Content/ContentId properties into a companion saveinstance-assets.txt list. Useful for recovering or cataloguing textures, sounds, meshes, decals, and animations alongside the save.
		AssetManifest = false,

			-- * Decompilation prepass: parallel-decompile all client scripts via an external API before saving (big speedup on script-heavy games). RISKY: sends script bytecode to a third-party API.
		DecompilePrepass = false,
		PrepassConcurrency = 24, -- parallel decompile requests kept in flight
		PrepassRateGap = 0.12, -- min seconds between API requests (lua.expert rejects unthrottled bursts). Lower = faster if the API allows.
		PrepassApiUrl = "https://api.lua.expert/decompile",
		PrepassMaxScripts = 6000, -- upper safety bound: only skip the prepass on truly enormous games (the gather is now cheap and decompiles are rate-limited, so this guards against an absurdly long run, not a crash). On-demand decompile takes over if exceeded.

		OptionsAliases = { -- You can't really modify these as a user
			Streaming = "SetStreaming",
			DecompileTimeout = "timeout",
			FileName = "FilePath",
			IgnoreArchivable = "IgnoreNotArchivable",
			IgnoreDefaultProps = "IgnoreDefaultProperties",
			SaveNonCreatable = "SaveNotCreatable",
			SavePlayers = "IsolatePlayers",
		},
	}

	local OPTIONS_lowercase, CustomOptions_valid = {}, {}
	for option_name in OPTIONS do
		local option_name_lowercase = string.lower(option_name)
		if OPTIONS_lowercase[option_name_lowercase] then
			warn("DUPLICATE OPTION", option_name)
		else
			OPTIONS_lowercase[option_name_lowercase] = option_name
		end
	end
	for option_alias, option_name in OPTIONS.OptionsAliases do
		local option_name_lowercase = string.lower(option_alias)
		if OPTIONS_lowercase[option_name_lowercase] then
			warn("DUPLICATE ALIAS", option_alias)
		else
			OPTIONS_lowercase[option_name_lowercase] = option_name
		end
	end

	do -- * Load Settings
		local function construct_NilinstanceFix(Name, ClassName, Separate)
			return function(instance, instancePropertyOverrides)
				local Exists

				if not Separate then
					Exists = OPTIONS.NilInstancesFixes[Name]
				end

				local Fix

				local DoesntExist = not Exists
				if DoesntExist then
					Fix = Instance.new(ClassName)
					if not Separate then
						OPTIONS.NilInstancesFixes[Name] = Fix
					end
					-- Fix.Name = Name

					instancePropertyOverrides[Fix] =
						{ __SaveSpecific = true, __Children = { instance }, Properties = { Name = Name } }
				else
					Fix = Exists
					table.insert(instancePropertyOverrides[Fix].__Children, instance)
				end

				-- InstancesOverrides[instance].Parent = AnimationController
				if DoesntExist then
					return Fix
				end
			end
		end

		-- TODO: Merge BaseWrap & Attachment & AdPortal fix (put all under MeshPart container)
		-- TODO?:
		-- DebuggerWatch DebuggerWatch must be a child of ScriptDebugger
		-- PluginAction Parent of PluginAction must be Plugin or PluginMenu that created it!
		OPTIONS.NilInstancesFixes.Animator = construct_NilinstanceFix(
			"Animator has to be placed under Humanoid or AnimationController",
			"AnimationController"
		)
		OPTIONS.NilInstancesFixes.AdPortal = construct_NilinstanceFix("AdPortal must be parented to a Part", "Part")
		OPTIONS.NilInstancesFixes.Attachment =
			construct_NilinstanceFix("Attachments must be parented to a BasePart or another Attachment", "Part") -- * Bones inherit from Attachments
		OPTIONS.NilInstancesFixes.BaseWrap =
			construct_NilinstanceFix("BaseWrap must be parented to a MeshPart", "MeshPart")
		OPTIONS.NilInstancesFixes.PackageLink =
			construct_NilinstanceFix("Package already has a PackageLink", "Folder", true)

		if CustomOptions2 and type(CustomOptions2) == "table" then
			local tmp = CustomOptions
			local Type = typeof(tmp)
			CustomOptions = CustomOptions2
			if Type == "Instance" then
				CustomOptions.Object = tmp
			elseif Type == "table" and typeof(tmp[1]) == "Instance" then
				CustomOptions.ExtraInstances = tmp
				OPTIONS.IsModel = true
			end
		end

		local Type = typeof(CustomOptions)

		if Type == "table" then
			if typeof(CustomOptions[1]) == "Instance" then
				OPTIONS.mode = "invalidmode"
				OPTIONS.ExtraInstances = CustomOptions
				OPTIONS.IsModel = true
				CustomOptions = {}
			else
				for key, value in CustomOptions do
					local option = OPTIONS_lowercase[string.lower(key)]

					if option then
						OPTIONS[option] = value
						CustomOptions_valid[option] = true
					end
				end
				local Decompile = CustomOptions.Decompile
				if Decompile ~= nil then
					OPTIONS.noscripts = not Decompile
				end
				local SavePlayerCharacters = CustomOptions.SavePlayerCharacters
				if SavePlayerCharacters ~= nil then
					OPTIONS.RemovePlayerCharacters = not SavePlayerCharacters
				end
				local RemovePlayers = CustomOptions.RemovePlayers
				if RemovePlayers ~= nil then
					OPTIONS.IsolatePlayers = not RemovePlayers
				end
			end
		elseif Type == "Instance" then
			OPTIONS.mode = "invalidmode"
			OPTIONS.Object = CustomOptions
			CustomOptions = {}
		else
			CustomOptions = {}
		end
	end

	do -- * Validate user-provided option types early so typos don't explode mid-save
		local option_type_checks = {
			-- booleans
			AssetManifest = "boolean",
			VerifySave = "boolean",
			ResumeSave = "boolean",
			Debug = "boolean",
			CapabilityReport = "boolean",
			SetStreaming = "boolean",
			NeutralizeLighting = "boolean",
			ExportObj = "boolean",
			DecompilePrepass = "boolean",
			noscripts = "boolean",
			FullUnionTerrainSupport = "boolean",
			IgnoreSpecialProperties = "boolean",
			TreatUnionsAsParts = "boolean",
			UseUGCValidationService = "boolean",
			ReadMe = "boolean",
			IsolateLocalPlayer = "boolean",
			IsolateLocalPlayerCharacter = "boolean",
			IsolateStarterPlayer = "boolean",
			IsolatePlayers = "boolean",
			SaveNotCreatable = "boolean",
			IgnoreDefaultProperties = "boolean",
			IgnoreNotArchivable = "boolean",
			SharedStringOverwrite = "boolean",
			AlternativeWritefile = "boolean",
			SafeMode = "boolean",
			IgnoreSharedStrings = "boolean",
			DecompileJobless = "boolean",
			scriptcache = "boolean",
			-- numbers
			timeout = "number",
			SaveCacheInterval = "number",
			PreloadAsync = "number",
			PrepassConcurrency = "number",
			PrepassRateGap = "number",
			PrepassMaxScripts = "number",
			StreamingAreaSize = "number",
			StreamingRadius = "number",
			StreamingTimeout = "number",
			StreamingSlices = "number",
			StreamingMaxTime = "number",
			StreamingChunkWait = "number",
			StreamingSettleTime = "number",
			ResumeCheckpointInterval = "number",
			-- strings
			mode = "string",
			FilePath = "string",
			PrepassApiUrl = "string",
			ResumeCacheDir = "string",
			CacheDir = "string",
			-- tables
			IgnoreList = "table",
			ExtraInstances = "table",
			IgnoreProperties = "table",
			IgnoreNamePatterns = "table",
			IgnoreTags = "table",
			SaveOnlyTags = "table",
			NilInstancesFixes = "table",
			NotCreatableFixes = "table",
			DecompileIgnore = "table",
		}

		for option_name in CustomOptions_valid do
			local expected = option_type_checks[option_name]
			if expected then
				local actual = typeof(OPTIONS[option_name])
				if actual ~= expected then
					warn(string.format(
						"[saveinstance] Invalid option type: %s expected %s, got %s",
						option_name,
						expected,
						actual
					))
				end
			end
		end
	end

	if OPTIONS.IgnoreDefaultPlayerScripts then
		-- TODO This is a bad workaround, find a better automatic way
		-- TODO Look into https://robloxapi.github.io/ref/class/LuaSourceContainer.html#member-isPlayerScript
		local DecompileIgnore = OPTIONS.DecompileIgnore

		local Path = service.StarterPlayer:FindFirstChild("StarterPlayerScripts")
		local Exclude = { ModuleScript = { "PlayerModule" }, LocalScript = { "RbxCharacterSounds" } }
		if Path then
			for _, className in Exclude do
				for _, name in className do
					local Found = Path:FindFirstChild(name)
					if Found then
						table.insert(DecompileIgnore, Found)
					end
				end
			end
		end
	end

	local InstancesOverrides = {}

	local DecompileIgnore, IgnoreList, IgnoreProperties, NotCreatableFixes =
		ArrayToDict(OPTIONS.DecompileIgnore, true),
	ArrayToDict(OPTIONS.IgnoreList, true),
	ArrayToDict(OPTIONS.IgnoreProperties),
	ArrayToDict(OPTIONS.NotCreatableFixes, true, "Folder")

	local __DEBUG_MODE = OPTIONS.__DEBUG_MODE

	if __DEBUG_MODE and type(__DEBUG_MODE) ~= "function" then
		__DEBUG_MODE = warn
	end

	-- Pattern & tag filtering setup
	local IgnoreNamePatterns = OPTIONS.IgnoreNamePatterns
	local IgnoreTagsDict, SaveOnlyTagsDict
	local hasIgnorePatterns = type(IgnoreNamePatterns) == "table" and #IgnoreNamePatterns > 0

	if type(OPTIONS.IgnoreTags) == "table" and #OPTIONS.IgnoreTags > 0 then
		IgnoreTagsDict = ArrayToDict(OPTIONS.IgnoreTags)
	end
	if type(OPTIONS.SaveOnlyTags) == "table" and #OPTIONS.SaveOnlyTags > 0 then
		SaveOnlyTagsDict = ArrayToDict(OPTIONS.SaveOnlyTags)
	end

	local CollectionService
	if IgnoreTagsDict or SaveOnlyTagsDict then
		CollectionService = service.CollectionService
	end

	local FilePath = OPTIONS.FilePath
	local SaveCacheInterval = OPTIONS.SaveCacheInterval
	local ToSaveInstance = OPTIONS.Object
	local IsModel = OPTIONS.IsModel

	if ToSaveInstance and CustomOptions.IsModel == nil then
		IsModel = true
	end

	local IgnoreDefaultProperties = OPTIONS.IgnoreDefaultProperties
	local IgnoreNotArchivable = not OPTIONS.IgnoreNotArchivable
	local IgnorePropertiesOfNotScriptsOnScriptsMode = OPTIONS.IgnorePropertiesOfNotScriptsOnScriptsMode

	if OPTIONS.FullUnionTerrainSupport then
		OPTIONS.SetStreaming = true
		OPTIONS.IgnoreSpecialProperties = false
		OPTIONS.TreatUnionsAsParts = false
		if CustomOptions_valid.StreamingSettleTime == nil then
			OPTIONS.StreamingSettleTime = math.max(tonumber(OPTIONS.StreamingSettleTime) or 5, 8)
		end
		if CustomOptions_valid.CapabilityReport == nil then
			OPTIONS.CapabilityReport = true
		end
		if CustomOptions_valid.VerifySave == nil then
			OPTIONS.VerifySave = true
		end
	end

	_api_ok, _api_fail, _api_first_fail, _api_warned = 0, 0, nil, false -- reset decompile counters/warn each run
	asset_manifest_enabled = OPTIONS.AssetManifest == true
	if asset_manifest_enabled then
		table.clear(asset_manifest_set)
	end
	verify_stats_enabled = OPTIONS.VerifySave == true
	if verify_stats_enabled then
		for k in verify_stats do
			verify_stats[k] = 0
		end
	end
	if OPTIONS.Debug then -- start the debug log (written to saveinstance-debug.txt at the end)
		debug_enabled = true
		table.clear(debug_log)
		debug_clock0 = os.clock()
		dbg("=== saveinstance debug log ===")
		dbg("executor:", EXECUTOR_NAME ~= "" and EXECUTOR_NAME or "Unknown", "| client:", CLIENT_VERSION, "| StreamingEnabled:", workspace.StreamingEnabled, "| place:", game.PlaceId)
		dbg("caps: gethiddenproperty=", gethiddenproperty ~= nil, "getscriptbytecode=", getscriptbytecode ~= nil, "decompile=", decompile ~= nil, "http_request=", get_http_request() ~= nil, "sethiddenproperty=", sethiddenproperty ~= nil, "base64encode=", base64encode ~= nil, "getloadedmodules=", getloadedmodules ~= nil, "sha384=", sha384 ~= nil)
		dbg("options: mode=", OPTIONS.mode, "noscripts=", OPTIONS.noscripts, "FullUnionTerrainSupport=", OPTIONS.FullUnionTerrainSupport, "SetStreaming=", OPTIONS.SetStreaming, "DecompilePrepass=", OPTIONS.DecompilePrepass, "IgnoreSpecialProperties=", OPTIONS.IgnoreSpecialProperties, "TreatUnionsAsParts=", OPTIONS.TreatUnionsAsParts, "UseUGCValidationService=", OPTIONS.UseUGCValidationService, "StreamingMaxTime=", OPTIONS.StreamingMaxTime, "StreamingConcurrency=", OPTIONS.StreamingConcurrency, "StreamingAreaSize=", OPTIONS.StreamingAreaSize, "StreamingSettleTime=", OPTIONS.StreamingSettleTime, "PrepassRateGap=", OPTIONS.PrepassRateGap)
	end

	local capability_missing = report_executor_support(OPTIONS) -- tell the user up front about any missing capabilities (must run before gethiddenproperty is possibly disabled below)

	local old_gethiddenproperty
	if OPTIONS.IgnoreSpecialProperties and gethiddenproperty then -- ? Only disable gethiddenproperty when the user opts into IgnoreSpecialProperties. Previously this read `if OPTIONS` (always truthy), which disabled gethiddenproperty for EVERY save and forced special props (e.g. Union MeshData2) through UGCValidationService, which can't read CSG blobs -> unions saved with no mesh.
		old_gethiddenproperty = gethiddenproperty
		gethiddenproperty = nil
	end

	local SaveNotCreatable = OPTIONS.SaveNotCreatable
	local TreatUnionsAsParts = OPTIONS.TreatUnionsAsParts

	local DecompileJobless = OPTIONS.DecompileJobless
	if DecompileJobless then
		OPTIONS.scriptcache = true
	end
	local ScriptCache = OPTIONS.scriptcache and getscriptbytecode

	local Timeout = OPTIONS.timeout

	local UseUGCValidationService = OPTIONS.UseUGCValidationService
	local IgnoreSharedStrings = OPTIONS.IgnoreSharedStrings
	local SharedStringOverwrite = OPTIONS.SharedStringOverwrite

	local ldeccache = GLOBAL_ENV.scriptcache

	local DecompileIgnoring, ToSaveList, ldecompile, placename, elapse_t, SaveNotCreatableWillBeEnabled, RecoveredScripts

	if OPTIONS.ReadMe then
		RecoveredScripts = {}
	end

		if ScriptCache and not ldeccache then
			ldeccache = {}
			GLOBAL_ENV.scriptcache = ldeccache
		end
			if OPTIONS.ResumeSave and ldeccache then
				resume_cache_dir = tostring(OPTIONS.ResumeCacheDir or "saveinstance_resume_cache")
				load_resume_cache(ldeccache, resume_cache_dir)
			end

	if ToSaveInstance == game then
		OPTIONS.mode = "full"
		ToSaveInstance = nil
		IsModel = nil
	end

	local function isLuaSourceContainer(instance)
		return instance:IsA("LuaSourceContainer")
	end

	do
		local mode = string.lower(OPTIONS.mode)
		local tmp = table.clone(OPTIONS.ExtraInstances)

		local PlaceName = game.PlaceId

		pcall(function()
			PlaceName ..= " " .. service.MarketplaceService:GetProductInfo(PlaceName).Name
		end)

		local function sanitizeFileName(str)
			return string.sub(string.gsub(string.gsub(string.gsub(str, "[^%w _]", ""), " +", " "), " +$", ""), 1, 240)
		end

		if ToSaveInstance then
			if mode == "optimized" then -- ! NOT supported with Model file mode
				mode = "full"
			end

			for _, key in
				{
					"IsolateLocalPlayer",
					"IsolateLocalPlayerCharacter",
					"IsolatePlayers",
					"IsolateStarterPlayer",
					"NilInstances",
				}
			do
				if CustomOptions_valid[key] == nil then
					OPTIONS[key] = false
				end
			end
		end

		if IsModel then
			placename = (
				FilePath
					or sanitizeFileName("model " .. PlaceName .. " " .. (ToSaveInstance or tmp[1] or game):GetFullName())
			) .. ".rbxmx"
		else
			placename = (FilePath or sanitizeFileName("place " .. PlaceName)) .. ".rbxlx"
		end

		if GLOBAL_ENV[placename] then
			-- warn("UniversalSynSaveInstance is already saving to this file")
			return
		end

		GLOBAL_ENV[placename] = true
		GLOBAL_ENV.USSI = nil
		if mode ~= "scripts" then
			IgnorePropertiesOfNotScriptsOnScriptsMode = nil
		end

		local TempRoot = ToSaveInstance or game

		if mode == "full" then
			if not ToSaveInstance then
				local Children = TempRoot:GetChildren()
				if 0 < #Children then
					local tmp_dict = ArrayToDict(tmp)
					for _, child in Children do
						if not tmp_dict[child] then
							table.insert(tmp, child)
						end
					end
				end
			end
		elseif mode == "optimized" then -- ! Incompatible with .rbxmx (Model file) mode
			-- if IsolatePlayers then
			-- 	table.insert(_list_0, "Players")
			-- end
			local tmp_dict = ArrayToDict(tmp)

			for _, serviceName in
				{
					"Workspace",
					"Players",
					"Lighting",
					"MaterialService",
					"ReplicatedFirst",
					"ReplicatedStorage",

					"ServerScriptService", -- LoadStringEnabled property (doesn't replicate); Just in case
					"ServerStorage", -- Just in case

					"StarterGui",
					"StarterPack",
					"StarterPlayer",
					"Teams",
					"SoundService",
					"Chat",
					"TextChatService",

					"LocalizationService", -- For LocalizationTables
					-- "InsertService",
					"JointsService",

					-- "TestService",
					-- "VoiceChatService",
				}
			do
				local _service = game:FindService(serviceName)
				if _service and not tmp_dict[_service] then
					table.insert(tmp, _service)
				end
			end
		elseif mode == "scripts" then
			-- TODO: Only save paths that lead to scripts (nothing else)
			-- Currently saves paths along with children of each tree
			local unique = {}
			for _, instance in TempRoot:GetDescendants() do
				if isLuaSourceContainer(instance) then
					local Parent = instance.Parent
					while Parent and Parent ~= TempRoot do
						instance = instance.Parent
						Parent = instance.Parent
					end
					if Parent then
						unique[instance] = true
					end
				end
			end
			for instance in unique do
				table.insert(tmp, instance)
			end
		end

		ToSaveList = tmp

		if ToSaveInstance then
			table.insert(ToSaveList, 1, ToSaveInstance)
		end
	end

	local IsolateLocalPlayer = OPTIONS.IsolateLocalPlayer
	local IsolateLocalPlayerCharacter = OPTIONS.IsolateLocalPlayerCharacter
	local IsolatePlayers = OPTIONS.IsolatePlayers
	local IsolateStarterPlayer = OPTIONS.IsolateStarterPlayer
	local NilInstances = OPTIONS.NilInstances

	if NilInstances and enablenilinstances then -- ? Solara fix
		enablenilinstances()
	end
	local function get_size_format()
		local Size

		-- local totalsize = #totalstr

		for i, unit in
			{
				"B",
				"KB",
				"MB",
				"GB",
				"TB",
			}
		do
			if totalsize < 0x400 ^ i then
				Size = math.floor(totalsize / (0x400 ^ (i - 1)) * 10) / 10 .. " " .. unit
				break
			end
		end

		return Size
	end

	local RunService = service.RunService
	local function wait_for_render()
		RunService.RenderStepped:Wait()
	end

	local Loading
	local function run_with_loading(text, keepStatus, waitForRender, taskFunction, ...)
		local previousStatus

		if StatusText then
			if keepStatus then
				previousStatus = StatusText.Text
			end
			Loading = task.spawn(function()
				local spinner_count = 0
				local chars = { "|", "/", "—", "\\" }
				local chars_size = #chars

				local function getLoadingText()
					spinner_count += 1

					if chars_size < spinner_count then
						spinner_count = 1
					end

					return chars[spinner_count]
				end

				text ..= " "

				while true do
					StatusText.Text = text .. getLoadingText()
					task.wait(0.25)
				end
			end)
			if waitForRender then
				wait_for_render()
			end
		end

		local result = { taskFunction(...) }

		if Loading then
			task.cancel(Loading)
			Loading = nil
			if previousStatus then
				StatusText.Text = previousStatus
			end
		end

		return unpack(result)
	end

	local function construct_TimeoutHandler(timeout, f, timeout_ret)
		return timeout < 0 and function(script)
			return pcall(f, script)
		end or function(script) -- TODO Ideally use ... (vararg) instead of `script` in case this is reused for something other than `decompile` & `getscriptbytecode`
			local thread = coroutine.running()
			local timeoutThread, isCancelled

			timeoutThread = task.delay(timeout, function()
				isCancelled = true -- TODO task.cancel
				coroutine.resume(thread, nil, timeout_ret)
			end)

			task.spawn(function()
				local ok, result = pcall(f, script)

				if isCancelled then
					return
				end

				task.cancel(timeoutThread)

				while coroutine.status(thread) ~= "suspended" do
					task.wait()
				end

				coroutine.resume(thread, ok, result)
			end)

			return coroutine.yield()
		end
	end

	local getbytecode
	if getscriptbytecode then
		getbytecode = construct_TimeoutHandler(3, getscriptbytecode) -- ? Solara fix
	end

	local SaveBytecode
	if OPTIONS.SaveBytecode and getscriptbytecode then
		SaveBytecode = function(script)
			local s, bytecode = getbytecode(script)

			if s and bytecode and bytecode ~= "" then
				return "-- Bytecode (Base64):\n-- " .. base64encode(bytecode) .. "\n\n"
			end
		end
	end

	do
		local Decompiler = decompile --OPTIONS.decomptype == "custom" and custom_decompiler or decompile or custom_decompiler

		-- if Decompiler == custom_decompiler then -- Cope
		-- 	local key = "DecompileTimeout"
		-- 	if CustomOptions[key] == nil then
		-- 		local Option = GetAlias(key)
		-- 		if CustomOptions[Option] == nil then
		-- 			Timeout = 1
		-- 		end
		-- 	end

		-- end

		if OPTIONS.noscripts then
			ldecompile = function()
				return "-- Decompiling is disabled"
			end
		elseif Decompiler then
			local decomp = construct_TimeoutHandler(Timeout, Decompiler, "Decompiler timed out")

			ldecompile = function(script)
				-- local name = scr.ClassName .. scr.Name
				local hashed_bytecode
				if ScriptCache then
					local s, bytecode = getbytecode(script)
					local cached

					if s then
						if not bytecode or bytecode == "" then
							return "-- The Script is Empty"
						end
						hashed_bytecode = sha384(bytecode)
						cached = ldeccache[hashed_bytecode]
					end

					if cached then
						if __DEBUG_MODE then
							__DEBUG_MODE("Found in Cache", script:GetFullName())
						end
						return cached
					end
				else
					if DecompileJobless then
						return "-- Not found in already decompiled ScriptCache"
					end

					task.wait() -- TODO Maybe remove?
				end

				local ok, result = run_with_loading("Decompiling " .. script.Name, true, nil, decomp, script)
				if not result then
					ok, result = false, "Empty Output"
				end

				local output
				if ok then
					result = string.gsub(result, "\0", "\\0") -- ? Some decompilers sadly output \0 which prevents files from opening
					output = result
				else
					output = "--[[ Failed to decompile. Reason:\n" .. (result or "") .. "\n]]"
				end

				if ScriptCache and hashed_bytecode then -- TODO there might(?) be an edgecase where it manages to decompile (built-in) even though getscriptbytecode failed, and the output won't get cached
					ldeccache[hashed_bytecode] = output -- ? Should we cache even if it timed out?
					if __DEBUG_MODE then
						__DEBUG_MODE("Cached", script:GetFullName())
					end
				end

				return output
			end
		else
			-- No executor decompiler -> fall back to the external API (lua.expert), using ldeccache.
			-- DecompilePrepass pre-fills the cache in parallel; otherwise each script is decompiled on
			-- demand here. This is what makes saves on decompiler-less executors (e.g. Volt) work.
			-- Call getscriptbytecode DIRECTLY (like the proven getgenv().decompile reference), NOT through
			-- the coroutine-timeout `getbytecode` wrapper — that wrapper returned failure in the save
			-- context on Volt, so the API was never reached.
			local canApi = get_http_request() and base64encode and getscriptbytecode and true or false
			print(string.format(
				"[saveinstance] lua.expert decompiler setup: canApi=%s (http=%s base64encode=%s getscriptbytecode=%s)",
				tostring(canApi),
				tostring(get_http_request() ~= nil),
				tostring(base64encode ~= nil),
				tostring(getscriptbytecode ~= nil)
			))
			local diagDone = false
			ldecompile = function(script)
				local ok, bytecode = pcall(getscriptbytecode, script)
				if not diagDone then -- one-time diagnostic: shows exactly why scripts may not decompile
					diagDone = true
					print(string.format(
						"[saveinstance] first on-demand decompile: getscriptbytecode ok=%s, bytecode=%s bytes, canApi=%s",
						tostring(ok),
						tostring((type(bytecode) == "string") and #bytecode or -1),
						tostring(canApi)
					))
				end
				if ok and type(bytecode) == "string" and bytecode ~= "" then
					local hashed = sha384(bytecode)
					local cached = ldeccache and ldeccache[hashed]
					if cached then
						return cached
					end
					if canApi then
						local body = decompile_via_api(bytecode, OPTIONS.PrepassApiUrl, OPTIONS.PrepassRateGap)
						if body and body ~= "" then
							body = (string.gsub(body, "\0", "\\0")) -- null bytes break the XML file
							if ldeccache then
								ldeccache[hashed] = body
							end
							return body
						end
					end
				end
				return "-- Your Executor does NOT have a Decompiler"
			end
		end
	end

	local function GetLocalPlayer()
		return service.Players.LocalPlayer
			or service.Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
			or service.Players.LocalPlayer
	end

	local function filterLinkedSource(str)
		local o, r = pcall(service.HttpService.JSONDecode, service.HttpService, str)
		if o and r.errors then
			return
		end
		return true
	end

	local function replaceClassName(instance, InstanceName, ClassName)
		local InstanceOverride
		if InstanceName ~= ClassName then -- TODO Compare against default instance instead (TouchTransmitter is called TouchInterest by default)
			InstanceOverride = InstancesOverrides[instance]
			if not InstanceOverride then
				InstanceOverride = { Properties = { Name = "[" .. ClassName .. "] " .. InstanceName } }
				InstancesOverrides[instance] = InstanceOverride
			end
		end
		return InstanceOverride
	end

	local function filterPropVal(result, propertyName, category) -- ? raw == nil thanks to SerializedDefaultAttributes; "can't get value" - due to WriteOnly tag;  "Invalid value for enum " - "StreamingPauseMode" (old games probably) Roexec
		return result == nil
			or result == "can't get value"
			or type(result) == "string"
			and (category == "Enum" or string_find(result, "Unable to get property " .. propertyName))
	end

	local IPM_ENABLED = math.huge <= CLIENT_VERSION and IgnoreDefaultProperties -- ! NOT ENABLED YET
	local IPM_DISABLED = not IPM_ENABLED
	local __BREAK = "__BREAK" .. service.HttpService:GenerateGUID(false)

	local function ReadProperty(instance, property, propertyName, special, category, optional)
		local raw = __BREAK

		local InstanceOverride = InstancesOverrides[instance]
		if InstanceOverride then
			local PropertiesOverride = InstanceOverride.Properties
			if PropertiesOverride then
				local PropertyOverride = PropertiesOverride[propertyName]
				if PropertyOverride ~= nil then
					return PropertyOverride
				end
			end
		end

		local CanRead = property.CanRead

		if CanRead == false then -- * Skips because we've checked this property before
			return __BREAK
		end

		if special then
			if gethiddenproperty then
				local ok, result = pcall(gethiddenproperty, instance, propertyName)

				if ok then
					raw = result
				end

				if filterPropVal(raw, propertyName, category) then
					-- * Skip next time we encounter this too perhaps (unless there's a chance for it to be readable on other instance, somehow)

					if result ~= nil or not optional then
						if __DEBUG_MODE then
							__DEBUG_MODE("Filtered", propertyName)
						end
						-- Property.Special = false
						property.CanRead = false
					end

					return __BREAK -- ? We skip it because even if we use "" it will just reset to default in most cases, unless it's a string tag for example (same as not being defined)
				end
			end
		else
			if CanRead then
				raw = instance[propertyName]
			else -- Assuming CanRead == nil (untested)
				local ok, result = pcall(index, instance, propertyName)

				if ok then
					raw = result
				elseif gethiddenproperty then -- ! Be careful with this 'and gethiddenproperty' logic
					ok, result = pcall(gethiddenproperty, instance, propertyName)

					if ok then
						raw = result

						property.Special = true
					end
				end

				property.CanRead = ok

				if not ok or filterPropVal(raw, propertyName, category) then
					return __BREAK
				end
			end
		end

		return raw
	end

	local function ReturnItem(className, instance)
		--return '<Item class="' .. className .. '" referent="' .. GetRef(instance) .. '"><Properties>' -- TODO: Ideally this shouldn't return <Properties> as well as the line below to close it IF  IgnorePropertiesOfNotScriptsOnScriptsMode is Enabled OR If all properties are default (reduces file size by at least 1.4%)
		local itemstring = '<Item class="' .. className .. '" referent="' .. GetRef(instance) .. '"><Properties>'
		if className == "Terrain" and realcheck then
			itemstring = itemstring ..
				'<BinaryString name="PhysicsGrid"><![CDATA[' .. getfenv().physicsgrid .. ']]></BinaryString>' ..
				'<BinaryString name="SmoothGrid"><![CDATA[' .. getfenv().smoothgrid .. ']]></BinaryString>'
		end
		return itemstring
	end

	local function ReturnProperty(tag, propertyName, value)
		return "<" .. tag .. ' name="' .. propertyName .. '">' .. value .. "</" .. tag .. ">"
	end

	local function ReturnValueAndTag(raw, valueType, descriptor)
		local value, tag = (descriptor or XML_Descriptors[valueType])(raw)

		return value, tag or valueType
	end

	local function InheritsFix(fixes, className, instance)
		local Fix = fixes[className]
		if Fix then
			return Fix
		elseif Fix == nil then
			for class_name, fix in fixes do
				if instance:IsA(class_name) then
					return fix
				end
			end
		end
	end

	local function GetInheritedProps(className)
		local prop_list = {}
		local layer = ClassList[className]
		while layer do
			local layer_props = layer.Properties
			table.move(layer_props, 1, #layer_props, #prop_list + 1, prop_list)

			-- for _, prop in layer.Properties do
			-- 	prop_list[prop_count] = prop -- ? table.clone is needed for case where .Default is modified
			-- 	prop_count += 1
			-- end

			layer = ClassList[layer.Superclass]
		end
		inherited_properties[className] = prop_list
		return prop_list
	end

	local CHUNK_LIMIT = 200 * 1024 * 1024 -- string length overflow prevention
	local last_save_yield = 0
	local function save_cache(final)
		local savestr = table.concat(savebuffer)
		currentparts[#currentparts + 1] = savestr -- * O(1) append; the chunk string is built once at the boundary below (was `currentstr ..= savestr`, which rebuilt the whole string each call -> O(n^2) + "not enough memory")

		-- writefile(placename, totalstr)
		-- appendfile(placename, savestr) -- * supposedly causes uneven amount of Tags (e.g. <Item> must be closed with </Item> but sometimes there's more of one than the other). While being under load, the function produces unexpected output?
		local savestr_len = #savestr
		totalsize += savestr_len
		currentsize += savestr_len

		table.clear(savebuffer)
		savebuffer_size = 1

		if CHUNK_LIMIT < currentsize or final then
			table.insert(chunks, { size = currentsize, str = table.concat(currentparts) }) -- * Build this chunk's string once from its pieces
			table.clear(currentparts)
			currentsize = 0
		end

		local now = os.clock()
		-- Yield to keep the client responsive, but time-gated: this used to wait a FULL render
		-- frame on EVERY ~55KB flush (thousands of frames on a big save = the main slowdown).
		-- Now we yield + refresh the UI only ~every 30ms of work, independent of flush count.
		if now - last_save_yield > 0.03 then
			last_save_yield = now
			if StatusText then
				StatusText.Text = "Saving instances: " .. saved_count .. " (" .. get_size_format() .. ")"
				if ProgressFill and total_count > 0 then
					ProgressFill.Size = UDim2.new(math.clamp(saved_count / total_count, 0, 0.99), 0, 1, 0)
				end
			end
			wait_for_render()
		end
	end

	local function save_specific(className, properties)
		local Ref = Instance.new(className) -- ! Assuming anything passed here is Creatable
		local Item = ReturnItem(Ref.ClassName, Ref)

		for propertyName, val in properties do
			local whitelisted, value, tag

			-- TODO: Improve all sort of overrides & exceptions in the code (code below is awful)
			if "Source" == propertyName then
				tag = "ProtectedString"
				value = XML_Descriptors.__PROTECTEDSTRING(val)
				whitelisted = true
			elseif "Name" == propertyName then
				whitelisted = true
				value, tag = ReturnValueAndTag(val, "string") -- * Doubt ValueType will change
			end

			if whitelisted then
				Item ..= ReturnProperty(tag, propertyName, value)
			end
		end
		Item ..= "</Properties>"
		return Item
	end

		local function save_hierarchy(hierarchy)
			for _, instance in hierarchy do
				if IgnoreNotArchivable and not instance.Archivable then
					continue
				end

				local SkipEntirely = IgnoreList[instance]
				if SkipEntirely then
					continue
				end

				local ClassName = instance.ClassName

				local InstanceName = instance.Name

				do
					local OnIgnoredList = IgnoreList[ClassName]
					if OnIgnoredList and (OnIgnoredList == true or OnIgnoredList[InstanceName]) then
						continue
					end
				end

				-- Pattern-based name matching (IgnoreNamePatterns)
				if hasIgnorePatterns then
					local skip = false
					for _, pattern in IgnoreNamePatterns do
						if type(pattern) == "string" and string_find(InstanceName, pattern) then
							skip = true
							break
						end
					end
					if skip then
						continue
					end
				end

				-- Tag-based filtering (needs flag because nested for loops)
				if IgnoreTagsDict or SaveOnlyTagsDict then
					local skip = false
					local tags = {}
					local ok, instanceTags = pcall(CollectionService.GetTags, CollectionService, instance)
					if ok then
						tags = instanceTags
					end
					if SaveOnlyTagsDict then
						local hasTag = false
						for _, t in tags do
							if SaveOnlyTagsDict[t] then
								hasTag = true
								break
							end
						end
						if not hasTag then
							skip = true
						end
					end
					if not skip and IgnoreTagsDict then
						for _, t in tags do
							if IgnoreTagsDict[t] then
								skip = true
								break
							end
						end
					end
					if skip then
						continue
					end
				end

			if not DecompileIgnoring then
				DecompileIgnoring = DecompileIgnore[instance]

				if DecompileIgnoring == nil then
					local DecompileIgnored = DecompileIgnore[ClassName]
					if DecompileIgnored then
						DecompileIgnoring = DecompileIgnored == true or DecompileIgnored[InstanceName]
					end
				end

				if DecompileIgnoring then
					DecompileIgnoring = instance
				elseif DecompileIgnoring == false then
					DecompileIgnoring = 1 -- Ignore one instance
				end
			end

			local InstanceOverride, ClassNameOverride, ClassTagOverride

			do
				local Fix = NotCreatableFixes[ClassName]

				if Fix then
					if SaveNotCreatable then
						ClassName, InstanceOverride = Fix, replaceClassName(instance, InstanceName, ClassName)
					else
						continue -- They won't show up in Studio anyway (Enable SaveNotCreatable if you wish to bypass this)
					end
				else -- ! Assuming nothing that is a PartOperation or inherits from it is in NotCreatableFixes
					if TreatUnionsAsParts and instance:IsA("PartOperation") then
						ClassName, InstanceOverride = "Part", replaceClassName(instance, InstanceName, ClassName)
						ClassNameOverride = "BasePart" -- * Mutual Superclass for PartOperation and Part; For properties only
					elseif not ClassList[ClassName] then -- ? API Dump is outdated then
						if __DEBUG_MODE then
							__DEBUG_MODE("Class not Found", ClassName)
						end

						ClassTagOverride = ClassName -- ? To at least retain .ClassName unlike the rest of the class-specific properties
						ClassName = "Folder" -- ? replaceClassName is not needed because of the ClassTagOverride
					end
				end
			end

				if not InstanceOverride then
					InstanceOverride = InstancesOverrides[instance]
				end

				-- VerifySave: count unions and MeshParts
				if verify_stats_enabled then
					verify_stats.instances_total += 1
					if instance:IsA("PartOperation") then
						verify_stats.unions_total += 1
						local ok_md, md = pcall(gethiddenproperty, instance, "MeshData2")
						if ok_md and md and md ~= "" then
							verify_stats.unions_mesh_ok += 1
						else
							verify_stats.unions_mesh_missing += 1
						end
					elseif instance:IsA("MeshPart") then
						verify_stats.meshparts_total += 1
						local ok_mh, mh = pcall(function() return instance.MeshId end)
						if ok_mh and mh and mh ~= "" then
							verify_stats.meshparts_data_ok += 1
						else
							verify_stats.meshparts_data_missing += 1
						end
					end
				end

				-- ? The reason we only save .Name (and few other props in save_specific) is because
			-- ? we can be sure this is a custom container (ex. NilInstancesFixes)
			-- ? However, in case of NotCreatableFixes, the Instance might have Tags, Attributes etc. that can potentially be saved (even though it's a Folder)
			if InstanceOverride and InstanceOverride.__SaveSpecific then
				savebuffer[savebuffer_size] = save_specific(ClassName, InstanceOverride.Properties) -- ! Assuming anything that has __SaveSpecific will have .Properties
				savebuffer_size += 1
			else
				-- local Properties =
				savebuffer[savebuffer_size] = ReturnItem(ClassTagOverride or ClassName, instance) -- TODO: Ideally this shouldn't return <Properties> as well as the line below to close it IF  IgnorePropertiesOfNotScriptsOnScriptsMode is ENABLED
				savebuffer_size += 1
				saved_count += 1 -- * Progress bar: one more instance serialized
				if not (IgnorePropertiesOfNotScriptsOnScriptsMode and not isLuaSourceContainer(instance)) then
					local default_instance, new_def_inst

					if IPM_DISABLED and IgnoreDefaultProperties then
						default_instance = default_instances[ClassName]
						if not default_instance then
							local ClassTags = ClassList[ClassName].Tags
							if not (ClassTags and ClassTags.NotCreatable) then -- __api_dump_class_not_creatable__ also indicates this
								-- ! NotCreatableFixes are exceptions to the check above meaning if we don't keep the NotCreatableFixes updated then Instance.new below might start erroring in the future potentially; HOWEVER IsPropertyModified solves this issue and no updates are really needed as NotCreatableFixes is up-to-date as of 664 (which is when IPM was enabled)
								-- pcall: a stale/incomplete API Dump can list a class as creatable when it actually
								-- isn't (e.g. AnalyticsService), which would otherwise throw and abort the save.
								local ok_new
								ok_new, new_def_inst = pcall(Instance.new, ClassName)
								if ok_new then
									default_instance = {}
									default_instances[ClassName] = default_instance
								else
									new_def_inst = nil
									default_instance = nil
									if __DEBUG_MODE then
										__DEBUG_MODE("Unable to create default Instance (pcall failed)", ClassName)
									end
								end
							elseif __DEBUG_MODE then
								__DEBUG_MODE("Unable to create default Instance", ClassName)
							end
						end
					end
					local proplist
					do
						local class = ClassNameOverride or ClassName
						proplist = inherited_properties[class]
						if not proplist then
							proplist = GetInheritedProps(class)
							inherited_properties[class] = proplist
						end
					end
					for _, Property in proplist do
						local PropertyName = Property.Name

						if IgnoreProperties[PropertyName] then
							continue
						end

						local ValueType = Property.ValueType

						if IgnoreSharedStrings and ValueType == "SharedString" and not KeepSharedStrings[PropertyName] then -- ? Keep union geometry (MeshData2/ChildData2); More info in Options
							continue
						end

						local Special = Property.Special

						-- if -- ! Not enabled yet (580), uncomment asap once enabled

						-- 	not Special -- TODO: .Special is checked more than once (because it might be updated during ReadProperty)
						-- 	and not (PropertyName == "Source" and isLuaSourceContainer(instance))
						-- then -- ? Could be not just "Source" in the future
						-- 	if not instance:IsPropertyModified(PropertyName) then
						-- 		continue
						-- 	end
						-- end
						local Category, Optional = Property.Category, Property.Optional

						local raw = ReadProperty(instance, Property, PropertyName, Special, Category, Optional)

						if raw == __BREAK then -- ! Assuming __BREAK is always returned when there's a failure to read a property
							local ok, result
							if UseUGCValidationService then -- * Toggle: when off, never touch UGCValidationService (some executors flag/lack it)
								ok, result = pcall(gethiddenproperty_fallback, instance, PropertyName) -- * This helps in reading: Vector3int16, OptionalCoordinateFrame DataTypes. It also acts as an almost entire fallback for gethiddenproperty in case it is missing
							end

							if result == nil and not Optional then
								ok = nil
							end

							if ok then
								raw = result
							else
								local Fallback = Property.Fallback

								if Fallback then
									ok, result = pcall(Fallback, instance)

									if ok then
										raw = result
									else
										if __DEBUG_MODE then
											-- TODO Maybe remove the fix during runtime if it fails to avoid re-trying
											__DEBUG_MODE("Fix Failed", PropertyName)
										end
										continue
									end
								else
									continue
								end
							end
						end

						if SharedStringOverwrite and ValueType == "BinaryString" then -- TODO: Convert this to table if more types are added
							ValueType = "SharedString"
						end

						-- Special = Property.Special -- ? Read TODO below (must be updated if it's used frequently afterwards)

						if
							default_instance
							and not Property.Special -- TODO: .Special is checked more than once (because it might be updated during ReadProperty)
							and not (PropertyName == "Source" and isLuaSourceContainer(instance))
						then -- ? Could be not just "Source" in the future
							if new_def_inst then
								default_instance[PropertyName] = index(new_def_inst, PropertyName)
							end
							if default_instance[PropertyName] == raw then
								continue
							end
						end

							-- AssetManifest: capture asset URIs from Content/ContentId and string properties
							if asset_manifest_enabled then
								if ValueType == "Content" or ValueType == "ContentId" then
									local uri = ""
									if type(raw) == "string" then
										uri = raw
									else
										local ok, got = pcall(function()
											return (raw.SourceType == Enum.ContentSourceType.Uri) and raw.Uri or ""
										end)
										uri = (ok and got) or ""
									end
									if uri ~= "" then
										asset_manifest_set[uri] = { Instance = instance:GetFullName(), Property = PropertyName }
									end
								elseif ValueType == "string" and type(raw) == "string" then
									if string_find(raw, "rbxassetid://") or string_find(raw, "rbxasset://") or string_find(raw, "http://") or string_find(raw, "https://") then
										asset_manifest_set[raw] = { Instance = instance:GetFullName(), Property = PropertyName }
									end
								end
							end

							-- Serialization start

							local tag, value
						if Category == "Class" then
							tag = "Ref"
							if typeof(raw) == "Instance" then -- only serialize a Ref if the value is actually an Instance (a weird non-Instance value would otherwise error on raw.ClassName below)
								if SaveNotCreatableWillBeEnabled then
									local Fix = NotCreatableFixes[raw.ClassName]
									if
										Fix
										and (
											PropertyName == "PlayerToHideFrom"
												or ValueType ~= "Instance" and ValueType ~= Fix
										)
									then
										-- * To avoid errors
										continue
									end
								end

								value = GetRef(raw)
							else
								value = "null"
							end
						elseif Category == "Enum" then -- ! We do this order (Enums before Descriptors) specifically because Font Enum might get a Font Descriptor despite having Enum Category, unlike Font DataType which that Descriptor is meant for
							value, tag = XML_Descriptors.__ENUM(raw)
						else
							local Descriptor = XML_Descriptors[ValueType]

							if Descriptor then
								value, tag = ReturnValueAndTag(raw, ValueType, Descriptor)
							elseif "ProtectedString" == ValueType then -- TODO: Try fitting this inside Descriptors
								tag = ValueType

								if PropertyName == "Source" then
									if DecompileIgnoring then -- ? Should this really prevent extraction of the original source if present ?
										if DecompileIgnoring == 1 then
											DecompileIgnoring = nil
										end
										value = "-- Ignored"
									else
										local should_decompile = true
										local LinkedSource
										local LinkedSource_Url = instance.LinkedSource -- ! Assuming every Class that has ProtectedString Source property also has a LinkedSource property
										local hasLinkedSource = LinkedSource_Url ~= ""
										local LinkedSource_type
										if hasLinkedSource then
											local Path = instance:GetFullName()
											if RecoveredScripts then
												table.insert(RecoveredScripts, Path)
											end

											LinkedSource = string.match(LinkedSource_Url, "%w+$") -- TODO: No sure if this pattern matches all possible cases. Example is: 'rbxassetid://0&hash=cd73dd2fe5e5013137231c227da3167e'
											if LinkedSource then
												if ScriptCache then
													local cached = ldeccache[LinkedSource]

													if cached then
														value = cached
														should_decompile = nil
													end
												end
												if should_decompile then
													if DecompileJobless then
														value = "-- Not found in LinkedSource ScriptCache"
														should_decompile = nil
													end

													LinkedSource_type = string.find(LinkedSource, "%a") and "hash"
														or "id"

													local asset = LinkedSource_type .. "=" .. LinkedSource

													local ok, source = pcall(function()
														-- Credits @halffalse
														return game:HttpGet(
															"https://assetdelivery.roproxy.com/v1/asset/?" .. asset
														)
													end)

													if ok and filterLinkedSource(source) then
														if ScriptCache then
															ldeccache[LinkedSource] = source
														end

														value = source

														should_decompile = nil
													end
												end
											else --if __DEBUG_MODE then -- * We print this anyway because very important
												warn(
													"FAILED TO EXTRACT ORIGINAL SCRIPT SOURCE (OPEN A GITHUB ISSUE): ",
													instance:GetFullName(),
													LinkedSource_Url
												)
											end
										end

										if should_decompile then
											local isLocalScript = instance:IsA("LocalScript")
											if
												isLocalScript and instance.RunContext == Enum.RunContext.Server
												or not isLocalScript
												and instance:IsA("Script")
												and instance.RunContext ~= Enum.RunContext.Client
											then
												value = "-- [FilteringEnabled] Server Scripts are IMPOSSIBLE to save" -- TODO: Could be not just server scripts in the future
											else
									value = ldecompile(instance)
											-- VerifySave: count script decompile results
											if verify_stats_enabled then
												verify_stats.scripts_total += 1
												local isPl = value and type(value) == "string" and not string_find(value, "-- [FilteringEnabled]") and not string_find(value, "-- Not found") and not string_find(value, "-- Ignored") and not string_find(value, "-- Server Script")
												local looksLikeErr = isPl and (string_find(value, "error") or string_find(value, "failed") or string_find(value, "FAIL"))
												if isPl and not looksLikeErr then
													verify_stats.scripts_decompiled += 1
												else
													verify_stats.scripts_failed += 1
												end
											end
											if SaveBytecode then
													local output = SaveBytecode(instance)
													if output then
														value = output .. value
													end
												end
											end
										end

										value = "-- Saved by USSI modded by Sashenka\n"
											.. "\n"
											.. (hasLinkedSource and "-- Original Source: https://assetdelivery.roblox.com/v1/asset/?" .. (LinkedSource_type or "id") .. "=" .. (LinkedSource or LinkedSource_Url) .. "\n\n" or "")
											.. value
									end
								end
								value = XML_Descriptors.__PROTECTEDSTRING(value)
							else
								--OptionalCoordinateFrame and so on, we make it dynamic

								if Optional then
									Descriptor = XML_Descriptors[Optional]

									if Descriptor then
										if raw == nil then
											-- * It can be empty, because it's optional
											-- ? Though why even save it if it's empty considering it's optional
											continue
											-- value, tag = "", ValueType
										else
											value, tag = ReturnValueAndTag(raw, ValueType, Descriptor)
										end
									end
								end
							end
						end

						if tag then
							savebuffer[savebuffer_size] = ReturnProperty(tag, PropertyName, value)
							savebuffer_size += 1
						else --if __DEBUG_MODE then -- * We print this anyway because very important
							warn("UNSUPPORTED TYPE (OPEN A GITHUB ISSUE): ", ValueType, ClassName, PropertyName)
						end
					end
				end
				savebuffer[savebuffer_size] = "</Properties>"
				savebuffer_size += 1

				if SaveCacheInterval < savebuffer_size then
					save_cache()
				end
			end

			if SkipEntirely ~= false then -- ? We save instance without it's descendants in this case (== false)
				local Children = InstanceOverride and InstanceOverride.__Children or instance:GetChildren()

				if #Children ~= 0 then
					save_hierarchy(Children)
				end
			end

			if DecompileIgnoring and DecompileIgnoring == instance then
				DecompileIgnoring = nil
			end

			savebuffer[savebuffer_size] = "</Item>"
			savebuffer_size += 1
		end
	end

	local function save_extra(name, hierarchy, customClassName, source)
		savebuffer[savebuffer_size] = save_specific((customClassName or "Folder"), { Name = name, Source = source })
		savebuffer_size += 1
		if hierarchy then
			save_hierarchy(hierarchy)
		end
		savebuffer[savebuffer_size] = "</Item>"
		savebuffer_size += 1
	end

	local function save_game()
		do
			if IsModel then
				--[[
			-- ? Roblox encodes the following additional attributes. These are not required. Moreover, any defined schemas are ignored, and not required for a file to be valid: xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd"
			Also http can be converted to https but not sure if Roblox cares
			-- ? <External>null</External><External>nil</External>  - <External> is a legacy concept that is no longer used.
		]]
				header ..= '<Meta name="ExplicitAutoJoints">true</Meta>'
			end

			writefile(placename, header) -- TODO This is sort of useless if writefile will be used at the end (like if AlternativeWritefile and Callback are unused)
		end

		-- TODO Find a better solution for this
		SaveNotCreatableWillBeEnabled = SaveNotCreatable
			or (IsolateLocalPlayer or IsolateLocalPlayerCharacter) and IsolateLocalPlayer
			or IsolatePlayers
			or NilInstances and global_container.getnilinstances -- ! Make sure this accurately reflects everything below

		save_hierarchy(ToSaveList)

		if IsolateLocalPlayer or IsolateLocalPlayerCharacter then
			local LocalPlayer = service.Players.LocalPlayer
			if LocalPlayer then
				if IsolateLocalPlayer then
					SaveNotCreatable = true
					save_extra("LocalPlayer", LocalPlayer:GetChildren())
				end
				if IsolateLocalPlayerCharacter then
					local LocalPlayerCharacter = LocalPlayer.Character
					if LocalPlayerCharacter then
						save_extra("LocalPlayer Character", LocalPlayerCharacter:GetChildren())
					end
				end
			end
		end

		if IsolateStarterPlayer then
			-- SaveNotCreatable = true -- TODO: Enable if StarterPlayerScripts or StarterCharacterScripts stop showing up in isolated folder in Studio
			save_extra("StarterPlayer", service.StarterPlayer:GetChildren())
		end

		if IsolatePlayers then
			SaveNotCreatable = true
			save_extra("Players", service.Players:GetChildren())
		end

		if NilInstances and global_container.getnilinstances then
			local nil_instances, nil_instances_size = {}, 1

			local NilInstancesFixes = OPTIONS.NilInstancesFixes

			for _, instance in global_container.getnilinstances() do
				if instance == game then
					instance = nil
					-- break
				else
					local ClassName = instance.ClassName

					local Fix = InheritsFix(NilInstancesFixes, ClassName, instance)

					if Fix then
						instance = Fix(instance, InstancesOverrides)
						-- continue
					end

					local Class = ClassList[ClassName]
					if Class then
						local ClassTags = Class.Tags
						if ClassTags and ClassTags.Service then -- For CSGDictionaryService, NonReplicatedCSGDictionaryService, LogService, ProximityPromptService, TestService & more
							-- instance.Parent = game
							instance = nil
							-- continue
						end
					end
				end
				if instance then
					nil_instances[nil_instances_size] = instance
					nil_instances_size += 1
				end
			end
			SaveNotCreatable = true
			save_extra("Nil Instances", nil_instances)
		end

		if OPTIONS.ReadMe then
			save_extra(
				"README",
				nil,
				"Script",
				"--[[\n"
					.. (#RecoveredScripts ~= 0 and "\t\tIMPORTANT: Original Source of these Scripts was Recovered: " .. service.HttpService:JSONEncode(
						RecoveredScripts
						) .. "\n" or "")
					.. [[
		Thank you for using USSI modded by Sashenka.

		If you didn't save in Binary (rbxl) - it's recommended to save the game right away to take advantage of the binary format & to preserve values of certain properties if you used IgnoreDefaultProperties setting (as they might change in the future).
		You can do that by going to FILE -> Save to File As -> Make sure File Name ends with .rbxl -> Save

		ServerStorage, ServerScriptService and Server Scripts are IMPOSSIBLE to save because of FilteringEnabled.

		If your player cannot spawn into the game, please move the scripts in StarterPlayer somewhere else. Then run `game:GetService("Players").CharacterAutoLoads = true`.
		And use "Play Here" to start game instead of "Play" to spawn your Character where your Camera currently is.

		If the chat system does not work, please use the explorer and delete everything inside the TextChatService/Chat service(s). 
		Or run `game:GetService("Chat"):ClearAllChildren() game:GetService("TextChatService"):ClearAllChildren()`
				
		If Union and MeshPart collisions don't work, run the script below in the Studio Command Bar:
				
				
		local C = game:GetService("CoreGui")
		local D = Enum.CollisionFidelity.Default
				
		for _, v in game:GetDescendants() do
			if v:IsA("TriangleMeshPart") and not v:IsDescendantOf(C) then
				v.CollisionFidelity = D
			end
		end
		print("Done")
				
		If you can't move the Camera, run this script in the Studio Command Bar:
			
		workspace.CurrentCamera.CameraType = Enum.CameraType.Fixed
		
		Or Destroy the Camera.

		This file was generated with the following settings:
		]]
					.. service.HttpService:JSONEncode(OPTIONS)
					.. "\n\n\t\tElapsed time: "
					.. os.clock() - elapse_t
					.. " PlaceId: "
					.. game.PlaceId
					.. " PlaceVersion: "
					.. game.PlaceVersion
					.. " Client Version: "
					.. version()
					.. " Executor: "
					.. (identify_executor and table.concat({ identify_executor() }, " ") or "Unknown")
					.. "\n]]"
			)
		end
		do
			local tmp = { "<SharedStrings>" }
			for identifier, value in SharedStrings do
				table.insert(tmp, '<SharedString md5="' .. identifier .. '">' .. value .. "</SharedString>")
			end

			if 1 < #tmp then -- TODO: This sucks so much because we try to iterate a table just to check this (check above)
				savebuffer[savebuffer_size] = table.concat(tmp)
				savebuffer_size += 1
				savebuffer[savebuffer_size] = "</SharedStrings>"
				savebuffer_size += 1
			end
		end

		savebuffer[savebuffer_size] =
			"</roblox><!-- Saved by USSI modded by Sashenka-->"
		savebuffer_size += 1
		save_cache(true)
		do
			-- ! Assuming we only write to file once hence why we only filter once
			-- TODO This might cause issues on non-unique Usernames (ex. "Cake" if game is about cakes then everything supposedly related to your name will be replaced with "Roblox"); Certain UserIds might also affect numbers, like if your UserId is 2481848 and there is some number that goes like "1.248184818837" then that the matched part will be replaced with 1, potentially making the number incorrect.
			-- TODO So for now it's best to keep this disabled by default
			-- TODO It's also not smart to filter entire file string at the end as this might also affect decompiled scripts content, which has no way of containing any user-related information. It would be better to use gsub in string Descriptor and such
			if OPTIONS.Anonymous then
				local LocalPlayer = service.Players.LocalPlayer
				if LocalPlayer then
					local function gsubCaseInsensitive(input, search, replacement) -- * Credits to friends
						local inputLower = string.lower(input)

						search = string.lower(search)

						local lastFinish = 0
						local subStrings = {}
						local search_len = #search
						local input_len = #input
						while search_len <= input_len - lastFinish do
							local init = lastFinish + 1

							local start, finish = string.find(inputLower, search, init, true)

							if start == nil then
								break
							end

							table.insert(subStrings, string.sub(input, init, start - 1))

							lastFinish = finish
						end

						if lastFinish == 0 then
							return input
						end

						table.insert(subStrings, string.sub(input, lastFinish + 1))

						return table.concat(subStrings, replacement)
					end

					local Anonymous = type(OPTIONS.Anonymous) == "table" and OPTIONS.Anonymous
						or { UserId = "1", Name = "Roblox" }

					for _, chunk in chunks do
						chunk.str = gsubCaseInsensitive(
							string.gsub(chunk.str, LocalPlayer.UserId, Anonymous.UserId),
							LocalPlayer.Name,
							Anonymous.Name
						)
					end
				end
			end

			local Callback = OPTIONS.Callback
			if Callback then
				local totalstr = header
				for _, chunk in chunks do
					totalstr ..= chunk.str
				end
				Callback(totalstr, chunks, totalsize)
			elseif OPTIONS.AlternativeWritefile and appendfile then
				local SEGMENT_SIZE = 4145728 -- Celery has an arbitrary savefile/appendfile size limit of ~4MB for reasons unknown. This is a workaround to save the file in segments.

				local totallen, currentlen = math.ceil(totalsize / SEGMENT_SIZE), 1

				for _, chunk in chunks do
					local length = math.ceil(chunk.size / SEGMENT_SIZE)
					for i = 1, length do
						local savestr = string.sub(chunk.str, (i - 1) * SEGMENT_SIZE + 1, i * SEGMENT_SIZE)

						run_with_loading(
							"Writing to File " .. math.round(currentlen / totallen * 100) .. "% (Depends on Exec)",
							nil,
							true,
							appendfile,
							placename,
							savestr
						)
						currentlen += 1

						if i ~= length then
							task.wait()
						end
					end
				end
			else
				local totalstr = header
				for _, chunk in chunks do
					totalstr ..= chunk.str
				end
				run_with_loading(
					"Writing " .. get_size_format() .. " to File (Depends on Exec)",
					nil,
					true,
					writefile,
					placename,
					totalstr
				)
			end
		end
		table.clear(SharedStrings)
	end

	local Connections
	do
		local Players = service.Players

		if IgnoreList.Model ~= true then
			Connections = {}
			local function ignoreCharacter(player)
				table.insert(
					Connections,
					player.CharacterAdded:Connect(function(character)
						IgnoreList[character] = true
					end)
				)

				local Character = player.Character
				if Character then
					IgnoreList[Character] = true
				end
			end

			if OPTIONS.RemovePlayerCharacters then
				table.insert(
					Connections,
					Players.PlayerAdded:Connect(function(player)
						ignoreCharacter(player)
					end)
				)
				for _, player in Players:GetPlayers() do
					ignoreCharacter(player)
				end
			else
				IgnoreNotArchivable = false -- TODO Bad solution (Characters are NotArchivable); Also make sure the next solution is compatible with IsolateLocalPlayerCharacter
				if IsolateLocalPlayerCharacter then
					task.spawn(function()
						ignoreCharacter(GetLocalPlayer())
					end)
				end
			end
		end
		if IsolateLocalPlayer and IgnoreList.Player ~= true then
			task.spawn(function()
				IgnoreList[GetLocalPlayer()] = true
			end)
		end
	end

	if IsolateStarterPlayer then
		IgnoreList.StarterPlayer = false
	end

	if IsolatePlayers then
		IgnoreList.Players = false
	end

	if OPTIONS.ShowStatus then
		do
			local Exists = GLOBAL_ENV._statustext
			if Exists then
				Exists:Destroy()
			end
		end

		local StatusGui = Instance.new("ScreenGui")

		GLOBAL_ENV._statustext = StatusGui

		StatusGui.DisplayOrder = 2e9
		pcall(function() -- ? Compatibility with level 2
			StatusGui.OnTopOfCoreBlur = true
		end)

		StatusText = Instance.new("TextLabel")

		StatusText.Text = "Saving..."

		StatusText.BackgroundTransparency = 1
		StatusText.Font = Enum.Font.Code
		StatusText.AnchorPoint = Vector2.new(1)
		StatusText.Position = UDim2.new(1)
		StatusText.Size = UDim2.new(0.3, 0, 0, 20)

		StatusText.TextColor3 = Color3.new(1, 1, 1)
		StatusText.TextScaled = true
		StatusText.TextStrokeTransparency = 0.7
		StatusText.TextXAlignment = Enum.TextXAlignment.Right
		StatusText.TextYAlignment = Enum.TextYAlignment.Top

		StatusText.Parent = StatusGui

		do -- * Save progress bar: a thin track + fill, just under the status text. Parented to StatusText so it's destroyed together with it.
			local ProgressTrack = Instance.new("Frame")
			ProgressTrack.AnchorPoint = Vector2.new(0, 0)
			ProgressTrack.Position = UDim2.new(0, 0, 1, 2)
			ProgressTrack.Size = UDim2.new(1, 0, 0, 6)
			ProgressTrack.BackgroundColor3 = Color3.new(0, 0, 0)
			ProgressTrack.BackgroundTransparency = 0.5
			ProgressTrack.BorderSizePixel = 0
			ProgressTrack.Parent = StatusText

			ProgressFill = Instance.new("Frame")
			ProgressFill.Size = UDim2.new(0, 0, 1, 0)
			ProgressFill.BackgroundColor3 = Color3.fromRGB(80, 170, 255)
			ProgressFill.BorderSizePixel = 0
			ProgressFill.Parent = ProgressTrack

			-- Estimated denominator (actual saved count is usually a bit lower due to filtering, so the bar is clamped below 100% until the final "Saved!")
			total_count = #(ToSaveInstance or game):GetDescendants()
		end

		local function randomString()
			local length = math.random(10, 20)
			local randomarray = table.create(length)
			for i = 1, length do
				randomarray[i] = string.char(math.random(32, 126))
			end
			return table.concat(randomarray)
		end

		if global_container.gethui then
			StatusGui.Name = randomString()
			StatusGui.Parent = global_container.gethui()
		else
			if global_container.protectgui then
				StatusGui.Name = randomString()
				global_container.protectgui(StatusGui)
				StatusGui.Parent = game:GetService("CoreGui")
			else
				local RobloxGui = game:GetService("CoreGui"):FindFirstChild("RobloxGui")
				if RobloxGui then
					StatusGui.Parent = RobloxGui
				else
					StatusGui.Name = randomString()
					StatusGui.Parent = game:GetService("CoreGui")
				end
			end
		end
	end

	do
		local SafeMode = OPTIONS.SafeMode
		if SafeMode then
			task.spawn(function()
				for i, v in ipairs(game:GetDescendants()) do
					if v:IsA("Script") or v:IsA("LocalScript") then
						v.Enabled = false
					end
				end

				local LocalPlayer = GetLocalPlayer()

				local PlayerScripts = LocalPlayer:FindFirstChild("PlayerScripts")
				if PlayerScripts then
					local function construct_InstanceOverride(instance)
						local children = instance:GetChildren()
						InstancesOverrides[instance] = {
							__Children = children,
						}
						for _, child in children do
							construct_InstanceOverride(child)
						end
					end
					construct_InstanceOverride(PlayerScripts)

					InstancesOverrides[LocalPlayer] = {
						__Children = LocalPlayer:GetChildren(),
						Properties = { Name = "[" .. LocalPlayer.ClassName .. "] " .. LocalPlayer.Name },
					}
				end

				LocalPlayer:Kick("\n[SAFEMODE] Saving in Progress..\nPlease do NOT leave")
				wait_for_render()
				task.delay(10, service.GuiService.ClearError, service.GuiService)
			end)

			service.RunService:Set3dRenderingEnabled(false)
		end

		local anti_idle
		if OPTIONS.AntiIdle then
			task.spawn(function()
				local getcon = global_container.getcon
				local Idled = GetLocalPlayer().Idled
				if getcon then
					for _, c in getcon(Idled) do
						if not pcall(function()
								c:Disable()
							end) then
							pcall(function()
								c:Disconnect()
							end)
						end
					end
				end
				anti_idle = Idled:Connect(function()
					service.VirtualInputManager:SendMouseWheelEvent(
						service.UserInputService:GetMouseLocation().X,
						service.UserInputService:GetMouseLocation().Y,
						true,
						game
					)
				end)
			end)
		end

		if OPTIONS.SetStreaming then
			print("[saveinstance] SetStreaming: force-loading the whole map (slow + laggy on big maps)...")
			if StatusText then
				StatusText.Text = "Streaming map in (this can take a while)..."
			end
			local streamOk, streamReason = StreamEntireMap(OPTIONS, function(streamed, totalChunks, eta)
				if StatusText then
					StatusText.Text = string.format(
						"Streaming map: %d / %d chunks%s",
						streamed,
						totalChunks,
						eta and (" (~" .. fmt_eta(eta) .. " left)") or ""
					)
				end
				if ProgressFill and totalChunks > 0 then
					ProgressFill.Size = UDim2.new(streamed / totalChunks, 0, 1, 0)
				end
			end)
			print(streamOk and "[saveinstance] Streaming complete." or ("[saveinstance] Streaming skipped: " .. tostring(streamReason)))
			-- Terrain (SmoothGrid/PhysicsGrid) was captured at LOAD, before streaming — so on a streaming
			-- map it only had the spawn-area terrain (the "squares of water" with missing land). Re-capture
			-- it now that the sweep has streamed the rest of the terrain in.
			if streamOk and realcheck then
				local terrainGHP = gethiddenproperty or (getgenv and getgenv().gethiddenpropertygethiddenproperty)
				if terrainGHP then
					-- Let background terrain finish loading before reading the grid, so we capture the
					-- FULL terrain instead of leaving floating-island gaps over water.
					if StatusText then
						StatusText.Text = "Waiting for terrain to finish loading..."
					end
					wait_terrain_loaded(terrainGHP, math.clamp((tonumber(OPTIONS.StreamingSettleTime) or 5) * 2, 6, 25))
					local reOk = pcall(function()
						getfenv().physicsgrid = base64encode(terrainGHP(workspace.Terrain, "PhysicsGrid"))
						getfenv().smoothgrid = base64encode(terrainGHP(workspace.Terrain, "SmoothGrid"))
					end)
					print("[saveinstance] Terrain " .. (reOk and "re-captured after streaming." or "re-capture failed (keeping load-time copy)."))
					dbg("[stream] terrain re-capture ok=", reOk)
				end
			end
			-- Streaming teleports the character around; its final spot can be just under the terrain, and
			-- Studio opens the place at the saved camera. Lift the camera above the map so it doesn't open
			-- underground.
			pcall(function()
				local cam = workspace.CurrentCamera
				local plr = service.Players.LocalPlayer
				local char = plr and plr.Character
				local root = char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
				local focus = (root and root.Position) or (cam and cam.CFrame.Position) or Vector3.new(0, 0, 0)
				if cam then
					cam.CFrame = CFrame.new(focus + Vector3.new(0, 300, 300), focus)
				end
			end)
			if ProgressFill then -- reset the bar for the save phase
				ProgressFill.Size = UDim2.new(0, 0, 1, 0)
			end
		end

		if OPTIONS.ExportObj then
			local objName = (placename or ("place " .. game.PlaceId .. ".rbxlx")):gsub("%.rbxl?x$", ".obj"):gsub("%.rbxmx$", ".obj")
			print("[saveinstance] ExportObj: baking MeshPart geometry to '" .. objName .. "' (recovers private meshes Studio can't load; file can be large on big maps)...")
			if StatusText then
				StatusText.Text = "Exporting map geometry to .obj..."
			end
			local okObj, info = export_map_obj(ToSaveInstance or workspace, objName, function(done, tot)
				if StatusText then
					StatusText.Text = string.format("Exporting .obj: %d / %d meshparts", done, tot)
				end
				if ProgressFill and tot > 0 then
					ProgressFill.Size = UDim2.new(done / tot, 0, 1, 0)
				end
			end)
			if okObj then
				print(string.format(
					"[saveinstance] ExportObj done: %d/%d meshparts baked (%d unique meshes, %d verts) -> %s",
					info.written, info.meshParts, info.uniqueMeshes, info.verts, objName
				))
				dbg("[obj] written:", info.written, "skipped:", info.skipped, "unique:", info.uniqueMeshes, "verts:", info.verts)
			else
				print("[saveinstance] ExportObj skipped: " .. tostring(info))
				dbg("[obj] skipped:", tostring(info))
			end
			if ProgressFill then
				ProgressFill.Size = UDim2.new(0, 0, 1, 0)
			end
		end

		if OPTIONS.DecompilePrepass and not OPTIONS.noscripts and ScriptCache and ldeccache then
			print("[saveinstance] DecompilePrepass: decompiling all scripts in parallel...")
			if StatusText then
				StatusText.Text = "Decompiling scripts (prepass)..."
			end
			local prepassOk, prepassReason = RunDecompilePrepass(ldeccache, OPTIONS, function(decompiled, totalScripts, eta)
				if StatusText then
					StatusText.Text = string.format(
						"Decompile prepass: %d / %d scripts%s",
						decompiled,
						totalScripts,
						eta and (" (~" .. fmt_eta(eta) .. " left)") or ""
					)
				end
				if ProgressFill and totalScripts > 0 then
					ProgressFill.Size = UDim2.new(decompiled / totalScripts, 0, 1, 0)
				end
			end)
			print(prepassOk and "[saveinstance] Decompile prepass complete." or ("[saveinstance] Decompile prepass skipped: " .. tostring(prepassReason)))
			if ProgressFill then -- reset the bar for the save phase
				ProgressFill.Size = UDim2.new(0, 0, 1, 0)
			end
		end

		if OPTIONS.NeutralizeLighting then
			print("[saveinstance] NeutralizeLighting: resetting Lighting/Atmosphere to clean daylight.")
			neutralize_lighting()
		end

		elapse_t = os.clock()

		local ok, err = xpcall(save_game, function(err)
			return debug.traceback(err)
		end)

		do -- console summary (size + time), regardless of whether the on-screen status is shown
			local elapsed = os.clock() - elapse_t
			if ok then
				print(string.format("[saveinstance] Saved! %s in %.2fs", get_size_format(), elapsed))
			else
				warn(string.format("[saveinstance] Save FAILED after %.2fs - see the error below", elapsed))
				warn(err)
			end
			if _api_ok > 0 or _api_fail > 0 then -- always show the decompile outcome + first failure reason (no Debug needed)
				print(string.format(
					"[saveinstance] Decompile via lua.expert: %d ok, %d failed%s",
					_api_ok,
					_api_fail,
					(_api_fail > 0 and _api_first_fail) and (" | first failure: " .. tostring(_api_first_fail)) or ""
				))
			end
			if OPTIONS.CapabilityReport then
				write_capability_report(OPTIONS, capability_missing, ok, elapsed, err)
			end
			if OPTIONS.VerifySave then
				write_verify_report(OPTIONS, ok, elapsed)
			end
			if asset_manifest_enabled then
				local lines = { "SaveInstanceFetch asset manifest", "place_id: " .. tostring(game.PlaceId), "elapsed: " .. string.format("%.2fs", elapsed), "assets:", }
				local n = #lines
				if next(asset_manifest_set) == nil then
					lines[n + 1] = "(none found)"
				else
					for uri, meta in asset_manifest_set do
						n += 1
						lines[n] = uri .. "  --  " .. meta.Instance .. " [" .. meta.Property .. "]"
					end
				end
				local wrote = writefile and pcall(writefile, "saveinstance-assets.txt", table.concat(lines, "\n"))
				print("[saveinstance] Asset manifest " .. (wrote and "written to saveinstance-assets.txt" or "could not be written"))
			end
			if debug_enabled then -- finish + write the debug log
				 dbg("[save] ok=", ok, "| size=", get_size_format(), "| time=", string.format("%.2fs", elapsed))
				 dbg("[decompile] lua.expert total ok:", _api_ok, "| failed:", _api_fail)
				 if _api_first_fail then
					 dbg("[decompile] first API failure:", _api_first_fail)
				 end
				 if not ok then
					 dbg("[save] ERROR:", err)
				 end
				 local wrote = pcall(writefile, "saveinstance-debug.txt", table.concat(debug_log, "\n"))
				 print("[saveinstance] Debug log " .. (wrote and "written to saveinstance-debug.txt (in your executor's workspace)" or "could not be written"))
			end
		end

		if SafeMode then
			service.GuiService:ClearError()
			service.RunService:Set3dRenderingEnabled(true)
		end

		if old_gethiddenproperty then
			gethiddenproperty = old_gethiddenproperty
		end

		if anti_idle then
			anti_idle:Disconnect()
		end
		if Connections then
			for _, connection in Connections do
				connection:Disconnect()
			end
		end
		GLOBAL_ENV[placename] = nil
		if StatusText then
			task.spawn(function()
				elapse_t = os.clock() - elapse_t
				local Log10 = math.log10(elapse_t)
				local ExtraTime = 10
				if ok then
					StatusText.Text = string.format("Saved! Time %.3f seconds; Size %s", elapse_t, get_size_format())
					StatusText.TextColor3 = Color3.new(0, 1)
					if ProgressFill then
						ProgressFill.Size = UDim2.new(1, 0, 1, 0)
						ProgressFill.BackgroundColor3 = Color3.new(0, 1, 0)
					end
					task.wait(Log10 * 2 + ExtraTime)
				else
					if Loading then
						task.cancel(Loading)
						Loading = nil
					end
					StatusText.Text = "Failed! Check F9 console for more info"
					StatusText.TextColor3 = Color3.new(1)
					warn("Error found while saving:")
					warn(err)
					task.wait(Log10 + ExtraTime)
				end
				StatusText:Destroy()
			end)
		end

		if OPTIONS.ShutdownWhenDone and ok then
			game:Shutdown()
		end
	end
end

-- Returns the function so it can be loaded as a library, matching the original USSI loader:
--   local synsaveinstance = loadstring(game:HttpGet(RepoURL .. "saveinstance.luau", true), "saveinstance")()
--   synsaveinstance({ ...options... })
return synsaveinstance
