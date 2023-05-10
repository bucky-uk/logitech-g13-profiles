------------------------------------------------------------------------------------------------------------
local
print_orig, type, floor, min, max, sqrt, format, byte, char, rep, sub, gsub, concat, select, tostring =
print, type, math.floor, math.min, math.max, math.sqrt, string.format, string.byte, string.char, string.rep, string.sub,
    string.gsub, table.concat, select, tostring
local
OutputLogMessage =
OutputLogMessage

local spinner = {}
spinner[0] = "/"
spinner[1] = "-"
spinner[2] = "\\"
spinner[3] = "|"
spinner[4] = "/"
spinner[5] = "-"
spinner[6] = "\\"
spinner[7] = "|"

local spinnerIndex = 0

local function print(...)
    print_orig(...)
    local t = { ... }
    for j = 1, select("#", ...) do
        t[j] = tostring(t[j])
    end
    OutputLogMessage(GetDate("%X") .. " %s\n", concat(t, "\t"))
end

local function printLCD(message, clear)
    if clear then
        ClearLCD()
    end
    OutputLCDMessage(message, 5000)
end

local function printLCDCountdown(displayName, timeLeft)
    local castCountdown = " in " .. string.format("%.1f", timeLeft / 1000)
    local castAnnouncement = 'Casting ' .. displayName
    if timeLeft > 0 then castAnnouncement = castAnnouncement .. " " .. castCountdown end

    spinnerIndex = spinnerIndex + 1
    if spinnerIndex == 8 then spinnerIndex = 0 end

    printLCD(castAnnouncement .. " " .. spinner[spinnerIndex], true)
end

local function printLCDProgressBar(displayName, timeLeft, timeTotal)
    ClearLCD()
    local castCountdown = " in " .. string.format("%.1f", timeLeft / 1000)
    local castAnnouncement = 'Casting ' .. displayName
    if timeLeft > 0 then castAnnouncement = castAnnouncement .. " " .. castCountdown end

    spinnerIndex = spinnerIndex + 1
    if spinnerIndex == 8 then spinnerIndex = 0 end

    local percent = (timeLeft / timeTotal)
    local bars = tonumber(string.format("%2d", 25 * percent))
    local output = ""
    for i = bars, 1, -1 do output = output .. "#" end

    OutputLCDMessage(castAnnouncement .. " " .. spinner[spinnerIndex], 1000)
    OutputLCDMessage(output, 1000)
end

----------------------------------------------------------------------------------------
-- VARIABLES
----------------------------------------------------------------------------------------

local CastType = {
    Power  = 1,
    Spell  = 2,
    AoW    = 3,
    Hotkey = 4,
    Macro  = 5
}

local MOUSE_LEFT    = 1
local MOUSE_RIGHT   = 3
local MOUSE_MIDDLE  = 2
local MOUSE_BACK    = 4
local MOUSE_FORWARD = 5

local SPELL_EQUIP_TIME      = 100
local SWORD_EQUIP_TIME      = 250
local ZWEIHANDER_EQUIP_TIME = 300

local HKEY_AOWMOD          = "R"
local HKEY_USE		    = "E"
local HKEY_HEAVY           = "V"
local HKEY_TAUNT           = "G"
local HKEY_POWER           = "Z"
local HKEY_READY           = "R"
local HKEY_RANGED          = "1"
local HKEY_TWOHAND         = "2"
local HKEY_SWORD           = "3"
local HKEY_MACE            = "4"
local HKEY_AXE             = "5"
local HKEY_DISPEL          = "6"
local HKEY_ILLUMINATION    = "7"
local HKEY_CONDUIT         = "8"
local CONDUIT_CAST_TIME    = "250"
local CONDUIT_CAN_OVERRIDE = false

-- loadout definitions
local Ranged = {
    hKey         = "F1",
    hKeyMod      = nil,
    hKeyDelay    = 0,
    name         = "Crossbow",
    sticky       = true,
    isConduit    = false,
    isSpell      = false,
    castType     = CastType.AoW,
    autoCast     = false,
    castDelay    = 250,
    castTime     = 250,
    recoveryTime = 250
}

local Zweihander = {
    hKey         = MOUSE_RIGHT,
    hKeyMod      = HKEY_USE,
    hKeyDelay    = 0,
    name         = "Dawnbreaker",
    sticky       = true,
    isConduit    = false,
    isSpell      = false,
    castType     = CastType.AoW,
    autoCast     = true,
    castDelay    = 500,
    castTime     = 1000,
    recoveryTime = 1000
}

local SwordAndBoard = {
    hKey         = "F3",
    hKeyMod      = nil,
    hKeyDelay    = 0,
    name         = "Flurry",
    sticky       = true,
    isConduit    = true,
    isSpell      = false,
    castType     = CastType.AoW,
    autoCast     = true,
    castDelay    = 250,
    castTime     = 250,
    recoveryTime = 250
}

local Ice = {
    hKey         = "F4",
    hKeyMod      = nil,
    hKeyDelay    = 0,
    name         = "Ice",
    isConduit    = false,
    isSpell      = true,
    castType     = CastType.Spell,
    autoCast     = true,
    castDelay    = 0,
    castTime     = 1000,
    recoveryTime = 250
}

local Fire = {
    hKey         = "F5",
    hKeyMod      = nil,
    hKeyDelay    = 0,
    name         = "Fire",
    sticky       = false,
    isConduit    = false,
    isSpell      = true,
    castType     = CastType.Spell,
    autoCast     = true,
    castDelay    = 0,
    castTime     = 1000,
    recoveryTime = 250
}

local Lightning = {
    hKey         = "F6",
    hKeyMod      = nil,
    hKeyDelay    = 0,
    name         = "Lightning",
    sticky       = false,
    isConduit    = false,
    isSpell      = true,
    castType     = CastType.Spell,
    autoCast     = true,
    castDelay    = 0,
    castTime     = 1000,
    recoveryTime = 250
}

local Resto = {
    hKey         = "F7",
    hKeyMod      = nil,
    hKeyDelay    = 0,
    name         = "Restoration",
    sticky       = false,
    isConduit    = false,
    isSpell      = true,
    castType     = CastType.Spell,
    autoCast     = true,
    castDelay    = 0,
    castTime     = 1000,
    recoveryTime = 250
}

local Pray = {
    hKey         = "F8",
    hKeyMod      = nil,
    hKeyDelay    = 2000,
    name         = "Prayer",
    sticky       = false,
    isConduit    = false,
    isSpell      = false,
    castType     = CastType.Power,
    autoCast     = true,
    castDelay    = 0,
    castTime     = 250,
    recoveryTime = 250
}

local TauntOrPray = {
    hKey         = "F8",
    hKeyMod      = nil,
    hKeyDelay    = 500,
    name         = "Prayer",
    sticky       = false,
    isConduit    = false,
    isSpell      = false,
    castType     = CastType.Power,
    autoCast     = true,
    castDelay    = 0,
    castTime     = 250,
    recoveryTime = 250
}

local Arcane = {
    hKey         = "7",
    hKeyMod      = nil,
    hKeyDelay    = 0,
    name         = "Arcane",
    sticky       = false,
    isConduit    = false,
    isSpell      = true,
    castType     = CastType.Spell,
    autoCast     = true,
    castDelay    = 250,
    castTime     = 1000,
    recoveryTime = 250
}

local Dispel = {
    hKey         = "6",
    hKeyMod      = nil,
    hKeyDelay    = 500,
    name         = "Dispel",
    sticky       = false,
    isConduit    = false,
    isSpell      = true,
    castType     = CastType.Spell,
    autoCast     = true,
    castDelay    = 250,
    castTime     = 1000,
    recoveryTime = 250
}

local PowerAttack = {
    hKey         = HKEY_HEAVY,
    hKeyMod      = HKEY_AOWMOD,
    hKeyDelay    = 500,
    name         = "BIG BADA BOOM",
    sticky       = false,
    isConduit    = false,
    isSpell      = false,
    castType     = CastType.AoW,
    autoCast     = true,
    castDelay    = 250,
    castTime     = 250,
    recoveryTime = 250
}

local _isReadyPressed = false
local _isCasting      = false
local _isSpellLocked  = false
local _isSticky       = false
local _activeKeyMap   = 0

local _previousLoadout, _currentLoadout, _defaultLoadout

----------------------------------------------------------------------------------------
-- UTILITY METHODS
----------------------------------------------------------------------------------------

local function LockCasting()
    _isCasting = true
end

local function StopAllCasting()
    ReleaseMouseButton(MOUSE_LEFT)
    ReleaseMouseButton(MOUSE_RIGHT)
    ReleaseMouseButton(MOUSE_FORWARD)
    ReleaseKey('lctrl')
    AbortMacro()
    _isCasting = false
end

local function SetCurrentLoadout(loadout)
    _currentLoadout = loadout
end

local function SetPreviousLoadout(loadout)
    _previousLoadout = loadout
end

local function Uninterrupted()
    return IsMouseButtonPressed(MOUSE_FORWARD)
end

----------------------------------------------------------------------------------------
-- LOADOUT
----------------------------------------------------------------------------------------

-- Meta class
Loadout = {
    hKey         = nil,
    hKeyMod      = nil,
    hKeyDelay    = 0,
    name         = nil,
    sticky       = false,
    isConduit    = false,
    isSpell      = false,
    castType     = CastType.Spell,
    autoCast     = false,
    castDelay    = 250,
    castTime     = 250,
    recoveryTime = 250
}

-- Base class method new
function Loadout:new(o, l)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    -- private
    local _hKey         = l.hKey or nil
    local _hKeyMod      = l.hKeyMod or nil
    local _hKeyDelay    = l.hKeyDelay or 0
    local _name         = l.name or ""
    local _sticky       = l.sticky or ""
    local _isConduit    = l.isConduit or false
    local _castType     = l.castType or CastType.Spell
    local _isSpell      = l.isSpell or false
    local _autoCast     = l.autoCast or false
    local _castDelay    = l.castDelay or 250
    local _castTime     = l.castTime or 250
    local _recoveryTime = l.recoveryTime or 250

    -- public
    self.displayName  = _name
    self.hKey         = _hKey
    self.hKeyMod      = _hKeyMod
    self.hKeyDelay    = _hKeyDelay
    self.sticky       = _sticky
    self.castType     = _castType
    self.isConduit    = _isConduit
    self.isSpell      = _isSpell
    self.autoCast     = _autoCast
    self.castDelay    = _castDelay
    self.castTime     = _castTime
    self.recoveryTime = _recoveryTime
    return o
end

function Loadout:activate()
	if self.hKey then
		if self.hKeyMod then
			PressAndReleaseKey(self.hKeyMod, self.hKey)
    		else
			PressAndReleaseKey(self.hKey)
		end
	end
end

-- Cast Power
function Loadout:castPower()
    print("==== POWER: Casting " .. self.displayName)
    PressAndReleaseKey(HKEY_POWER)
    Sleep(self.castTime)
end

-- Cast Spell
function Loadout:castSpell()
    if _previousLoadout.isConduit then
        self:castLeft()
    else
        self:dualCast()
    end
end

-- Cast Left
function Loadout:castLeft()
    print("==== SPELL: Casting " .. self.displayName .. " in left hand...")
    PressMouseButton(MOUSE_RIGHT)
    Sleep(self.castTime)
end

-- Cast Right
function Loadout:castRight()
    print("==== SPELL: Casting " .. self.displayName .. " in right hand...")
    PressMouseButton(MOUSE_LEFT)
    Sleep(self.castTime)
end

-- Dual Cast
function Loadout:dualCast()
    print("==== SPELL: Dual casting " .. self.displayName .. "...")
    PressMouseButton(MOUSE_RIGHT)
    PressMouseButton(MOUSE_LEFT)
    Sleep(self.castTime)
end

function Loadout:castConduit(l)
    if self.isConduit and l.castType == CastType.Spell then
        print("==== CONDUIT: applying " .. _currentLoadout.name .. " to " .. self.displayName)
        printLCD("zzzzZZZZAAAAP!", true)
        PressAndReleaseKey(HKEY_CONDUIT)
        Sleep(CONDUIT_CAST_TIME)
    end
end

-- Ashes of War
function Loadout:ashesOfWar()
    printLCD("WITNESS MEEEE", true)
    print("==== AOW: casting " .. self.displayName .. " Ashes of War")
    PressKey(HKEY_USE)
    PressAndReleaseKey(HKEY_AOWMOD)
    Sleep(self.castTime)
    ReleaseKey(HKEY_USE)
end

-- Loadout:cast
--	Determines whether to cast spells or trigger the weapons Ashes of War on hold.
-- 	Cast is broken by releasing Mouse 5
function Loadout:cast()
    local start = GetRunningTime()
    local timeLeft = 0
    local triggered = false
    local castAnnouncement, castCountdown

    while Uninterrupted() do

        Sleep(100)

        timeLeft = start + self.castDelay - GetRunningTime()
        printLCDCountdown(self.displayName, timeLeft)

        if timeLeft <= 0 then
            if not _isCasting and self.castType then
                LockCasting()
                if self.castType == CastType.Power then
                    self:castPower()
                    self:dualCast()
                end

                if self.castType == CastType.Spell then
                    self:castSpell()
                end

                if self.castType == CastType.AoW then
                    self:ashesOfWar()
                end
            end
        end
    end

    StopAllCasting()
    Sleep(self.recoveryTime)
end

-- Loadout:swap
--	Swap the loadout
function Loadout:swap()
    local c = _currentLoadout

    -- Before we switch weapon, check to see if we can cast Conduit
    self:castConduit(c)
    self:activate()

    Sleep(200)

    -- When switching to magic from a 1-hander, always try to keep that 1-hander equipped
    if CONDUIT_CAN_OVERRIDE and (c.isConduit and self.isSpell) then
        print("==== CONDUIT: Overriding left hand...")
        PressAndReleaseKey(HKEY_ONEHAND)
    end
end

------------------------------------------------------------------------------------------------------------

-- Invoke a loadout swap.
-- 		autoCast: does the loadout automatically cast when the key is held?
-- 		sticky: does the loadout flip back to the previous loadout when the key is released?

local function SwapLoadout(l)
    local loadout = Loadout:new(nil, l)

    _isSticky = l.sticky

    SetPreviousLoadout(_currentLoadout)
    loadout:swap()
    SetCurrentLoadout(l)

    print("==== SWAP: Current Loadout: " ..
        _currentLoadout.name .. " | Previous Loadout: " .. _previousLoadout.name .. " ===")

    if l.autoCast then
        loadout:cast()
    end
end

local function SwapLoadoutAfterDelay(l)
    local start = GetRunningTime()
    local timeLeft = 0

    while Uninterrupted() do
        Sleep(100)

        timeLeft = start + l.hKeyDelay - GetRunningTime()
        printLCDProgressBar(l.name, timeLeft, l.hKeyDelay)

        if (timeLeft) <= 0 then
            SwapLoadout(l)
        end
    end
end

function OnEvent(event, arg)

    Sleep(20)

    local gKeyMaps = {}
    gKeyMaps[1] = nil
    gKeyMaps[2] = nil
    gKeyMaps[3] = nil
    gKeyMaps[4] = nil
    gKeyMaps[5] = nil
    gKeyMaps[6] = nil
    gKeyMaps[7] = nil
    gKeyMaps[8] = nil
    gKeyMaps[9] = nil
    gKeyMaps[10] = nil
    gKeyMaps[11] = nil
    gKeyMaps[12] = nil
    gKeyMaps[13] = Zweihander
    gKeyMaps[14] = nil
    gKeyMaps[15] = nil
    gKeyMaps[16] = nil
    gKeyMaps[17] = nil
    gKeyMaps[18] = nil
    gKeyMaps[19] = SwordAndBoard
    gKeyMaps[20] = nil
    gKeyMaps[21] = nil
    gKeyMaps[22] = nil


    local mouse_button

    if event == "PROFILE_ACTIVATED" then
        ClearLog()
        EnablePrimaryMouseButtonEvents(false)

        SetMouseDPITableIndex(2)

        if IsKeyLockOn "NumLock" then
            PressAndReleaseKey "NumLock"
        end

        _defaultLoadout = SwordAndBoard
        SetCurrentLoadout(_defaultLoadout)
        SetPreviousLoadout(_defaultLoadout)
        print("=== START: Current loadout: " .. _defaultLoadout.name .. " ===")

    end

    if event == "PROFILE_DEACTIVATED" then
        EnablePrimaryMouseButtonEvents(false)

    end
    if event == "G_RELEASED" and arg == 01 then
        StopAllCasting()
        AbortMacro()
    end

    if event == "G_PRESSED" and arg == 06 then
        PressAndReleaseKey(HKEY_READY)
    end

    if event == "G_PRESSED" and arg == 09 then
        PressAndReleaseKey(HKEY_RANGED)
    end

    if event == "G_RELEASED" and arg == 10 then
        --PressAndReleaseKey(HKEY_MACE)
    end

    if event == "G_RELEASED" and arg == 11 then
        PressAndReleaseKey(HKEY_TAUNT)
    end

    if event == "G_RELEASED" and arg == 12 then
        PressAndReleaseKey(HKEY_HEAVY)
    end

    if event == "G_PRESSED" and arg == 13 then
        PressAndReleaseKey(HKEY_TWOHAND)
    end

    if event == "G_RELEASED" and arg == 16 then
        --PressAndReleaseKey(HKEY_AXE)
    end

    if event == "G_RELEASED" and arg == 17 then
        --PressAndReleaseKey(HKEY_MACE)
    end

    if event == "G_RELEASED" and arg == 18 then
        --PressAndReleaseKey(HKEY_SWORD)
    end

    if event == "G_PRESSED" and arg == 19 then
        PressAndReleaseKey(HKEY_SWORD)
    end

    if event == "G_RELEASED" and arg == 21 then
        PressAndReleaseKey(HKEY_ILLUMINATION)
    end

    if event == "G_PRESSED" then
        local l = gKeyMaps[arg]
        if not l then
            -- do nothing
        else
            if not _isCasting then
                _activeKeyMap = arg
                if l.hKeyDelay and l.hKeyDelay > 0 then
                    print("=== G_PRESSED: " .. l.hKey .. " pressed, swapping to " .. l.name .. " (Longpress mode)")
                    SwapLoadoutAfterDelay(l)
                else
                    print("=== G_PRESSED: " .. l.hKey .. " pressed, swapping to " .. l.name)
                    SwapLoadout(l)
                end
            end
        end
    end

    if event == "G_RELEASED" then
        local l = gKeyMaps[arg]
        if not l then
            -- not a loadout key, do nothing...
        else
            if _activeKeyMap == arg then
                if not _isSticky then
                    print("=== G_RELEASED: " .. l.hKey .. " released, reverting to " .. _previousLoadout.name)
                    SwapLoadout(_previousLoadout)
                end

                StopAllCasting()
                _activeKeyMap = 0
            end
        end
    end
end