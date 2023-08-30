require "/scripts/util.lua"
require "/items/active/weapons/weapon.lua"

local initSB = init
local updateSB = update
local uninitSB = uninit

function init()
	initSB()
	status.setPersistentEffects("nekiWeaponEffect", {self.primaryAbility.nekiWeaponEffect})
end

function update(dt, fireMode, shiftHeld)
	updateSB(dt, fireMode, shiftHeld)
end

function uninit()
	uninitSB()
	status.clearPersistentEffects("nekiWeaponEffect")
end
