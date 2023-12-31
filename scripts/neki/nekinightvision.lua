-- Created with the direct assistance of Kherae

local oldUpdate = update

function update(dt,...)
    if player.species() == "neki" then
        local lightval = math.min(125*status.resourcePercentage("health"),255)
        localAnimator.spawnParticle({
            type = "textured",
            image = "/projectiles/invisibleprojectile/invisibleprojectile.png",
            light = {lightval,lightval,lightval},
            position = entity.position(),
            timeToLive = dt
        })
    end
    if oldUpdate then
        oldUpdate(dt,...)
    end
end
