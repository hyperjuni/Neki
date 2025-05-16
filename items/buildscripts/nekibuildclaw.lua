require "/scripts/util.lua"

function build(directory, config, parameters, level, seed) -- luacheck: ignore 212
  local configParameter = function(keyName, defaultValue)
    if parameters[keyName] ~= nil then
      return parameters[keyName]
    elseif config[keyName] ~= nil then
      return config[keyName]
    else
      return defaultValue
    end
  end

  config.tooltipFields = config.tooltipFields or {}
 
  if level and not configParameter("fixedLevel", true) then
    parameters.level = level
  end
  config.tooltipFields.levelLabel=configParameter("level",level)

  -- calculate damage level multiplier
  config.damageLevelMultiplier = root.evalFunction("weaponDamageLevelMultiplier", configParameter("level", 1))

  -- Neki addition
  config.tooltipFields.damageKindImage = "/interface/elements/nekiphysical.png"
  if config.elementalType then
    config.tooltipFields.damageKindImage = "/interface/elements/" .. "neki" .. string.lower(config.elementalType) .. ".png"
  end
  
    if (configParameter("critChance")) then
    config.tooltipFields.critChanceLabel = util.round(configParameter("critChance",0), 0)
    if config.tooltipFields.critChanceLabel == 0 then
      config.tooltipFields.critChanceLabel = ""
      config.tooltipFields.critChanceImage = emptyimage
      config.tooltipFields.critChanceLabel = ""
      config.tooltipFields.critChanceTitleLabel = ""
    else
      config.tooltipFields.critChanceImage = "/interface/statuses/crit2.png"
      config.tooltipFields.critChanceDivLabel = dividercolon
    end
  else
    config.tooltipFields.critChanceImage = emptyimage
    config.tooltipFields.critChanceLabel = ""
    config.tooltipFields.critChanceTitleLabel = ""
  end

  if (configParameter("critBonus")) then
    config.tooltipFields.critBonusLabel = util.round(configParameter("critBonus",0), 0)
    if config.tooltipFields.critBonusLabel == 0 then
      config.tooltipFields.critBonusLabel = ""
      config.tooltipFields.critBonusImage = emptyimage
      config.tooltipFields.critBonusLabel = ""
      config.tooltipFields.critBonusTitleLabel = ""
    else
      config.tooltipFields.critBonusImage = "/interface/statuses/dmgplus.png"
      config.tooltipFields.critBonusDivLabel = dividercolon
    end
  else
    config.tooltipFields.critBonusImage = emptyimage
    config.tooltipFields.critBonusLabel = ""
    config.tooltipFields.critBonusTitleLabel = ""
  end

  config.tooltipFields.subtitle = parameters.category
  config.tooltipFields.speedLabel = util.round(1 / config.primaryAbility.fireTime, 1)
  config.tooltipFields.damagePerShotLabel = util.round(config.primaryAbility.baseDps * config.primaryAbility.fireTime * config.damageLevelMultiplier, 1)

  -- set price
  config.price = (config.price or 0) * root.evalFunction("itemLevelPriceMultiplier", configParameter("level", 1))

  return config, parameters
end
