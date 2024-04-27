function init()
  script.setUpdateDelta(5)
end

function update(dt)
  if not status.statusProperty('inPod', false) then
		effect.expire()
	end
end
