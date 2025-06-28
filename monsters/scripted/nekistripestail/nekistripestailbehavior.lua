-- Made by Lofty for Juni <3

require "/scripts/vec2.lua"

--  Basic overview:
--
--    This monster spawns at the Outpost.
--    It searches for objects it is allowed to "hide behind", then moves near a valid object.
--    Once near a valid object, the monster reveals itself and becomes interactive.
--    Interacting with the monster several times causes it to spawn an npc, then despawn.
--
--    Most of the rest of the script focuses on reading the config in the .monstertype file.

function nekistripestailbehavior(args, board)
  --  required for behaviors to work
  return true
end

function init()
  --  reset interact count
  if storage.interactionCount == nil then
    storage.interactionCount = 0
  end
  --  set monster invisible
  animator.setAnimationState("movement","hide")
  --  reset the list of things we have already hidden behind
  storage.objectsAlreadyHiddenBehind = {}
  --  range for scanning for more objects to hide behind
  self.scamperRange = config.getParameter("scamperRange")
  --  used for calculating delays
  self.scamperSpeed = config.getParameter("scamperSpeed")
  --  the actual time spent waiting between visiting different objects
  --  this will be adjusted to different values as needed and counts down to 0
  self.scamperTimer = 0
  --  set the name of the object we prefer to start at
  self.preferredTargetObjects = config.getParameter("preferredStarterObjects")
  --  scan for nekistripesvisitor npc type periodically
  self.stripesScanTimer = 0
  self.stripesScanInterval = 10
  --  keep track of the object id behind which we are hiding
  if not storage.hidingBehindId then
    storage.hidingBehindId = -1
  end
end

function interact()
  --  only allow interact while idling
  if animator.animationState("movement") == "idle" then
    --  make noise
    animator.playSound("interact")
    --  increase interact count
    storage.interactionCount = storage.interactionCount + 1
    --  pull tail a number of times, spawn npc
    if storage.interactionCount >= config.getParameter("tailPulls") then
      youFoundMe()
    --  otherwise move to new object
    else
      --  start the tail_hide animation
      animator.setAnimationState("movement","tail_hide")
    end
  end
end

function youFoundMe()
  --  spawn the npc
  world.spawnNpc(vec2.add(entity.position(), {0,2}), "nekistripes", "nekistripesvisitor", 1)
  animator.playSound("appear")
  --  despawn the tail
  quietlyDie()
end

function quietlyDie()
  --  quietly despawn
  monster.setDeathSound()
  monster.setDeathParticleBurst()
  monster.setDropPool("empty")
  status.setResource("health", 0)
end

function scanForStripes(dt)
  --  remove the time we've spent waiting from the time remaining
  if self.stripesScanTimer > 0 then
    self.stripesScanTimer = self.stripesScanTimer - dt
  --  if timer is <= 0 it means it is time to scan
  else
    self.stripesScanTimer = self.stripesScanInterval
    --  scan for npcs
    local result = world.npcQuery(entity.position(), 5000)
    for i_result, v_result in ipairs(result) do
      --  if it's Stripes
      if world.npcType(v_result) == "nekistripesvisitor" or world.npcType(v_result) == "nekistripescrewmember" then
        --  tail can die if the visitor or crewmember is nearby
        sb.logInfo("Neki: Despawning; another instance of Stripes detected.")
        quietlyDie()
      end
    end
  end
end

function update(dt)
  scanForStripes(dt)
  --  The tail will be in one of 5 states:
  --    hide
  --    tail_wait
  --    tail_show
  --    idle
  --    tail_hide
  --  ...but we only care about "idle", "tail_wait", and "hide"
  local currentState = animator.animationState("movement")

  --  only allow interactivity during idle anim
  if currentState == "idle" then
    monster.setInteractive(true)
  else
    monster.setInteractive(false)
  end

  --  during this state we just sit still playing an animation that keeps us invisible
  if currentState == "tail_wait" then
    if self.scamperTimer > 0 then
      --  subtract the amount of time that has elapsed while waiting
      self.scamperTimer = self.scamperTimer - dt
    else
      --  begin unhide
      animator.setAnimationState("movement","tail_show")
    end
  end

  --  if we're in the hidden state, find a new item to attach to
  if currentState == "hide" then
    --  scan for objects
    local result = world.objectQuery(entity.position(), self.scamperRange)
    --  keep a list of valid things to hide behind
    local validTargets = {}
    --  retrieve list of obects we are allowed to hide behind
    local validObjectsToHideBehind = config.getParameter("validObjectsToHideBehind")
    --  iterate the objects we found
    if result then
      for i_result, v_result in ipairs(result) do
        --  get object name
        local objName = world.entityName(v_result)
        --  check to see if this object is in our list of valid stuff to hide behind
        for k_hide, v_hide in pairs(validObjectsToHideBehind) do
          --  object is something we're allowed to hide behind
          if objName == k_hide then
            --  is the object oriented in a way that we can use?
            local validOrientations = config.getParameter("validObjectsToHideBehind." .. objName)
            for k_orientations, v_orientations in pairs(validOrientations) do
              --  get the target's orientation
              local objDirection = world.callScriptedEntity(v_result, "object.direction")
              objDirection = tostring(objDirection)
              if objDirection == "-1" then
                objDirection = "left"
              else
                objDirection = "right"
              end
              --  we have a config for this direction, so it's usable
              if k_orientations == objDirection then
                --  have we already hidden behind this particular object?
                local alreadyUsed = false
                for i_already, v_already in ipairs(storage.objectsAlreadyHiddenBehind) do
                  --  already used it, not valid
                  if v_already == v_result then
                    alreadyUsed = true
                    break
                  end
                end
                if alreadyUsed == false then
                  --  add valid hiding place
                  table.insert(validTargets, v_result)
                end
              end
            end
          end
        end
      end
    end
    --  if we have a valid object to hide behind, do that
    if #validTargets > 0 then
      --  choose a target
      local index = math.random(#validTargets)
      local chosenTarget = validTargets[index]
      --  for the first interaction, prefer one of the starter objects
      if storage.interactionCount <= 0 then
        local preferredTargets = {}
        for i_target, v_target in ipairs(validTargets) do
          local objName = world.entityName(v_target)
          for i_preferred, v_preferred in ipairs(self.preferredTargetObjects) do
            if objName == v_preferred then
              table.insert(preferredTargets, v_target)
            end
          end
        end
        if #preferredTargets > 0 then
          index = math.random(#preferredTargets)
          chosenTarget = preferredTargets[index]
        end
      end
      --  get the target's orientation
      local objDirection = world.callScriptedEntity(chosenTarget, "object.direction")
      objDirection = tostring(objDirection)
      if objDirection == "-1" then
        objDirection = "left"
      else
        objDirection = "right"
      end
      --  get the object's name
      local objName = world.entityName(chosenTarget)
      local validOrientationSides = config.getParameter("validObjectsToHideBehind." .. objName .. "." .. objDirection)
      --  at this point we have a list of one-or-more luaObjects for leftSide or rightSide offsets
      --  we choose one of these options at random here
      --  this is slightly clunky because we care about the name of the luaObject
      local numberOfOptions = 0
      for i_num, v_num in pairs(validOrientationSides) do
        numberOfOptions = numberOfOptions + 1
      end
      local randChoice = math.random(numberOfOptions)
      local iterator = 0
      local leftOrRight = nil
      local pixelOffset = { 0, 0 }
      for k_osides, v_osides in pairs(validOrientationSides) do
        iterator = iterator + 1
        if iterator == randChoice then
          leftOrRight = k_osides
          pixelOffset = v_osides.offset
          --  convert from pixels to tiles
          pixelOffset[1] = pixelOffset[1] / 8.0
          pixelOffset[2] = pixelOffset[2] / 8.0
          break
        end
      end
      if leftOrRight == nil then
        sb.logInfo("Neki: Bad left/right config for object '" .. objName .. "'")
      end
      --  try to swap back and forth between leftSide and rightSide if possible
      if storage.previousLeftOrRightChoice ~= nil then
        if leftOrRight == storage.previousLeftOrRightChoice then
          for k_osides, v_osides in pairs(validOrientationSides) do
            if k_osides ~= leftOrRight then
              leftOrRight = k_osides
              pixelOffset = v_osides.offset
              --  convert from pixels to tiles
              pixelOffset[1] = pixelOffset[1] / 8.0
              pixelOffset[2] = pixelOffset[2] / 8.0
              --  this break is important
              break
            end
          end
        end
      end
      storage.previousLeftOrRightChoice = leftOrRight
      --  scan the spaces occupied by the object to find the leftmost or rightmost offset
      local offset = { 0, 0 }
      local spaces = world.objectSpaces(chosenTarget)
      for i_space, v_space in ipairs(spaces) do
        --  we only care about spaces aligned with the 'ground' for an object
        if v_space[2] == 0 then
          --  leftways behavior
          if leftOrRight == "leftSide" then
            --  we only care about the leftmost tile
            if v_space[1] < offset[1] then
              offset[1] = v_space[1]
            end
          --  rightways behavior
          else
            --  we only care about the rightmost tile
            if v_space[1] > offset[1] then
              offset[1] = v_space[1]
            end
          end
        end
      end
      --  add or subtract half a tile, and face the correct direction
      if leftOrRight == "leftSide" then
        offset[1] = offset[1] - 0.5
        mcontroller.controlFace(1)
      else
        offset[1] = offset[1] + 0.5
        mcontroller.controlFace(-1)
      end
      --  combine the object-size offset and the config pixel-offset
      offset = vec2.add(offset, pixelOffset)
      --  combine offset with object position
      local finalPosition = vec2.add(world.entityPosition(chosenTarget), offset)
      --  calculate the distance and set the timer for her tail to become visible again
      local dist = world.magnitude(entity.position(), finalPosition)
      self.scamperTimer = dist * self.scamperSpeed
      --  reset critical fail counter if we find any target - including where we already are
      storage.criticalFailures = 0
      --  move to position
      mcontroller.setPosition(finalPosition)
      --  add target to already-hidden list
      table.insert(storage.objectsAlreadyHiddenBehind, chosenTarget)
      --  track the current object we're hiding behind
      storage.hidingBehindId = chosenTarget
      --  move into our tail_wait state to chill until it's time to pop out again
      animator.setAnimationState("movement","tail_wait")
    else
      --  no valid hiding places, I guess that means you found her
      --youFoundMe()
      --  clear the list of objects we have already used so she can re-use the same hiding place
      storage.objectsAlreadyHiddenBehind = {}
      --  track the number of hiding failures
      --  if this happens an unreasonable number of times (more than # of interactions required),
      --  then we can assume there are no valid objects anywhere nearby and just despawn the monster
      if storage.criticalFailures then
        storage.criticalFailures = storage.criticalFailures + 1
        if storage.criticalFailures >= 50 then
          sb.logInfo("Neki: Despawning, no suitable objects for Stripes to hide behind.")
          quietlyDie()
        end
      else
        storage.criticalFailures = 1
      end
    end
  end
  --  if the the object we're hiding behind gets broken, reveal Stripes
  if storage.hidingBehindId ~= nil then
    if storage.hidingBehindId ~= -1 then
      if world.entityExists( storage.hidingBehindId ) == false then
        youFoundMe()
      end
    end
  end
end

function uninit()
end
