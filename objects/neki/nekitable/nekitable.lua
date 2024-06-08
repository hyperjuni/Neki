function init()
	self.sounds = config.getParameter("sounds", {})
	animator.setSoundPool("noise", self.sounds)
end

function onInteraction(args)
	local species = world.entitySpecies(args.sourceId)
	local canUse = config.getParameter("canUse")
	if not canUse[species] then
		if #self.sounds > 0 then
			animator.playSound("noise")
		end
		return {"Message", {messageType = "queueRadioMessage", messageArgs = {{messageId = "nekitable", unique = false, text = config.getParameter("deniedText", "No.")}}}}
	end
end

function onNpcInteract(args)
	onInteraction(args)
end
