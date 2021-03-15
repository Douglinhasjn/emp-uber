-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONEXÃO
-----------------------------------------------------------------------------------------------------------------------------------------
src = {}
Tunnel.bindInterface("emp_uber",src)
vSERVER = Tunnel.getInterface("emp_uber")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIÁVEIS
-----------------------------------------------------------------------------------------------------------------------------------------
local pedidoAtivo = false
local emCorrida = false
local emServico = false
local emRota = false
local popUp = false
local diff = false
local currentId = 0
local state = 0
local px, py, pz = 0,0,0
local mx,my,mz = 0,0,0
local open = false
local blips = 1

Citizen.CreateThread(function()
	while true do
		local idle = 1000
		local playerped = PlayerPedId()		
		if IsPedInAnyVehicle(playerped) then
			local veh = GetVehiclePedIsUsing(playerped)
			if GetPedInVehicleSeat(veh,-1) == playerped and emServico then
				idle = 5
				if IsControlJustPressed(0,Config.console) then
					if not open then
						SendNUIMessage({ action = "showMenu", state = state })
					else
						SendNUIMessage({ action = "hideMenu" })
					end
					open = not open
				end

				if IsControlJustPressed(0,Config.done) then

					if emCorrida then
						if emRota then 
							emCorrida = false
							state = 0
							SendNUIMessage({ action = "showMenu", state = state })
							TriggerEvent("Notify","sucesso","Você finalizou a corrida do passageiro.")
							open = true
							emRota = false
						else
							vSERVER.cancelRace()
							emCorrida = false
							state = 0
							SendNUIMessage({ action = "showMenu", state = state })
							open = true
							TriggerEvent("Notify","negado","Você cancelou a corrida do passageiro.")
							RemoveBlip(blips)
						end
					else

					end
				end
			end
		else
			if emServico and not emCorrida and not emRota then
				TriggerEvent("Notify","negado","Você saiu do veículo e está fora de servico.")
				emServico = false
				SendNUIMessage({ action = "hideMenu" })
				open = false
			end
		end
		if not emServico then
			SendNUIMessage({ action = "hideMenu" })
		end
		Citizen.Wait(idle)
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(2000)
		local ped = PlayerPedId()
		local x,y,z = table.unpack(GetEntityCoords(ped))
		local distance = Vdist(x,y,z,px,py,pz)
		if distance < 15.0 then
			if emCorrida then
				RemoveBlip(blips)
				TriggerEvent("Notify","importante","Você chegou até a localização do passageiro, leve-o ao seu destino.",5000)
				px,py,pz = 0,0,0
				vSERVER.startRace()
				emRota = true
			end
		end
		--
		if pedidoAtivo then
			local distance = Vdist(x,y,z,mx,my,mz)
			if distance > Config.dist then
				pedidoAtivo = false
				vSERVER.removeRace()
				TriggerEvent("Notify","negado","Você saiu da sua localização e o pedido de Uber foi cancelado.",5000)
			end
		end
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- STARTFOCUS
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	SetNuiFocus(false,false)
end)

RegisterNetEvent("start") 
AddEventHandler("start",function()
	pedidoAtivo = false
	TriggerEvent("Notify","sucesso","O Uber chegou à sua localização.")
end)

RegisterNetEvent("end") 
AddEventHandler("end",function()
	pedidoAtivo = false
	TriggerEvent("Notify","negado","O Uber cancelou sua corrida, tente chamar novamente.")
end)

RegisterNetEvent("setRace") 
AddEventHandler("setRace",function(x, y, z)
	blips = AddBlipForCoord(x,y,z)
	SetBlipSprite(blips,1)
	SetBlipColour(blips,5)
	SetBlipScale(blips,0.4)
	SetBlipAsShortRange(blips,false)
	SetBlipRoute(blips,true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Passageiro")
	EndTextCommandSetBlipName(blips)
	emCorrida = true
	state = 2
	px,py,pz = x,y,z
end)

RegisterNetEvent("cancelRace") 
AddEventHandler("cancelRace",function()
	state = 0
	SendNUIMessage({ action = "showMenu", state = state })
	open = true
	TriggerEvent("Notify","negado","O passageiro cancelou a corrida.",5000)
	emCorrida = false
	RemoveBlip(blips)
end)

RegisterNetEvent("popUp")
AddEventHandler("popUp",function(id)
	currentId = id
	if not popUp then
		if emServico then
			if not emCorrida then
				popUp = true
				Wait(500)
				TriggerEvent("vrp_sound:source",'uber',0.5)
				Wait(500)
				diff = true
				SendNUIMessage({ action = "showMenu", state = 1 })
				open = true
				SetTimeout(5000,function()
					SendNUIMessage({ action = "showMenu", state = state })
					open = true
					popUp = false
					diff = false
				end)
			end
		end
	end
end)

Citizen.CreateThread(function() 
	while true do
		local idle = 1000
		if popUp then
			idle = 5
			if IsControlJustPressed(0,Config.accept) then
				if diff then
					popUp = false
					if not emCorrida then
						vSERVER.checkUber(currentId)
					else
						TriggerEvent("Notify", "negado", "Você já aceitou uma corrida")
					end
					SendNUIMessage({ action = "showMenu", state = state })
					open = true
				end
			end
		end
		Citizen.Wait(idle)		
	end
end)

RegisterCommand('uber',function(source,args)

	if not args[1] then
		if not emServico then
			if not pedidoAtivo then
				local ped = PlayerPedId()
				local x,y,z = table.unpack(GetEntityCoords(ped))
				mx,my,mz = x,y,z
				TriggerServerEvent("SetUber", x, y, z)
				pedidoAtivo = true
				TriggerEvent("Notify","sucesso","Você chamou um Uber, aguarde...",5000)
			else
				TriggerEvent("Notify","negado","Você ja tem um pedido ativo",5000)
			end
		else
			TriggerEvent("Notify","negado","Você não pode chamar uber em servico",5000)
		end
	else
		if args[1] == "on" then
			local playerped = PlayerPedId()		
			if IsPedInAnyVehicle(playerped) then
				local veh = GetVehiclePedIsUsing(playerped)
				if GetPedInVehicleSeat(veh,-1) == playerped then
					emServico = true
					TriggerEvent("Notify","sucesso","Entrou em servico de Uber",5000)
					SendNUIMessage({ action = "showMenu", state = state })
					open = true
				end
			else
				TriggerEvent("Notify","negado","Voce precisa estar em um veiculo",5000)
			end
		elseif args[1] == "off" then
			emServico = false
			TriggerEvent("Notify","sucesso","Saiu do servico de Uber",5000)
			SendNUIMessage({ action = "hideMenu" })
			open = false
		else
			TriggerEvent("Notify","negado","Comando inválido")
		end
	end
end)