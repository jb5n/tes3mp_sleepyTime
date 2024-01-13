-- SleepyTime Release 1 for tes3mp v0.8
-- Gives a popup when activating a bed while sneaking, allowing you to skip time if enough players choose to do so
-- Time will skip to evening if it is daytime, or morning if it is nighttime. The precise hours are set in custom/config.lua
-- under config.nightStartHour and config.nightEndHour, by default 6 AM and 8 PM
-- Place this script in your server/scripts/custom folder, then add the following line (without the two dashes) to server/scripts/customScripts.lua:
-- sleepyTime = require("custom/sleepyTime")
-- Should work with all beds and bedrolls. Some mods may add beds that do not work with the plugin.

local scriptConfig = {}

-- Percentage of players necessary to skip to the next day. Set to 1 to require the whole server to sleep to skip time
scriptConfig.percentPlayersSleeping = 0.5

-- END CONFIG

local sleepyTimeChoiceID = 31760
local cancelSleepyTimeID = 31761
local endSleepyTimeID    = 31762

local playersSleeping = 0

local function showSleepyChoice(eventStatus,pid)
    tes3mp.CustomMessageBox(pid, sleepyTimeChoiceID, "Do you wish to sleep or skip time?", "Sleep;Skip Time;Cancel")
end

local function showSleepyMenu(eventStatus,pid)
    tes3mp.CustomMessageBox(pid, cancelSleepyTimeID, "Waiting for more players to skip time...", "Cancel")
end

local function endSleepyMenu(pid)
    tes3mp.CustomMessageBox(pid, endSleepyTimeID, "Time Skipped!", "Close")
end

local function CheckTimeSkip()
	local playerCount = logicHandler.GetConnectedPlayerCount()
	if playersSleeping / playerCount >= scriptConfig.percentPlayersSleeping then
		if WorldInstance.data.time.hour >= config.nightStartHour or WorldInstance.data.time.hour < config.nightEndHour then
			-- sleep til morning
			WorldInstance.data.time.hour = config.nightEndHour
			WorldInstance.data.time.day = WorldInstance.data.time.day + 1
            WorldInstance:QuicksaveToDrive()
            WorldInstance:LoadTime(0, true)
            hourCounter = config.nightEndHour
		else
			-- sleep til night
			WorldInstance.data.time.hour = config.nightStartHour
            WorldInstance:QuicksaveToDrive()
            WorldInstance:LoadTime(0, true)
            hourCounter = config.nightStartHour
		end
		
		playersSleeping = 0 -- reset sleep counter
		
		for pid, player in pairs(Players) do
		if not tableHelper.containsValue({}, pid) then
			if Players[pid].sleepy then
				endSleepyMenu(pid)
			end
			Players[pid].sleepy = false
			tes3mp.SendMessage(pid, "Time Skipped!\n")
		end
	end
	end
end

local function BroadcastPlayersSleeping()	
	if playersSleeping == 0 then
		return
	end
	local playerCount = logicHandler.GetConnectedPlayerCount()
	local requiredPlayersSleeping = scriptConfig.percentPlayersSleeping * playerCount
	local message = "Players Sleeping: " .. playersSleeping .. "/" .. requiredPlayersSleeping
	for pid, player in pairs(Players) do
		if not tableHelper.containsValue({}, pid) then
			tes3mp.SendMessage(pid, message .. "\n")
		end
	end
end

local function OnGUIAction(newStatus,pid,idGui,data)
    local cellDescription = tes3mp.GetCell(pid)

    if idGui == sleepyTimeChoiceID then
        if tonumber(data) == 0 then -- sleep
            logicHandler.ActivateObjectForPlayer(pid,cellDescription,Players[pid].objectUniqueIndex)
        elseif tonumber(data) == 1 then -- skip time
			playersSleeping = playersSleeping + 1
			Players[pid].sleepy = true
			showSleepyMenu(newStatus,pid)
			CheckTimeSkip()
			BroadcastPlayersSleeping()
        end
	elseif idGui == cancelSleepyTimeID then
		if tonumber(data) == 0 then -- cancel
			if playersSleeping ~= 0 then
				playersSleeping = playersSleeping - 1
			end
			Players[pid].sleepy = false
			BroadcastPlayersSleeping()
		end
	end
end

local function OnObjectActivate(eventStatus,pid,cellDescription,objects,players)
	if not tes3mp.GetSneakState(pid) then
		return
	end
    for _, object in pairs(objects) do
        if string.match(object.refId, "bed_") or string.match(object.refId, "bedroll") then
			Players[pid].objectUniqueIndex = object.uniqueIndex -- storing the bed's index in a variable belonging to the player
            showSleepyChoice(eventStatus,pid)
            return customEventHooks.makeEventStatus(false, false)
        end
    end
end

customEventHooks.registerValidator("OnGUIAction", OnGUIAction)
customEventHooks.registerValidator("OnObjectActivate", OnObjectActivate)

tes3mp.LogMessage(enumerations.log.INFO, "sleepyTime started")
