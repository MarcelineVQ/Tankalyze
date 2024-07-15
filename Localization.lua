local L = AceLibrary("AceLocale-2.2"):new("Tankalyze")

L:RegisterTranslations("enUS", function() return {
	["addonname"] = "Tankalyze |cff7fff7f -Ace2-|r",
	["author"] = "Tristan - Frostmane.eu",
	["translator"] = "Using translation by: Tristan - Frostmane.eu",
	["consolecommands"] = {"/ttankcl", "/ttauntcl"},
	
	["Menu"] = true,
	["Show Menu"] = true,
	
	["ResistTauntRX"] = "Your Taunt was resisted by (.+)",
	["ImmuneTauntRX1"] = "(.+) is immune to your Taunt%.",
	["ImmuneTauntRX2"] = "Your Taunt failed%. (.+) is immune%.",
	["MissTauntRX"] = "Your Taunt missed (.+)",
	["ResistGrowlRX"] = "Your Growl was resisted by (.+)",
	["ImmuneGrowlRX1"] = "(.+) is immune to your Growl%.",
	["ImmuneGrowlRX2"] = "Your Growl failed%. (.+) is immune%.",
	["MissGrowlRX"] = "Your Growl missed (.+)",	
	["TauntRX"] = "(.*)Taunt(.*)",
	["MockingBlowRX"] = "(.*)Mocking Blow(.*)",
	["MockingBlowSuccessRX"] = "Your Mocking Blow (.+) for (.+)",
	["ChallengingShoutRX"] = "(.*)Challenging Shout(.*)",
	["ChallengingRoarRX"] = "(.*)Challenging Roar(.*)",
	
	["TauntMessage"] = ">>> Taunt failed against: {t} ({l}) <<<",
	["TauntMessageSCT"] = "Taunt failed: {t}",
	["GrowlMessage"] = ">>> Growl failed against: {t} ({l}) <<<",
	["GrowlMessageSCT"] = "Growl failed: {t}",
	["MockingMessage"] = ">>> Mocking Blow missed against: {t} ({l}) <<<",
	["MockingMessageSCT"] = "Mocking Blow missed: {t}",
	["ShoutMessage"] = ">>> Challenging Shout failed against: {t} ({l}) <<<",
	["ShoutMessageSCT"] = "Challenging Shout failed: {t}",
	["RoarMessage"] = ">>> Challenging Roar failed against: {t} ({l}) <<<",
	["RoarMessageSCT"] = "Challenging Roar failed: {t}",
	["level "] = true,
	["MessagesInfo"] = "Type the text you want to use for the setting {t} will be swapped for targetname and {l} for level (case sensitive)",
	["MessagesInfoNoTarget"] = "Type the text you want to use for the setting",
	["TauntUsedMessage"] = ">>> Taunted {t} {m} <<<",
	["TauntUsedMessageSCT"] = ">>> Taunted {t} <<<",
	["MockingUsedMessage"] = ">>> Mockinging Blow on {t} {m} <<<",
	["MockingUsedMessageSCT"] = ">>> Mocking {t} <<<",
	["WallUsedMessage"] = ">>> Shield Walling <<<",
	["DeathWishUsedMessage"] = ">>> Death Wish used <<<",
	["StandUsedMessage"] = ">>> Last Stand used <<<",
	["GemUsedMessage"] = ">>> Lifegiving Gem used <<<",
	["ShoutUsedMessage"] = ">>> Challenging Shout used (6 sec) <<<",
	["RoarUsedMessage"] = ">>> Challenging Roar used (6 sec) <<<",
	
	["Group Only"] = true,
	["Active only when player in group"] = true,

	["Resists"] = true,
	["Settings for resists"] = true,
	["Resists Messages"] = true,
	["Message settings for resists"] = true,
	["Taunt"] = true,
	["Announces resisted taunts"] = true,
	["Growl"] = true,
	["Announces resisted growls"] = true,
	["Mocking Blow"] = true,
	["Announces missed Mocking Blows"] = true,
	["Challenging Shout"] = true,
	["Announces resisted challenging shouts"] = true,
	["Challenging Roar"] = true,
	["Announces resisted challenging roars"] = true,
	
	["Announce To"] = true,
	["Set where to announce"] = true,
	["Custom Chan"] = true,
	["Name of the channel to send to (only used if Announce To is set to CHANNEL)"] = true,
	["Alert Self"] = true,
	["Toggles alert in the standard UI Error Frame"] = true,
	["Scrolling Combat Text Alert"] = true,
	["Toggles message sent to Scrolling Combat Text (if installed) as Combat Flag"] = true,
	
	["Announces"] = true,
	["Settings for announces"] = true,
	["Announce Messages"] = true,
	["Message settings for announces"] = true,
	["Death Wish"] = true,
	["Shield Wall"] = true,
	["Challenging Shout"] = true,
	["Challenging Roar"] = true,
	["Last Stand"] = true,
	["Lifegiving Gem"] = true,
	["Used"] = " used",
	["<No Target>"] = true,
	["<Friendly Target>"] = true,
	["go me"] = true,
	["GG, I just put rend on a worldboss!"] = true,
	
	["Test"] = true,
	["Send test messages with current settings"] = true,
	
	["Custom channel [{c}] not found, join it for functionallity to be restored"] = true,
	["Custom channel [{c}] not found, please type |cffffff7f/join {c}|r in chat"] = "Custom channel [|cffff7f7f{c}|r] not found, please type |cff7fff7f/join {c}|r in chat",
	["Custom channel not found"] = "Custom channel [|cffff7f7f{c}|r] not found, please type |cff7fff7f/join {c}|r in chat",
	
	["ClassificationBoss"] = "worldboss",
	["ClassificationElite"] = "elite",
	
	["|cffffff7fDebug : |r"] = true,
	
	["Rend"] = true,
	["Humour"] = true,
	["Do you have it?"] = true,
	["Logging"] = true,
	["Logging for Challenging Shout/Roar if you want to help"] = true,

	["Fubar plugin"] = true,
	["Fubar plugin options."] = true
	
} end)

--[[
IMMUNESPELLSELFOTHER = "%s is immune to your %s.";
SPELLIMMUNESELFOTHER = "Your %s failed. %s is immune.";
SPELLMISSSELFOTHER = "Your %s missed %s.";
]]