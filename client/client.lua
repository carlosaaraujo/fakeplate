ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

local LastVehicle = nil
local LicensePlate = {}
local IsAnimated = false

LicensePlate.Index = false
LicensePlate.Number = false

RegisterNetEvent('fakeplate:newPlate')
AddEventHandler('fakeplate:newPlate', function()
	if not LicensePlate.Index and not LicensePlate.Number then

		local PlayerPed = PlayerPedId()
		local Coords = GetEntityCoords(PlayerPed)
		local Vehicle = ESX.Game.GetClosestVehicle(Coords)

		local VehicleCoords	= GetEntityCoords(Vehicle)
		local Distance = Vdist(VehicleCoords.x, VehicleCoords.y, VehicleCoords.z, Coords.x, Coords.y, Coords.z)
		local generatedPlate = GeneratePlate()

		if Distance <= 4 and not IsPedInAnyVehicle(PlayerPed, false) then

			LastVehicle = Vehicle

			TriggerEvent("fakeplate:animPlate")
				TriggerEvent("hy_loading:startLoading", (12 * 1000))
					Citizen.Wait((12 * 1000))

					LicensePlate.Index = GetVehicleNumberPlateTextIndex(Vehicle)
					LicensePlate.Number = GetVehicleNumberPlateText(Vehicle)

					SetVehicleNumberPlateText(Vehicle, generatedPlate)
					TriggerServerEvent("fakeplate:useFake")
					
					TriggerServerEvent('fakeplate:dclog', "🚗 Placa original: " ..LicensePlate.Number.. "\n🚗 Placa gerada: " ..generatedPlate)
				else
				TriggerEvent('esx:showNotification', '~r~ Nenhum veículo por perto.')
			end
		else
		TriggerEvent('esx:showNotification', '~r~ Você já modificou a placa de um veículo.')
	end
end)

RegisterNetEvent('fakeplate:oldPlate')
AddEventHandler('fakeplate:oldPlate', function()
	if LicensePlate.Index and LicensePlate.Number then

		local PlayerPed = PlayerPedId()
		local Coords = GetEntityCoords(PlayerPed)
		local Vehicle = ESX.Game.GetClosestVehicle(Coords)

		local VehicleCoords	= GetEntityCoords(Vehicle)
		local Distance = Vdist(VehicleCoords.x, VehicleCoords.y, VehicleCoords.z, Coords.x, Coords.y, Coords.z)

		if ((Distance <= 4) and not IsPedInAnyVehicle(PlayerPed, false)) then

			if (Vehicle == LastVehicle) then

				LastVehicle = nil

				TriggerEvent("fakeplate:animPlate")
				TriggerEvent("hy_loading:startLoading", (12 * 1000))
				Citizen.Wait((12 * 1000))
			
				SetVehicleNumberPlateTextIndex(Vehicle, LicensePlate.Index)
				SetVehicleNumberPlateText(Vehicle, LicensePlate.Number)
				TriggerServerEvent('fakeplate:dclog', "🚗 Reverteu a placa: " ..LicensePlate.Number)
				LicensePlate.Index = false
				LicensePlate.Number = false

				TriggerServerEvent("fakeplate:useOld")
				else				
				TriggerEvent('esx:showNotification', '~r~ Essa placa não pertence a esse veículo.')
			end
			else
			TriggerEvent('esx:showNotification', '~r~ Nenhum veículo por perto.')
		end
		else
		TriggerEvent('esx:showNotification', '~r~ A placa é incompatível com o veículo.')
	end
end)

RegisterNetEvent('fakeplate:animPlate')
AddEventHandler('fakeplate:animPlate', function()
	if not IsAnimated then
		IsAnimated = true

		Citizen.CreateThread(function()
			local player = PlayerPedId()
			local anim_lib, anim_dict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer"
			local x,y,z = table.unpack(GetEntityCoords(player))
			local prop = CreateObject(GetHashKey("p_num_plate_01"), x, y, z + 0.2, true, true, true)
			local boneIndex = GetPedBoneIndex(player, 28422)

			AttachEntityToEntity(prop, player, boneIndex, -0.02, 0.0, -0.19, 80.0, 180.0, 0.0, true, true, false, true, 1, true)

			ESX.Streaming.RequestAnimDict(anim_lib, function()
			TaskPlayAnim(player, anim_lib, anim_dict, 8.0, -8.0, -1, 0, 0, false, false, false)

				Citizen.Wait((12 * 1000))

				IsAnimated = false
				DeleteObject(prop)
				ClearPedTasksImmediately(player)
			end)
		end)
	end
end)

