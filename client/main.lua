local CurrentActionData, this_Spawner = {}, {}
local HasAlreadyEnteredMarker, IsInMainMenu = false, false
local LastZone, CurrentAction, CurrentActionMsg
ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

Citizen.CreateThread(function()
while true do
	Citizen.Wait(100)
	TriggerServerEvent("delivery:checkMoney")
end
end)

RegisterNetEvent("checkMoney2")
AddEventHandler("checkMoney2", function(moneys) 

moneyamount = moneys

end)


-- Resource Stop
AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		if IsInMainMenu then
			ESX.UI.Menu.CloseAll()
		end
	end
end)

RegisterCommand("delivery", function()

	OpenSpawnerMenu()

end, false)

Citizen.CreateThread(function()
while true do
Citizen.Wait(0)

if IsControlJustPressed(0--[[control type]],  322--[[control index]]) then
	ESX.UI.Menu.CloseAll()
end



end
end)

------------------------------------------------------------------------------------------------------

local enroute = false
local mechPed = nil
local playerPos = GetEntityCoords(GetPlayerPed(-1))

-- Vehicle Spawn Menu
function OpenSpawnerMenu()
	ESX.TriggerServerCallback('delivery:getVehicles', function (vehicles)
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_spawner', {
		title = 'Vehicle Spawner',
		align = GetConvar('esx_MenuAlign', 'top-left'),
		elements = {
			{label = ('Vehicle Spawner'), value = 'veh_menu'}
	}}, function(data, menu)
		local action = data.current.value

		if action == 'veh_menu' then
			local elements2 = {}

			for i=1, #vehicles, 1 do
				
				table.insert(elements2, {
					label = (('%s [<span style="color:green;">%s</span>]'):format(GetDisplayNameFromVehicleModel(vehicles[i].props.model), (vehicles[i].plate))),
					value = "get_car",
					model = vehicles[i].props.model,
					plate = vehicles[i].plate,
					props = vehicles[i].props,
				})

			end

			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'veh_menu', {
				title = 'Available Cars',
				align = GetConvar('esx_MenuAlign', 'top-left'),
				elements = elements2
			}, function(data, menu)

				ESX.UI.Menu.CloseAll()
				if moneyamount >= Config.Price then 
				if enroute then
					ESX.ShowNotification(('You Have to wait before doing that!'))
					return
				end
			
				local gameVehicles = ESX.Game.GetVehicles()
			
				for i = 1, #gameVehicles do
					local vehicle = gameVehicles[i]

					if DoesEntityExist(vehicle) then
						if ESX.Math.Trim(GetVehicleNumberPlateText(vehicle)) == ESX.Math.Trim(data.current.plate) then
							local vehicleCoords = GetEntityCoords(vehicle)
						--	SetNewWaypoint(vehicleCoords.x, vehicleCoords.y)
							ESX.ShowNotification(('That vehicle is already outside'))
							return
						end
					end
				end
			
				TriggerServerEvent("delivery:valet-car-set-outside", data.current.plate)
				
				local player = PlayerPedId()
				local playerPos = GetEntityCoords(player)
			
				local driverhash = 999748158
				
			
				while not HasModelLoaded(driverhash) and RequestModel(driverhash) or not HasModelLoaded(data.current.model) and RequestModel(data.current.model) do
					RequestModel(driverhash)
					RequestModel(data.current.model)
					Citizen.Wait(0)
				end
			
				local found, spawnPos, spawnHeading = GetClosestVehicleNodeWithHeading(playerPos.x + math.random(-100, 100), playerPos.y + math.random(-100, 100), playerPos.z, 0, 3, 0)

				
				ESX.Game.SpawnVehicle(data.current.model, spawnPos, spawnHeading, function(callback_vehicle)
					local mechPos = GetEntityCoords(callback_vehicle)
					SetVehicleHasBeenOwnedByPlayer(callback_vehicle, true)
        
  				      SetEntityAsMissionEntity(callback_vehicle, true, true)
     				  ClearAreaOfVehicles(GetEntityCoords(callback_vehicle), 5000, false, false, false, false, false);  
  				      SetVehicleOnGroundProperly(callback_vehicle)
      				  ESX.Game.SetVehicleProperties(callback_vehicle, data.current.props)			
					if Config.DriveToPlayer == true then
						mechPed = CreatePedInsideVehicle(callback_vehicle, 26, driverhash, -1, true, false)           	
					end
										 mechBlip = AddBlipForEntity(callback_vehicle)                                                        
										 SetBlipFlashes(mechBlip, true)  
										 SetBlipColour(mechBlip, 5)
										 GoToTarget(playerPos.x, playerPos.y, playerPos.z, callback_vehicle, mechPed, GetPlayerPed(-1))
					  
				
				end)
				else 
					ESX.ShowNotification("Not Enough Money")
				end
			end)
		end
	end, function(data, menu)
		menu.close()

	end)
end)
end

function GoToTarget(x, y, z, vehicle, driver, vehhash, target)
    enroute = true
    while enroute do
        Citizen.Wait(500)
        local player = PlayerPedId()
        local playerPos = GetEntityCoords(player)
		if Config.DriveToPlayer == true then
        SetDriverAbility(driver, 1.0)        -- values between 0.0 and 1.0 are allowed.
        SetDriverAggressiveness(driver, 0.0)
        TaskVehicleDriveToCoord(driver, vehicle, playerPos.x, playerPos.y, playerPos.z, 20.0, 0, vehhash, 4457279, 1, true)
		end
        local distanceToTarget = #(playerPos - GetEntityCoords(vehicle))
        if distanceToTarget < 15 or distanceToTarget > 150 then
            RemoveBlip(mechBlip)
			if Config.DriveToPlayer == true then
            TaskVehicleTempAction(driver, vehicle, 27, 6000)
            SetVehicleUndriveable(vehicle, true)
			end
            SetEntityHealth(mechPed, 2000)
            GoToTargetWalking(x, y, z, vehicle, driver)
            enroute = false
        end
    end
end

function GoToTargetWalking(x, y, z, vehicle, driver)
    Citizen.Wait(500)
	if Config.DriveToPlayer == true then
    TaskWanderStandard(driver, 10.0, 10)
	SetVehicleUndriveable(vehicle, false)
	end
    TriggerServerEvent('delivery:finish')
    Citizen.Wait(35000)
	if Config.DriveToPlayer == true then
	DeletePed(mechPed)
	end
    mechPed = nil
end 