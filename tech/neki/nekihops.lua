-- Created by Erina Sugino for Juni <3
-- A bug squashed by Khe <3

require "/tech/doubletap.lua"

function init()

  self.landed = true
  self.abilityActive = false
  self.hopDirection = 0
  self.pounceDirection = 0

  self.hopTimeout = 0
  self.pounceTimer = 0
  self.pounceCharge = 0
  self.hopSfxTimeout = 0
  self.landSfxTimeout = 0
  self.rechargeEffectTimer = 0
  self.afterPounceCooldownTimer = 0

  self.hopJump = config.getParameter("hopJump")
  self.hopSpeed = config.getParameter("hopSpeed")
  self.energyCostPerHop = config.getParameter("energyCostPerHop")

  self.pounceJump = config.getParameter("pounceJump")
  self.pounceSpeed = config.getParameter("pounceSpeed")
  self.pounceDuration = config.getParameter("pounceDuration")
  self.pounceMinimumDuration = config.getParameter("pounceMinimumDuration")
  self.pounceChargeTime = config.getParameter("pounceChargeTime")
  self.energyCostPerPounce = config.getParameter("energyCostPerPounce")
  self.afterPounceCooldown = config.getParameter("afterPounceCooldown")

  self.flashDirectives = config.getParameter("flashDirectives")
  self.flashChargeDirectives = config.getParameter("flashChargeDirectives")
  self.flashEffectTime = config.getParameter("flashEffectTime")

  self.easterRate = config.getParameter("easterRate")

  self.holdingUp = false
  self.holdingDown = false
  self.doStun = false

  self.effectQueue = nil

  self.groundOnly = config.getParameter("groundOnly")
  self.doubleTapB = DoubleTap:new({"left", "right"}, config.getParameter("maximumDoubleTapTime"), function(hopKey)
    if self.abilityActive then
      return
    end
    local direction = hopKey == "left" and -1 or 1

    if not self.hopDirection
      and groundValid()
      and not mcontroller.crouching()
      and not status.resourceLocked("energy")
      and not status.statPositive("activeMovementAbilities") then
        startHop(direction)
      end
    end
  )
  animator.setAnimationState("hopping", "off")
  animator.setAnimationState("pouncing", "off")
end

function uninit()
  status.clearPersistentEffects("movementAbility")
  tech.setParentDirectives()
  animator.setAnimationState("hopping", "off")
  animator.setAnimationState("pouncing", "off")
end

function update(args)
  if self.rechargeEffectTimer > 0 then
    self.rechargeEffectTimer = math.max(0, self.rechargeEffectTimer - args.dt)
    if self.rechargeEffectTimer == 0 then
      if not self.effectQueue then
        tech.setParentDirectives()
      else
        tech.setParentDirectives(self.effectQueue)
      end
    end
  end

  if self.afterPounceCooldownTimer > 0 then
    self.afterPounceCooldownTimer = math.max(0, self.afterPounceCooldownTimer - args.dt)
    if self.afterPounceCooldownTimer == 0 then
      self.rechargeEffectTimer = self.flashEffectTime
      tech.setParentDirectives(self.flashDirectives)
    end
  end

  if not self.abilityActive then
    if groundValid() and mcontroller.crouching() and not status.resourceLocked("energy") and not status.statPositive("activeMovementAbilities") then
      if self.pounceTimer == 0 and self.pounceCharge < 1 and self.holdingUp then
        self.pounceCharge = math.min(1, self.pounceCharge + (1 / self.pounceChargeTime) * args.dt)
        if self.pounceCharge >= 1 then
          self.effectQueue = self.flashChargeDirectives
          tech.setParentDirectives(self.flashChargeDirectives)
        end
      end

      if self.pounceCharge > 0 and not self.holdingUp then
        if self.afterPounceCooldownTimer == 0 then
          local pounceDirection = mcontroller.facingDirection()
          startPounce(pounceDirection)
          self.rechargeEffectTimer = self.flashEffectTime
        else
          self.pounceCharge = 0
          tech.setParentDirectives()
          self.effectQueue = nil
        end
      end
    else
      self.pounceCharge = 0
      self.effectQueue = nil
      tech.setParentDirectives()
    end
  else
    self.pounceCharge = 0
  end

  if self.pounceTimer > 0 then
    mcontroller.controlMove(self.pounceDirection, true)
    mcontroller.controlModifiers({jumpingSuppressed = true})
    animator.setFlipped(mcontroller.facingDirection() == -1)

    if not args.moves["down"] then
      self.doStun = false
    end

    if self.pounceTimer < self.pounceDuration
    and (mcontroller.onGround() or mcontroller.liquidPercentage() >= 0.5) then
      if self.pounceDuration - self.pounceTimer >= self.pounceMinimumDuration then
        if self.doStun and mcontroller.liquidPercentage() < 0.5 then
          stun()
        end
      end
      self.pounceTimer = 0
      landingSound()
    end
    self.pounceTimer = math.max(0, self.pounceTimer - args.dt)

    if self.pounceTimer == 0 then
      endPounce()
    end
  end

  if self.hopTimeout > 0 then
    self.hopTimeout = math.max(0, self.hopTimeout - args.dt)
  end

  if self.hopSfxTimeout > 0 then
    self.hopSfxTimeout = math.max(0, self.hopSfxTimeout - args.dt)
  end

  if self.landSfxTimeout > 0 then
    self.landSfxTimeout = math.max(0, self.landSfxTimeout - args.dt)
  end

  if not self.landed and mcontroller.onGround() then
    land()
  end

  self.doubleTapB:update(args.dt, args.moves)

  if self.hopDirection then
    if args.moves[self.hopDirection > 0 and "right" or "left"]
    and not mcontroller.liquidMovement() then
      animator.setAnimationState("hopping", "on")
      if mcontroller.onGround()
      and self.hopTimeout <= 0 then
        if status.resource("energy") >= self.energyCostPerHop then
          hop()
          animator.setFlipped(self.hopDirection == -1)
        else
          endHop()
        end
      end
    else
      if args.moves[self.hopDirection > 0 and "left" or "right"] then
        self.hopDirection = self.hopDirection * -1
      else
        endHop()
      end
    end
  end

  self.holdingUp = not not args.moves["up"]
  self.holdingDown = not not args.moves["down"]
end

function groundValid()
  return mcontroller.groundMovement() or not self.groundOnly
end

function startPounce(direction)
  self.pounceDirection = direction
  self.pounceTimer = self.pounceDuration
  status.setPersistentEffects("movementAbility", {{stat = "activeMovementAbilities", amount = 1}})
  local pools = {"pounce", "easter"}
  local roll = math.random(self.easterRate)
  animator.playSound(roll == self.easterRate and pools[2] or pools[1])
  animator.setAnimationState("pouncing", "on")
  animator.setParticleEmitterActive("pounceParticles", true)
  mcontroller.setVelocity({self.pounceSpeed*direction*self.pounceCharge,self.pounceJump*self.pounceCharge})
  self.abilityActive = true
  status.overConsumeResource("energy", self.energyCostPerPounce)
  self.doStun = true
  self.pounceCharge = 0
  tech.setParentDirectives()
  self.effectQueue = nil
end

function stun()
  local pounceDirection = mcontroller.facingDirection()
  animator.playSound("hit")
  animator.burstParticleEmitter('landParticlesPounce')
  world.spawnProjectile("nekipouncestun", mcontroller.position(), entity.id(), {1*pounceDirection,0}, true)
end

function endPounce()
  status.clearPersistentEffects("movementAbility")
  animator.setAnimationState("pouncing", "off")
  animator.setParticleEmitterActive("pounceParticles", false)
  self.afterPounceCooldownTimer = self.afterPounceCooldown
  self.abilityActive = false
end

function startHop(direction)
  self.hopDirection = direction
  self.hopTimer = self.hopDuration
  animator.setFlipped(self.hopDirection == -1)
  animator.setAnimationState("hopping", "on")
  animator.playSound("huff")
  self.abilityActive = true
  self.landSfxTimeout = 0.1
  hop()
end

function hop()
  self.hopTimeout = 0.25
  mcontroller.setVelocity({self.hopSpeed*self.hopDirection,self.hopJump})
  status.overConsumeResource("energy", self.energyCostPerHop)
  self.landed = false
end

function land()
  if self.landSfxTimeout <= 0 then
    landingSound()
    self.landSfxTimeout = 0.1
  end
  --animator.setSoundVolume("hop", 1)
  animator.playSound("hop")
  animator.burstParticleEmitter('landParticlesHop')
  self.landed = true
end

function landingSound()
  local pos = entity.position()
  local matPos = {pos[1],pos[2]-8}
  local mat = world.material(matPos, "foreground")
  if mat then
    local matConfig = root.materialConfig(mat) or {}
    matConfig = matConfig.config or {}
    local soundpool = matConfig.nekiLandSound or {}
    local sounds = #soundpool
    if sounds > 0 then
      animator.setSoundPool("dynamicLandSound", soundpool)
      animator.playSound("dynamicLandSound")
    else
      soundpool = {matConfig.footstepSound}
      sounds = #soundpool
      if sounds > 0 then
        animator.setSoundPool("dynamicLandSound", soundpool)
        animator.playSound("dynamicLandSound")
      else
        animator.playSound("hop")
      end
    end
  else
    animator.playSound("hop")
  end
end

function endHop()
  status.clearPersistentEffects("movementAbility")
  animator.setAnimationState("hopping", "off")
  --animator.setParticleEmitterActive("hopParticles", false)
  self.hopDirection = nil
  self.abilityActive = false
  --self.landed = true
end
