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

local SpawnedVehicles          = {}
local PID                      = 0
local PlayerData               = {}
local GUI                      = {}
GUI.Time                       = 0
local hasAlreadyEnteredMarker  = false
local lastZone                 = nil
local PoliceMenuTargetPlayerId = nil
local PlayerIsHandcuffed       = false
local CurrentFine              = nil
local StingerDeployed          = false
local Stinger                  = nil
local inputDelay               = 120

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

function SetVehicleProperties(vehicle, props)

	SetVehicleModKit(vehicle,  0)

	if props.plate ~= nil then
		SetVehicleNumberPlateText(vehicle,  props.plate)
	end

	if props.plateIndex ~= nil then
		SetVehicleNumberPlateTextIndex(vehicle,  props.plateIndex)
	end

	if props.color1 ~= nil and props.color2 ~= nil then
		SetVehicleColours(vehicle, props.color1, props.color2)
	end

	if props.pearlescentColor ~= nil and props.wheelColor ~= nil then
		SetVehicleExtraColours(vehicle,  props.pearlescentColor,  props.wheelColor)
	end

	if props.wheels ~= nil then
		SetVehicleWheelType(vehicle,  props.wheels)
	end

	if props.windowTint ~= nil then
		SetVehicleWindowTint(vehicle,  props.windowTint)
	end

	if props.neonColor ~= nil then
		SetVehicleNeonLightsColour(vehicle,  props.neonColor[1], props.neonColor[2], props.neonColor[3])
	end

	if props.modSpoilers ~= nil then
		SetVehicleMod(vehicle, 0, props.modSpoilers, false)
	end

	if props.modFrontBumper ~= nil then
		SetVehicleMod(vehicle, 1, props.modFrontBumper, false)
	end

	if props.modRearBumper ~= nil then
		SetVehicleMod(vehicle, 2, props.modRearBumper, false)
	end

	if props.modSideSkirt ~= nil then
		SetVehicleMod(vehicle, 3, props.modSideSkirt, false)
	end

	if props.modExhaust ~= nil then
		SetVehicleMod(vehicle, 4, props.modExhaust, false)
	end

	if props.modFrame ~= nil then
		SetVehicleMod(vehicle, 5, props.modFrame, false)
	end

	if props.modGrille ~= nil then
		SetVehicleMod(vehicle, 6, props.modGrille, false)
	end

	if props.modHood ~= nil then
		SetVehicleMod(vehicle, 7, props.modHood, false)
	end

	if props.modFender ~= nil then
		SetVehicleMod(vehicle, 8, props.modFender, false)
	end

	if props.modRightFender ~= nil then
		SetVehicleMod(vehicle, 9, props.modRightFender, false)
	end

	if props.modRoof ~= nil then
		SetVehicleMod(vehicle, 10, props.modRoof, false)
	end

	if props.modEngine ~= nil then
		SetVehicleMod(vehicle, 11, props.modEngine, false)
	end

	if props.modBrakes ~= nil then
		SetVehicleMod(vehicle, 12, props.modBrakes, false)
	end

	if props.modTransmission ~= nil then
		SetVehicleMod(vehicle, 13, props.modTransmission, false)
	end

	if props.modHorns ~= nil then
		SetVehicleMod(vehicle, 14, props.modHorns, false)
	end

	if props.modSuspension ~= nil then
		SetVehicleMod(vehicle, 15, props.modSuspension, false)
	end

	if props.modArmor ~= nil then
		SetVehicleMod(vehicle, 16, props.modArmor, false)
	end

	if props.modTurbo ~= nil then
		ToggleVehicleMod(vehicle,  18, props.modTurbo)
	end

	if props.modXenon ~= nil then
		ToggleVehicleMod(vehicle,  22, props.modXenon)
	end

	if props.modFrontWheels ~= nil then
		SetVehicleMod(vehicle, 23, props.modFrontWheels, false)
	end

	if props.modBackWheels ~= nil then
		SetVehicleMod(vehicle, 24, props.modBackWheels, false)
	end

end

function SetVehicleMaxMods(vehicle)

	local props = {
		modEngine       = 2,
		modBrakes       = 2,
		modTransmission = 2,
		modSuspension   = 3,
		modTurbo        = true,
	}

	SetVehicleProperties(vehicle, props)
end

AddEventHandler('playerSpawned', function(spawn)
	PID = GetPlayerServerId(PlayerId())
	TriggerServerEvent('esx_policejob:requestPlayerData', 'playerSpawned')
end)

RegisterNetEvent('esx_phone:loaded')
AddEventHandler('esx_phone:loaded', function(phoneNumber, contacts)
	
	TriggerEvent('esx_phone:addContact', 'Police', 'police', 'special', false)

	TriggerEvent('esx_phone:registerMessageCallback', 'copy_that', function(sender, phoneNumber, type, message, position)
		TriggerServerEvent('esx_phone:send', 'player', phoneNumber, GetPlayerName(PlayerId()), 'Bien reçu')
	end)

end)

AddEventHandler('esx_policejob:hasEnteredMarker', function(zone)

	if zone == 'CloakRoom' then
		if PlayerData.job.name ~= nil and PlayerData.job.name == 'cop' then
			SendNUIMessage({
				showControls = true,
				controls     = 'cloakroom'
			})
		end
	end

	if zone == 'Armory' then
		if PlayerData.job.name ~= nil and PlayerData.job.name == 'cop' then
			SendNUIMessage({
				showControls = true,
				controls     = 'armory'
			})
		end
	end

	if zone == 'VehicleSpawner' then
		if PlayerData.job.name ~= nil and PlayerData.job.name == 'cop' then
			SendNUIMessage({
				showControls = true,
				controls     = 'vehiclespawner'
			})
		end
	end

	if zone == 'HelicopterLandingPadSpawner1' then

		if SpawnedVehicles['Polmav1'] ~= nil and not DoesEntityExist(GetPedInVehicleSeat(SpawnedVehicles['Polmav1'], -1)) then
			DeleteVehicle(SpawnedVehicles['Polmav1'])
			SpawnedVehicles['Polmav1'] = nil
		end

		Citizen.CreateThread(function()

			local coords      = Config.Zones.HelicopterLandingPad1.Pos
			local vehicleModel = GetHashKey('polmav')

			RequestModel(vehicleModel)

			while not HasModelLoaded(vehicleModel) do
				Citizen.Wait(0)
			end

			if not IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 10.0) then
				SpawnedVehicles['Polmav1'] = CreateVehicle(vehicleModel, coords.x, coords.y, coords.z, 0.0, true, false)
				SetVehicleModKit(SpawnedVehicles['Polmav1'], 0)
				SetVehicleLivery(SpawnedVehicles['Polmav1'], 0)
				SetVehicleHasBeenOwnedByPlayer(SpawnedVehicles['Polmav1'],  true)
				--SetEntityAsMissionEntity(SpawnedVehicles['Polmav1'],  true,  true)
				local id = NetworkGetNetworkIdFromEntity(SpawnedVehicles['Polmav1'])
				SetNetworkIdCanMigrate(id, true)
			end

		end)

	end

	if zone == 'VehicleDeleter1' or zone == 'VehicleDeleter2' then

		local playerPed = GetPlayerPed(-1)

		if IsPedInAnyVehicle(playerPed, 0) then

			local vehicle = GetVehiclePedIsIn(playerPed,  false)

			DeleteVehicle(vehicle)

		end

	end

end)

AddEventHandler('esx_policejob:hasExitedMarker', function(zone)
	SendNUIMessage({
		showControls = false,
		showMenu     = false,
	})
end)

RegisterNetEvent('esx_policejob:handcuff')
AddEventHandler('esx_policejob:handcuff', function()

	PlayerIsHandcuffed = not PlayerIsHandcuffed;
	local playerPed    = GetPlayerPed(-1)

	Citizen.CreateThread(function()

		if PlayerIsHandcuffed then
			
			RequestAnimDict('mp_arresting')
			
			while not HasAnimDictLoaded('mp_arresting') do
				Wait(100)
			end
			
			TaskPlayAnim(playerPed, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0, 0, 0, 0)
			SetEnableHandcuffs(playerPed, true)
			SetPedCanPlayGestureAnims(playerPed, false)
			FreezeEntityPosition(playerPed,  true)
		
		else
			
			ClearPedSecondaryTask(playerPed)
			SetEnableHandcuffs(playerPed, false)
			SetPedCanPlayGestureAnims(playerPed,  true)
			FreezeEntityPosition(playerPed, false)
		
		end

	end)
end)

RegisterNetEvent('esx_policejob:putInVehicle')
AddEventHandler('esx_policejob:putInVehicle', function()

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

RegisterNetEvent('esx_policejob:confiscatePlayerWeapon')
AddEventHandler('esx_policejob:confiscatePlayerWeapon', function(weaponName)
	local playerPed = GetPlayerPed(-1)
	RemoveWeaponFromPed(playerPed,  GetHashKey(weaponName))
end)

RegisterNetEvent('esx_policejob:requestPlayerWeapons')
AddEventHandler('esx_policejob:requestPlayerWeapons', function(playerId, reason)

	local playerPed = GetPlayerPed(-1)
	local weapons   = {}

	for i=1, #Config.Weapons, 1 do
		
		local weaponHash = GetHashKey(Config.Weapons[i].name)

		if HasPedGotWeapon(playerPed,  weaponHash,  false) and Config.Weapons[i].name ~= 'WEAPON_UNARMED' then

			local ammo = GetAmmoInPedWeapon(playerPed, weaponHash)

			table.insert(weapons, {
				name = Config.Weapons[i].name,
				ammo = ammo,
			})

		end
	end

	TriggerServerEvent('esx_policejob:responsePlayerWeapons', weapons, playerId, reason)

end)

RegisterNetEvent('esx_policejob:responsePlayerPositions')
AddEventHandler('esx_policejob:responsePlayerPositions', function(positions, reason)

	if reason == 'identity_card' then

		local closestPlayer = GetClosestPlayerInArea(positions, 3.0)

    if closestPlayer ~= -1 then
    	PoliceMenuTargetPlayerId = closestPlayer;
    	TriggerServerEvent('esx_policejob:requestOtherPlayerData', closestPlayer, 'identity_card')
		end

	end

	if reason == 'body_search' then

		local closestPlayer = GetClosestPlayerInArea(positions, 3.0)

    if closestPlayer ~= -1 then
    	PoliceMenuTargetPlayerId = closestPlayer;
    	TriggerServerEvent('esx_policejob:requestOtherPlayerData', closestPlayer, 'body_search')
		end

	end

	if reason == 'handcuff' then

		local closestPlayer = GetClosestPlayerInArea(positions, 3.0)

    if closestPlayer ~= -1 then
    	PoliceMenuTargetPlayerId = closestPlayer;
    	TriggerServerEvent('esx_policejob:handcuff', closestPlayer);
		end

	end

	if reason == 'put_in_vehicle' then

		local closestPlayer = GetClosestPlayerInAreaNotInAnyVehicle(positions, 3.0)

    if closestPlayer ~= -1 then
    	PoliceMenuTargetPlayerId = closestPlayer;
    	TriggerServerEvent('esx_policejob:putInVehicle', closestPlayer);
		end

	end

	if reason == 'fine_data' then

		local closestPlayer = GetClosestPlayerInArea(positions, 3.0)

    if closestPlayer ~= -1 then
    	PoliceMenuTargetPlayerId = closestPlayer;
    	TriggerServerEvent('esx_policejob:applyFine', closestPlayer, CurrentFine);
		end

	end
    
    if reason == 'barrier' then
        PlaceObject("prop_barrier_work05")
        log('Barrière posée.')
    end
    
    if reason == 'stinger' then
        PlaceObject("p_ld_stinger_s")
        log('Herse posée.')
    end
    
    if reason == 'sandbag' then
        PlaceObject("prop_conc_sacks_02a")
        log('Sac de sable posé.')
    end
    
    if reason == 'pickup' then
        PickupObject()
        log('Voie dégagée.')
    end

end)

function PickupObject()
    local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))
    local object = nil    
    local hash = { "prop_barrier_work05", "p_ld_stinger_s", "prop_conc_sacks_02a" }
    local i = 1
    while i < 4 do
        object = GetClosestObjectOfType(x, y, z, 1.0, hash[i], true, true, true)
        if object ~= nil then
            DeleteObject(object)            
            StingerDeployed = false
            Stinger = nil
        end
        i = i + 1
    end
end

function PlaceObject(obj)
    local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))
    -- On appel un model et on attend qu'il soit chargé
    RequestModel(obj)
    while not HasModelLoaded(obj) do
        Wait(1)
    end
    -- Enregistrer la direction qui fait face au joueur
    local playerHeading = GetEntityHeading(GetPlayerPed(-1))
    -- On convertit en radians pour les calculs de trigonométrie
    local playerHeadingRad = math.rad(playerHeading)
    local a = math.cos(playerHeadingRad)
    local b = math.sin(playerHeadingRad)
    -- position X de l'objet = player.x - sinus de la direction regardée
    -- position Y de l'objet = player.y + cosinus de la direction regardée
    local object = nil
    if obj ~= "p_ld_stinger_s" then
        object = CreateObject(obj, x-b, y+a, z, true, true, true)
    elseif (obj == "p_ld_stinger_s" and StingerDeployed == false) then
        object = CreateObject(obj, x-b, y+a, z, true, true, true)
        StingerDeployed = true
        Stinger = object
    end
    -- Orienter l'objet vers la direction qui fait face au joueur
    SetEntityHeading(object, playerHeading)
    -- Quelle que soit la hauteur Z de CreateObject ou du joueur, colle l'objet au sol
    PlaceObjectOnGroundProperly(object)
end

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
end)

RegisterNetEvent('esx_policejob:responsePlayerData')
AddEventHandler('esx_policejob:responsePlayerData', function(data, reason)
	PlayerData = data
end)

RegisterNetEvent('esx_policejob:responseOtherPlayerData')
AddEventHandler('esx_policejob:responseOtherPlayerData', function(data, reason)
	
	if reason == 'identity_card' then

		local jobLabel = nil

		if data.job.grade_label ~= nil and  data.job.grade_label ~= '' then
			jobLabel = 'Job : ' .. data.job.label .. ' - ' .. data.job.grade_label
		else
			jobLabel = 'Job : ' .. data.job.label
		end

		local items = {
			{label = 'Nom : ' .. data.name, value = nil},
			{label = jobLabel,              value = nil}
		}

		SendNUIMessage({
			showControls = false,
			showMenu     = true,
			menu         = 'identity_card',
			items        = items
		})

	end

	if reason == 'body_search' then

		local items = {}
		
		local blackMoney = 0

		for i=1, #data.accounts, 1 do
			if data.accounts[i].name == 'black_money' then
				blackMoney = data.accounts[i].money
			end
		end

		table.insert(items, {
			label          = 'Confisquer argent sale : $' .. blackMoney,
			value          = blackMoney,
			type           = 'black_money',
			removeOnSelect = true
		})

		table.insert(items, {label = '--- Armes ---', value = nil})

		for i=1, #data.weapons, 1 do
			table.insert(items, {
				label          = 'Confisquer ' .. data.weapons[i].name,
				value          = data.weapons[i].name,
				type           = 'weapon',
				count          = data.ammo,
				removeOnSelect = true
			})
		end

		table.insert(items, {label = '--- Inventaire ---', value = nil})

		for i=1, #data.inventory, 1 do
			if data.inventory[i].count > 0 then
				table.insert(items, {
					label          = 'Confisquer x' .. data.inventory[i].count .. ' ' .. data.inventory[i].label,
					value          = data.inventory[i].item,
					type           = 'inventory_item',
					count          = data.inventory[i].count,
					removeOnSelect = true
				})
			end
		end

		SendNUIMessage({
			showControls = false,
			showMenu     = true,
			menu         = 'body_search',
			items        = items
		})

	end

end)

RegisterNetEvent('esx_policejob:responseFineData')
AddEventHandler('esx_policejob:responseFineData', function(data)

	local items = {}

	for i=1, #data, 1 do
		table.insert(items, {
			label = data[i].label .. ' : $' .. data[i].amount,
			value = data[i].id
		})
	end

	SendNUIMessage({
		showControls = false,
		showMenu     = true,
		menu         = 'fine_data',
		items        = items
	})

end)

RegisterNetEvent('esx_policejob:responseFineList')
AddEventHandler('esx_policejob:responseFineList', function(fines)

	local items = {}

	for i=1, #fines, 1 do
		table.insert(items, {
			label          = 'Payer $' .. fines[i].amount .. ' pour ' .. fines[i].label,
			value          = fines[i].id,
			count          = fines[i].amount,
			removeOnSelect = true
		})
	end

	SendNUIMessage({
		showControls = false,
		showMenu     = true,
		menu         = 'fine_list',
		items        = items
	})

end)

RegisterNetEvent('esx_policejob:hasPayedFine')
AddEventHandler('esx_policejob:hasPayedFine', function(playerName, amount)
	if PlayerData.job ~= nil and PlayerData.job.name == 'cop' then
		TriggerEvent('esx:showNotification', playerName .. ' a payé une amende de $' .. amount)
	end
end)
local hashSkin = GetHashKey("mp_m_freemode_01")
RegisterNUICallback('select', function(data, cb)

		if data.menu == 'cloakroom' then

			if data.val == 'civilian_wear' then
				TriggerEvent('esx_skin:loadSkin', PlayerData.skin)
			end

			if data.val == 'policeman_wear' then
				if(GetEntityModel(GetPlayerPed(-1)) == hashSkin) then
					SetPedPropIndex(GetPlayerPed(-1), 1, 5, 0, 2)             --Sunglasses
					SetPedPropIndex(GetPlayerPed(-1), 2, 0, 0, 2)             --Bluetoothn earphone
					SetPedComponentVariation(GetPlayerPed(-1), 11, 55, 0, 2)  --Shirt
					SetPedComponentVariation(GetPlayerPed(-1), 8, 58, 0, 2)   --Nightstick decoration
					SetPedComponentVariation(GetPlayerPed(-1), 4, 35, 0, 2)   --Pants
					SetPedComponentVariation(GetPlayerPed(-1), 6, 24, 0, 2)   --Shooes
					SetPedComponentVariation(GetPlayerPed(-1), 10, 8, 0, 2)   --rank
				else
					TriggerEvent('esx_skin:loadJobSkin', PlayerData.skin, PlayerData.job.skin_female)
				end
			end

			if data.val == 'policeman_veste' then
				if(GetEntityModel(GetPlayerPed(-1)) == hashSkin) then
					SetPedComponentVariation(GetPlayerPed(-1), 8, 59, 0, 2)
				else
					SetPedComponentVariation(GetPlayerPed(-1), 8, 36, 0, 2)
				end
			end

			if data.val == 'policeman_retirer_veste' then
				if(GetEntityModel(GetPlayerPed(-1)) == hashSkin) then
					SetPedComponentVariation(GetPlayerPed(-1), 8, 58, 0, 2)
				else
					SetPedComponentVariation(GetPlayerPed(-1), 8, 35, 0, 2)
				end
			end

			if data.val == 'tenue_agent' then
				if(GetEntityModel(GetPlayerPed(-1)) == hashSkin) then
					SetPedComponentVariation(GetPlayerPed(-1), 7, 18, 0, 0) -- Cravate
				    SetPedComponentVariation(GetPlayerPed(-1), 8, 21, 4, 0) -- Chemise
				    SetPedComponentVariation(GetPlayerPed(-1), 3, 4, 0, 0) -- Main
				    SetPedComponentVariation(GetPlayerPed(-1), 11, 10, 0, 0) -- Veste
				    SetPedComponentVariation(GetPlayerPed(-1), 4, 10, 0, 0) -- Jeans
				    SetPedComponentVariation(GetPlayerPed(-1), 6, 10, 0, 0) -- Chaussure
				else
					SetPedComponentVariation(GetPlayerPed(-1), 8, 21, 4, 0) -- Chemise
				    SetPedComponentVariation(GetPlayerPed(-1), 7, 12, 2, 0) -- Cravate
				    SetPedComponentVariation(GetPlayerPed(-1), 3, 4, 0, 0) -- Main
				    SetPedComponentVariation(GetPlayerPed(-1), 11, 72, 2, 0) -- Veste
				    SetPedComponentVariation(GetPlayerPed(-1), 4, 10, 0, 0) -- Jeans
				    SetPedComponentVariation(GetPlayerPed(-1), 6, 10, 0, 0) -- Chaussure
				    SetPedPropIndex(GetPlayerPed(-1), 1, 7, 0, 1) -- Lunette
				    SetPedPropIndex(GetPlayerPed(-1), 2, 0, 0, 1) -- Oreilliette
				end
			end

			if data.val == 'tenue_sergent' then
				if(GetEntityModel(GetPlayerPed(-1)) == hashSkin) then
					SetPedComponentVariation(GetPlayerPed(-1), 3, 30, 0, 0)--Gants
					SetPedComponentVariation(GetPlayerPed(-1), 4, 35, 0, 0)--Jean
					SetPedComponentVariation(GetPlayerPed(-1), 6, 24, 0, 0)--Chaussure
					SetPedComponentVariation(GetPlayerPed(-1), 8, 58, 0, 0)--mattraque
					SetPedComponentVariation(GetPlayerPed(-1), 11, 55, 0, 0)--Veste
					SetPedPropIndex(GetPlayerPed(-1), 2, 2, 0, 1)--Oreillete
					SetPedPropIndex(GetPlayerPed(-1), 6, 3, 0, 1)--Montre
					SetPedPropIndex(GetPlayerPed(-1), 1, 7, 0, 1)--Lunette
				end
			end

			if data.val == 'tenue_sergentchef' then
				if(GetEntityModel(GetPlayerPed(-1)) == hashSkin) then
					SetPedComponentVariation(GetPlayerPed(-1), 3, 30, 0, 0)--Gants
					SetPedComponentVariation(GetPlayerPed(-1), 4, 35, 0, 0)--Jean
					SetPedComponentVariation(GetPlayerPed(-1), 6, 24, 0, 0)--Chaussure
					SetPedComponentVariation(GetPlayerPed(-1), 8, 58, 0, 0)--mattraque
					SetPedComponentVariation(GetPlayerPed(-1), 11, 55, 0, 0)--Veste
					SetPedComponentVariation(GetPlayerPed(-1), 10, 8, 2, 0)--Grade
					SetPedPropIndex(GetPlayerPed(-1), 2, 2, 0, 1)--Oreillete
					SetPedPropIndex(GetPlayerPed(-1), 6, 3, 0, 1)--Montre
					SetPedPropIndex(GetPlayerPed(-1), 1, 7, 0, 1)--Lunette
				end
			end

			if data.val == 'tenue_lieutenant' then
				if(GetEntityModel(GetPlayerPed(-1)) == hashSkin) then
					SetPedComponentVariation(GetPlayerPed(-1), 3, 30, 0, 0)--Gants
					SetPedComponentVariation(GetPlayerPed(-1), 4, 35, 0, 0)--Jean
					SetPedComponentVariation(GetPlayerPed(-1), 6, 24, 0, 0)--Chaussure
					SetPedComponentVariation(GetPlayerPed(-1), 8, 58, 0, 0)--mattraque
					SetPedComponentVariation(GetPlayerPed(-1), 11, 55, 0, 0)--Veste
					SetPedComponentVariation(GetPlayerPed(-1), 10, 8, 2, 0)--Grade
					SetPedPropIndex(GetPlayerPed(-1), 2, 2, 0, 1)--Oreillete
					SetPedPropIndex(GetPlayerPed(-1), 6, 3, 0, 1)--Montre
					SetPedPropIndex(GetPlayerPed(-1), 1, 7, 0, 1)--Lunette
				end
			end

			if data.val == 'tenue_capitaine' then
				if(GetEntityModel(GetPlayerPed(-1)) == hashSkin) then
					SetPedComponentVariation(GetPlayerPed(-1), 3, 30, 0, 0)--Gants
					SetPedComponentVariation(GetPlayerPed(-1), 4, 35, 0, 0)--Jean
					SetPedComponentVariation(GetPlayerPed(-1), 6, 24, 0, 0)--Chaussure
					SetPedComponentVariation(GetPlayerPed(-1), 8, 58, 0, 0)--mattraque
					SetPedComponentVariation(GetPlayerPed(-1), 11, 55, 0, 0)--Veste
					SetPedComponentVariation(GetPlayerPed(-1), 10, 8, 3, 0)--Grade
					SetPedPropIndex(GetPlayerPed(-1), 2, 2, 0, 1)--Oreillete
					SetPedPropIndex(GetPlayerPed(-1), 6, 3, 0, 1)--Montre
					SetPedPropIndex(GetPlayerPed(-1), 1, 18, 2, 1)--Lunette
				end
			end

		end

		if data.menu == 'armory' then

	    local playerPed = GetPlayerPed(-1)
	    local weapon    = GetHashKey(data.val)

			GiveWeaponToPed(playerPed, weapon, 1000, false, true)

			TriggerEvent('esx:showNotification', 'Vous avez recu votre arme')
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
					--SetEntityAsMissionEntity(vehicle,  true,  true)
					local id = NetworkGetNetworkIdFromEntity(vehicle)
					SetNetworkIdCanMigrate(id, true)
					TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
					SetVehicleMaxMods(vehicle)
				end

			end)

			SendNUIMessage({
				showControls = false,
				showMenu     = false,
			})

		end
        
        if data.menu == 'traffic_interaction' then
        
            if data.val == 'barrier' then
                TriggerServerEvent('esx_policejob:requestPlayerPositions', 'barrier')
            end
            if data.val == 'stinger' then
                TriggerServerEvent('esx_policejob:requestPlayerPositions', 'stinger')
            end
            if data.val == 'sandbag' then
                TriggerServerEvent('esx_policejob:requestPlayerPositions', 'sandbag')
            end
            if data.val == 'pickup' then
                TriggerServerEvent('esx_policejob:requestPlayerPositions', 'pickup')
            end
        
        end

		if data.menu == 'citizen_interaction' then

			if data.val == 'identity_card' then
				TriggerServerEvent('esx_policejob:requestPlayerPositions', 'identity_card')
			end

			if data.val == 'body_search' then
				TriggerServerEvent('esx_policejob:requestPlayerPositions', 'body_search')
			end

			if data.val == 'handcuff' then
				TriggerServerEvent('esx_policejob:requestPlayerPositions', 'handcuff')
			end

			if data.val == 'put_in_vehicle' then
				TriggerServerEvent('esx_policejob:requestPlayerPositions', 'put_in_vehicle')
			end

			if data.val == 'fine' then
				SendNUIMessage({
					showControls = false,
					showMenu     = true,
					menu         = 'fine',
				})
			end

		end

		if data.menu == 'body_search' then

			if data.type == 'black_money' then
				local playerServerId = GetPlayerServerId(PlayerId())
				TriggerServerEvent('esx_policejob:confiscatePlayerBlackMoney', PoliceMenuTargetPlayerId, data.val)
			end

			if data.type == 'weapon' then
				local playerPed = GetPlayerPed(-1)
				TriggerServerEvent('esx_policejob:confiscatePlayerWeapon', PoliceMenuTargetPlayerId, data.val)
				GiveWeaponToPed(playerPed,  GetHashKey(data.val),  0,  false,  false)
			end

			if data.type == 'inventory_item' then
				local playerServerId = GetPlayerServerId(PlayerId())
				TriggerServerEvent('esx_policejob:confiscatePlayerInventoryItem', PoliceMenuTargetPlayerId, data.val, tonumber(data.count))
				TriggerServerEvent('esx_policejob:addPlayerInventoryItem',        playerServerId,           data.val, tonumber(data.count))
			end
			

		end

		if data.menu == 'fine' then
			TriggerServerEvent('esx_policejob:requestFineData', data.val)
		end

		if data.menu == 'fine_data' then
			CurrentFine = data.val
			TriggerServerEvent('esx_policejob:requestPlayerPositions', 'fine_data')
		end

		if data.menu == 'fine_list' then
			TriggerServerEvent('esx_policejob:requestPayFine', data.val, data.count, GetPlayerName(PlayerId()))
		end

		if data.menu == 'vehicle_interaction' then

			if data.val == 'vehicle_infos' then

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
	        	
	        	local plateText = GetVehicleNumberPlateText(vehicle)
						local items     = {}

						table.insert(items, {label = 'N°: ' .. plateText, value = nil})

						local ownerName = 'IA'

						SendNUIMessage({
							showControls = false,
							showMenu     = true,
							menu         = 'vehicle_infos',
							items        = items
						})

	        end

	      end

			end

			if data.val == 'hijack_vehicle' then

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
	        	SetVehicleDoorsLocked(vehicle, 1)
            SetVehicleDoorsLockedForAllPlayers(vehicle, false)
            TriggerEvent('esx:showNotification', 'Véhicule déverouillé')

	        end

	      end

			end

		end

		cb('ok')

end)

-- Display markers
Citizen.CreateThread(function()
	while true do
		
		Wait(0)
		
		local coords = GetEntityCoords(GetPlayerPed(-1))
		
		for k,v in pairs(Config.Zones) do

			if(PlayerData.job ~= nil and PlayerData.job.name == 'cop' and v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
				DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, true, 2, false, false, false, false)
			end
		end

	end
end)

-- Activate menu when player is inside marker
Citizen.CreateThread(function()
	while true do
		
		Wait(0)
		
		if(PlayerData.job ~= nil and PlayerData.job.name == 'cop') then

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
				TriggerEvent('esx_policejob:hasEnteredMarker', currentZone)
			end

			if not isInMarker and hasAlreadyEnteredMarker then
				hasAlreadyEnteredMarker = false
				TriggerEvent('esx_policejob:hasExitedMarker', lastZone)
			end

		end

	end
end)

-- Stingers
Citizen.CreateThread(function()
	while true do		
		Wait(1)
        if StingerDeployed then
            local vehicle = nil
            local x, y, z = table.unpack(GetEntityCoords(Stinger, true))
            vehicle = GetClosestVehicle(x, y, z, 2.0, 0, 70)
            if vehicle ~= nil then
                -- REPEAT FROM 0 to 7 FOR ALL TYPE OF TYRES
                SetVehicleTyreBurst(vehicle, 0, true, 1000.0)
                SetVehicleTyreBurst(vehicle, 1, true, 1000.0)
            end
            
        end
    end
end)

-- Handcuff
Citizen.CreateThread(function()
	while true do
		Wait(0)
		if PlayerIsHandcuffed then
			DisableControlAction(0, 142, true) -- MeleeAttackAlternate
			DisableControlAction(0, 30,  true) -- MoveLeftRight
			DisableControlAction(0, 31,  true) -- MoveUpDown
		end
	end
end)

-- Create blips
Citizen.CreateThread(function()
	local blip = AddBlipForCoord(425.130, -979.558, 30.711)
  
  SetBlipSprite (blip, 60)
  SetBlipDisplay(blip, 4)
  SetBlipScale  (blip, 1.2)
  SetBlipAsShortRange(blip, true)
	
	BeginTextCommandSetBlipName("STRING")
  AddTextComponentString("Commissariat")
  EndTextCommandSetBlipName(blip)

end)

-- Menu Controls
Citizen.CreateThread(function()
	while true do

		Wait(0)

		if PlayerData.job ~= nil and PlayerData.job.name == 'cop' and IsControlPressed(0, Keys['F6']) and (GetGameTimer() - GUI.Time) > inputDelay then

			SendNUIMessage({
				showControls = false,
				showMenu     = true,
				menu         = 'police_actions'
			})

			GUI.Time = GetGameTimer()

		end

		if IsControlPressed(0, Keys['F7']) and (GetGameTimer() - GUI.Time) > inputDelay then

			TriggerServerEvent('esx_policejob:requestFineList')

			GUI.Time = GetGameTimer()

		end

		if IsControlPressed(0, Keys['ENTER']) and (GetGameTimer() - GUI.Time) > inputDelay then

			SendNUIMessage({
				enterPressed = true
			})

			GUI.Time = GetGameTimer()

		end

		if IsControlPressed(0, Keys['BACKSPACE']) and (GetGameTimer() - GUI.Time) > inputDelay then

			SendNUIMessage({
				backspacePressed = true
			})

			GUI.Time = GetGameTimer()

		end

		if IsControlPressed(0, Keys['LEFT']) and (GetGameTimer() - GUI.Time) > inputDelay then

			SendNUIMessage({
				move = 'LEFT'
			})

			GUI.Time = GetGameTimer()

		end

		if IsControlPressed(0, Keys['RIGHT']) and (GetGameTimer() - GUI.Time) > inputDelay then

			SendNUIMessage({
				move = 'RIGHT'
			})

			GUI.Time = GetGameTimer()

		end

		if IsControlPressed(0, Keys['TOP']) and (GetGameTimer() - GUI.Time) > inputDelay then

			SendNUIMessage({
				move = 'UP'
			})

			GUI.Time = GetGameTimer()

		end

		if IsControlPressed(0, Keys['DOWN']) and (GetGameTimer() - GUI.Time) > inputDelay then

			SendNUIMessage({
				move = 'DOWN'
			})

			GUI.Time = GetGameTimer()

		end

	end
end)