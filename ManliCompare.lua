-- create an addon with AceHook embeded
ManliCompare = LibStub("AceAddon-3.0"):NewAddon("ManliCompare", "AceEvent-3.0")

local last = ""
local hoverID = ""
local hoverslot = ""
local lastHoverID = "-"
local lnkHover = ""
local debug = false

local setScoreActiveGreen = 0.99999779462814

function dump(o)
  if type(o) == 'table' then
    local s = '{ '
    for k, v in pairs(o) do
      if type(k) ~= 'number' then k = '"'..k..'"' end
      s = s .. '['..k..'] = ' .. dump(v) .. ','
    end
    return s .. '} '
  else
    return tostring(o)
  end
end

function math.sign(x)
   if x<0 then
     return "-"..x
   elseif x>0 then
     return "+"..x
   else
     return x
   end
end

function mLog(x)

  if debug and last ~= x then
    print(dump(x))
  end
  last = x
end

local function contains(table, val)
   for i=1,#table do
      if table[i] == val then
         return true
      end
   end
   return false
end

local itemEquipLocToSlot1 =
{
  INVTYPE_HEAD = 1,
  INVTYPE_NECK = 2,
  INVTYPE_SHOULDER = 3,
  INVTYPE_BODY = 4,
  INVTYPE_CHEST = 5,
  INVTYPE_ROBE = 5,
  INVTYPE_WAIST = 6,
  INVTYPE_LEGS = 7,
  INVTYPE_FEET = 8,
  INVTYPE_WRIST = 9,
  INVTYPE_HAND = 10,
  INVTYPE_FINGER = 11,
  INVTYPE_TRINKET = 13,
  INVTYPE_CLOAK = 15,
  INVTYPE_WEAPON = 16,
  INVTYPE_SHIELD = 17,
  INVTYPE_2HWEAPON = 16,
  INVTYPE_WEAPONMAINHAND = 16,
  INVTYPE_RANGED = 16,
  INVTYPE_RANGEDRIGHT = 16,
  INVTYPE_WEAPONOFFHAND = 17,
  INVTYPE_HOLDABLE = 17,
  INVTYPE_TABARD = 19,
}
local itemEquipLocToSlot2 =
{
  INVTYPE_FINGER = 12,
  INVTYPE_TRINKET = 14,
  INVTYPE_WEAPON = 17,
}

local newdb = {
  Shaman =
  {
    Enhancement = {
      Icon = "ability_shaman_stormstrike",
      Set = {},
      IgnoreTypes = {"Wand", "Bow", "Gun", "Sword", "Polearm", "Two-Hand", "Plate"},
      Weights = {
        Agility = 9.08,
        Haste = 7.58,
        Mastery = 6.08,
        CriticalStrike = 4.58,
      Versatility = 3.08}
    },
    Restoration = {
      Icon = "spell_nature_healingwavelesser",
      Set = {},
      IgnoreTypes = {"Wand", "Bow", "Gun", "Sword", "Polearm", "Plate"},
      Weights = {
        Intellect = 9.06,
        Haste = 3.06,
        Mastery = 7.56,
        CriticalStrike = 6.06,
        Versatility = 4.56
      }
    },
    Elemental = {
      Icon = "Spell_nature_lightning",
      IgnoreTypes = {"Wand", "Bow", "Gun", "Sword", "Polearm"},
      Set = {},
      Weights = {
        Intellect = 9.07,
        Mastery = 7.57,
        CriticalStrike = 6.82,
        Versatility = 4.57,
        Haste = 3.07
      }
    }
  },
  Priest = {
    Shadow = {
      Icon = "spell_shadow_demonicfortitude",
      IgnoreTypes = {"Two-Hand", "Plate", "Mail", "Bow", "Gun", "Sword", "Sheild", "Polearm"},
      Set = {},
      Weights = {
        Haste = 9.05,
        Crit = 7.55,
        Mastery = 6.05,
        Versatility = 4.55,
        Intellect = 3.05
      }
    },
    Holy = {
      Icon = "spell_holy_guardianspirit",
      IgnoreTypes = {"Two-Hand", "Plate", "Mail", "Bow", "Gun", "Sword", "Sheild", "Polearm"},
      Set = {},
      Weights = {
        Intellect = 9.05,
        Mastery = 7.55,
        Crit = 6.05,
        Haste = 4.55,
        Versatility = 3.05
      }
    }
  },
  DeathKnight =
  {
    Blood = {
      Icon = "spell_deathknight_bloodpresence",
      IgnoreTypes = {"Wand", "Bow", "Gun"},
      Set = {},
      Weights = {
        Stamina = 12.01,
        Strength = 9.01,
        Haste = 7.51,
        Versatility = 6.01,
        Mastery = 4.51,
        CriticalStrike = 3.01
      }
    },
    Frost = {
      Icon = "spell_deathknight_frostpresence",
      IgnoreTypes = {"Wand", "Bow", "Gun"},
      Set = {},
      Weights = {
        Strength = 9.01,
        Mastery = 7.51,
        CriticalStrike = 6.76,
        Haste = 6.01,
        Versatility = 5.26
      }
    },
    Unholy = {
      Icon = "spell_deathknight_unholypresence",
      IgnoreTypes = {"Wand", "Bow", "Gun"},
      Set = {},
      Weights = {
        Strength = 9.07,
        Mastery = 7.57,
        Haste = 6.07,
        CriticalStrike = 4, 57,
        Versatility = 4
      }
    }
  }
}


-- data access
local frame = CreateFrame("FRAME"); -- Need a frame to respond to events
frame:RegisterEvent("ADDON_LOADED"); -- Fired when saved variables are loaded
frame:RegisterEvent("PLAYER_LOGOUT"); -- Fired when about to log out

function frame:OnEvent(event, arg1)
  if event == "ADDON_LOADED" and arg1 == "ManliCompare" then

    if ManliCompareDB == nil then
      ManliCompareDB = newdb
      mLog("ManliCompare has created new db")
    end
  elseif event == "PLAYER_LOGOUT" then

  end
end

frame:SetScript("OnEvent", frame.OnEvent);

SLASH_MANLICOMPARE1 = "/manlicompare";
function SlashCmdList.MANLICOMPARE(msg)

  if msg == "reset" then
    ManliCompareDB = newdb
    print("Compare profiles reset")
  end
end


local class = select(1, UnitClass("player")):gsub(" ", "")

if string.match(class, "DeathKnight") then
  class = "DeathKnight" -- one day this line will make sense and I'll fix it, somewhere along the way I'm getting "DeathKnight 1" and can't figure out where
end
mLog("class " .. class)

function ManliCompare:OnInitialize()
  self:RegisterEvent("UNIT_INVENTORY_CHANGED")
end

function ManliCompare:UNIT_INVENTORY_CHANGED()

  id, name = GetSpecializationInfo(GetSpecialization())

  -- if there isn't a set with this spec name, we have a fishing pole equipped or we don't have a INVTYPE_CHEST equipped, then return without saving
  if not EquipmentSetExists(name) or IsEquippedItemType("Fishing Poles") or GetInventoryItemLink("player", 5) == nil then
    return
  end

  SaveEquipmentSet(name, ManliCompareDB[class][name]["Icon"])

  local _, specName = GetSpecializationInfo(GetSpecialization())
  local numSets = GetNumEquipmentSets()
  local inSet = {}
  for i = 1, numSets do
    local setName, icon, setID = GetEquipmentSetInfo(i)
    local items = GetEquipmentSetItemIDs(setName)

    if setName == specName then
      ManliCompareDB[class][setName]["Set"] = {}
      local setSlots = {}
      for slot, item in pairs(items) do
        local stSpec = GetItemStats(GetInventoryItemLink("player", slot))
        mLog(stSpec)
        setSlots[slot] = GetWeightedStatScore(class, specName, stSpec)
      end

      ManliCompareDB[class][setName]["Set"] = setSlots
    end
  end
end

function EquipmentSetExists(checkName)
  local numSets = GetNumEquipmentSets()
  local inSet = {}

  for i = 1, numSets do
    local name = GetEquipmentSetInfo(i)
    if checkName == name then return true end
  end
  return false
end

function SpecializationExists(checkName)
  local numSpecs = GetNumSpecializations(false, false) -- get player spec LibStub
  for i = 1, numSpecs do
    local _, name = GetSpecializationInfo(i)
    if name == checkName then return name end

  end
  return false
end

function GetCurrentEquipmentSetName()
  local numSets = GetNumEquipmentSets()
  local inSet = {}

  for i = 1, numSets do
    local name, _, _, isEquipped = GetEquipmentSetInfo(i)
    if isEquipped then return name end
  end
  return "NA"
end


-- TOOLTIPS
local function OnTooltipSetItem (self)

  _, lnkHover = GameTooltip:GetItem()
  local hasStats = false

  if lnkHover == nil then return end

  local _, currentSpecName = GetSpecializationInfo(GetSpecialization())

  local hoverItemName, _, _, _, _, _, _, _, itemSlot = GetItemInfo(lnkHover)


  local itemSlotNum = itemEquipLocToSlot1[itemSlot] or itemEquipLocToSlot2[itemSlot]

  if itemSlotNum == nil then return end

  for spec, v in pairs(ManliCompareDB[class]) do

    if ManliCompareDB[class][spec]["Set"] ~= nil and EquipmentSetExists(spec) then

      local altSetScore = 0
      local socketMod = ""
      local old = ""
      local setScore = ManliCompareDB[class][spec]["Set"][itemSlotNum] or 0


      if itemSlot == "INVTYPE_FINGER" or itemSlot == "INVTYPE_TRINKET" then
        altSetScore = ManliCompareDB[class][spec]["Set"][itemSlotNum + 1] or 0

      end



      if setScore ~= nil then
        if lnkHover ~= nil then
          local stHover = {}
          local ignore = false
          local ignoreTypes = ManliCompareDB[class][spec]["IgnoreTypes"]


          --parse the tooltip for item stats
          for i = 1, GameTooltip:NumLines() do
            local textLeft = _G["GameTooltipTextLeft"..i]:GetText() or ""
            local textRight = _G["GameTooltipTextRight"..i]:GetText() or ""

            -- stat block
            if string.starts(textLeft, "+") then
              --\+(\d*) (.*)
              --%+(%d+|%d{1,3}(,%d{3})*)(%.%d+)
              hasStats = true
              for value, stat in textLeft:gmatch("%+([%d,]*) (.*)") do
                stHover[stat] = value:gsub(",", "")

                --mLog(stat .. " = " ..  value)
              end
            end

            --sockets

            --set bonus
            if string.starts(textLeft, "Set:")  then

              for statName,val in pairs(ManliCompareDB[class][spec]["Weights"]) do
                for value in textLeft:gmatch("%" .. string.lower(statName) .. " by (%d+)") do

                    stHover[statName.."+"] = (stHover[statName] or 0) + value

                end
              end
            end


            if string.starts(textLeft, "Two-Hand") then
              setScore = setScore + ManliCompareDB[class][spec]["Set"][itemSlotNum + 1] or 0
            end

            if contains(ignoreTypes, textLeft) or contains(ignoreTypes, textRight) then
              ignore = true
            end

          end

          if not hasStats then return end
          hasStats = false

          local hoverScore, hoverPlusScore = GetWeightedStatScore(class, spec, stHover)

          if ignore then
            hoverScore = 0
          end

          if hoverPlusScore > 0 and IsAltKeyDown() then
            hoverScore = hoverPlusScore
          end

          local delta = hoverScore - setScore

          if altSetScore > 0 then

            local currentScore = setScore + altSetScore -- 2,4
            local ACSetScore = setScore + hoverScore-- 2,6
            local BCSetScore = altSetScore + hoverScore -- 4,6


            if setScore == hoverScore or altSetScore == hoverScore then -- need to handle this better for items with same specs but not the same item
              delta = 0
            elseif ACSetScore > BCSetScore then
              delta = hoverScore - altSetScore
              setScore = altSetScore
            else
              delta = hoverScore - setScore
            end

          end


          local deltaPerc = formatValue(( 100 / setScore) * delta)



          if deltaPerc > 0 then
            GameTooltip:AddDoubleLine(spec, "+"..deltaPerc.."%", 1, 1, 1, 0, 1, 0)
            else if deltaPerc < 0 then
              if deltaPerc == -100 then
                GameTooltip:AddDoubleLine(spec, "X ", 1, 1, 1, 0.8, 0, 0)
              else
                GameTooltip:AddDoubleLine(spec, deltaPerc.."%", 1, 1, 1, 0.8, 0, 0)
              end
            else
              GameTooltip:AddDoubleLine(spec, "[E]", 1, 1, 1, 1, 1, 1)
            end
          end
        end
      end
    end
  end
end

GameTooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem)

--Maths
function GetWeightedStatScore(class, spec, stats)
  local score = 0
  local plusScore = 0

  if stats ~= nil then
    for stat, value in pairs(stats) do


      if string.match(stat, "_") then
        stat = _G[stat]
      end



      if stat ~= nil then

        if string.match(stat, "+") then

          if plusScore == 0 then
            plusScore = score
          end

          plusScore = plusScore + ApplyStatWeight(class, spec, stat:gsub("+", ""):gsub(" ", ""), value)
        else
          score = score + ApplyStatWeight(class, spec, stat:gsub(" ", ""), value)

        end

      end

    end
    return score, plusScore
  end
  return 0, 0
end

function ApplyStatWeight(class, spec, stat, value)

  if ManliCompareDB[class][spec]["Weights"][stat] ~= nil then
    return value * (ManliCompareDB[class][spec]["Weights"][stat])
  end

  if last ~= class..spec..stat then
    --mLog("Unable to find weight for ".. class .. ".".. spec..".".. stat)
    last = class..spec..stat
  end

  return 0
end

-- string helpers
function formatValue(v)
  return tonumber(string.format("%.0f", v))
end

function string.starts(String, Start)
  return string.sub(String, 1, string.len(Start)) == Start
end
