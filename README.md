# BuffHook - **REQUIRES GETSPELLINFOVANILLA**
World of Warcraft 1.12.1 Vanilla Addon which shows enemy buffs by hooking WoW API's UnitBuff(unitID, index) and adding buffs to it.

Please do not use this yet. While it may work well in PvP (short fights), it is still unfinished.
Buffs aren't removed properly (always) yet and information isn't added properly at all times yet. Basically data structure is still a bit unpolished.

TODO:
- properly integrate with EnemyBuffTimers (mostly meaning: Hook GameTooltip:SetUnitBuff(x) too
- support more buffs (and specials like stances)
- write some kind of "easy way out" function that replaces most functionality with SetUnitBuff on enemies and getting buffs by reading the the result, then getting spell info from GetSpellInfoVanilla

However, this is what it can look like together with EnemyBuffTimersVanilla:

![example image](http://i.imgur.com/zbJemMO.jpg "Example on LunaUnitFrames")
