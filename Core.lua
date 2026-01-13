--[[
  TODO LIST:
  - Challenging Shout (Challenging Roar)
  - (?) Whisper Target on fail
  - (?) Nightfall
  - countdown saying when challenging ends, cancel it if someone else sends a challenge line
]]
--[[ *** Create Ace2 AddOn *** ]]
Tankalyze = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0", "AceConsole-2.0", "AceDB-2.0", "AceHook-2.1", "AceDebug-2.0", "FuBarPlugin-2.0")
local L = AceLibrary("AceLocale-2.2"):new("Tankalyze")
-- local status = AceLibrary("SpellStatus-1.0")
local dewdrop = AceLibrary("Dewdrop-2.0")
local waterfall = AceLibrary("Waterfall-1.0")

local player_guid = nil
local _, playerclass = UnitClass("player")
-- if ((playerclass ~= "WARRIOR") and (playerclass ~= "DRUID") and (playerclass ~= "PALADIN")) then
if ((playerclass ~= "WARRIOR") and (playerclass ~= "DRUID") and (playerclass ~= "PALADIN") and (playerclass ~= "SHAMAN")) then
  DisableAddOn("Tankalyze")
  return
end
local at_combat_start = false
local in_combat = false
local tried_vs = nil
local spellstore = {}

Tankalyze.hasIcon  = "Interface\\AddOns\\Tankalyze\\icon"
Tankalyze.defaultPosition = "CENTER"
Tankalyze.defaultMinimapPosition = 245
Tankalyze.cannotDetachTooltip = true
Tankalyze.tooltipHiddenWhenEmpty = true
Tankalyze.hideWithoutStandby = true
Tankalyze.clickableTooltip = false
Tankalyze.hasNoColor = true
Tankalyze.rightclick = false

local fubarOptions = {
  "detachTooltip", 
  "colorText", 
  "text", 
  "lockTooltip", 
  "position", 
  "minimapAttach", 
  "hide", 
  "icon" 
}

--[[ *** Initialize the AddOn *** ]]
function Tankalyze:OnInitialize()
  --[[ Register a DB for saving ]]
  self:RegisterDB("TankalyzeDB")

  self:RegisterDefaults('char', {
    resists = {
      taunt = true,
      mocking = true,
      growl = true,
      reckoning = true,
      earthshaker_slam = true,
      shout = false,
      roar = false,
      channel = "Tankalyze",
      type = "YELL", -- "GROUP_RW", "GROUP", "RAID", "PARTY", "CHANNEL", "YELL", "SAY", "DEBUG"
      messages = {
        taunt = L["TauntMessage"],
        tauntSCT = L["TauntMessageSCT"],
        growl = L["GrowlMessage"],
        growlSCT = L["GrowlMessageSCT"],
        mocking = L["MockingMessage"],
        mockingSCT = L["MockingMessageSCT"],
        shout = L["ShoutMessage"],
        shoutSCT = L["ShoutMessageSCT"],
        roar = L["RoarMessage"],
        roarSCT = L["RoarMessageSCT"],
        reckoning = L["ReckoningMessage"],
        reckoningSCT = L["ReckoningMessageSCT"],
        earthshaker_slam = L["EarthshakerSlamMessage"],
        earthshaker_slamSCT = L["EarthshakerSlamMessageSCT"],
      },
    },
    
    announces = {
      taunt = true,
      mocking = true,
      growl = true,
      reckoning = true,
      earthshaker_slam = true,
      wall = true,
      stand = true,
      gem = true,
      shout = true,
      roar = true,
      channel = "Tankalyze",
      type = "SAY", -- "GROUP_RW", "GROUP", "RAID", "PARTY", "CHANNEL", "YELL", "SAY", "DEBUG"
      messages = {
        taunt = L["TauntUsedMessage"],
        tauntSCT = L["TauntUsedMessageSCT"],
        mocking = L["MockingUsedMessage"],
        mockingSCT = L["MockingUsedMessageSCT"],
        growl = L["TauntUsedMessage"],
        growlSCT = L["TauntUsedMessageSCT"],
        reckoning = L["TauntUsedMessage"],
        reckoningSCT = L["TauntUsedMessageSCT"],
        earthshaker_slam = L["TauntUsedMessage"],
        earthshaker_slamSCT = L["TauntUsedMessageSCT"],
        deathwish = L["DeathWishUsedMessage"],
        wall = L["WallUsedMessage"],
        stand = L["StandUsedMessage"],
        gem = L["GemUsedMessage"],
        shout = L["ShoutUsedMessage"],
        roar = L["RoarUsedMessage"],
      },
    },
    
    grouponly = true,
    removesalv = false,
    removesalv_notify = true,

    alertSelf = false,
    sct = false,
    humour = false,
    mainTank = false,
    mainTankDuration = 12,
    
    isLogging = false,
    logShout = { },
    logRoar = { },
  })

  --[[ Build Options ]]
  self.opts = {
    type = "group",
    icon = "Interface\\AddOns\\Tankalyze\\icon",
    args = {
      header = {
        type = "header",
        name = L["addonname"],
        icon = "Interface\\Icons\\Spell_Nature_Reincarnation",
        iconHeight = 16,
        iconWidth = 16,
        order = 1
      },
      mspacer = {
        type = "header",
        order = 2
      },
      grouponly = {
        type = "toggle",
        name = L["Group Only"],
        desc = L["Active only when player in group"],
        -- icon = "Interface\\Icons\\Spell_Nature_Reincarnation",
        get = function()
          return self.db.char.grouponly
        end,
        set = function()
          self.db.char.grouponly = not self.db.char.grouponly
        end,
        order = 3,
      },
      removesalv = {
        type = "toggle",
        name = L["RemoveSalvation"],
        desc = L["RemoveSalvationDesc"],
        -- icon = "Interface\\Icons\\Spell_Nature_Reincarnation",
        get = function()
          return self.db.char.removesalv
        end,
        set = function()
          self.db.char.removesalv = not self.db.char.removesalv
          -- Tankalyze:CheckSalvation()
        end,
        order = 4,
      },
      resists = {
        type = "group",
        order = 6,
        name = L["Resists"],
        desc = L["Settings for resists"],
        --icon = "Interface\\Icons\\Spell_Nature_Reincarnation",
        args = {
          taunt = {
            type = "toggle",
            name = L["Taunt"],
            desc = L["Announces resisted taunts"],
            icon = "Interface\\Icons\\Spell_Nature_Reincarnation",
            get = function()
              return self.db.char.resists.taunt
            end,
            set = function()
              self.db.char.resists.taunt = not self.db.char.resists.taunt
            end,
            order = 1,
          },
          growl = {
            type = "toggle",
            name = L["Growl"],
            desc = L["Announces resisted growls"],
            icon = "Interface\\Icons\\Ability_Physical_Taunt",
            get = function()
              return self.db.char.resists.growl
            end,
            set = function()
              self.db.char.resists.growl = not self.db.char.resists.growl
            end,
            order = 2,
          },
          reckoning = {
            type = "toggle",
            name = L["Hand of Reckoning"],
            desc = L["Announces resisted Hand of Reckoning"],
            icon = "Interface\\Icons\\Spell_Holy_SealOfWrath",
            get = function()
              return self.db.char.resists.reckoning
            end,
            set = function()
              self.db.char.resists.reckoning = not self.db.char.resists.reckoning
            end,
            order = 3,
          },
          earthshaker_slam = {
            type = "toggle",
            name = L["Earthshaker Slam"],
            desc = L["Announces resisted Earthshaker Slam"],
            icon = "Interface\\Icons\\Spell_Nature_Earthquake",
            get = function()
              return self.db.char.resists.earthshaker_slam
            end,
            set = function()
              self.db.char.resists.earthshaker_slam = not self.db.char.resists.earthshaker_slam
            end,
            order = 4,
          },
          mocking = {
            type = "toggle",
            name = L["Mocking Blow"],
            desc = L["Announces missed Mocking Blows"],
            icon = "Interface\\Icons\\Ability_Warrior_PunishingBlow",
            get = function()
              return self.db.char.resists.mocking
            end,
            set = function()
              self.db.char.resists.mocking = not self.db.char.resists.mocking
            end,
            order = 10,
          },
          shout = {
            type = "toggle",
            name = L["Challenging Shout"],
            desc = L["Announces resisted challenging shouts"],
            icon = "Interface\\Icons\\Ability_BullRush",
            get = function()
              return self.db.char.resists.shout
            end,
            set = function()
              self.db.char.resists.shout = not self.db.char.resists.shout
            end,
            order = 20,
          },
          roar = {
            type = "toggle",
            name = L["Challenging Roar"],
            desc = L["Announces resisted challenging roars"],
            icon = "Interface\\Icons\\Ability_Druid_ChallangingRoar",
            get = function()
              return self.db.char.resists.roar
            end,
            set = function()
              self.db.char.resists.roar = not self.db.char.resists.roar
            end,
            order = 21,
          },
          type = {
            type = "text",
            name = L["Announce To"],
            desc = L["Set where to announce"],
            --icon = "Interface\\Icons\\Ability_Warrior_BattleShout",
            get = function()
              return self.db.char.resists.type
            end,
            set = function(arg1)
              self.db.char.resists.type = arg1
            end,
            validate = { "GROUP_RW", "GROUP", "RAID", "PARTY", "CHANNEL", "YELL", "SAY", "DEBUG" },
            order = 30,
          },
          channel = {
            type = "text",
            name = L["Custom Chan"],
            desc = L["Name of the channel to send to (only used if Announce To is set to CHANNEL)"],
            --icon = "Interface\\Icons\\Spell_ChargePositive",
            get = function()
              return self.db.char.resists.channel
            end,
            set = function(arg1)
              self.db.char.resists.channel = arg1
            end,
            usage = "<any string>",
            order = 31,
          },
          messages = {
            type = "group",
            order = 40,
            name = L["Resists Messages"],
            desc = L["Message settings for resists"],
            --icon = "Interface\\Icons\\INV_Misc_Note_01",
            args = {
              taunt = {
                type = "text",
                name = L["Taunt"],
                desc = L["MessagesInfo"],
                icon = "Interface\\Icons\\Spell_Nature_Reincarnation",
                get = function()
                  return self.db.char.resists.messages.taunt
                end,
                set = function(arg1)
                  self.db.char.resists.messages.taunt = arg1
                end,
                usage = "<any string>",
                order = 1,
              },
              growl = {
                type = "text",
                name = L["Growl"],
                desc = L["MessagesInfo"],
                icon = "Interface\\Icons\\Ability_Physical_Taunt",
                get = function()
                  return self.db.char.resists.messages.growl
                end,
                set = function(arg1)
                  self.db.char.resists.messages.growl = arg1
                end,
                usage = "<any string>",
                order = 2,
              },
              reckoning = {
                type = "text",
                name = L["Hand of Reckoning"],
                desc = L["MessagesInfo"],
                icon = "Interface\\Icons\\Spell_Holy_Redemption",
                get = function()
                  return self.db.char.resists.messages.reckoning
                end,
                set = function(arg1)
                  self.db.char.resists.messages.reckoning = arg1
                end,
                usage = "<any string>",
                order = 3,
              },
              earthshaker_slam = {
                type = "text",
                name = L["Earthshaker Slam"],
                desc = L["MessagesInfo"],
                icon = "Interface\\Icons\\Spell_Nature_Earthquake",
                get = function()
                  return self.db.char.resists.messages.earthshaker_slam
                end,
                set = function(arg1)
                  self.db.char.resists.messages.earthshaker_slam = arg1
                end,
                usage = "<any string>",
                order = 4,
              },
              mocking = {
                type = "text",
                name = L["Mocking Blow"],
                desc = L["MessagesInfo"],
                icon = "Interface\\Icons\\Ability_Warrior_PunishingBlow",
                get = function()
                  return self.db.char.resists.messages.mocking
                end,
                set = function(arg1)
                  self.db.char.resists.messages.mocking = arg1
                end,
                usage = "<any string>",
                order = 4,
              },
              shout = {
                type = "text",
                name = L["Challenging Shout"],
                desc = L["MessagesInfoNoTarget"],
                icon = "Interface\\Icons\\Ability_BullRush",
                get = function()
                  return self.db.char.resists.messages.shout
                end,
                set = function(arg1)
                  self.db.char.resists.messages.shout = arg1
                end,
                usage = "<any string>",
                order = 5,
              },
              roar = {
                type = "text",
                name = L["Challenging Roar"],
                desc = L["MessagesInfoNoTarget"],
                icon = "Interface\\Icons\\Ability_Druid_ChallangingRoar",
                get = function()
                  return self.db.char.resists.messages.roar
                end,
                set = function(arg1)
                  self.db.char.resists.messages.roar = arg1
                end,
                usage = "<any string>",
                order = 6,
              },
            },
          },
        },
      },
      announces = {
        type = "group",
        order = 7,
        name = L["Announces"],
        desc = L["Settings for announces"],
        --icon = "Interface\\Icons\\Spell_Holy_AshesToAshes",
        args = {
          taunt = {
            type = "toggle",
            name = L["Taunt"],
            desc = L["Taunt"],
            icon = "Interface\\Icons\\Spell_Nature_Reincarnation",
            get = function()
              return self.db.char.announces.taunt
            end,
            set = function()
              self.db.char.announces.taunt = not self.db.char.announces.taunt
            end,
            order = 1,
          },
          growl = {
            type = "toggle",
            name = L["Growl"],
            desc = L["Growl"],
            icon = "Interface\\Icons\\Ability_Physical_Taunt",
            get = function()
              return self.db.char.announces.growl
            end,
            set = function()
              self.db.char.announces.growl = not self.db.char.announces.growl
            end,
            order = 2,
          },
          reckoning = {
            type = "toggle",
            name = L["Hand of Reckoning"],
            desc = L["Hand of Reckoning"],
            icon = "Interface\\Icons\\Spell_Holy_Redemption",
            get = function()
              return self.db.char.announces.reckoning
            end,
            set = function()
              self.db.char.announces.reckoning = not self.db.char.announces.reckoning
            end,
            order = 3,
          },
          earthshaker_slam = {
            type = "toggle",
            name = L["Earthshaker Slam"],
            desc = L["Earthshaker Slam"],
            icon = "Interface\\Icons\\Spell_Nature_Earthquake",
            get = function()
              return self.db.char.announces.earthshaker_slam
            end,
            set = function()
              self.db.char.announces.earthshaker_slam = not self.db.char.announces.earthshaker_slam
            end,
            order = 4,
          },
          mocking = {
            type = "toggle",
            name = L["Mocking Blow"],
            desc = L["Mocking Blow"],
            icon = "Interface\\Icons\\Ability_Warrior_PunishingBlow",
            get = function()
              return self.db.char.announces.mocking
            end,
            set = function()
              self.db.char.announces.mocking = not self.db.char.announces.mocking
            end,
            order = 12,
          },
          deathwish = {
            type = "toggle",
            name = L["Death Wish"],
            desc = L["Death Wish"],
            icon = "Interface\\Icons\\Spell_Shadow_DeathPact",
            get = function()
              return self.db.char.announces.deathwish
            end,
            set = function()
              self.db.char.announces.deathwish = not self.db.char.announces.deathwish
            end,
            order = 13,
          },
          wall = {
            type = "toggle",
            name = L["Shield Wall"],
            desc = L["Shield Wall"],
            icon = "Interface\\Icons\\Ability_Warrior_ShieldWall",
            get = function()
              return self.db.char.announces.wall
            end,
            set = function()
              self.db.char.announces.wall = not self.db.char.announces.wall
            end,
            order = 14,
          },
          stand = {
            type = "toggle",
            name = L["Last Stand"],
            desc = L["Last Stand"],
            icon = "Interface\\Icons\\Spell_Holy_AshesToAshes",
            get = function()
              return self.db.char.announces.stand
            end,
            set = function()
              self.db.char.announces.stand = not self.db.char.announces.stand
            end,
            order = 15,
          },
          gem = {
            type = "toggle",
            name = L["Lifegiving Gem"],
            desc = L["Lifegiving Gem"],
            icon = "Interface\\Icons\\INV_Misc_Gem_Pearl_05",
            get = function()
              return self.db.char.announces.gem
            end,
            set = function()
              self.db.char.announces.gem = not self.db.char.announces.gem
            end,
            order = 16,
          },
          shout = {
            type = "toggle",
            name = L["Challenging Shout"],
            desc = L["Challenging Shout"],
            icon = "Interface\\Icons\\Ability_BullRush",
            get = function()
              return self.db.char.announces.shout
            end,
            set = function()
              self.db.char.announces.shout = not self.db.char.announces.shout
            end,
            order = 17,
          },
          roar = {
            type = "toggle",
            name = L["Challenging Roar"],
            desc = L["Challenging Roar"],
            icon = "Interface\\Icons\\Ability_Druid_ChallangingRoar",
            get = function()
              return self.db.char.announces.roar
            end,
            set = function()
              self.db.char.announces.roar = not self.db.char.announces.roar
            end,
            order = 18,
          },
          type = {
            type = "text",
            name = L["Announce To"],
            desc = L["Set where to announce"],
            --icon = "Interface\\Icons\\Ability_Warrior_BattleShout",
            get = function()
              return self.db.char.announces.type
            end,
            set = function(arg1)
              self.db.char.announces.type = arg1
            end,
            validate = { "GROUP_RW", "GROUP", "RAID", "PARTY", "CHANNEL", "YELL", "SAY", "DEBUG" },
            order = 30,
          },
          channel = {
            type = "text",
            name = L["Custom Chan"],
            desc = L["Name of the channel to send to (only used if Announce To is set to CHANNEL)"],
            --icon = "Interface\\Icons\\Spell_ChargePositive",
            get = function()
              return self.db.char.announces.channel
            end,
            set = function(arg1)
              self.db.char.announces.channel = arg1
            end,
            usage = "<any string>",
            order = 31,
          },
          messages = {
            type = "group",
            order = 40,
            name = L["Announce Messages"],
            desc = L["Message settings for announces"],
            --icon = "Interface\\Icons\\INV_Misc_Note_01",
            args = {
              taunt = {
                type = "text",
                name = L["Taunt"],
                desc = L["MessagesInfo"],
                icon = "Interface\\Icons\\Spell_Nature_Reincarnation",
                get = function()
                  return self.db.char.announces.messages.taunt
                end,
                set = function(arg1)
                  self.db.char.announces.messages.taunt = arg1
                end,
                usage = "<any string>",
                order = 1,
              },
              growl = {
                type = "text",
                name = L["Growl"],
                desc = L["MessagesInfo"],
                icon = "Interface\\Icons\\Ability_Physical_Taunt",
                get = function()
                  return self.db.char.announces.messages.growl
                end,
                set = function(arg1)
                  self.db.char.announces.messages.growl = arg1
                end,
                usage = "<any string>",
                order = 2,
              },
              reckoning = {
                type = "text",
                name = L["Hand of Reckoning"],
                desc = L["MessagesInfo"],
                icon = "Interface\\Icons\\Spell_Holy_Redemption",
                get = function()
                  return self.db.char.announces.messages.reckoning
                end,
                set = function(arg1)
                  self.db.char.announces.messages.reckoning = arg1
                end,
                usage = "<any string>",
                order = 3,
              },
              earthshaker_slam = {
                type = "text",
                name = L["Earthshaker Slam"],
                desc = L["MessagesInfo"],
                icon = "Interface\\Icons\\Spell_Nature_Earthquake",
                get = function()
                  return self.db.char.announces.messages.earthshaker_slam
                end,
                set = function(arg1)
                  self.db.char.announces.messages.earthshaker_slam = arg1
                end,
                usage = "<any string>",
                order = 4,
              },
              mocking = {
                type = "text",
                name = L["Mocking Blow"],
                desc = L["MessagesInfo"],
                icon = "Interface\\Icons\\Ability_Warrior_PunishingBlow",
                get = function()
                  return self.db.char.announces.messages.mocking
                end,
                set = function(arg1)
                  self.db.char.announces.messages.mocking = arg1
                end,
                usage = "<any string>",
                order = 12,
              },
              deathwish = {
                type = "text",
                name = L["Death Wish"],
                desc = L["MessagesInfoNoTarget"],
                icon = "Interface\\Icons\\Spell_Shadow_DeathPact",
                get = function()
                  return self.db.char.announces.messages.deathwish
                end,
                set = function(arg1)
                  self.db.char.announces.messages.deathwish = arg1
                end,
                usage = "<any string>",
                order = 13,
              },
              wall = {
                type = "text",
                name = L["Shield Wall"],
                desc = L["MessagesInfoNoTarget"],
                icon = "Interface\\Icons\\Ability_Warrior_ShieldWall",
                get = function()
                  return self.db.char.announces.messages.wall
                end,
                set = function(arg1)
                  self.db.char.announces.messages.wall = arg1
                end,
                usage = "<any string>",
                order = 14,
              },
              stand = {
                type = "text",
                name = L["Last Stand"],
                desc = L["MessagesInfoNoTarget"],
                icon = "Interface\\Icons\\Spell_Holy_AshesToAshes",
                get = function()
                  return self.db.char.announces.messages.stand
                end,
                set = function(arg1)
                  self.db.char.announces.messages.stand = arg1
                end,
                usage = "<any string>",
                order = 15,
              },
              gem = {
                type = "text",
                name = L["Lifegiving Gem"],
                desc = L["MessagesInfoNoTarget"],
                icon = "Interface\\Icons\\INV_Misc_Gem_Pearl_05",
                get = function()
                  return self.db.char.announces.messages.gem
                end,
                set = function(arg1)
                  self.db.char.announces.messages.gem = arg1
                end,
                usage = "<any string>",
                order = 16,
              },
              shout = {
                type = "text",
                name = L["Challenging Shout"],
                desc = L["MessagesInfoNoTarget"],
                icon = "Interface\\Icons\\Ability_BullRush",
                get = function()
                  return self.db.char.announces.messages.shout
                end,
                set = function(arg1)
                  self.db.char.announces.messages.shout = arg1
                end,
                usage = "<any string>",
                order = 17,
              },
              roar = {
                type = "text",
                name = L["Challenging Roar"],
                desc = L["MessagesInfoNoTarget"],
                icon = "Interface\\Icons\\Ability_Druid_ChallangingRoar",
                get = function()
                  return self.db.char.announces.messages.roar
                end,
                set = function(arg1)
                  self.db.char.announces.messages.roar = arg1
                end,
                usage = "<any string>",
                order = 18,
              },
            },
          },
        },
      },
      mainTankMode = {
        type = "group",
        name = L["MainTankMode"],
        desc = L["MainTankModeDesc"],
        icon = "Interface\\Icons\\Ability_Warrior_DefensiveStance",
        args = {
          mainTank = {
            type = "toggle",
            name = "Enable Main Tank Mode",
            desc = "Toggle the Main Tank Mode",
            -- icon = "Interface\\Icons\\Ability_Warrior_DefensiveStance",
            get = function()
              return self.db.char.mainTank
            end,
            set = function()
              self.db.char.mainTank = not self.db.char.mainTank
              Tankalyze:CheckSalvation()
            end,
            order = 11,
          },
          duration = {
            type = "text",
            name = "Main Tank Duration",
            desc = "How long the main tank announce phase lasts at fight start",
            --icon = "Interface\\Icons\\Spell_ChargePositive",
            get = function()
              return self.db.char.mainTankDuration
            end,
            set = function(arg1)
              local n = tonumber(arg1)
              if n then
                self.db.char.mainTankDuration = n
              end
            end,
            usage = "<any string>",
            order = 21,
          },
        },
        order = 8,
      },
      mspacer1 = {
        type = "header",
        order = 9,
      },
      removesalv_notify = {
        type = "toggle",
        name = L["NotifySalvationRemoval"],
        desc = L["NotifySalvationRemovalDesc"],
        icon = "Interface\\Icons\\Spell_Holy_SealOfSalvation",
        get = function()
          return self.db.char.removesalv_notify
        end,
        set = function()
          self.db.char.removesalv_notify = not self.db.char.removesalv_notify
        end,
        order = 10,
      },
      alertSelf = {
        type = "toggle",
        name = L["Alert Self"],
        desc = L["Toggles alert in the standard UI Error Frame"],
        icon = "Interface\\Icons\\Ability_Warrior_BattleShout",
        get = function()
          return self.db.char.alertSelf
        end,
        set = function()
          self.db.char.alertSelf = not self.db.char.alertSelf
        end,
        order = 10,
      },
      sct = {
        type = "toggle",
        name = L["Scrolling Combat Text Alert"],
        desc = L["Toggles message sent to Scrolling Combat Text (if installed) as Combat Flag"],
        icon = "Interface\\Icons\\Spell_Lightning_LightningBolt01",
        get = function()
          return self.db.char.sct
        end,
        set = function()
          self.db.char.sct = not self.db.char.sct
        end,
        order = 11,
      },
      mspacer2 = {
        type = "header",
        order = 19,
      },
      humour = {
        type = "toggle",
        name = L["Humour"],
        desc = L["Do you have it?"],
        icon = "Interface\\Icons\\Ability_Suffocate",
        get = function()
          return self.db.char.humour
        end,
        set = function()
          self.db.char.humour = not self.db.char.humour
        end,
        order = 80,
      },
      log = {
        type = "toggle",
        name = L["Logging"],
        desc = L["Logging for Challenging Shout/Roar if you want to help"],
        icon = "Interface\\Icons\\INV_Misc_Note_01",
        get = function()
          return self.db.char.isLogging
        end,
        set = function()
          self.db.char.isLogging = not self.db.char.isLogging
        end,
        order = 82,
      },
      mspacer3 = {
        type = "header",
        order = 99,
      },
      test = {
        type = "execute",
        name = L["Test"],
        desc = L["Send test messages with current settings"],
        func = function() Tankalyze:Test() end,
        order = 100,
      },
      menu = {
        type = "execute",
        name = L["Menu"],
        desc = L["Show Menu"],
        guiHidden = true,
        func = function() Tankalyze:ShowMenu() end,
        order = 101,
      },
      mspacer4 = {
        type = "header",
        order = 102,
      },      
      fubar = { 
        type = "group", name = L["Fubar plugin"], desc = L["Fubar plugin options."], order=-15,
        args = {}
      }      
    },
  }
  
  -- redo this
  local _, englishClass = UnitClass("player")
  if (englishClass == "WARRIOR") then
    -- hide Shaman options
    self.opts.args.resists.args.earthshaker_slam = nil
    self.opts.args.announces.args.earthshaker_slam = nil
    self.opts.args.resists.args.messages.args.earthshaker_slam = nil
    self.opts.args.announces.args.messages.args.earthshaker_slam = nil
    -- hide Paladin options
    self.opts.args.resists.args.reckoning = nil
    self.opts.args.announces.args.reckoning = nil
    self.opts.args.resists.args.messages.args.reckoning = nil
    self.opts.args.announces.args.messages.args.reckoning = nil
    -- hide Druid options
    self.opts.args.resists.args.growl = nil
    self.opts.args.resists.args.roar = nil
    self.opts.args.resists.args.messages.args.growl = nil
    self.opts.args.resists.args.messages.args.roar = nil

    self.opts.args.announces.args.roar = nil
    self.opts.args.announces.args.growl = nil
    self.opts.args.announces.args.messages.args.roar = nil
    self.opts.args.announces.args.messages.args.growl = nil
  elseif (englishClass == "DRUID") then
    -- hide Shaman options
    self.opts.args.resists.args.earthshaker_slam = nil
    self.opts.args.announces.args.earthshaker_slam = nil
    self.opts.args.resists.args.messages.args.earthshaker_slam = nil
    self.opts.args.announces.args.messages.args.earthshaker_slam = nil
    -- hide Paladin options
    self.opts.args.resists.args.reckoning = nil
    self.opts.args.announces.args.reckoning = nil
    self.opts.args.resists.args.messages.args.reckoning = nil
    self.opts.args.announces.args.messages.args.reckoning = nil
    -- hide Warrior options
    self.opts.args.resists.args.taunt = nil
    self.opts.args.resists.args.mocking = nil
    self.opts.args.resists.args.shout = nil
    self.opts.args.resists.args.messages.args.taunt = nil
    self.opts.args.resists.args.messages.args.mocking = nil
    self.opts.args.resists.args.messages.args.shout = nil

    self.opts.args.announces.args.taunt = nil
    self.opts.args.announces.args.wall = nil
    self.opts.args.announces.args.stand = nil
    self.opts.args.announces.args.gem = nil
    self.opts.args.announces.args.shout = nil
    self.opts.args.announces.args.mocking = nil
    self.opts.args.announces.args.deathwish = nil
    self.opts.args.announces.args.messages.args.taunt = nil
    self.opts.args.announces.args.messages.args.wall = nil
    self.opts.args.announces.args.messages.args.stand = nil
    self.opts.args.announces.args.messages.args.gem = nil
    self.opts.args.announces.args.messages.args.shout = nil
    self.opts.args.announces.args.messages.args.mocking = nil
    self.opts.args.announces.args.messages.args.deathwish = nil
  elseif (englishClass == "PALADIN") then
    -- hide Shaman options
    self.opts.args.resists.args.earthshaker_slam = nil
    self.opts.args.announces.args.earthshaker_slam = nil
    self.opts.args.resists.args.messages.args.earthshaker_slam = nil
    self.opts.args.announces.args.messages.args.earthshaker_slam = nil
    -- hide Druid options
    self.opts.args.resists.args.growl = nil
    self.opts.args.resists.args.roar = nil
    self.opts.args.resists.args.messages.args.growl = nil
    self.opts.args.resists.args.messages.args.roar = nil

    self.opts.args.announces.args.growl = nil
    self.opts.args.announces.args.roar = nil
    self.opts.args.announces.args.messages.args.growl = nil
    self.opts.args.announces.args.messages.args.roar = nil
    -- hide Warrior options
    self.opts.args.resists.args.taunt = nil
    self.opts.args.resists.args.mocking = nil
    self.opts.args.resists.args.shout = nil
    self.opts.args.resists.args.messages.args.taunt = nil
    self.opts.args.resists.args.messages.args.mocking = nil
    self.opts.args.resists.args.messages.args.shout = nil

    self.opts.args.announces.args.taunt = nil
    self.opts.args.announces.args.wall = nil
    self.opts.args.announces.args.stand = nil
    self.opts.args.announces.args.gem = nil
    self.opts.args.announces.args.shout = nil
    self.opts.args.announces.args.mocking = nil
    self.opts.args.announces.args.deathwish = nil
    self.opts.args.announces.args.messages.args.taunt = nil
    self.opts.args.announces.args.messages.args.wall = nil
    self.opts.args.announces.args.messages.args.stand = nil
    self.opts.args.announces.args.messages.args.gem = nil
    self.opts.args.announces.args.messages.args.shout = nil
    self.opts.args.announces.args.messages.args.mocking = nil
    self.opts.args.announces.args.messages.args.deathwish = nil
  elseif (englishClass == "SHAMAN") then
    -- hide Paladin options
    self.opts.args.resists.args.reckoning = nil
    self.opts.args.announces.args.reckoning = nil
    self.opts.args.resists.args.messages.args.reckoning = nil
    self.opts.args.announces.args.messages.args.reckoning = nil
    -- hide Druid options
    self.opts.args.resists.args.growl = nil
    self.opts.args.resists.args.roar = nil
    self.opts.args.resists.args.messages.args.growl = nil
    self.opts.args.resists.args.messages.args.roar = nil

    self.opts.args.announces.args.growl = nil
    self.opts.args.announces.args.roar = nil
    self.opts.args.announces.args.messages.args.growl = nil
    self.opts.args.announces.args.messages.args.roar = nil
    -- hide Warrior options
    self.opts.args.resists.args.taunt = nil
    self.opts.args.resists.args.mocking = nil
    self.opts.args.resists.args.shout = nil
    self.opts.args.resists.args.messages.args.taunt = nil
    self.opts.args.resists.args.messages.args.mocking = nil
    self.opts.args.resists.args.messages.args.shout = nil

    self.opts.args.announces.args.taunt = nil
    self.opts.args.announces.args.wall = nil
    self.opts.args.announces.args.stand = nil
    self.opts.args.announces.args.gem = nil
    self.opts.args.announces.args.shout = nil
    self.opts.args.announces.args.mocking = nil
    self.opts.args.announces.args.deathwish = nil
    self.opts.args.announces.args.messages.args.taunt = nil
    self.opts.args.announces.args.messages.args.wall = nil
    self.opts.args.announces.args.messages.args.stand = nil
    self.opts.args.announces.args.messages.args.gem = nil
    self.opts.args.announces.args.messages.args.shout = nil
    self.opts.args.announces.args.messages.args.mocking = nil
    self.opts.args.announces.args.messages.args.deathwish = nil
  end

  --[[ Register chat commands ]]
  self:RegisterChatCommand(L["consolecommands"], self.opts)  

  waterfall:Register('Tankalyze', 'aceOptions', self.opts, 'title','Tankalyze Options','colorR', 0.8, 'colorG', 0.8, 'colorB', 0.0,
  'treeLevels', 3)--, 'treeType', "SECTIONS")

  Tankalyze:RegisterChatCommand({'/tankalyze', '/ttank'}, function()
    waterfall:Open('Tankalyze')
  end) 

  local t = AceLibrary("AceDB-2.0"):GetAceOptionsDataTable(Tankalyze)

  for k,v in pairs(t) do
    if self.opts.args[k] == nil then
      if k == "profile" then 
        self.opts.args["profile"] = v  
      else
        self.opts.args[k] = v
      end
    end
  end
  
  for k in t do t[k] = nil end
  table.setn(t,0)
  
  t = AceLibrary("FuBarPlugin-2.0"):GetAceOptionsDataTable(Tankalyze)
  for k,v in pairs(t) do
    if not self.opts.args.fubar.args[k] then  self.opts.args.fubar.args[k] = v  end
  end

  self.OnClick = function() waterfall:Open('Tankalyze') end
  self.OnMenuRequest = self.opts
  self.OnMenuRequest.args.lockTooltip.hidden = true
  self.OnMenuRequest.args.detachTooltip.hidden = true
  if not FuBar then
    self.OnMenuRequest.args.hide.guiName = "Hide minimap icon"
    self.OnMenuRequest.args.hide.desc = "Hide minimap icon"
  end
  dewdrop:InjectAceOptionsTable(self, self.OnMenuRequest)

  self:Print(L["translator"])
end

--[[ *** Do stuff when enabled? *** ]]
function Tankalyze:OnEnable()
  for k,v in fubarOptions do
    if self.OnMenuRequest.args[v] then 
      self.OnMenuRequest.args[v].hidden = true
    else
    end
  end  
  --[[ Register Events for example ]]

  -- CHAT_MSG_SPELL_SELF_DAMAGE:Your Taunt failed. Chromatic Dragonspawn is immune.
  -- CHAT_MSG_SPELL_SELF_DAMAGE:Your Challenging Shout failed. Chromatic Dragonspawn is immune.
  -- CHAT_MSG_SPELL_SELF_DAMAGE:Your Taunt was resisted by Chromatic Dragonspawn.
  -- self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE") -- Challenging Shout & Challenging Roar?
  -- self:RegisterEvent("SpellStatus_SpellCastInstant") -- SpellStatusMixin
  self:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE") -- Taunt, Growl & Mocking should stay in here
  self:RegisterEvent("UNIT_CASTEVENT")
  self:RegisterEvent("CHAT_MSG_COMBAT_SELF_MISSES")
  self:RegisterEvent("PLAYER_REGEN_ENABLED") -- setting combat start timer, salv removal
  self:RegisterEvent("PLAYER_REGEN_DISABLED") -- setting combat start timer, salv removal
  self:RegisterEvent("PLAYER_ENTERING_WORLD") -- setting player guid, salv removal
  self:RegisterEvent("PLAYER_AURAS_CHANGED") -- savl removal
  self:RegisterEvent("ONE_HANDED_MISSES")
  self:RegisterEvent("TRACKING_TIME_ENDED")
  self:RegisterEvent("SALVATION_REMOVED")
  self:RegisterEvent("CheckSalvation")
end

--[[ *** Do stuff when disabled? *** ]]
function Tankalyze:OnDisable()
  --[[ Unregister Events for example ]]
  self:UnregisterAllEvents()
end

local TauntFails = {
  "ResistTauntRX","ImmuneTauntRX1","ImmuneTauntRX2","MissTauntRX"
}
local GrowlFails = {
  "ResistGrowlRX","ImmuneGrowlRX1","ImmuneGrowlRX2","MissGrowlRX"
}
local ReckoningFails = {
  "ResistReckoningRX","ImmuneReckoningRX1","ImmuneReckoningRX2","MissReckoningRX"
}
local EarthshakerSlamFails = {
  "ResistEarthshakerSlamRX","ImmuneEarthshakerSlamRX1","ImmuneEarthshakerSlamRX2","MissEarthshakerSlamRX"
}
local taunt_whys = {"resisted", "immune", "immune", "missed"}
local mocking_whys = {"missed", "dodged", "parried", "immune"}
--[[ *** EVENTS *** ]]
function Tankalyze:CHAT_MSG_SPELL_PARTY_DAMAGE()
  --print(event..":"..tostring(arg1)..":"..tostring(arg2))
  -- Taunt, Growl
end

function Tankalyze:CheckSalvAuras()
  local threat_stance_ix = nil
  local threat_buff_ix = nil
  local threat_buff_id = nil

  local c = 0
  while true do
    local id = GetPlayerBuffID(c)
    if not id then break end

    -- if id == 25895 or id == 1038 or id == 12970 or id == 25289 then
    if id == 25895 or id == 1038 then -- greater salv or salv
      threat_buff_ix = c
      threat_buff_id = id
    elseif (id == 5487 or id == 9634) or id == 71 or id == 25780 then -- bears or def stance or rf
      threat_stance_ix = c
      -- print("stance "..SpellInfo(id))
    end
    if threat_buff_ix and threat_stance_ix then break end
    c = c + 1
  end
  return threat_stance_ix,threat_buff_ix,threat_buff_id
end

function Tankalyze:CheckSalvation(force)
  local removed = false
  if not force and Tankalyze:CheckGroupOnly() then return end
  if not force and (not (self.db.char.removesalv or self.db.char.mainTank)) then return end
  -- if not (in_combat or self.db.char.mainTank) then return end
  if Tankalyze:IsEventScheduled("SALVATION_REMOVED") then return end

  local threat_stance,threat_buff_ix,threat_buff_id = Tankalyze:CheckSalvAuras()

  -- weapon imbue for shaman
  local imbue = string.find(GetWeaponEnchantInfo("player") or "","^Rockbiter")
  if imbue then threat_stance = -1 end -- not an ix, but not nil

  -- defensive tactics + shield = threat stance
  local tname,_,_,_,_,levels = GetTalentInfo(3,18)
  if tname == "Defensive Tactics" and levels > 0 then
    local _,_,OH_ID = string.find(GetInventoryItemLink("player", 17) or "","item:(%d+)")
    _, _, _, _, _, itemType = GetItemInfo(OH_ID or "")
    if itemType and itemType ==  "Shields" then
      threat_stance = -1 -- not an ix, but not nil
    end
  end

  if (threat_stance or self.db.char.mainTank) and threat_buff_ix then
    CancelPlayerBuff(threat_buff_ix)
    Tankalyze:ScheduleEvent("SALVATION_REMOVED",0.2,threat_buff_id)
    removed = true
  end

  return removed,threat_stance and true or false
end

function Tankalyze:PLAYER_REGEN_DISABLED()
  at_combat_start = true
  in_combat = true

  -- Check salv. Did we start combat in a tank-mode? keep salv removed for the fight then unless toggled off
  local _,was_in_def = Tankalyze:CheckSalvation()
  if (was_in_def or self.db.char.mainTank) and not Tankalyze.salv_repeat_event then
    Tankalyze.salv_repeat_event = Tankalyze:ScheduleRepeatingEvent("CheckSalvation",1)
  end
  
  Tankalyze:ScheduleEvent("TRACKING_TIME_ENDED",self.db.char.mainTankDuration)
end

function Tankalyze:PLAYER_REGEN_ENABLED()
  in_combat = false
  if Tankalyze.salv_repeat_event then
    Tankalyze:CancelScheduledEvent(Tankalyze.salv_repeat_event)
    Tankalyze.salv_repeat_event = nil
  end
end

function Tankalyze:TRACKING_TIME_ENDED()
  -- print("itended")
  at_combat_start = false
end

function Tankalyze:SALVATION_REMOVED(id)
  if self.db.char.removesalv_notify then
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00Tankalyze:|r Cancelled [|cFF8FB9D0"..SpellInfo(id).."|r]")
  end
end

function Tankalyze:PLAYER_ENTERING_WORLD()
  _,player_guid = UnitExists("player")
  -- if player_guid then
    -- Tankalyze:CheckSalvation()
  -- end
  -- fill spellstore to check against for ability misses
  spellstore = {}
  local i = 1
  while true do
    local name, rank, id = GetSpellName(i, BOOKTYPE_SPELL) -- todo update all my addons to recheck spells on spellbook changes
    -- local name,tank,texture,minrange,maxrange = SpellInfo(id) 
    if not name then
        break
    end

    spellstore[name] = true

    i = i + 1
  end
end

-- mt always removes salv, only check outside of comabt for efficiency, combat has a scheduled check
function Tankalyze:PLAYER_AURAS_CHANGED()
  if not UnitAffectingCombat("player") and self.db.char.mainTank then
    Tankalyze:CheckSalvation()
  end
end

function Tankalyze:ONE_HANDED_MISSES(ability,type,target)
  if not at_combat_start or not self.db.char.mainTank then return end
  local _,_,OH_ID = string.find(GetInventoryItemLink("player", 17) or "","item:(%d+)")
  _, _, _, _, _, itemType = GetItemInfo(OH_ID or "")

  -- TODO: localize
  local onehanded = itemType == nil or itemType == "Shields" or itemType == "Miscellaneous"
  local chan = self.db.char.resists.type
  if ability == "MELEE" and onehanded then
    ability = "Melee Hit"
    chan = self.db.char.announces.type
  end
  if type == "MISS" and ability ~= "MELEE" then
    self:Announce(">>> "..ability.." missed "..target.." <<<", chan)
  elseif type == "DODGE" and ability ~= "MELEE" then
    self:Announce(">>> "..ability.." was dodged by "..target.." <<<", chan)
  elseif type == "PARRY" and ability ~= "MELEE" then
    self:Announce(">>> "..ability.." was parried by "..target.." <<<", chan)
  elseif type == "IMMUNE" and ability ~= "MELEE" then
    self:Announce(">>> "..ability.." failed, "..target.." was Immune <<<", chan)
  end
end

function Tankalyze:CHAT_MSG_COMBAT_SELF_MISSES(msg)
  -- print(msg)

  local Misses = {
    L["MeleeMiss"],
    L["MeleeDodge"],
    L["MeleeParry"],
    L["MeleeFail"],
  }
  local ix,target
  for i,v in ipairs(Misses) do
    local _,_,v_target = string.find(msg,v)
    if v_target then
      ix,target = i,v_target
      break
    end
  end

  if ix == 1 then
    Tankalyze:TriggerEvent("ONE_HANDED_MISSES","MELEE","MISS",target)
  elseif ix == 2 then
    Tankalyze:TriggerEvent("ONE_HANDED_MISSES","MELEE","DODGE",target)
  elseif ix == 3 then
    Tankalyze:TriggerEvent("ONE_HANDED_MISSES","MELEE","PARRY",target)
  elseif ix == 4 then
    Tankalyze:TriggerEvent("ONE_HANDED_MISSES","MELEE","IMMUNE",target)
  end
end

function Tankalyze:CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE()
  --print(event..":"..tostring(arg1)..":"..tostring(arg2))
  -- Taunt, Growl
end

function Tankalyze:CHAT_MSG_SPELL_PET_DAMAGE()
  --print(event..":"..tostring(arg1)..":"..tostring(arg2))
  -- Growl, Torment
end

function Tankalyze:CHAT_MSG_SPELL_SELF_DAMAGE(msg)
  --[[ An event we are subscribing too ]]

  -- print(msg)

  local _, _, UsedMockingBlow = string.find(msg, L["MockingBlowRX"])
  local _, _, UsedChallengingShout = string.find(msg, L["ChallengingShoutRX"])
  local _, _, UsedChallengingRoar = string.find(msg, L["ChallengingRoarRX"])

  if ((UsedChallengingShout) and (self.db.char.isLogging)) then
    self.db.char.logShout[time()] = "(1) "..msg
  end
  if ((UsedChallengingRoar) and (self.db.char.isLogging)) then
    self.db.char.logRoar[time()] = "(1) "..msg
  end

  -- handled with general melee below
  -- if (UsedMockingBlow) then
  --   local MockingBlowHit = string.find(msg, L["MockingBlowSuccessRX"])
  --   -- check here for failure and report why
  --   -- ["TauntMessage"] = ">>> Taunt failed against: {t} ({l}) <<<",
  --   -- ["TauntMessage"] = ">>> Taunt {r} against: {t} ({l}) <<<",

  --   if (not MockingBlowHit) then
  --     self:AnnounceResist(self.db.char.resists.messages.mocking, self.db.char.resists.messages.mockingSCT)
  --     return
  --   end
  -- end

  if self.db.char.resists.taunt then
    for i,key in ipairs(TauntFails) do
      if string.find(msg,L[key]) then
        self:AnnounceResist(self.db.char.resists.messages.taunt, self.db.char.resists.messages.tauntSCT, taunt_whys[i])
        return
      end
    end
  end
  
  if self.db.char.resists.growl then
    for i,key in ipairs(GrowlFails) do
      local _,_,GrowlFailed = string.find(msg,L[key])
      if string.find(msg,L[key]) then  
        self:AnnounceResist(self.db.char.resists.messages.growl, self.db.char.resists.messages.growlSCT, taunt_whys[i])
        return
      end
    end
  end
  if self.db.char.resists.reckoning then
    for i,key in ipairs(ReckoningFails) do
      if string.find(msg,L[key]) then
        self:AnnounceResist(self.db.char.resists.messages.reckoning, self.db.char.resists.messages.reckoningSCT, taunt_whys[i])
        return
      end
    end
  end

  if self.db.char.resists.earthshaker_slam then
    for i,key in ipairs(EarthshakerSlamFails) do
      if string.find(msg,L[key]) then
        self:AnnounceResist(self.db.char.resists.messages.earthshaker_slam, self.db.char.resists.messages.earthshaker_slamSCT, taunt_whys[i])
        return
      end
    end
  end

  -- check for general yellow fails
  -- TODO maybe check for resists too, e.g. exercism for a pulling paladin
  local Misses = {
    L["MeleeAbilityMiss"],
    L["MeleeAbilityDodge"],
    L["MeleeAbilityParry"],
    L["MeleeAbilityFail"],
  }
  local ix,ability,target
  for i,v in ipairs(Misses) do
    local _,_,v_ability,v_target = string.find(msg,v)
    if v_ability and spellstore[v_ability] and v_target then
      ix,ability,target = i,v_ability,v_target
      break
    end
  end

  if ability == L["Mocking Blow"] and ix then
    self:AnnounceResist(self.db.char.resists.messages.mocking, self.db.char.resists.messages.mockingSCT, mocking_whys[ix])
  elseif ix == 1 then
    Tankalyze:TriggerEvent("ONE_HANDED_MISSES",ability,"MISS",target)
  elseif ix == 2 then
    Tankalyze:TriggerEvent("ONE_HANDED_MISSES",ability,"DODGE",target)
  elseif ix == 3 then
    Tankalyze:TriggerEvent("ONE_HANDED_MISSES",ability,"PARRY",target)
  elseif ix == 4 then
    Tankalyze:TriggerEvent("ONE_HANDED_MISSES",ability,"IMMUNE",target)
  end
end

-- function Tankalyze:SpellStatus_SpellCastInstant(sId, sName, sRank, sFullName, sCastTime)
-- todo: convert these to simply use id's
function Tankalyze:UNIT_CASTEVENT(casterGuid,targetGuid,type,sId,sCastTime)
  local sName, sRank = SpellInfo(sId)
  if arg3 ~= "CAST" then return end
  if casterGuid ~= player_guid then return end

  if (sName == L["Taunt"]) then
    tried_vs = targetGuid
		if self.db.char.announces.taunt then
    	self:AnnounceTaunt(self.db.char.announces.messages.taunt, self.db.char.announces.messages.tauntSCT)
		end
  elseif (sName == L["Growl"]) then
    tried_vs = targetGuid
    if self.db.char.announces.growl then
      self:AnnounceTaunt(self.db.char.announces.messages.growl, self.db.char.announces.messages.growlSCT)
    end
  elseif (sName == L["Hand of Reckoning"]) then
    tried_vs = targetGuid
    if self.db.char.announces.reckoning then
      self:AnnounceTaunt(self.db.char.announces.messages.reckoning, self.db.char.announces.messages.reckoningSCT)
    end
  elseif (sName == L["Earthshaker Slam"]) then
    tried_vs = targetGuid
    if self.db.char.announces.earthshaker_slam then
      self:AnnounceTaunt(self.db.char.announces.messages.earthshaker_slam, self.db.char.announces.messages.earthshaker_slamSCT)
    end
  elseif (sName == L["Mocking Blow"]) then
    tried_vs = targetGuid
    if self.db.char.announces.mocking then
    	self:AnnounceTaunt(self.db.char.announces.messages.mocking, self.db.char.announces.messages.mockingSCT)
		end
  elseif (sName == L["Death Wish"]) then
    if self.db.char.announces.deathwish and not self.db.char.mainTank then
      self:AnnounceInfo(self.db.char.announces.messages.deathwish)
    elseif self.db.char.mainTank then
      self:Announce(self.db.char.announces.messages.deathwish,"YELL")
    end
  elseif ((sName == L["Shield Wall"]) and (self.db.char.announces.wall)) then
    self:AnnounceInfo(self.db.char.announces.messages.wall)
  -- last stand is two buffs, we only want to detect it once so use an id instead
  elseif (sId == 12976 and (self.db.char.announces.stand)) then
    self:AnnounceInfo(self.db.char.announces.messages.stand)
  elseif ((sName == L["Gift of Life"]) and (self.db.char.announces.gem)) then
    self:AnnounceInfo(self.db.char.announces.messages.gem)
  elseif ((sName == L["Challenging Shout"]) and (self.db.char.announces.shout)) then
    self:AnnounceInfo(self.db.char.announces.messages.shout)
  elseif ((sName == L["Challenging Roar"]) and (self.db.char.announces.roar)) then
    self:AnnounceInfo(self.db.char.announces.messages.roar)
  elseif ((sName == L["Rend"]) and (self.db.char.humour) and (UnitClassification("target") == "worldboss")) then
    self:Announce(L["GG, I just put rend on a worldboss!"], "GROUP")
  end
end

--[[ *** Functions *** ]]


-- SpellstatusV2IndexToIcon
local raidMarkIcon = {
  "",
  "|cFFF7EF52[Star]|r", --u+2726
  "|cFFE76100[Circle]|r", --u+25CF
  "|cFFDE55E7[Diamond]|r", --u+2666
  "|cFF2BD923[Triangle]|r", --u+25BC
  "|cFF8FB9D0[Moon]|r", --u+263D
  "|cFF00B9F3[Square]|r", --u+25A0
  "|cFFB20A05[X]|r", --u+2716
  "|cFFF1EFE4[Skull]|r", --u+263B
}

function Tankalyze:AnnounceTaunt(msg, msgSCT)
  local target = tried_vs or "target"
  local TargetName = UnitName(target)
  local TargetLevel = UnitLevel(target) -- If the unit's level is unknown, i.e. a Level ?? target, or is a special boss, UnitLevel() will return -1
  local TargetMark = raidMarkIcon[(GetRaidTargetIndex(target) or 0) + 1]

  local TargetClassification = UnitClassification(target) -- "worldboss", "rareelite", "elite", "rare" or "normal"
  if ((not TargetLevel) or (TargetLevel == -1)) then TargetLevel = "??" end
  if (not TargetName) then TargetName = L["<No Target>"] end

  if (TargetClassification == L["ClassificationBoss"]) then
    TargetLevel = "Boss"
    -- TargetLevel = L["level "].."??, Boss"
  elseif (TargetClassification == L["ClassificationElite"]) then
    TargetLevel = L["level "].."+"..TargetLevel
  else
    TargetLevel = L["level "]..TargetLevel
  end

  if ((UnitIsFriend("player", target)) and (self.db.char.humour)) then
    TargetName = L["<Friendly Target>"]
    TargetLevel = L["go me"]
  end
  local alertString = string.gsub(string.gsub(string.gsub(msg, "{t}", TargetName), "{l}", TargetLevel), "{m}", TargetMark)
  local alertStringShort = string.gsub(string.gsub(msgSCT, "{t}", TargetName), "{l}", TargetLevel)

  if ((self.db.char.sct) and IsAddOnLoaded("sct")) then --if ((self.db.char.sct) and (SCT))then
    --SCT:Display_Event("SHOWMISS", alertStringShort)
    SCT:Display_Event("SHOWCOMBAT", alertStringShort)
  end

  self:Announce(alertString, self.db.char.announces.type, self.db.char.announces.channel)
end

function Tankalyze:AnnounceResist(msg, msgSCT, why)
  local target = tried_vs or "target"
  local Why = why or "failed"
  local TargetName = UnitName(target)
  local TargetLevel = UnitLevel(target) -- If the unit's level is unknown, i.e. a Level ?? target, or is a special boss, UnitLevel() will return -1
  local TargetClassification = UnitClassification(target) -- "worldboss", "rareelite", "elite", "rare" or "normal"
  if ((not TargetLevel) or (TargetLevel == -1)) then TargetLevel = "??" end
  if (not TargetName) then TargetName = L["<No Target>"] end

  if (TargetClassification == L["ClassificationBoss"]) then
    TargetLevel = "Boss"
    -- TargetLevel = L["level "].."??, Boss"
  elseif (TargetClassification == L["ClassificationElite"]) then
    TargetLevel = L["level "].."+"..TargetLevel
  else
    TargetLevel = L["level "]..TargetLevel
  end

  if ((UnitIsFriend("player", target)) and (self.db.char.humour)) then
    TargetName = L["<Friendly Target>"]
    TargetLevel = L["go me"]
  end

  local alertString = string.gsub(string.gsub(string.gsub(msg, "{r}", Why), "{t}", TargetName), "{l}", TargetLevel)
  local alertStringShort = string.gsub(string.gsub(string.gsub(msgSCT, "{r}", Why), "{t}", TargetName), "{l}", TargetLevel)

  if (self.db.char.alertSelf) then
    UIErrorsFrame:AddMessage(alertString)
  end
  if ((self.db.char.sct) and IsAddOnLoaded("sct")) then --if ((self.db.char.sct) and (SCT))then
    --SCT:Display_Event("SHOWMISS", alertStringShort)
    SCT:Display_Event("SHOWCOMBAT", alertStringShort)
  end

  self:Announce(alertString, self.db.char.resists.type, self.db.char.resists.channel)
  tried_vs = nil -- reset who you tried on
end

function Tankalyze:AnnounceInfo(msg)
  self:Announce(msg, self.db.char.announces.type, self.db.char.announces.channel)
end

function Tankalyze:CheckGroupOnly()
  return self.db.char.grouponly and not (GetNumPartyMembers() + GetNumRaidMembers() > 0)
end

function Tankalyze:Announce(msg, type, channel)
  if Tankalyze:CheckGroupOnly() then return end
  if ((type == "GROUP") or (type == "GROUP_RW")) then
    local whereTo = nil
    if (GetNumRaidMembers() > 0) then
      whereTo = "RAID"
      if (type == "GROUP_RW") then
         if (IsRaidOfficer()) then
          whereTo = "RAID_WARNING"
        end
      end
    elseif (GetNumPartyMembers() > 0) then
      whereTo = "PARTY"
    end
    if (whereTo) then
      SendChatMessage(msg, whereTo)
    --[[ else
      self:Print(L["|cffffff7fDebug : |r"]..msg) ]]
    end
  elseif (type == "DEBUG") then
    self:Print(L["|cffffff7fDebug : |r"]..msg)
  elseif (type == "CHANNEL") then
    local chanIndex = GetChannelName(channel)
    if ((chanIndex) and (chanIndex > 0)) then
      SendChatMessage(msg, type, nil, chanIndex);
    else
      local chanError = string.gsub(L["Custom channel not found"], "{c}", channel)
      self:Print(chanError)
    end
  else
    SendChatMessage(msg, type)
  end
end

function Tankalyze:ShowMenu()
  dewdrop:Open(UIParent, 'children', function() dewdrop:FeedAceOptionsTable(self.opts) end, 'cursorX', true, 'cursorY', true)
end

function Tankalyze:Test()
  local localizedClass, englishClass = UnitClass("player")
  if (englishClass == "WARRIOR") then
    self:AnnounceResist("(TEST)"..self.db.char.resists.messages.taunt, "(TEST)"..self.db.char.resists.messages.tauntSCT)
    self:AnnounceInfo("(TEST)"..self.db.char.announces.messages.shout)
  elseif (englishClass == "DRUID") then
    self:AnnounceResist("(TEST)"..self.db.char.resists.messages.growl, "(TEST)"..self.db.char.resists.messages.growlSCT)
    self:AnnounceInfo("(TEST)"..self.db.char.announces.messages.roar)
  end
  
  self:Announce("(TEST)", "CHANNEL", "WhatSanePersonWouldBeInAChanWithThisName")
end