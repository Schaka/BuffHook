local abilities = { 
-- Buffs
	["Will of the Forsaken"] = 5, -- Will of the Forsaken
	["Cannibalize"] = 10,
	["Perception"] = 20,
	["Stoneform"] = 8,
	["Blood Fury"] = 25,
	["War Stomp"] = 2,
	["Berserking"] = 10,
	["Reckless Charge"] = 30,
	["Sleep"] = 30,
	-- Warrior
	["Death Wish"] = 30, -- Death Wish
	["Sunder Armor"] = 30, -- Sunder Armor
	["Berserker Rage"] = 10, -- Berserker Rage
	["Mortal Strike"] = 10, -- Mortal Strike
	-- Paladin
	["Blessing of Freedom"] = 14, -- Blessing of Freedom
	["Blessing of Sacrifice"] = 30, -- Blessing of Sacrifice
	["Blessing of Protection"] = 10, -- Blessing of Protection
	-- Hunter
	["Bestial Wrath"] = 18, -- Bestial Wrath
	["Viper Sting"] = 8, -- Viper Sting
	["Frost Trap Aura"] = 30, -- Frost Trap Aura
	["Frost Trap"] = 30, -- Frost Trap
	-- Druid
	["Regrowth"] = 21, -- Regrowth
	["Rejuvenation"] = 12, -- Rejuvenation
	["Fairie Fire"] = 40, -- Fairie Fire
	["Fairie Fire (Feral)"] = 40, -- Fairie Fire (Feral)
	["Barkskin"] = 12, -- Barkskin
	["Abolish Poison"] = 8, -- Abolish Poison
	-- Rogue
	["Sprint"] = 15, -- Sprint
	["Wound Poison"] = 15, -- Wound Poison
	["Evasion"] = 15, -- Evasion
	["Adrenaline Rush"] = 15, -- Adrenaline Rush
	["Cheap Shot"] = 4,
	["Kidney Shot"] = 6, -- would need combopoint check
	["Gouge"] = 5.5, -- needs talent check
	["Blind"] = 10,
	-- Priest
	["Abolish Disease"] = 20,
	["Power Word: Shield"] = 30, -- Power Word: Shield
	["Divine Shield"] = 12, -- Divine Shield
	["Weakened Soul"] = 15, -- Weakened Soul
	["Renew"] = 15,
	["Holy Fire"] = 10,
	["Fade"] = 10,
	["Power Word: Fortitude"] = 1800,
	["Prayer of Fortitude"] = 3600,
	["Divine Spirit"] = 1800,
	["Prayer of Spirit"] = 3600,
	["Shadow Protection"] = 600,
	["Prayer of Shadow Protection"] = 1200,
	["Power Infusion"] = 15, -- Power Infusion
	["Shadow Word: Pain"] = 18, -- Shadow Word: Pain
	["Starshards"] = 15, -- Starshards
	["Elune's Grace"] = 15, -- Elune's Grace
	["Devouring Plague"] = 24, -- Devouring Plague
	["Fear Ward"] = 180, -- Fear Ward
	-- Mage
	["Arcane Intellect"] = 1800,
	["Arcane Brilliance"] = 3600,
	["Amplify Magic"] = 600,
	["Dampen Magic"] = 600,
	["Mage Armor"] = 1800,
	["Ice Armor"] = 1800,
	["Frost Armor"] = 1800,
	["Frost Ward"] = 30,
	["Fire Ward"] = 30,
	["Pyroblast"] = 12,
	["Fireball"] = 8,
	["Frost Nova"] = 8,
	["Blast Wave"] = 6,
	["Detect Magic"] = 120,
	["Mana Shield"] = 60,
	["Slow Fall"] = 30,
	["Ice Block"] = 10,
	["Ignite"] = 4,
	-- Warlock
};

local function log(msg) DEFAULT_CHAT_FRAME:AddMessage(msg) end -- alias for convenience

BuffHook = CreateFrame("Frame", "BuffHook", UIParent)
BuffHook.TimeSinceLastUpdate = 0
BuffHook.OnEvent = function() -- functions created in "object:method"-style have an implicit first parameter of "this", which points to object || in 1.12 parsing arguments as ... doesn't work
	this[event](BuffHook, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10) -- route event parameters to BuffHook:event methods
end

function BuffHook:OnUpdate(elapsed)
	if not elapsed then
		elapsed = 1/GetFramerate()
	end	
	this.TimeSinceLastUpdate = this.TimeSinceLastUpdate + elapsed
	if this.TimeSinceLastUpdate >= 0.1 then
		if this.buffOrder then
			for k,v in pairs(this.buffOrder) do
				if GetTime() - this.buffOrder[k]["lastUpdate"] > 0.01 then
					for ke,va in pairs(v) do
						if ke ~= "lastUpdate" then
							this.buffOrder[k][ke] = nil
						end
					end
				end
			end
		end
		if this.targetBuffs then
			for playerName, v in pairs(this.targetBuffs) do
				for buffName, duration in pairs(v) do
					if type(duration) ~= "boolean" then
						if duration <= GetTime() then
							this:RemoveBuff(playerName, buffName)
						end	
					end
				end
			end
		end
		this.TimeSinceLastUpdate = 0
	end
end

BuffHook:SetScript("OnEvent", BuffHook.OnEvent)
BuffHook:SetScript("OnUpdate", BuffHook.OnUpdate)
BuffHook:RegisterEvent("PLAYER_ENTERING_WORLD")

function BuffHook:PLAYER_ENTERING_WORLD()
	--events for gain/refresh frames
	this:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_BUFFS")
	this:RegisterEvent("CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF")
	this:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS")
	
	-- for healers || buff/debuff || hots/dots
	this:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_BUFF")
	this:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS")
	
	this:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS")
	this:RegisterEvent("CHAT_MSG_SPELL_PARTY_BUFF")
	
	this.targetBuffs = {}
	this.buffOrder = {}
end

function BuffHook:AddBuff(playerName, buffName)
	if type(this.targetBuffs[playerName]) ~= "table" then
		this.targetBuffs[playerName] = {}
		this.buffOrder[playerName] = { lastUpdate = 0}
	end
	if abilities[buffName] then
		this.targetBuffs[playerName][buffName] = GetTime() + abilities[buffName];
	end
end

function BuffHook:RemoveBuff(playerName, buffName)
	if this.targetBuffs and this.targetBuffs[playerName] and this.targetBuffs[playerName][buffName] then
		this.targetBuffs[playerName][buffName] = nil;	
	end
end

-----------------
-- HIDE FRAMES --
----------------- 
function BuffHook:CHAT_MSG_SPELL_AURA_GONE_OTHER()
	--log(event.."  "..arg1.."  "..arg2.."  "..arg3.."  "..arg4)
	local first, last = string.find(arg1, "([\s\S]*)fades") -- idk what I'm doing
	if first ~=nil then
	local spellName = string.sub(arg1, 0, first-2)
	end
	
	local first, last = string.find(arg1, "[^ ]*$") --last word of a sentence
	if first ~=nil then
	local destName = string.sub(arg1, first, last-1) -- remove period
	end
	
	this:RemoveBuff(destName, spellName)
end

function BuffHook:CHAT_MSG_SPELL_BREAK_AURA()
	local first, last = string.find(arg1, "([\s\S]*)fades") -- idk what I'm doing
	if first ~=nil then
	local spellName = string.sub(arg1, 0, first-2)
	end
	
	local first, last = string.find(arg1, "[^ ]*$") --last word of a sentence
	if first ~=nil then
	local destName = string.sub(arg1, first, last-1) -- remove period
	end
	this:RemoveBuff(destName, spellName)
end

------------------
-- TargetFrames --
------------------ 

function BuffHook:CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_BUFFS()
	local destName = ""
	local spellName = ""
	log(arg1)
	local first, last = string.find(arg1, "([\s\S]*)gains") -- idk what I'm doing
	if first ~=nil then
	destName = string.sub(arg1, 0, first-2)
	end
	
	local first, last = string.find(arg1, "gains(.+)") --last word of a sentence
	if first ~=nil then
	spellName = string.sub(arg1, first+6, last-1) -- remove gains and space
	end
	this:AddBuff(destName, spellName)
end

function BuffHook:CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF()
	local destName = ""
	local spellName = ""
	log(arg1)
	local first, last = string.find(arg1, "([\s\S]*)gains") -- idk what I'm doing
	if first ~=nil then
	destName = string.sub(arg1, 0, first-2)
	end
	
	local first, last = string.find(arg1, "gains(.+)") --last word of a sentence
	if first ~=nil then
	spellName = string.sub(arg1, first+6, last-1) -- remove gains and space
	end
	this:AddBuff(destName, spellName)
end


function BuffHook:CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS()
	local destName = ""
	local spellName = ""
	
	local first, last = string.find(arg1, "([\s\S]*)gains") -- idk what I'm doing
	if first ~=nil then
	destName = string.sub(arg1, 0, first-2)
	end
	
	local first, last = string.find(arg1, "gains(.+)") --last word of a sentence
	if first ~=nil then
	spellName = string.sub(arg1, first+6, last-1) -- remove gains and space
	end
	this:AddBuff(destName, spellName)
end

----------------
-- HealTarget --
----------------
function BuffHook:CHAT_MSG_SPELL_FRIENDLYPLAYER_BUFF()
	--buffs
	--playerName gains spellName.
	local destName = ""
	local spellName = ""
	
	local first, last = string.find(arg1, "([\s\S]*)gains") -- idk what I'm doing
	if first ~=nil then
	destName = string.sub(arg1, 0, first-2)
	end
	
	local first, last = string.find(arg1, "gains(.+)") --last word of a sentence
	if first ~=nil then
	spellName = string.sub(arg1, first+6, last-1) -- remove gains and space
	end
	this:AddBuff(destName, spellName)
end

function BuffHook:CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS()
	--hots
	--playerName gains spellName.
	local destName = ""
	local spellName = ""
	
	local first, last = string.find(arg1, "([\s\S]*)gains") -- idk what I'm doing
	if first ~=nil then
	destName = string.sub(arg1, 0, first-2)
	end
	
	local first, last = string.find(arg1, "gains(.+)") --last word of a sentence
	if first ~=nil then
	spellName = string.sub(arg1, first+6, last-1) -- remove gains and space
	end
	this:AddBuff(destName, spellName)
end

---------------
---- PARTY ----
---------------

function BuffHook:CHAT_MSG_SPELL_PARTY_BUFF()
	--buffs
	--playerName gains spellName.
	local destName = ""
	local spellName = ""
	
	local first, last = string.find(arg1, "([\s\S]*)gains") -- idk what I'm doing
	if first ~=nil then
	destName = string.sub(arg1, 0, first-2)
	end
	
	local first, last = string.find(arg1, "gains(.+)") --last word of a sentence
	if first ~=nil then
	spellName = string.sub(arg1, first+6, last-1) -- remove gains and space
	end
	this:AddBuff(destName, spellName)
end

function BuffHook:CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS()
	--hots
	--playerName gains spellName.
	local destName = ""
	local spellName = ""
	
	local first, last = string.find(arg1, "([\s\S]*)gains") -- idk what I'm doing
	if first ~=nil then
	destName = string.sub(arg1, 0, first-2)
	end
	
	local first, last = string.find(arg1, "gains(.+)") --last word of a sentence
	if first ~=nil then
	spellName = string.sub(arg1, first+6, last-1) -- remove gains and space
	end
	this:AddBuff(destName, spellName)
end

local function getSingleSpellByName(name)
	local tbl;
	for k, v in pairs(GetSpellInfoByName(name)) do
		tbl = v;
		break;
	end
	return tbl;
end

local _UnitBuff = UnitBuff
function UnitBuff(unitID, id, showCastable)
	local unitName = UnitName(unitID);
	local buffTexture, buffApplications, arg3, arg4, arg5, arg6 = _UnitBuff(unitID, id, showCastable);
	if not BuffHook or not UnitIsEnemy("player", "target") then return  buffTexture, buffApplications, arg3, arg4, arg5, arg6 end
	
	if buffTexture then
		BuffHookToolTip:ClearLines()
		BuffHookToolTip:SetUnitBuff(unitID, id, filter)
		local name = BuffHookToolTipTextLeft1:GetText()
		if type(BuffHook.targetBuffs) ~= "table" then
			BuffHook.targetBuffs = {}
			BuffHook.buffOrder = { }
		end
		if type(BuffHook.targetBuffs[unitName]) ~= "table" then
			BuffHook.targetBuffs[unitName] = {}
			BuffHook.buffOrder[unitName] = { lastUpdate = 0 }
		end
		BuffHook.targetBuffs[unitName][name] = true;
		BuffHook.buffOrder[unitName][id] = name;
		BuffHook.buffOrder[unitName]["lastUpdate"] = GetTime()
	else
		if not BuffHook.targetBuffs or not BuffHook.targetBuffs[unitName] then return end
		for k,v in pairs(BuffHook.targetBuffs[unitName]) do
			if BuffHook.targetBuffs[unitName] and not BuffHook:IsInBuffList(unitName, k) then
				BuffHook.buffOrder[unitName][id] = k;
				BuffHook.buffOrder[unitName]["lastUpdate"] = GetTime()
				if getSingleSpellByName(k) then
					buffTexture = getSingleSpellByName(k)["icon"]
					buffApplications = 1
				end
			end
		end
	end
	return buffTexture, buffApplications, arg3, arg4, arg5, arg6
end

function BuffHook:IsInBuffList(playerName, buffName)
	for k,v in pairs(BuffHook.buffOrder[playerName]) do
		if v == buffName then
			return true
		end	
	end
	return false
end