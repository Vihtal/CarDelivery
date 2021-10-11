ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
ESX.RegisterServerCallback('delivery:getVehicles', function (source, cb)
	local c = ESX.GetPlayerFromId(source)
    if not c then
        return
    end;
    MySQL.Async.fetchAll('SELECT plate, vehicle, "stored" FROM owned_vehicles WHERE owner = @id and type = @type', {["@id"] = c.identifier , ["@type"] = "car"}, function (result)
		--for i=1, #result, 1 do
		--	table.insert(vehicles, {
		--		name  = result[i].stored,
		--		plate = result[i].plate,
       --         props = json.decode(g["vehicle"])
		--	})
			local vehicles = {} 
			for f, g in ipairs(result) do
				table.insert(vehicles, {["garage"] = g["stored"], ["plate"] = g["plate"], ["props"] = json.decode(g["vehicle"])})
			end;
		
			

		cb(vehicles)
	end)
end)

RegisterServerEvent('delivery:finish')
AddEventHandler('delivery:finish', function(plate)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	xPlayer.removeAccountMoney('bank', Config.Price)
end)

RegisterServerEvent("delivery:valet-car-set-outside")
AddEventHandler("delivery:valet-car-set-outside", function(a)
    local b = source;
    local c = ESX.GetPlayerFromId(b)
    if c then
        MySQL.Async.insert("UPDATE owned_vehicles SET stored = @stored WHERE plate = @plate", {["@plate"] = a, ["@stored"] = 0})
    end
end)

RegisterServerEvent('delivery:checkMoney')
AddEventHandler('delivery:checkMoney', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	if xPlayer == nil then
		return
	end	
	moneys = xPlayer.getAccount('bank').money
	TriggerClientEvent("checkMoney2", source, moneys)
end)


