-- GET_VEHICLE_CLASS 
local vehicleClassWhitelist = {0, 1, 3, 4, 5, 6, 7}

local handleMods = {
	{"fInitialDragCoeff", 90.22},
	{"fDriveInertia", .31},
	{"fSteeringLock", 22},
	{"fTractionCurveMax", -1.1},
	{"fTractionCurveMin", -.4},
	{"fTractionCurveLateral", 2.5},
	{"fLowSpeedTractionLossMult", -.57}
}

local ped, vehicle
local driftMode = false

Citizen.CreateThread( function()
	while true do
		Wait(1)
		ped = GetPlayerPed(-1)

		if IsPedInAnyVehicle(ped) then
			local vehicle = GetVehiclePedIsIn(ped, false)
			if (GetPedInVehicleSeat(vehicle, -1) == ped) then			 
				if GetVehicleHandlingFloat(vehicle, "CHandlingData", "fDriveBiasFront") ~= 1 and IsVehicleOnAllWheels(vehicle) and IsControlJustReleased(0, 20) and IsVehicleClassWhitelisted(GetVehicleClass(vehicle)) then
					ToggleDrift(vehicle)
				end
				if GetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDragCoeff") < 90 then
					SetVehicleEnginePowerMultiplier(vehicle, 0.0)
				else
					if GetVehicleHandlingFloat(vehicle, "CHandlingData", "fDriveBiasFront") == 0.0 then
						SetVehicleEnginePowerMultiplier(vehicle, 190.0)
					else
						SetVehicleEnginePowerMultiplier(vehicle, 100.0)
					end
				end
			end
		end
	end
end)

function ToggleDrift(vehicle)
	local modifier = 1
	
	if GetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDragCoeff") > 90 then
		driftMode = true
	else 
		driftMode = false
	end
	
	if driftMode then
		modifier = -1
	end
	
	for index, value in ipairs(handleMods) do
		SetVehicleHandlingFloat(vehicle, "CHandlingData", value[1], GetVehicleHandlingFloat(vehicle, "CHandlingData", value[1]) + value[2] * modifier)
	end
	
	if driftMode then
		
		PrintDebugInfo("stock")
		DrawNotif("~b~TCS~s~, ~b~ABS~s~, ~b~ESP ~s~is ~g~on~s~!\nStandard Mode!")
	else
		
		PrintDebugInfo("drift")
		DrawNotif("~b~TCS~s~, ~b~ABS~s~, ~b~ESP ~s~is ~r~OFF~s~!\nDrift Mode!")
	end
	
end

function DrawNotif(text)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(text)
	DrawNotification(false, false)
end

function PrintDebugInfo(mode)
	ped = GetPlayerPed(-1)
	local vehicle = GetVehiclePedIsIn(ped, false)
	print(mode)
	for index, value in ipairs(handleMods) do
		print(GetVehicleHandlingFloat(vehicle, "CHandlingData", value[1]))
	end
end

function IsVehicleClassWhitelisted(vehicleClass)
	for index, value in ipairs(vehicleClassWhitelist) do
		if value == vehicleClass then
			return true
		end
	end

	return false
end

