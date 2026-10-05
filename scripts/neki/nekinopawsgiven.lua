-- MyFirstBigScript_ihavenoideawhatimdoing.halp
-- -Juni <3

-- 'local' means it will only exist in this script?
local _init = init
local _update = update
local doNekiStuff = true
local needNekiStuff = true
local nekiTimer = 0.0

function init()
  -- Anything to wrap?
  if _init ~= nil then
    _init()
  end

  -- Not a Neki?
  if player.species() ~= "neki" then
    -- sb.logInfo("Neki_noPawsGiven: Not a Neki, aborting")
    doNekiStuff = false
  end

  -- Paws given and has MM?
  if player.getProperty("pawsGiven", false)
  and player.essentialItem("beamaxe") then
    -- sb.logInfo("Neki_noPawsGiven: Has MM, paws given, aborting")
    needNekiStuff = false
  end
end

function update(dt)
  -- Anything to wrap?
  if _update ~= nil then
    _update(dt)
  end

  if doNekiStuff
  and needNekiStuff then
    -- Intro complete?
    nekiTimer = nekiTimer + dt
    if nekiTimer > 1.0 then
      nekiTimer = 0
        if not player.introComplete() then
        -- sb.logInfo("Neki_noPawsGiven: Intro not complete yet...")
        return
      end
    end
  
    -- Paws given? If not, give 2 paws
    if not player.getProperty("pawsGiven", false) then
      if not player.hasItem("nekiclaws1") then
        -- sb.logInfo("Neki_noPawsGiven: Giving missing paws...")
        player.giveItem("nekiclaws1")
        player.giveItem("nekiclaws1")
      end
      player.setProperty("pawsGiven", true)
    end
  
    -- On the ship with no MM? If so, give MM
    if world.type() == "unknown"
    and not player.essentialItem("beamaxe") then
      -- sb.logInfo("Neki_noPawsGiven: Giving missing MM...")
      player.giveEssentialItem("beamaxe", "beamaxe")
    end
  end
end
