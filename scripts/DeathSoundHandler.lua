require("/scripts/messageutil.lua")

local oldinit = init;
local olduninit = uninit;

--local DEFAULT_DEATH_NOISE_ARRAY = {"/sfx/humanoid/player_death1.ogg", "/sfx/humanoid/player_death2.ogg", "/sfx/humanoid/player_death3.ogg"}
local DEFAULT_DEATH_NOISE_ARRAY = {} --Edit: These death sounds aren't even used in the game by default. I could add them to a config switch. Or just let you edit this here on your own, but please be careful for conflicts, as this may not load if a mod that loads after yours employs this same script.

function init()
	if oldinit then oldinit() end
	
	--Get our species file and death effects accordingly.
	self.playerSpeciesFile = root.assetJson("/species/" .. player.species() .. ".species")
	self.deathSoundFx = self.playerSpeciesFile["deathNoises"] or DEFAULT_DEATH_NOISE_ARRAY
end

function wouldDieOnThisFrame()
	--Is our health zero?
	if status.stat("health") == 0 then
		return true
	end
	
	--Do we have any lingering damage requests?
	local damageNotifications, nextStep = status.damageTakenSince(self.queryDamageSince)
	self.queryDamageSince = nextStep
	for _, notification in ipairs(damageNotifications) do
		if notification.healthLost > 0 and notification.sourceEntityId ~= notification.targetEntityId then
			if status.stat("health") - notification.healthLost <= 0 then
				return true
			end
		end
	end
	
	return false
end

--This runs when the player dies.
function uninit()
	if olduninit then olduninit() end
	
	if wouldDieOnThisFrame() and self.deathSoundFx and #self.deathSoundFx > 0 then
		world.spawnProjectile("invisibleprojectile", entity.position(), player.id(), {0,0}, false, 
		{
			timeToLive = 0,
			actionOnReap = {
				{
					action = "actions",
					list = {
						{
							action = "sound",
							options = self.deathSoundFx
						}
					}
				}
			}
		})
	end
end