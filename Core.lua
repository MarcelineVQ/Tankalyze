--[[
	TODO LIST:
	- Challenging Shout (Challenging Roar)
	- (?) Whisper Target on fail
	- (?) Nightfall
]]
--[[ *** Create Ace2 AddOn *** ]]
Tankalyze = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0", "AceConsole-2.0", "AceDB-2.0", "AceHook-2.1", "AceDebug-2.0", "FuBarPlugin-2.0")
local L = AceLibrary("AceLocale-2.2"):new("Tankalyze")
local status = AceLibrary("SpellStatus-1.0")
local dewdrop = AceLibrary("Dewdrop-2.0")
local waterfall = AceLibrary("Waterfall-1.0")

local _, playerclass = UnitClass("player")
if ((playerclass ~= "WARRIOR") and (playerclass ~= "DRUID")) then
	DisableAddOn("Tankalyze")
	return
end

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
			growl = false,
			mocking = true,
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
			},
		},
		
		announces = {
			taunt = false,
			wall = false,
			stand = false,
			gem = false,
			shout = false,
			roar = false,
			channel = "Tankalyze",
			type = "SAY", -- "GROUP_RW", "GROUP", "RAID", "PARTY", "CHANNEL", "YELL", "SAY", "DEBUG"
			messages = {
				taunt = L["TauntUsedMessage"],
				tauntSCT = L["TauntUsedMessageSCT"],
				wall = L["WallUsedMessage"],
				stand = L["StandUsedMessage"],
				gem = L["GemUsedMessage"],
				shout = L["ShoutUsedMessage"],
				roar = L["RoarUsedMessage"],
			},
		},
		
		alertSelf = false,
		sct = false,
		humour = true,
		
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
	  	resists = {
	  		type = "group",
	  		order = 3,
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
					      order = 3,
							},
							shout = {
								type = "text",
							  name = L["Challenging Shout"],
								desc = L["MessagesInfo"],
								icon = "Interface\\Icons\\Ability_BullRush",
								get = function()
									return self.db.char.resists.messages.shout
								end,
							  set = function(arg1)
							  	self.db.char.resists.messages.shout = arg1
							  end,
							  usage = "<any string>",
					      order = 4,
							},
							roar = {
								type = "text",
							  name = L["Challenging Roar"],
								desc = L["MessagesInfo"],
								icon = "Interface\\Icons\\Ability_Druid_ChallangingRoar",
								get = function()
									return self.db.char.resists.messages.roar
								end,
							  set = function(arg1)
							  	self.db.char.resists.messages.roar = arg1
							  end,
							  usage = "<any string>",
					      order = 5,
							},
			  		},
			  	},
				},
	  	},
	  	announces = {
	  		type = "group",
	  		order = 4,
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
			      order = 2,
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
			      order = 3,
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
			      order = 4,
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
			      order = 5,
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
			      order = 6,
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
					      order = 2,
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
					      order = 3,
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
					      order = 4,
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
					      order = 5,
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
					      order = 6,
							},
						},
					},
				},
	  	},
	  	mspacer1 = {
				type = "header",
				order = 9,
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
	      order = 81,
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
	
	local _, englishClass = UnitClass("player")
	if (englishClass == "WARRIOR") then
		-- Ugly hide Druid options
		self.opts.args.resists.args.growl = nil
		self.opts.args.resists.args.roar = nil
		self.opts.args.resists.args.messages.args.growl = nil
		self.opts.args.resists.args.messages.args.roar = nil
		
		self.opts.args.announces.args.roar = nil
		self.opts.args.announces.args.messages.args.roar = nil
	elseif (englishClass == "DRUID") then
		-- Ugly hide Warrior options
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
		self.opts.args.announces.args.messages.args.taunt = nil
		self.opts.args.announces.args.messages.args.wall = nil
		self.opts.args.announces.args.messages.args.stand = nil
		self.opts.args.announces.args.messages.args.gem = nil
		self.opts.args.announces.args.messages.args.shout = nil
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
		if not self.opts.args.fubar.args[k] then	self.opts.args.fubar.args[k] = v	end
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
  self:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE") -- Taunt, Growl & Mocking should stay in here
  -- self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE") -- Challenging Shout & Challenging Roar?
  -- self:RegisterEvent("SpellStatus_SpellCastInstant") -- SpellStatusMixin
  self:RegisterEvent("UNIT_CASTEVENT") -- SpellStatusMixin
  self:RegisterEvent("CHAT_MSG_SPELL_PARTY_DAMAGE") -- group member taunts (does it fire for raid member not in my party?)
  self:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE") -- friendly player taunts
  self:RegisterEvent("CHAT_MSG_SPELL_PET_DAMAGE") -- pet taunts
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
--[[ *** EVENTS *** ]]
function Tankalyze:CHAT_MSG_SPELL_PARTY_DAMAGE()
	--print(event..":"..tostring(arg1)..":"..tostring(arg2))
  -- Taunt, Growl
end

function Tankalyze:CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE()
	--print(event..":"..tostring(arg1)..":"..tostring(arg2))
  -- Taunt, Growl
end

function Tankalyze:CHAT_MSG_SPELL_PET_DAMAGE()
	--print(event..":"..tostring(arg1)..":"..tostring(arg2))
  -- Growl, Torment
end

local tried_vs = nil
function Tankalyze:CHAT_MSG_SPELL_SELF_DAMAGE()
	--[[ An event we are subscribing too ]]

	local _, _, UsedMockingBlow = string.find(arg1, L["MockingBlowRX"])
	local _, _, UsedChallengingShout = string.find(arg1, L["ChallengingShoutRX"])
	local _, _, UsedChallengingRoar = string.find(arg1, L["ChallengingRoarRX"])

	if (UsedMockingBlow) then
		local MockingBlowHit = string.find(arg1, L["MockingBlowSuccessRX"])

		if (not MockingBlowHit) then
			self:AnnounceResist(self.db.char.resists.messages.mocking, self.db.char.resists.messages.mockingSCT)
		end
	end

	if ((UsedChallengingShout) and (self.db.char.isLogging)) then
		self.db.char.logShout[time()] = "(1) "..arg1
	end
	if ((UsedChallengingRoar) and (self.db.char.isLogging)) then
		self.db.char.logRoar[time()] = "(1) "..arg1
	end

	local TauntFailed = false
	for _,key in ipairs(TauntFails) do
		local _,_,TauntFailed = string.find(arg1,L[key])
		if (TauntFailed) then 
			self:AnnounceResist(self.db.char.resists.messages.taunt, self.db.char.resists.messages.tauntSCT)
			break	
		end
	end
	local GrowlFailed = false
	for _,key in ipairs(GrowlFails) do
		local _,_,GrowlFailed = string.find(arg1,L[key])
		if (GrowlFailed) then	
			self:AnnounceResist(self.db.char.resists.messages.growl, self.db.char.resists.messages.growlSCT)
			break	
		end
	end
end

-- function Tankalyze:CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE()
-- 	local _, _, UsedChallengingShout = string.find(arg1, L["ChallengingShoutRX"])
-- 	local _, _, UsedChallengingRoar = string.find(arg1, L["ChallengingRoarRX"])

-- 	if ((UsedChallengingShout) and (self.db.char.isLogging)) then
-- 		self.db.char.logShout[time()] = "(2) "..arg1
-- 	end
-- 	if ((UsedChallengingRoar) and (self.db.char.isLogging)) then
-- 		self.db.char.logRoar[time()] = "(2) "..arg1
-- 	end
-- end


-- function Tankalyze:SpellStatus_SpellCastInstant(sId, sName, sRank, sFullName, sCastTime)
function Tankalyze:UNIT_CASTEVENT(casterGuid,targetGuid,type,sId,sCastTime)
  local sName, sRank = SpellInfo(sId)
	print(sName)

	if ((sName == L["Taunt"]) and (self.db.char.announces.taunt)) then
		tried_vs = targetGuid
		self:AnnounceTaunt(self.db.char.announces.messages.taunt, self.db.char.announces.messages.tauntSCT)
	elseif (sName == L["Mocking Blow"]) then
		tried_vs = targetGuid
	elseif (sName == L["Challenging Shout"]) then
		tried_vs = targetGuid
	elseif ((sName == L["Shield Wall"]) and (self.db.char.announces.wall)) then
		self:AnnounceInfo(self.db.char.announces.messages.wall)
	elseif ((sName == L["Last Stand"]) and (self.db.char.announces.stand)) then
		self:AnnounceInfo(self.db.char.announces.messages.stand)
	elseif ((sName == L["Lifegiving Gem"]) and (self.db.char.announces.gem)) then
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

function Tankalyze:AnnounceTaunt(msg, msgSCT)
	local target = tried_vs
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

	local alertString = string.gsub(string.gsub(msg, "{t}", TargetName), "{l}", TargetLevel)
	local alertStringShort = string.gsub(string.gsub(msgSCT, "{t}", TargetName), "{l}", TargetLevel)

	if ((self.db.char.sct) and IsAddOnLoaded("sct")) then --if ((self.db.char.sct) and (SCT))then
		--SCT:Display_Event("SHOWMISS", alertStringShort)
		SCT:Display_Event("SHOWCOMBAT", alertStringShort)
	end
	
	self:Announce(alertString, self.db.char.announces.type, self.db.char.announces.channel)
end

function Tankalyze:AnnounceResist(msg, msgSCT)
	local target = tried_vs
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

	local alertString = string.gsub(string.gsub(msg, "{t}", TargetName), "{l}", TargetLevel)
	local alertStringShort = string.gsub(string.gsub(msgSCT, "{t}", TargetName), "{l}", TargetLevel)

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

function Tankalyze:Announce(msg, type, channel)
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