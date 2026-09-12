function init()
  object.setInteractive(true)
end

function onInteraction(args)
  animator.playSound("nekitutorialbreak", 0)
  animator.burstParticleEmitter("tutorialSparks")
  object.smash()
end
