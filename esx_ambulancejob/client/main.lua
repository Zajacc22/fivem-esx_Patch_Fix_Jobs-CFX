local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, 
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, 
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70, 
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local lang = 'fr'

local txt = {
	['fr'] = {
		['inComa'] = '~r~Vous êtes dans le coma',
		['accident'] = 'Un accident s\'est produit',
		['murder'] = 'Tentative de meurtre',
		['ambIsComming'] = 'Une ~b~ambulance~s~ est en route !',
		['res'] = 'Vous avez été réanimé',
		['ko'] = 'Vous êtes KO !',
		['callAmb'] = 'Appuyez sur ~g~E~s~ pour respawn',
		['respawn'] = 'Appuyez sur ~r~FLECHE HAUT~s~ pour appeler une ambulance avec le téléphone',
		['cannotRespawnYet'] = "Vous ne pouvez pas encore réapparaitre. Appelez d'abord les secours !",
		['thatWasClose'] = "T'y as échappé de justesse... Bon retour parmis nous !"
	},
	['en'] = {
		['inComa'] = '~r~You are in coma',
		['accident'] = 'An accident happened',
		['murder'] = 'An attempted murder.',
		['ambIsComming'] = 'An ambulance arrives !',
		['res'] = 'You have been resuscitated',
		['ko'] = 'You are KO !',
		['callAmb'] = 'Press ~g~E~s~ to call an ambulance.',
		['respawn'] = 'Press ~r~X~s~ to respawn',
		['cannotRespawnYet'] = "You cannot respawn yet. Call a medic first !",
		['thatWasClose'] = "Wow, that was close... ! Welcome back !"
	}
}

local isDead = false
local isKO = false
local isRes = false

--[[
################################
            THREADS
################################
--]]

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(1)
    --NetworkResurrectLocalPlayer(357.757, -597.202, 28.6314, true, true, false)
    local playerPed = GetPlayerPed(-1)
    local playerID = PlayerId()
    local currentPos = GetEntityCoords(playerPed, true)
    local previousPos

    isDead = IsEntityDead(playerPed)

    if isKO and previousPos ~= currentPos then
      isKO = false
    end

    if (GetEntityHealth(playerPed) < 120 and not isDead and not isKO) then
      if (IsPedInMeleeCombat(playerPed)) then
        SetPlayerKO(playerID, playerPed)
      end
    end

    previousPos = currentPos
  end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
  	if IsEntityDead(PlayerPedId()) then
			StartScreenEffect("DeathFailOut", 0, 0)
			ShakeGameplayCam("DEATH_FAIL_IN_EFFECT_SHAKE", 1.0)

			local scaleform = RequestScaleformMovie("MP_BIG_MESSAGE_FREEMODE")

			if HasScaleformMovieLoaded(scaleform) then
				Citizen.Wait(0)

				PushScaleformMovieFunction(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
				BeginTextComponent("STRING")
				AddTextComponentString(txt[lang]['inComa'])
				EndTextComponent()
				PopScaleformMovieFunctionVoid()

		  	Citizen.Wait(500)

		    while IsEntityDead(PlayerPedId()) do
					DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
			 		Citizen.Wait(0)
		    end

		  	StopScreenEffect("DeathFailOut")
			end
		end
	end
end)

--[[
################################
            EVENTS
################################
--]]

AddEventHandler("playerSpawned", function(spawn)
    exports.spawnmanager:setAutoSpawn(false)
end)

-- Triggered when player died by environment
AddEventHandler('baseevents:onPlayerDied',
  function(playerId, reasonID)
    local reason = txt[lang]['accident']
		OnPlayerDied(playerId, reasonID, reason)
	end
)

-- Triggered when player died by an another player
AddEventHandler('baseevents:onPlayerKilled',
  function(playerId, playerKill, reasonID)
    local reason = txt[lang]['murder']
		OnPlayerDied(playerId, reasonID, reason)
	end
)

RegisterNetEvent('es_em:cl_sendMessageToPlayerInComa')
AddEventHandler('es_em:cl_sendMessageToPlayerInComa',
	function()
		SendNotification(txt[lang]['ambIsComming'])
	end
)

RegisterNetEvent('es_em:cl_resurectPlayer')
AddEventHandler('es_em:cl_resurectPlayer',
	function()
		local playerPed = GetPlayerPed(-1)
		isRes = true

		if IsEntityDead(playerPed) then
			SendNotification(txt[lang]['res'])

			ResurrectPed(playerPed)
			SetEntityHealth(playerPed, GetPedMaxHealth(playerPed)/2)
			ClearPedTasksImmediately(playerPed)
		end
	end
)

--[[
################################
        BUSINESS METHODS
################################
--]]

function SetPlayerKO(playerID, playerPed)
  isKO = true
  SendNotification(txt[lang]['ko'])
  SetPedToRagdoll(playerPed, 6000, 6000, 0, 0, 0, 0)
end

function SendNotification(message)
  SetNotificationTextEntry('STRING')
  AddTextComponentString(message)
  DrawNotification(true, false)
end

function OnPlayerDied(playerId, reasonID, reason)
	local pos = GetEntityCoords(GetPlayerPed(-1))
	local isDocConnected = nil

	TriggerServerEvent('es_em:sv_getDocConnected')

	Citizen.CreateThread(
		function()
			while isDocConnected == nil do
				Citizen.Wait(1)

				RegisterNetEvent('es_em:cl_getDocConnected')
				AddEventHandler('es_em:cl_getDocConnected',
					function(cb)
						isDocConnected = cb
						if isDocConnected then
							SendNotification(txt[lang]['callAmb'])
						end
					end
				)
			end
		end
	)

	SendNotification(txt[lang]['respawn'])

	Citizen.CreateThread(
		function()
			local emergencyCalled = false

			--local respawn_wait_time = 30 -- 30 secondes si aucun medic n'est présent
			--local RESPAWN_ALLOWED_TIME = GetGameTimer() + (1000 * respawn_wait_time)

			while not isRes do
				Citizen.Wait(1)
				if (IsControlJustReleased(1, Keys['E'])) and not emergencyCalled then
					if not isDocConnected then
						ResPlayer()
					else
						TriggerEvent("chatMessage", "[SAV-Medic]", {255, 255, 0}, "Les secours vont être avertis")
						TriggerServerEvent('es_em:sendEmergency', reason, GetPlayerServerId(PlayerId()), pos.x, pos.y, pos.z)
					end
					emergencyCalled = true
				else
					if (IsControlJustReleased(1, Keys['X'])) then
						if (GetGameTimer() < RESPAWN_ALLOWED_TIME)then
							TriggerEvent("chatMessage", "[SAV-Medic]", {255, 255, 0}, txt[lang]['cannotRespawnYet'])
							SendNotification()
						else
							TriggerEvent("chatMessage", "[SAV-Medic]", {255, 255, 0}, txt[lang]['thatWasClose'])
							ResPlayer()
						end
					end
				end
			end
			isDocConnected = nil
			isRes = false
	end)
end


--[[
################################
        USEFUL METHODS
################################
--]]


local PlayerData                  = {}
local GUI                         = {}
GUI.Time                          = 0
local hasAlreadyEnteredMarker     = false;
local lastZone                    = nil;
local AmbulanceMenuTargetPlayerId = nil;
local IsAlreadyDead               = false;

function GetClosestPlayerInArea(positions, radius)

	local playerPed             = GetPlayerPed(-1)
	local playerServerId        = GetPlayerServerId(PlayerId())
	local playerCoords          = GetEntityCoords(playerPed)
	local closestPlayer         = -1
	local closestDistance       = math.huge

	for k, v in pairs(positions) do

   if tonumber(k) ~= playerServerId then
      
      local otherPlayerCoords = positions[k]
      local distance          = GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, otherPlayerCoords.x, otherPlayerCoords.y, otherPlayerCoords.z, true)

      if distance <= radius and distance < closestDistance then
      	closestPlayer   = tonumber(k)
      	closestDistance = distance
      end
   	end
  end

  return closestPlayer

end

function GetClosestPlayerInAreaNotInAnyVehicle(positions, radius)

	local playerPed             = GetPlayerPed(-1)
	local playerServerId        = GetPlayerServerId(PlayerId())
	local playerCoords          = GetEntityCoords(playerPed)
	local closestPlayer         = -1
	local closestDistance       = math.huge

	for k, v in pairs(positions) do

    if tonumber(k) ~= playerServerId then
      
      local otherPlayerPed    = GetPlayerPed(GetPlayerFromServerId(tonumber(k)))
      local otherPlayerCoords = positions[k]
      local distance          = GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, otherPlayerCoords.x, otherPlayerCoords.y, otherPlayerCoords.z, true)

      if distance <= radius and distance < closestDistance and not IsPedInAnyVehicle(otherPlayerPed,  false) then
      	closestPlayer   = tonumber(k)
      	closestDistance = distance
      end
   	end
  end

  return closestPlayer

end

function respawnPed(ped,coords)
	SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false, true)
	NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, coords.heading, true, false) 
	SetPlayerInvincible(ped, false) 
	TriggerEvent('playerSpawned', coords.x, coords.y, coords.z, coords.heading)
	ClearPedBloodDamage(ped)
	IsAlreadyDead = false
end

AddEventHandler('playerSpawned', function(spawn)
	TriggerServerEvent('esx_ambulancejob:requestPlayerData', 'playerSpawned')
end)

RegisterNetEvent('esx_phone:loaded')
AddEventHandler('esx_phone:loaded', function(phoneNumber, contacts)
	TriggerEvent('esx_phone:addContact', 'Ambulance', 'ambulance', 'special', false)
end)

AddEventHandler('esx_ambulancejob:hasEnteredMarker', function(zone)

	if zone == 'CloakRoom' then
		SendNUIMessage({
			showControls = true,
			controls     = 'cloakroom'
		})
	end

	if zone == 'VehicleSpawner' then
		SendNUIMessage({
			showControls = true,
			controls     = 'vehiclespawner'
		})
	end

	if zone == 'VehicleDeleter' then
		local playerPed = GetPlayerPed(-1)

		if IsPedInAnyVehicle(playerPed, 0) then
			DeleteVehicle(GetVehiclePedIsIn(playerPed, 0))
		end
	end

end)

AddEventHandler('esx_ambulancejob:hasExitedMarker', function(zone)
	SendNUIMessage({
		showControls = false,
		showMenu     = false,
	})
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
end)

RegisterNetEvent('esx_ambulancejob:responsePlayerData')
AddEventHandler('esx_ambulancejob:responsePlayerData', function(data, reason)
	PlayerData = data
end)

RegisterNetEvent('esx_ambulancejob:responsePlayerPositions')
AddEventHandler('esx_ambulancejob:responsePlayerPositions', function(positions, reason)

	if reason == 'revive' then

		local closestPlayer = GetClosestPlayerInArea(positions, 3.0)

    if closestPlayer ~= -1 then
    	AmbulanceMenuTargetPlayerId = closestPlayer;
    	TriggerServerEvent('esx_ambulancejob:revive', closestPlayer)
		end

	end

	if reason == 'put_in_vehicle' then

		local closestPlayer = GetClosestPlayerInAreaNotInAnyVehicle(positions, 3.0)

    if closestPlayer ~= -1 then
    	PoliceMenuTargetPlayerId = closestPlayer;
    	TriggerServerEvent('esx_ambulancejob:putInVehicle', closestPlayer);
		end

	end

end)

RegisterNetEvent('esx_ambulancejob:respawnToHospital')
AddEventHandler('esx_ambulancejob:respawnToHospital', function()
	if IsAlreadyDead then
		
		local playerPed = GetPlayerPed(-1)
		
		TriggerServerEvent('esx_ambulancejob:onBeforeRespawn')

		respawnPed(playerPed, Config.Zones.Hospital.Pos)

		SendNUIMessage({
			showControls = false
		})
	end
end)

RegisterNetEvent('esx_ambulancejob:revive')
AddEventHandler('esx_ambulancejob:revive', function()

	local playerPed = GetPlayerPed(-1)
	local coords    = GetEntityCoords(playerPed)

	NetworkResurrectLocalPlayer(coords, true, true, false)
	SetPlayerInvincible(playerPed, false)
	ClearPedBloodDamage(playerPed) 

	SendNUIMessage({
		showControls = false,
		showMenu     = false,
	})

	IsAlreadyDead = false;

end)

RegisterNetEvent('esx_ambulancejob:putInVehicle')
AddEventHandler('esx_ambulancejob:putInVehicle', function()

	local playerPed = GetPlayerPed(-1)
	local coords    = GetEntityCoords(playerPed)

  if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then

    local vehicle = nil

    if IsPedInAnyVehicle(playerPed, false) then
      vehicle = GetVehiclePedIsIn(playerPed, false)
    else
      vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
    end

    if DoesEntityExist(vehicle) then

    	local maxSeats = GetVehicleMaxNumberOfPassengers(vehicle)
    	local freeSeat = nil

    	for i=maxSeats - 1, 0, -1 do
    		if IsVehicleSeatFree(vehicle,  i) then
    			freeSeat = i
    			break
    		end
    	end

    	if freeSeat ~= nil then
    		SetPedIntoVehicle(playerPed,  vehicle,  freeSeat)
    	end

    end

  end	

end)
local hashSkin = GetHashKey("mp_m_freemode_01")
RegisterNUICallback('select', function(data, cb)

		if data.menu == 'citizen_interaction' then

			if data.val == 'revive' then
				TriggerServerEvent('esx_ambulancejob:requestPlayerPositions', 'revive')
			end

			if data.val == 'put_in_vehicle' then
				TriggerServerEvent('esx_ambulancejob:requestPlayerPositions', 'put_in_vehicle')
			end

		end

		if data.menu == 'cloakroom' then
			local playerPed = GetPlayerPed(-1)
			if data.val == 'citizen_wear' then
				TriggerEvent('esx_skin:loadSkin', PlayerData.skin)
			end

			if data.val == 'ambulance_wear' then
				if(GetEntityModel(GetPlayerPed(-1)) == hashSkin) then
					SetPedComponentVariation(playerPed, 11, 13, 3, 0)
					SetPedComponentVariation(playerPed, 8, 15, 0, 0)
					SetPedComponentVariation(playerPed, 4, 9, 3, 0)
					SetPedComponentVariation(playerPed, 3, 92, 0, 0)
					SetPedComponentVariation(playerPed, 6, 25, 0, 0)
				else
					SetPedComponentVariation(playerPed, 11, 119, 0, 0)
					SetPedComponentVariation(playerPed, 8, 2, 0, 0)
					SetPedComponentVariation(playerPed, 4, 61, 5, 0)
					SetPedComponentVariation(playerPed, 3, 109, 0, 0)
					SetPedComponentVariation(playerPed, 6, 25, 0, 0)
				end
			end

		end

		if data.menu == 'vehiclespawner' then

	    local playerPed = GetPlayerPed(-1)

			Citizen.CreateThread(function()

				local coords       = Config.Zones.VehicleSpawnPoint.Pos
				local vehicleModel = GetHashKey(data.val)

				RequestModel(vehicleModel)

				while not HasModelLoaded(vehicleModel) do
					Citizen.Wait(0)
				end

				if not IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then
					local vehicle = CreateVehicle(vehicleModel, coords.x, coords.y, coords.z, 90.0, true, false)
					SetVehicleHasBeenOwnedByPlayer(vehicle,  true)
					SetEntityAsMissionEntity(vehicle,  true,  true)
					local id = NetworkGetNetworkIdFromEntity(vehicle)
					SetNetworkIdCanMigrate(id, true)
					TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
				end

			end)

			SendNUIMessage({
				showControls = false,
				showMenu     = false,
			})

		end

		if data.menu == 'dead' then

			if data.val == 'no_revive' then
				
				SendNUIMessage({
					showMenu     = false,
					showControls = true,
					controls     = 'dead'
				})

			end

			if data.val == 'yes_revive' then

				local playerPed = GetPlayerPed(-1)

				TriggerServerEvent('esx_ambulancejob:onBeforeRespawn')

				respawnPed(playerPed, Config.Zones.Hospital.Pos)

				SendNUIMessage({
					showMenu     = false,
					showControls = false
				})

			end

		end

		cb('ok')

end)

RegisterNUICallback('select_control', function(data, cb)
		cb('ok')

end)

-- Display markers
Citizen.CreateThread(function()
	while true do
		
		Wait(0)
		
		local coords = GetEntityCoords(GetPlayerPed(-1))
		
		for k,v in pairs(Config.Zones) do

			if(PlayerData.job ~= nil and PlayerData.job.name == 'ambulance' and v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
				DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, true, 2, false, false, false, false)
			end
		end

	end
end)

-- Activate menu when player is inside marker
Citizen.CreateThread(function()
	while true do
		
		Wait(0)
		
		if(PlayerData.job ~= nil and PlayerData.job.name == 'ambulance') then

			local coords      = GetEntityCoords(GetPlayerPed(-1))
			local isInMarker  = false
			local currentZone = nil

			for k,v in pairs(Config.Zones) do
				if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
					isInMarker  = true
					currentZone = k
				end
			end

			if isInMarker and not hasAlreadyEnteredMarker then
				hasAlreadyEnteredMarker = true
				lastZone                = currentZone
				TriggerEvent('esx_ambulancejob:hasEnteredMarker', currentZone)
			end

			if not isInMarker and hasAlreadyEnteredMarker then
				hasAlreadyEnteredMarker = false
				TriggerEvent('esx_ambulancejob:hasExitedMarker', lastZone)
			end

		end

	end
end)

-- RP Death
Citizen.CreateThread(function()
	while true do

		Wait(0)

		local playerPed = GetPlayerPed(-1)

		if IsEntityDead(playerPed) then

			if not IsAlreadyDead then

				IsAlreadyDead = true

				SetPlayerInvincible(playerPed, true)
				SetEntityHealth(playerPed, 1)

				SendNUIMessage({
					showControls = true,
					controls     = 'dead'
				})

				local foo = 'bar'

				TriggerEvent('esx:setTimeout', Config.RespawnDelayAfterRPDeath, function()
					TriggerEvent('esx_ambulancejob:respawnToHospital')
				end)

			end
		end

	end
end)

-- Create blips
Citizen.CreateThread(function()
	local blip = AddBlipForCoord(Config.Zones.Hospital.Pos.x, Config.Zones.Hospital.Pos.y, Config.Zones.Hospital.Pos.z)
  
  SetBlipSprite (blip, 61)
  SetBlipDisplay(blip, 4)
  SetBlipScale  (blip, 1.2)
  SetBlipAsShortRange(blip, true)
	
	BeginTextCommandSetBlipName("STRING")
  AddTextComponentString("Ambulancier")
  EndTextCommandSetBlipName(blip)

end)

-- Menu Controls
Citizen.CreateThread(function()
	while true do

		Wait(0)

		if PlayerData.job ~= nil and PlayerData.job.name == 'ambulance' and IsControlPressed(0, Keys['F6']) and (GetGameTimer() - GUI.Time) > 300 then

			SendNUIMessage({
				showControls = false,
				showMenu     = true,
				menu         = 'ambulance_actions'
			})

			GUI.Time = GetGameTimer()

		end

		if IsControlPressed(0, Keys['ENTER']) and (GetGameTimer() - GUI.Time) > 300 then

			SendNUIMessage({
				enterPressed = true
			})

			GUI.Time = GetGameTimer()

		end

		if IsControlPressed(0, Keys['BACKSPACE']) and (GetGameTimer() - GUI.Time) > 300 then

			SendNUIMessage({
				backspacePressed = true
			})

			GUI.Time = GetGameTimer()

		end

		if IsControlPressed(0, Keys['LEFT']) and (GetGameTimer() - GUI.Time) > 300 then

			SendNUIMessage({
				move = 'LEFT'
			})

			GUI.Time = GetGameTimer()

		end

		if IsControlPressed(0, Keys['RIGHT']) and (GetGameTimer() - GUI.Time) > 300 then

			SendNUIMessage({
				move = 'RIGHT'
			})

			GUI.Time = GetGameTimer()

		end

		if IsControlPressed(0, Keys['TOP']) and (GetGameTimer() - GUI.Time) > 300 then

			SendNUIMessage({
				move = 'UP'
			})

			GUI.Time = GetGameTimer()

		end

		if IsControlPressed(0, Keys['DOWN']) and (GetGameTimer() - GUI.Time) > 300 then

			SendNUIMessage({
				move = 'DOWN'
			})

			GUI.Time = GetGameTimer()

		end

	end
end)

--Load unloaded ipl's
Citizen.CreateThread(function()
  LoadMpDlcMaps()
  EnableMpDlcMaps(true)
  RequestIpl("Coroner_Int_on")	-- Morgue => 244.9 -1374.7 39.5
end)