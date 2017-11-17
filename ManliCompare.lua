-- create an addon with AceHook embeded
ManliCompare = LibStub("AceAddon-3.0"):NewAddon("ManliCompare", "AceEvent-3.0")

local last = ""
local hoverID = ""
local lnkHover = ""
local debug = false

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


local weights =
{
  Shaman =
  {
    Enhancement =
    {
      Agility = 9.08,
      Haste = 7.58,
      Mastery = 6.08,
      CriticalStrike = 4.58,
      Versatility = 3.08
    },

    Restoration =
    {
      Intellect = 9.06,
      Haste = 3.06,
      Mastery = 7.56,
      CriticalStrike = 6.06,
      Versatility = 4.56
    }
  },
  DeathKnight =
  {
    Blood = {
      Stamina = 12.01,
      Strength  = 9.01,
      Haste = 7.51,
      Versatility = 6.01,
      Mastery = 4.51,
      CriticalStrike = 3.01
    },

    Frost = {
      Strength = 9.01,
      Mastery = 7.51,
      CriticalStrike = 6.76,
      Haste = 6.01,
      Versatility = 5.26
    },

    Unholy = {
      Strength = 9.07,
      Mastery = 7.57,
      Haste = 6.07,
      CriticalStrike = 4,57,
      Versatility = 4.}
  }
}

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

local specIcons = {
  Restoration = "spell_nature_healingwavelesser",
  Enhancement = "ability_shaman_stormstrike",
  Blood = "spell_deathknight_bloodpresence",
  Frost = "spell_deathknight_frostpresence",
  Unholy = "spell_deathknight_unholypresence"
}

local specs = {
  Shaman =
  {
    Enhancement = {},
    Restoration = {}
  },

  DeathKnight =
  {
    Blood ={},
    Frost = {},
    Unholy = {}
  }
}

local class = select(1, UnitClass("player")):gsub(" ", "")


function mLog(...)

  if debug then
    print(dump(...))
  end
end

function ManliCompare:OnInitialize()
  self:RegisterEvent("UNIT_INVENTORY_CHANGED")
end

function ManliCompare:UNIT_INVENTORY_CHANGED()

  id, name = GetSpecializationInfo(GetSpecialization())

  if not EquipmentSetExists(name) or IsEquippedItemType("Fishing Poles") then
    return
  end

  SaveEquipmentSet(name, specIcons[name])

  local _, specName = GetSpecializationInfo(GetSpecialization())
  local numSets = GetNumEquipmentSets()
  local inSet = {}
  for i = 1, numSets do
    local setName, icon, setID = GetEquipmentSetInfo(i)
    local items = GetEquipmentSetItemIDs(setName)

    if specs[class][setName] ~= nil and setName == specName then
      specs[class][setName] = {}
      local setSlots = {}
      for slot, item in pairs(items) do
        local stSpec = GetItemStats(GetInventoryItemLink("player", slot))
        setSlots[slot] = GetWeightedStatScore(class, specName, stSpec)
      end

      table.insert(specs[class][setName], setSlots)
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
    local _,name =GetSpecializationInfo(i)
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
local function OnTooltipSetItem ()

  local _, currentSpecName = GetSpecializationInfo(GetSpecialization())

  for spec, v in pairs(specs[class]) do

    if specs[class][spec][1] ~= nil then
      local hoverItemName, _, _, _, _, _, _, _, itemSlot = GetItemInfo(hoverID)
      local itemSlotNum = itemEquipLocToSlot1[itemSlot] or itemEquipLocToSlot2[itemSlot]
      local specScore = specs[class][spec][1][itemSlotNum]

      if specScore ~= nil then
        if lnkHover ~= nil then
          local stHover = {}
        --parse the tooltip for item stats
          for i = 1, GameTooltip:NumLines() do
            local textLeft = _G["GameTooltipTextLeft"..i]:GetText() or ""

            --\+(\d*) (.*)
            for value,stat in textLeft:gmatch("%+(%d*) (.*)") do
              stHover[stat] = value
            end
          end

          if hoverItemName ~= last then
            mLog(hoverItemName)
            mLog(stHover)
          end

          last = hoverItemName

          local hoverScore = GetWeightedStatScore(class, spec, stHover)

          local delta = hoverScore - specScore
          local deltaPerc = ( 100 / specScore) * delta

          if delta >= 1 then
            GameTooltip:AddDoubleLine(spec, "+"..formatValue(deltaPerc).."%", 1, 1, 1, 0, 1, 0)
          else if delta < 1 then
              if deltaPerc == -100 or deltaPerc == 0 then
                GameTooltip:AddDoubleLine(spec, "X ", 1, 1, 1, 1, 0, 0)
              else
                GameTooltip:AddDoubleLine(spec, formatValue(deltaPerc).."%", 1, 1, 1, 1, 0, 0)
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


function setHoverItem(tip, bag, slot)
  if slot ~= nil then
    lnkHover = GetContainerItemLink(bag, slot)
    if lnkHover ~= nil then
      hoverID = tonumber(lnkHover:match("|Hitem:(%d+):"))
    end
  end
end

-- Hooks
GameTooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem)
hooksecurefunc (GameTooltip, "SetBagItem", setHoverItem)
hooksecurefunc (GameTooltip, "SetLootRollItem", setHoverItem)
hooksecurefunc (GameTooltip, "SetLootItem", setHoverItem)

--Maths
function GetWeightedStatScore(class, spec, stats)
  local score = 0
  for stat, value in pairs(stats) do
    if string.match(stat, "_")  then
        stat= _G[stat]
    end
    score = score + ApplyStatWeight(class, spec, stat:gsub(" ", ""), value)
  end
  return score
end

function ApplyStatWeight(class, spec, stat, value)

  if weights[class][spec][stat] ~= nil then
    return value * (weights[class][spec][stat])
  end

  if last ~= class..spec..stat then
   mLog("Unable to find weight for ".. class .. ".".. spec..".".. stat)
   last = class..spec..stat
  end

  return 0
end

function formatValue(v)
  return tonumber(string.format("%.0f", v))
end
