local PlayersHarvesting = {}
local PlayersReselling  = {}

RegisterServerEvent('esx_fishermanjob:requestPlayerData')
AddEventHandler('esx_fishermanjob:requestPlayerData', function(reason)
	TriggerEvent('esx:getPlayerFromId', source, function(xPlayer)
		TriggerEvent('esx_skin:requestPlayerSkinInfosCb', source, function(skin, jobSkin)

			local data = {
				job       = xPlayer.job,
				inventory = xPlayer.inventory,
				skin      = skin
			}

			TriggerClientEvent('esx_fishermanjob:responsePlayerData', source, data, reason)
		end)
	end)
end)

local function HarvestFish(source)

	SetTimeout(2000, function()

		if PlayersHarvesting[source] == true then

			TriggerEvent('esx:getPlayerFromId', source, function(xPlayer)

				local fishQuantity = xPlayer:getInventoryItem('fish').count

				if fishQuantity >= 100 then
					TriggerClientEvent('esx:showNotification', source, 'Vous ne pouvez plus ramasser de poisson, votre inventaire est plein')
				else
					xPlayer:addInventoryItem('fish', 1)
					HarvestFish(source)
				end

			end)

		end
	end)
end

RegisterServerEvent('esx_fishermanjob:startHarvestFish')
AddEventHandler('esx_fishermanjob:startHarvestFish', function()
	PlayersHarvesting[source] = true
	TriggerClientEvent('esx:showNotification', source, 'Pêche en cours...')
	HarvestFish(source)
end)

RegisterServerEvent('esx_fishermanjob:stopHarvestFish')
AddEventHandler('esx_fishermanjob:stopHarvestFish', function()
	PlayersHarvesting[source] = false
end)

local function Resell(source)

	SetTimeout(500, function()

		if PlayersReselling[source] == true then

			TriggerEvent('esx:getPlayerFromId', source, function(xPlayer)

				local fishQuantity = xPlayer:getInventoryItem('fish').count

				if fishQuantity <= 0 then
					TriggerClientEvent('esx:showNotification', source, 'Vous n\'avez plus de poisson à vendre')
				else
					
					xPlayer:removeInventoryItem('fish', 1)
					xPlayer:addMoney(3)

					Resell(source)
				end

			end)

		end
	end)
end

RegisterServerEvent('esx_fishermanjob:startResell')
AddEventHandler('esx_fishermanjob:startResell', function()
	PlayersReselling[source] = true
	TriggerClientEvent('esx:showNotification', source, 'Vente en cours...')
	Resell(source)
end)

RegisterServerEvent('esx_fishermanjob:stopResell')
AddEventHandler('esx_fishermanjob:stopResell', function()
	PlayersReselling[source] = false
end)