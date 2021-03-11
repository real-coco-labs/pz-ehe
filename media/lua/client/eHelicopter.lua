---@class eHelicopter
---@field soundRef long
---@field emitter FMODSoundEmitter
eHelicopter = {}

---@param obj IsoMovingObject
---@return FMODSoundEmitter
local function getFreeEmitterForMovingObject(obj)
	return getWorld():getFreeEmitter(obj:getX() + 0.5, obj:getY() + 0.5, 20)
end

---@param target IsoMovingObject
---@return FMODSoundEmitter
function eHelicopter:createEmitter(target)

	local result = getFreeEmitterForMovingObject(target)
	ModLogger:debug("Created new helicopter emitter (" .. tostring(result) .. ')')
	eHelicopter.emitter = result
	return result
end

---@param target IsoMovingObject
---@return long @sound reference number
function eHelicopter:playSound(target)
	return eHelicopter:createEmitter(target):playSoundImpl("Helicopter", target)
end

---@return boolean
function eHelicopter:isSoundPlaying()
	return eHelicopter.emitter and eHelicopter.emitter:isPlaying("Helicopter") or false
end

function eHelicopter:launch()

	--the -1 is to offset playerIDs starting at 0
	local numActivePlayers = getNumActivePlayers() - 1

	---target is a random IsoPlayer
	---@type IsoMovingObject
	local target = getSpecificPlayer(ZombRand(numActivePlayers))
	ModLogger:debug("Set helicopter target to player " .. target:getObjectName())

	--start playing helicopter sound
	local ref = eHelicopter:playSound(target)
	ModLogger:debug("Playing helicopter noise (" .. tostring(ref) .. ')')
	eHelicopter.soundRef = ref
function eHelicopter.unlaunch()
	Events.OnTick.Remove(eHelicopter.update)
	eHelicopter.emitter.stopAll()
end

---@param destination _Vector2
function eHelicopter.setUpMovement(destination)

	eHelicopter.movement:set(eHelicopter.pos.x,eHelicopter.pos.y)

	movement:aimAt(destination)
	movement:normalize()
	movement:setLength(speed)

	return movement
end


---@param movement _Vector2
---@param destination _Vector2
function eHelicopter.moveStep(movement)

	eHelicopter.pos.x = eHelicopter.pos.x+movement.x
	eHelicopter.pos.y = eHelicopter.pos.y+movement.y

	print("HELI: X:"..eHelicopter.pos.x.."  Y:"..eHelicopter.pos.y)

	eHelicopter.emitter.setPos(eHelicopter.pos.x,eHelicopter.pos.y,eHelicopter.pos.z)
end


---@param movement _Vector2
---@param destination _Vector2
function eHelicopter.moveDampen(movement, destination)
	movement.x = movement.x * math.max(0.1,((destination.x - position.x)/destination.x))
	movement.y = movement.y * math.max(0.1,((destination.y - position.y)/destination.y))
end


--- Used only for testing purposes
Events.OnCustomUIKey.Add(function(key)
	if key == Keyboard.KEY_0 then
		eHelicopter.launch()
	--elseif key == Keyboard.KEY_9 then---add different behaviors + send away
	--	if eHelicopter.emitter then
	--		eHelicopter.emitter.stopAll()
	--		ModLogger.debug("Stopping helicopter emitter")
	--	else
	--		ModLogger.error("Unable to find helicopter emitter!")
	--	end
	end
end)
