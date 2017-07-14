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

local PID                     = 0
local PlayerData              = {}
local GUI                     = {}
GUI.Time                      = 0
local hasAlreadyEnteredMarker = false;
local lastZone                = nil;
local Blips                   = {}


AddEventHandler('playerSpawned', function(spawn)
	PID = GetPlayerServerId(PlayerId())
	TriggerServerEvent('esx_fishermanjob:requestPlayerData', 'playerSpawned')
end)

AddEventHandler('esx_fishermanjob:hasEnteredMarker', function(zone)

	if zone == 'CloakRoom' then
		SendNUIMessage({
			showControls = true,
			controls     = 'cloakroom'
		})
	end

	if zone == 'BoatSpawner' then
		SendNUIMessage({
			showControls = true,
			controls     = 'boatspawner'
		})
	end

	if zone == 'TruckSpawner' then
		SendNUIMessage({
			showControls = true,
			controls     = 'truckspawner'
		})
	end

	if zone == 'FishingSpot' then

		SendNUIMessage({
			showControls = true,
			controls     = 'fishing'
		})
	
	end

	if zone == 'Delivery' then
		
		if Blips['delivery'] ~= nil then
			RemoveBlip(Blips['delivery'])
			Blips['delivery'] = nil
		end

		SendNUIMessage({
			showControls = true,
			controls     = 'delivery'
		})

	end

end)

AddEventHandler('esx_fishermanjob:hasExitedMarker', function(zone)
	
	if zone == 'FishingSpot' then
		TriggerServerEvent('esx_fishermanjob:stopHarvestFish')
	end

	if zone == 'Delivery' then
		TriggerServerEvent('esx_fishermanjob:stopResell')
	end

	SendNUIMessage({
		showControls = false,
		showMenu     = false,
	})
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
end)

RegisterNetEvent('esx_fishermanjob:responsePlayerData')
AddEventHandler('esx_fishermanjob:responsePlayerData', function(data, reason)
	PlayerData = data
end)
local hashSkin = GetHashKey("mp_m_freemode_01")
RegisterNUICallback('select', function(data, cb)

	if data.menu == 'cloakroom' then

		if data.val == 'citizen_wear' then
			TriggerEvent('esx_skin:loadSkin', PlayerData.skin)
		end

		if data.val == 'fisherman_wear' then
			if(GetEntityModel(GetPlayerPed(-1)) == hashSkin) then
			SetPedComponentVariation(GetPlayerPed(-1), 11, 124, 0, 2)  -- Top
			SetPedComponentVariation(GetPlayerPed(-1), 8, 24, 1, 2)   -- under coat
			SetPedComponentVariation(GetPlayerPed(-1), 4, 47, 1, 2)   -- Pants
			SetPedComponentVariation(GetPlayerPed(-1), 6, 25, 0, 2)   -- shoes
			SetPedComponentVariation(GetPlayerPed(-1), 3, 108, 0, 2)   -- under skin
		else
			SetPedComponentVariation(GetPlayerPed(-1), 11, 63, 3, 2)  -- Top
			SetPedComponentVariation(GetPlayerPed(-1), 8, 44, 1, 2)   -- under coat
			SetPedComponentVariation(GetPlayerPed(-1), 4, 11, 14, 2)   -- Pants
			SetPedComponentVariation(GetPlayerPed(-1), 6, 36, 0, 2)   -- shoes
			SetPedComponentVariation(GetPlayerPed(-1), 3, 78, 0, 2)   -- under skin
			end
		end

	end

	if data.menu == 'boatspawner' then

    local playerPed = GetPlayerPed(-1)

		Citizen.CreateThread(function()

			local coords       = Config.Zones.BoatSpawnPoint.Pos
			local vehicleModel = GetHashKey(data.val)

			RequestModel(vehicleModel)

			while not HasModelLoaded(vehicleModel) do
				Citizen.Wait(0)
			end

			if not IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then
				local vehicle = CreateVehicle(vehicleModel, coords.x, coords.y, coords.z, -90.0, true, false)
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

	if data.menu == 'truckspawner' then

    local playerPed = GetPlayerPed(-1)

		Citizen.CreateThread(function()

			local coords       = Config.Zones.TruckSpawnPoint.Pos
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

		Blips['delivery'] = AddBlipForCoord(Config.Zones.Delivery.Pos.x,  Config.Zones.Delivery.Pos.y,  Config.Zones.Delivery.Pos.z)
		SetBlipRoute(Blips['delivery'], true)

		TriggerEvent('esx:showNotification', 'Rendez-vous au point de livraison')

		SendNUIMessage({
			showControls = false,
			showMenu     = false,
		})

	end

	cb('ok')

end)

RegisterNUICallback('select_control', function(data, cb)
	
	if data.control == 'fishing' then
		
		TriggerServerEvent('esx_fishermanjob:startHarvestFish')

		SendNUIMessage({
			showControls = false
		})

	end

	if data.control == 'delivery' then
		
		TriggerServerEvent('esx_fishermanjob:startResell')

		SendNUIMessage({
			showControls = false
		})

	end

	cb('ok')
end)

-- Display markers
Citizen.CreateThread(function()
	while true do
		
		Wait(0)
		
		local coords = GetEntityCoords(GetPlayerPed(-1))
		
		for k,v in pairs(Config.Zones) do

			if(PlayerData.job ~= nil and PlayerData.job.name == 'fisherman' and v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
				DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, true, 2, false, false, false, false)
			end

		end
	end
end)

-- Activate menu when player is inside marker
Citizen.CreateThread(function()
	while true do
		
		Wait(0)
		
		if(PlayerData.job ~= nil and PlayerData.job.name == 'fisherman') then

			local coords      = GetEntityCoords(GetPlayerPed(-1))
			local isInMarker  = false
			local currentZone = nil

			for k,v in pairs(Config.Zones) do
				if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x / 2) then
					isInMarker  = true
					currentZone = k
				end
			end

			if isInMarker and not hasAlreadyEnteredMarker then
				hasAlreadyEnteredMarker = true
				lastZone                = currentZone
				TriggerEvent('esx_fishermanjob:hasEnteredMarker', currentZone)
			end

			if not isInMarker and hasAlreadyEnteredMarker then
				hasAlreadyEnteredMarker = false
				TriggerEvent('esx_fishermanjob:hasExitedMarker', lastZone)
			end

		end

	end
end)

-- Create blips
Citizen.CreateThread(function()

	local blip = AddBlipForCoord(Config.Zones.BoatSpawnPoint.Pos.x, Config.Zones.BoatSpawnPoint.Pos.y, Config.Zones.BoatSpawnPoint.Pos.z)
  
  SetBlipSprite (blip, 68)
  SetBlipDisplay(blip, 4)
  SetBlipScale  (blip, 1.2)
  SetBlipColour (blip, 38)
  SetBlipAsShortRange(blip, true)
	
	BeginTextCommandSetBlipName("STRING")
  AddTextComponentString("Pêche")
  EndTextCommandSetBlipName(blip)

end)

-- Menu Controls
Citizen.CreateThread(function()
	while true do

		Wait(0)

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