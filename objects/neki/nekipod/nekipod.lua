-- Created with the help of Erina Sugino <3

require("/scripts/util.lua")

function init()
	self._delay = 0
	self._timeout = 0

	self.soundAlarm = config.getParameter("soundAlarm", {})
	animator.setSoundPool("alarm", self.soundAlarm)
	self.soundError = config.getParameter("soundError", {})
	animator.setSoundPool("error", self.soundError)
	self.soundWarning = config.getParameter("soundWarning", {})
	animator.setSoundPool("warning", self.soundWarning)

	script.setUpdateDelta(5)
end

function onInteraction(args)
	-- Determine species and store on player
	local species = world.entitySpecies(args.sourceId)
	self._species = species

	-- Timeout in seconds
	self._timeout = 0.8
end

function update(dt)
	-- Delay pod's reaction
	if self._timeout > 0 then
		self._timeout = self._timeout - dt
			if self._timeout <= 0 then
				self._delay = 0.1
			end
		end
		if self._delay > 0 and not world.loungeableOccupied(entity.id()) then
			self._delay = 0
		end
	if self._delay > 0 then
		self._delay = self._delay - dt
		if self._delay <= 0 then
			-- Is the occupant NOT Human or Neki?
			if self._species ~= "human" and self._species ~= "neki" then
				-- If they're Apex
				if self._species == "apex" then
					local chatApex = config.getParameter("chatApex", {})
					object.say(chatApex[math.random(1, #chatApex)])
					if #self.soundAlarm > 0 then
						animator.playSound("alarm")
					end
					return
				end
				-- Glitch
				if self._species == "glitch" then
					local chatGlitch = config.getParameter("chatGlitch", {})
					object.say(chatGlitch[math.random(1, #chatGlitch)])
					if #self.soundError > 0 then
						animator.playSound("error")
					end
					return
				end
				-- Novakid
				if self._species == "novakid" then
					local chatNovakid = config.getParameter("chatNovakid", {})
					object.say(chatNovakid[math.random(1, #chatNovakid)])
					if #self.soundError > 0 then
						animator.playSound("error")
					end
					return
				end
				-- Other species
				local chatOther = config.getParameter("chatOther", {})
				object.say(chatOther[math.random(1, #chatOther)])
				if #self.soundWarning > 0 then
					animator.playSound("warning")
				end
			end
		end
	end
end

function onNpcInteract(args)
	onInteraction(args)
end
