-- Created by Erina Sugino for Juni <3

require("/scripts/util.lua")

function init()
  self._wasFull = false
  self._skipFrame = 0
  self.sounds = config.getParameter("sounds", {})
  animator.setSoundPool("noise", self.sounds)
end

function onInteraction(args)
  local species = world.entitySpecies(args.sourceId)
  if species ~= "neki" then
    if #self.sounds > 0 then
      animator.playSound("noise")
    end
    return {"Message", {messageType = "queueRadioMessage", messageArgs = {{messageId = "nekibedlocker", unique = false, text = config.getParameter("deniedText", "No.")}}}}
  end

  local bodyDirectives = ""
  util.each(world.entityPortrait(args.sourceId, "full"), function(_, v)
  -- Attempt to find body identity
    if (string.find(v.image, "body.png") ~= nil) then
      bodyDirectives = string.match(v.image, '%?replace.*')
    end
  end)

  animator.setGlobalTag("tailDirectives", bodyDirectives)
  animator.setAnimationState("tail", "on", true)

  self._wasFull = true
  self._skipFrame = 4
end

function onNpcInteract(args)
  onInteraction(args)
end

function update(dt)
  if self._wasFull then
    if self._skipFrame > 0 then
      self._skipFrame = self._skipFrame - 1 return
    end
    if not world.loungeableOccupied(entity.id()) then
      animator.setAnimationState("tail", "off", true)
      self._wasFull = false
    end
  end
end
