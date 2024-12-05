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
	["MissTauntRX"] = "Your Taunt missed (.+)", -- can't happen?
	["ResistGrowlRX"] = "Your Growl was resisted by (.+)",
	["ImmuneGrowlRX1"] = "(.+) is immune to your Growl%.",
	["ImmuneGrowlRX2"] = "Your Growl failed%. (.+) is immune%.",
	["MissGrowlRX"] = "Your Growl missed (.+)",	-- can't happen?
	["ResistReckoningRX"] = "Your Hand of Reckoning was resisted by (.+)",
	["ImmuneReckoningRX1"] = "(.+) is immune to your Hand of Reckoning%.",
	["ImmuneReckoningRX2"] = "Your Hand of Reckoning failed%. (.+) is immune%.",
	["MissReckoningRX"] = "Your Earthshaker Slam missed (.+)", -- can't happen?
	["ResistEarthshakerSlamRX"] = "Your Earthshaker Slam was resisted by (.+)",
	["ImmuneEarthshakerSlamRX1"] = "(.+) is immune to your Earthshaker Slam%.",
	["ImmuneEarthshakerSlamRX2"] = "Your Earthshaker Slam failed%. (.+) is immune%.",
	["MissEarthshakerSlamRX"] = "Your Earthshaker Slam missed (.+)", -- can't happen?
	["TauntRX"] = "(.*)Taunt(.*)",
	["MockingBlowRX"] = "(.*)Mocking Blow(.*)",
	["MockingBlowSuccessRX"] = "Your Mocking Blow (.+) for (.+)",
	["ChallengingShoutRX"] = "(.*)Challenging Shout(.*)",
	["ChallengingRoarRX"] = "(.*)Challenging Roar(.*)",
	
	["MeleeMiss"]  = "You miss (.+)%.",
	["MeleeDodge"] = "You attack. (.+) dodges%.",
	["MeleeParry"] = "You attack. (.+) parries%.",
	["MeleeFail"]  = "You attack but (.+) is immune%.",

	["MeleeAbilityMiss"]  = "Your (.+) missed (.+)%.",
	["MeleeAbilityDodge"] = "Your (.+) was dodged by (.+)%.",
	["MeleeAbilityParry"] = "Your (.+) is parried by (.+)%.",
	["MeleeAbilityFail"]  = "Your (.+) failed%. (.+) is immune%.",

	["TauntMessage"] = ">>> Taunt {r} against: {t} ({l}) <<<",
	["TauntMessageSCT"] = "Taunt {r}: {t}",
	["GrowlMessage"] = ">>> Growl {r} against: {t} ({l}) <<<",
	["GrowlMessageSCT"] = "Growl {r}: {t}",
	["MockingMessage"] = ">>> Mocking Blow {r} against: {t} ({l}) <<<",
	["MockingMessageSCT"] = "Mocking Blow {r}: {t}",
	["ShoutMessage"] = ">>> Challenging Shout {r} against: {t} ({l}) <<<",
	["ShoutMessageSCT"] = "Challenging Shout {r}: {t}",
	["RoarMessage"] = ">>> Challenging Roar {r} against: {t} ({l}) <<<",
	["RoarMessageSCT"] = "Challenging Roar {r}: {t}",
	["ReckoningMessage"] = ">>> Taunt {r} against: {t} ({l}) <<<",
	["ReckoningMessageSCT"] = "Taunt {r}: {t}",
	["EarthshakerSlamMessage"] = ">>> Taunt {r} against: {t} ({l}) <<<",
	["EarthshakerSlamMessageSCT"] = "Taunt {r}: {t}",
	["level "] = true,
	["MessagesInfo"] = "Type the text you want to use for the setting {t} will be swapped for targetname and {l} for level (case sensitive). {r} will be swapped for the failure reason, if any.",
	["MessagesInfoNoTarget"] = "Type the text you want to use for the setting",
	["TauntUsedMessage"] = ">>> Taunted {t} {m} <<<",
	["TauntUsedMessageSCT"] = ">>> Taunted {t} <<<",
	["MockingUsedMessage"] = ">>> Mocking Blow on {t} {m} <<<",
	["MockingUsedMessageSCT"] = ">>> Mocking {t} <<<",
	["WallUsedMessage"] = ">>> Shield Walling <<<",
	["DeathWishUsedMessage"] = ">>> Death Wish used <<<",
	["StandUsedMessage"] = ">>> Last Stand used <<<",
	["GemUsedMessage"] = ">>> Lifegiving Gem used <<<",
	["ShoutUsedMessage"] = ">>> Challenging Shout used (6 sec) <<<",
	["RoarUsedMessage"] = ">>> Challenging Roar used (6 sec) <<<",
	
	["Group Only"] = true,
	["Active only when player in group"] = true,

	["RemoveSalvation"] = "Remove Salvation",
	["RemoveSalvationDesc"] = "Remove threat-reduction buffs at combat start if you are in a defensive stance.\nAutomatically on in Main Tank mode, ignoring stance.",
	["NotifySalvationRemoval"] = "Notify Salvation Removal",
	["NotifySalvationRemovalDesc"] = "Print to chatbox when salvation is removed.",

	["Resists"] = true,
	["Settings for resists"] = true,
	["Resists Messages"] = true,
	["Message settings for resists"] = true,
	["Taunt"] = true,
	["Announces resisted taunts"] = true,
	["Growl"] = true,
	["Announces resisted growls"] = true,
	["Hand of Reckoning"] = true,
	["Announces resisted Hand of Reckoning"] = true,
	["Earthshaker Slam"] = true,
	["Announces resisted Earthshaker Slam"] = true,
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
	["Gift of Life"] = true,
	["Used"] = " used",
	["<No Target>"] = true,
	["<Friendly Target>"] = true,
	["go me"] = true,
	["GG, I just put rend on a worldboss!"] = true,
	
	["MainTankMode"] = true,
	["MainTankModeDesc"] = "Announces misses, parries, dodges at fight start.\nDeathwish announce is on in this mode.\nSalvation removal is on in this mode.",

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