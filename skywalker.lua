-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONEXÃO
-----------------------------------------------------------------------------------------------------------------------------------------
src = {}
Tunnel.bindInterface("emp_uber",src)
vCLIENT = Tunnel.getInterface("emp_uber")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS
-----------------------------------------------------------------------------------------------------------------------------------------
local pedidos = {}
local corridas = {}

function dist ( x1, y1, z1, x2, y2, z2 )
	local dx = x1 - x2
	local dy = y1 - y2
	local dz = z1 - z2
	return math.sqrt ( dx * dx + dy * dy + dz*dz )
end

function tablelength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end

local function getIndex(tab, val)
    local index = nil
    for i, v in ipairs (tab) do 
        if (v.id == val) then
          index = i 
        end
    end
    return index
end

function src.cancelRace()
	local source = source
    local user_id = vRP.getUserId(source) 
	for k,v in pairs(corridas) do
		if v.driver == user_id then
			local passenger = vRP.getUserSource(v.passenger)
			TriggerClientEvent("end", passenger)
			table.remove(corridas, k)
			break
		end
	end
end

function src.checkRide()
	local source = source
    local user_id = vRP.getUserId(source) 
	for k,v in pairs(corridas) do
		if v.driver == user_id then
			return true
		end
	end
	return false
end

function src.checkUber(id)
	local source = source
	local bool = false
	for k,v in pairs(pedidos) do
		if v.id == id then
			table.remove(pedidos, k)
			bool = true
			TriggerClientEvent("setRace", source, v.x, v.y, v.z)
			TriggerClientEvent("Notify",source,"sucesso","Vá até a localização do passageiro marcada no mapa.")
			local passenger = vRP.getUserSource(id)
			local driverId = vRP.getUserId(source)
			TriggerClientEvent("Notify",passenger,"sucesso","Um Uber aceitou sua solicitação, fique próximo de onde está.")
			table.insert(corridas, {driver = driverId, passenger = id})
		end
	end
	if not bool then
		TriggerClientEvent("Notify",source,"negado","Solicitação já aceita por algum Uber.")
	end
end

function src.startRace()
	local source = source
    local user_id = vRP.getUserId(source) 
	for k,v in pairs(corridas) do
		if v.driver == user_id then
			local passenger = vRP.getUserSource(v.passenger)
			TriggerClientEvent("start", passenger)
			table.remove(corridas, k)
			break
		end
	end
end

function src.removeRace()
	local source = source
    local user_id = vRP.getUserId(source)
	for k,v in pairs(pedidos) do 
		if v.id == user_id then
			table.remove(pedidos, k)
			break
		end
	end
	for k,v in pairs(corridas) do 
		if v.passenger == user_id then
			local driver = vRP.getUserSource(v.driver)
			TriggerClientEvent("cancelRace", driver)
			table.remove(corridas, k)
			break
		end
	end
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(Config.time*1000)
		if tablelength(pedidos) > 0 then
			for k,v in pairs(pedidos) do
				TriggerClientEvent('popUp',-1, v.id)
				break
			end
		end
	end
end)

RegisterServerEvent("SetUber") 
AddEventHandler("SetUber",function(x, y, z, time)
	local source = source
    local user_id = vRP.getUserId(source)
	table.insert(pedidos,{ id = user_id, x = x, y = y, z = z, time = os.time() })
	TriggerClientEvent('popUp',-1, user_id)
end)

AddEventHandler("vRP:playerLeave", function(user_id, group, gtype)

	for k,v in pairs(pedidos) do 
		if v.id == user_id then
			table.remove(pedidos, k)
			break
		end
	end
	for k,v in pairs(corridas) do 
		if user_id == v.passenger then
			local driver = vRP.getUserSource(v.driver)
			TriggerClientEvent("cancelRace", driver)
			table.remove(corridas, k)
			break
		elseif user_id == v.driver then
			local passenger = vRP.getUserSource(v.passenger)
			TriggerClientEvent("end", passenger)
			table.remove(corridas, k)
			break
		end
	end
end)
