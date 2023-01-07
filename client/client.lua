local QBCore = exports['qb-core']:GetCoreObject()

local PlayerData = QBCore.Functions.GetPlayerData()
local occupied = {}
local PlayerData = {}
local CanSit = false
local working = false
PlayerJob = {}

----------------
----Handlers
----------------
RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
	QBCore.Functions.GetPlayerData(function(PlayerData)
		PlayerJob = PlayerData.job
	end)
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
end)

AddEventHandler('onClientResourceStart',function(resource)
	if GetCurrentResourceName() == resource then
		Citizen.CreateThread(function()
			while true do
				QBCore.Functions.GetPlayerData(function(PlayerData)
					if PlayerData.job then
						PlayerJob = PlayerData.job
						QBCore.Functions.TriggerCallback('CL-BeanMachine:CheckDuty', function(result)
							if result then
								TriggerServerEvent("CL-BeanMachine:ResetDuty")
							end
						end)
					end
				end)
				break
			end
			Citizen.Wait(1)
		end)
	end
end)

----------------
----Blips
----------------
Citizen.CreateThread(function()
	for _, info in pairs(Config.BlipLocation) do
		if Config.UseBlips then
			info.blip = AddBlipForCoord(info.x, info.y, info.z)
			SetBlipSprite(info.blip, info.id)
			SetBlipDisplay(info.blip, 4)
			SetBlipScale(info.blip, 0.6)	
			SetBlipColour(info.blip, info.colour)
			SetBlipAsShortRange(info.blip, true)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(info.title)
			EndTextCommandSetBlipName(info.blip)
		end
	end	
end)

----------------
----Garage Marker
----------------
CreateThread(function()
    while true do
        local plyPed = PlayerPedId()
        local plyCoords = GetEntityCoords(plyPed)
        local letSleep = true        

        if PlayerJob.name == Config.Job then
            if (GetDistanceBetweenCoords(plyCoords.x, plyCoords.y, plyCoords.z, 130.01286, -1034.836, 29.433467, true) < Config.MarkerDistance) then
                letSleep = false
                DrawMarker(36, 130.01286, -1034.836, 29.433467 + 0.2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.7, 0.7, 0.5, 0.5, 120, 119, 42, 255, true, false, false, true, false, false, false)
                 if (GetDistanceBetweenCoords(plyCoords.x, plyCoords.y, plyCoords.z, 130.01286, -1034.836, 29.433467, true) < 1.5) then
                    DrawText3D(130.01286, -1034.836, 29.433467, "~g~E~w~ - Bean Machine Garage") 
                    if IsControlJustReleased(0, 38) then
                        TriggerEvent("CL-BeanMachine:Garage:Menu")
                    end
                end  
            end
        end

        if letSleep then
            Wait(2000)
        end

        Wait(1)
    end
end)

----------------
----Target
----------------
Citizen.CreateThread(function()
	exports[Config.Target]:AddBoxZone("Duty", vector3(126.99156, -1035.663, 29.569875), 0.3, 1.2, {
		name = "Duty",
		heading = 248.91331,
		debugPoly = Config.PolyZone,
		minZ = 28.569875,
		maxZ = 30.569875,
	}, {
		options = { 
			{
				type = "client",
				event = "CL-BeanMachine:DutyMenu",
				icon = Config.Locals["DutyTarget"]["Icon"],
				label = Config.Locals["DutyTarget"]["Label"],
				canInteract = function()
					if PlayerJob.name == Config.Job then
						return true
					else
						return false
					end
				end,
			},
			{
				type = "client",
				event = "qb-clothing:client:openMenu",
				icon = Config.Locals["ClothingTarget"]["Icon"],
				label = Config.Locals["ClothingTarget"]["Label"],
				canInteract = function()
					if Config.UseClothing == true and PlayerJob.name == Config.Job then
						return true
					else
						return false
					end
				end,
			}
		},
		distance = 1.1,
	})

	for k, v in pairs(Config.Chairs) do
		exports[Config.Target]:AddBoxZone("Chair"..k, vector3(v.coords.x, v.coords.y, v.coords.z), v.poly1, v.poly2, {
			name = "Chair"..k,
			heading = v.heading,
			debugPoly = Config.PolyZone,
			minZ = v.minZ,
			maxZ = v.maxZ,
			}, {
				options = { 
				{
					type = "client",
					event = "CL-BeanMachine:Sit",
					icon = Config.Locals['SitTarget']['Icon'],
					label = Config.Locals['SitTarget']['Label'],
					pos = v.coords,
					heading = v.heading
				}
			},
			distance = 1.2,
		})
	end

	exports[Config.Target]:AddBoxZone("Toasts", vector3(121.52722, -1038.46, 29.868322), 0.5, 1.4, {
		name = "Toasts",
		heading = 70.007614,
		debugPoly = Config.PolyZone,
		minZ = 28.274829,
		maxZ = 30.274829,
		}, {
			options = { 
			{
				type = "client",
				event = "CL-BeanMachine:ToastsMenu",
				icon = Config.Locals['ToastsTarget']['Icon'],
				label = Config.Locals['ToastsTarget']['Label'],
				canInteract = function()
					if PlayerJob.name == Config.Job then
						return true
					else
						return false
					end
				end,
			}
		},
		distance = 1.2,
	})

	exports[Config.Target]:AddBoxZone("Tray1", vector3(121.84783, -1037.075, 29.967689), 0.3, 0.5, {
		name = "Tray1",
		heading = 250.27737,
		debugPoly = Config.PolyZone,
		minZ = 28.967689,
		maxZ = 30.967689,
		}, {
			options = { 
			{
				type = "client",
				event = "CL-BeanMachine:OpenTray1",
				icon = Config.Locals['TrayTarget']['Icon'],
				label = Config.Locals['TrayTarget']['Label'],
			}
		},
		distance = 1.2,
	})

	exports[Config.Target]:AddBoxZone("Tray2", vector3(120.52185, -1040.673, 29.967689), 0.3, 0.5, {
		name = "Tray2",
		heading = 250.27737,
		debugPoly = Config.PolyZone,
		minZ = 28.967689,
		maxZ = 30.967689,
		}, {
			options = { 
			{
				type = "client",
				event = "CL-BeanMachine:OpenTray2",
				icon = Config.Locals['TrayTarget']['Icon'],
				label = Config.Locals['TrayTarget']['Label'],
			}
		},
		distance = 1.2,
	})

	exports[Config.Target]:AddBoxZone("Fruits", vector3(119.99523, -1043.654, 29.277912), 0.4, 0.4, {
		name = "Fruits",
		heading = 136.63201,
		debugPoly = Config.PolyZone,
		minZ = 28.277912,
		maxZ = 30.277912,
		}, {
			options = { 
			{
				type = "client",
				event = "CL-BeanMachine:FruitsMenu",
				icon = Config.Locals['FruitsTarget']['Icon'],
				label = Config.Locals['FruitsTarget']['Label'],
			}
		},
		distance = 1.2,
	})

	exports[Config.Target]:AddBoxZone("Oranges", vector3(119.18809, -1034.112, 29.606691), 0.4, 0.4, {
		name = "Oranges",
		heading = 70.05281,
		debugPoly = Config.PolyZone,
		minZ = 28.606691,
		maxZ = 30.606691,
		}, {
			options = { 
			{
				type = "client",
				event = "CL-BeanMachine:FruitsMenu2",
				icon = Config.Locals['FruitsTarget']['Icon'],
				label = Config.Locals['FruitsTarget']['Label'],
			}
		},
		distance = 1.2,
	})

	exports[Config.Target]:AddBoxZone("Muffins", vector3(122.76106, -1044.733, 29.598379), 0.5, 0.5, {
		name = "Muffins",
		heading = 161.81346,
		debugPoly = Config.PolyZone,
		minZ = 28.598379,
		maxZ = 30.598379,
		}, {
			options = { 
			{
				type = "client",
				event = "CL-BeanMachine:MuffinsMenu",
				icon = Config.Locals['MuffinsTarget']['Icon'],
				label = Config.Locals['MuffinsTarget']['Label'],
				canInteract = function()
					if PlayerJob.name == Config.Job then
						return true
					else
						return false
					end
				end,
			}
		},
		distance = 1.5,
	})

	exports[Config.Target]:AddBoxZone("Stash", vector3(121.75633, -1038.512, 28.200302), 0.5, 3.3, {
		name = "Stash",
		heading = 70.007614,
		debugPoly = Config.PolyZone,
		minZ = 27.127885,
		maxZ = 29.127885,
		}, {
			options = { 
			{
				type = "client",
				event = "CL-BeanMachine:OpenWorkersStash",
				icon = Config.Locals['StashTarget']['Icon'],
				label = Config.Locals['StashTarget']['Label'],
				canInteract = function()
					if PlayerJob.name == Config.Job then
						return true
					else
						return false
					end
				end,
			}
		},
		distance = 1.2,
	})

	exports[Config.Target]:AddBoxZone("Shop", vector3(120.53882, -1041.839, 28.596639), 0.5, 3.3, {
		name = "Shop",
		heading = 70.007614,
		debugPoly = Config.PolyZone,
		minZ = 27.127885,
		maxZ = 29.127885,
		}, {
			options = { 
			{
				type = "client",
				event = "CL-BeanMachine:OpenShop",
				icon = Config.Locals['ShopTarget']['Icon'],
				label = Config.Locals['ShopTarget']['Label'],
				canInteract = function()
					if PlayerJob.name == Config.Job then
						return true
					else
						return false
					end
				end,
			}
		},
		distance = 1.2,
	})

	exports[Config.Target]:AddBoxZone("Washbasin", vector3(123.72518, -1039.217, 29.277908), 0.5, 1.0, {
		name = "Washbasin",
		heading = 249.26232,
		debugPoly = Config.PolyZone,
		minZ = 28.96301,
		maxZ = 30.96301,
		}, {
			options = { 
			{
				type = "client",
				event = "CL-BeanMachine:WashHands",
				icon = Config.Locals['WashHandsTarget']['Icon'],
				label = Config.Locals['WashHandsTarget']['Label'],
				canInteract = function()
					if PlayerJob.name == Config.Job then
						return true
					else
						return false
					end
				end,
			},
		},
		distance = 1.2,
	})

	for k, v in pairs(Config.CupsLocations) do
		exports[Config.Target]:AddBoxZone("CupLocation"..k, vector3(v.coords.x, v.coords.y, v.coords.z), 0.3, 0.3, {
			name = "CupLocation"..k,
			heading = v.heading,
			debugPoly = Config.PolyZone,
			minZ = v.minZ,
			maxZ = v.maxZ,
			}, {
				options = { 
				{
					type = "client",
					event = "CL-BeanMachine:CupMenu",
					icon = Config.Locals['CupTarget']['Icon'],
					label = Config.Locals['CupTarget']['Label'],
					canInteract = function()
						if PlayerJob.name == Config.Job then
							return true
						else
							return false
						end
					end,
				}
			},
			distance = 1.2,
		})
	end

	exports[Config.Target]:AddBoxZone("Drinks", vector3(123.5383, -1042.678, 29.466598), 0.5, 1.4, {
		name = "Drinks",
		heading = 339.35379,
		debugPoly = Config.PolyZone,
		minZ = 28.466598,
		maxZ = 30.466598,
		}, {
			options = { 
			{
				type = "client", 
				event = "CL-BeanMachine:DrinksMenu",
				icon = Config.Locals['DrinksTarget']['Icon'],
				label = Config.Locals['DrinksTarget']['Label'],
				canInteract = function()
					if PlayerJob.name == Config.Job then
						return true
					else
						return false
					end
				end,
			}
		},
		distance = 1.2,
	})

	exports[Config.Target]:AddBoxZone("Slush", vector3(126.05076, -1036.595, 29.085569), 0.4, 0.5, {
		name = "Slush",
		heading = 342.10079,
		debugPoly = Config.PolyZone,
		minZ = 28.085569,
		maxZ = 30.085569,
		}, {
			options = { 
			{
				type = "client", 
				event = "CL-BeanMachine:SlushsMenu",
				icon = Config.Locals['SlushsTarget']['Icon'],
				label = Config.Locals['SlushsTarget']['Label'],
				canInteract = function()
					if PlayerJob.name == Config.Job then
						return true
					else
						return false
					end
				end,
			}
		},
		distance = 1.0,
	})

	for k, v in pairs(Config.CoffeeLocations) do
		exports[Config.Target]:AddBoxZone("CoffeeLocation"..k, vector3(v.coords.x, v.coords.y, v.coords.z), 0.4, 0.7, {
			name = "CoffeeLocation"..k,
			heading = v.heading,
			debugPoly = Config.PolyZone,
			minZ = v.minZ,
			maxZ = v.maxZ,
			}, {
				options = { 
				{
					type = "client",
					event = "CL-BeanMachine:SeperatingEvent",
					icon = Config.Locals['CoffeeTarget']['Icon'],
					label = Config.Locals['CoffeeTarget']['Label'],
					firstmenu = v.firstmenu,
					secondmenu = v.secondmenu,
					canInteract = function()
						if PlayerJob.name == Config.Job then
							return true
						else
							return false
						end
					end,
				}
			},
			distance = 1.2,
		})
	end

	exports[Config.Target]:AddBoxZone("Beans", vector3(123.30837, -1040.704, 29.320747), 0.2, 0.8, {
		name = "Beans",
		heading = 249.3034,
		debugPoly = Config.PolyZone,
		minZ = 29.020747,
		maxZ = 29.920747,
		}, {
			options = { 
			{
				type = "client", 
				event = "CL-BeanMachine:BeansMenu",
				icon = Config.Locals['BeansTarget']['Icon'],
				label = Config.Locals['BeansTarget']['Label'],
				canInteract = function()
					if PlayerJob.name == Config.Job then
						return true
					else
						return false
					end
				end,
			}
		},
		distance = 1.0,
	})

	exports[Config.Target]:AddBoxZone("Beans2", vector3(124.29961, -1037.889, 29.320747), 0.2, 0.8, {
		name = "Beans2",
		heading = 249.3034,
		debugPoly = Config.PolyZone,
		minZ = 28.220747,
		maxZ = 30.020747,
		}, {
			options = { 
			{
				type = "client", 
				event = "CL-BeanMachine:BeansMenu",
				icon = Config.Locals['BeansTarget']['Icon'],
				label = Config.Locals['BeansTarget']['Label'],
				canInteract = function()
					if PlayerJob.name == Config.Job then
						return true
					else
						return false
					end
				end,
			}
		},
		distance = 1.0,
	})

	exports[Config.Target]:AddBoxZone("Glasses", vector3(123.37149, -1040.964, 29.997602), 0.4, 1.6, {
		name = "Glasses",
		heading = 249.3034,
		debugPoly = Config.PolyZone,
		minZ = 29.997602,
		maxZ = 30.597602,
		}, {
			options = { 
			{
				type = "client", 
				event = "CL-BeanMachine:GlassesMenu",
				icon = Config.Locals['GlassesTarget']['Icon'],
				label = Config.Locals['GlassesTarget']['Label'],
				canInteract = function()
					if PlayerJob.name == Config.Job then
						return true
					else
						return false
					end
				end,
			}
		},
		distance = 1.5,
	})
end)

----------------
----Events
----------------
RegisterNetEvent("CL-BeanMachine:OpenTray1", function()
	TriggerServerEvent("inventory:server:OpenInventory", "stash", "Bean Machine Tray", {maxweight = 30000, slots = 10})
	TriggerEvent("inventory:client:SetCurrentStash", "Bean Machine Tray") 
end)

RegisterNetEvent("CL-BeanMachine:OpenTray2", function()
	TriggerServerEvent("inventory:server:OpenInventory", "stash", "Bean Machine Tray 2", {maxweight = 30000, slots = 10})
	TriggerEvent("inventory:client:SetCurrentStash", "Bean Machine Tray 2") 
end)

RegisterNetEvent("CL-BeanMachine:OpenWorkersStash", function()
	QBCore.Functions.TriggerCallback('CL-BeanMachine:CheckDuty', function(result)
		if result then
			TriggerServerEvent("inventory:server:OpenInventory", "stash", "Bean Machine Stash", {maxweight = 100000, slots = 100})
			TriggerEvent("inventory:client:SetCurrentStash", "Bean Machine Stash") 
		else
			QBCore.Functions.Notify("You must be on duty.", "error")
		end
	end)
end)

RegisterNetEvent('CL-BeanMachine:OpenShop', function()
	QBCore.Functions.TriggerCallback('CL-BeanMachine:CheckDuty', function(result)
		if result then
			TriggerServerEvent("inventory:server:OpenInventory", "shop", "Main Shop", Config.ShopItems)
		else
			QBCore.Functions.Notify("You must be on duty.", "error")
		end
	end)
end)

RegisterNetEvent('CL-BeanMachine:WashHands', function()
	QBCore.Functions.TriggerCallback('CL-BeanMachine:CheckDuty', function(result)
		if result then
			QBCore.Functions.Progressbar("wash_hands", Config.Locals["WashingHandsProgressBar"]["Txt"], Config.Locals["WashingHandsProgressBar"]["Time"], false, true, {
				disableMovement = true,
				disableCarMovement = false,
				disableMouse = false,
				disableCombat = true,
			}, {
				animDict = "amb@world_human_bum_wash@male@low@base",
				anim = "base",
				flags = 49,
			}, {}, {}, function()
				TriggerServerEvent('hud:server:RelieveStress', Config.WashingHandsStress)
			end, function()
				QBCore.Functions.Notify("Canceled...", "error")
			end)
		else
			QBCore.Functions.Notify("You must be on duty.", "error")
		end
	end)
end)

RegisterNetEvent("CL-BeanMachine:Sit")
AddEventHandler("CL-BeanMachine:Sit", function(data)
	QBCore.Functions.TriggerCallback('CL-BeanMachine:GetPlace', function(occupied)
		if occupied then
			QBCore.Functions.Notify('Chair Is Being Used.', 'error')
		else
			local playerPos = GetEntityCoords(PlayerPedId())
			local playerPed = PlayerPedId()
			CanSit = true
		
			SetEntityHeading(data.heading)
		
			TriggerServerEvent('CL-BeanMachine:TakePlace', data.pos.x, data.pos.y, data.pos.z)
				
			TaskStartScenarioAtPosition(playerPed, "PROP_HUMAN_SEAT_CHAIR_MP_PLAYER", data.pos.x, data.pos.y, data.pos.z-0.20, data.heading, 0, true, true)
		
			Citizen.CreateThread(function()
				while true do
					if CanSit then
						ShowHelpNotification("Press ~INPUT_FRONTEND_RRIGHT~ To Get Up")
					elseif not CanSit then
						break
					end
					if IsControlJustReleased(0, 177) then
						CanSit = false
						ClearPedTasks(playerPed)
						TriggerServerEvent('CL-BeanMachine:LeavePlace', data.pos.x, data.pos.y, data.pos.z)
						TriggerServerEvent("CL-BeanMachine:CheckSit:Server:SetSitActive", false)
						PlaySoundFrontend(-1, "NO", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
						break
					end
					Citizen.Wait(1)
				end
			end)
		end
	end, data.pos.x, data.pos.y, data.pos.z)
end)

RegisterNetEvent("CL-BeanMachine:SpawnObject")
AddEventHandler("CL-BeanMachine:SpawnObject", function(prop, bone, boneindex1, boneindex2, boneindex3, boneindex4, boneindex5, boneindex6, time, slush, coffee)
	LoadModel(prop)
	local Object = CreateObject(GetHashKey(prop), GetEntityCoords(PlayerPedId()), true)
	local pedCoords = GetEntityCoords(PlayerPedId())
	local object = GetClosestObjectOfType(pedCoords, 10.0, GetHashKey(prop), false)
	local itemid = object
	AttachEntityToEntity(object, GetPlayerPed(PlayerId()),GetPedBoneIndex(GetPlayerPed(PlayerId()), bone),boneindex1, boneindex2, boneindex3, boneindex4, boneindex5, boneindex6,1,1,0,1,0,1)
	Wait(time)
	DetachEntity(object, true, true)
	DeleteObject(object)
	if slush then
		SlushEffect()
		QBCore.Functions.Notify("Your Head Hurts A Bit")
	elseif coffee then
		CoffeeEffect()
		QBCore.Functions.Notify("You Are Feeling More Awake")
	end
end)

RegisterNetEvent("CL-BeanMachine:SpawnVehicle")
AddEventHandler("CL-BeanMachine:SpawnVehicle", function(vehicle)
    local coords = vector4(129.97741, -1035.136, 29.433469, 342.09756)

    QBCore.Functions.SpawnVehicle(vehicle, function(veh)
        SetVehicleNumberPlateText(veh, "BEAN"..tostring(math.random(1000, 9999)))
        exports['LegacyFuel']:SetFuel(veh, 100.0)
        CloseMenu()
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
        SetVehicleEngineOn(veh, true, true)
    end, coords, true)
end)

RegisterNetEvent('CL-BeanMachine:StoreVehicle')
AddEventHandler('CL-BeanMachine:StoreVehicle', function()
    local ped = PlayerPedId()
    local car = GetVehiclePedIsIn(PlayerPedId(), true)

    if IsPedInAnyVehicle(ped, false) then
        TaskLeaveVehicle(ped, car, 1)
        Citizen.Wait(2000)
        QBCore.Functions.Notify('Vehicle Stored !', 'success')
        DeleteVehicle(car)
        DeleteEntity(car)
    else
        QBCore.Functions.Notify("You Are Not In Any Vehicle !", "error")
    end
end)

RegisterNetEvent('CL-BeanMachine:client:donut',function ()
	QBCore.Functions.GetPlayerData(function (PlayerData)
		PlayerJob = PlayerData.job
		if PlayerData.job.onduty then
				working = true
				LocalPlayer.state:set("inv_busy", true, true)
				QBCore.Functions.Progressbar('pickup_sla', 'Grabing a Donut', 5000, false, true, {
					disableMovement = true,
					disableCarMovement = false,
					disableMouse = false,
					disableCombat = false,
				},{
					animDict = 'mini@drinking',
					anim = 'shots_barman_b',
					flags = 8,
					}, {}, {}, function()
				working = false
				StopAnimTask(PlayerPedId(), 'mini@drinking' , 'shots_barman_b' , 1.0)
				LocalPlayer.state:set("inv_busy", false, true)
				TriggerServerEvent('CL-BeanMachine:GiveDonut')
				end, function ()
					LocalPlayer.state:set("inv_busy", false, true)
					QBCore.Functions.Notify('Canceled..', 'error')
					working = false
					
				end) 
			else
				
			end
		
			QBCore.Functions.Notify('You must be clocked into work', 'error')
	end)
end)
RegisterNetEvent('CL-BeanMachine:client:Toast',function ()
	QBCore.Functions.GetPlayerData(function (PlayerData)
		PlayerJob = PlayerData.job
		if PlayerData.job.onduty then
				working = true
				LocalPlayer.state:set("inv_busy", true, true)
				QBCore.Functions.Progressbar('pickup_sla', 'Grabing a Grilled Cheese', 5000, false, true, {
					disableMovement = true,
					disableCarMovement = false,
					disableMouse = false,
					disableCombat = false,
				},{
					animDict = 'mini@drinking',
					anim = 'shots_barman_b',
					flags = 8,
					}, {}, {}, function()
				working = false
				StopAnimTask(PlayerPedId(), 'mini@drinking' , 'shots_barman_b' , 1.0)
				LocalPlayer.state:set("inv_busy", false, true)
				TriggerServerEvent('CL-BeanMachine:GiveToast')
				end, function ()
					LocalPlayer.state:set("inv_busy", false, true)
					QBCore.Functions.Notify('Canceled..', 'error')
					working = false
					
				end) 
			else
				
			end
		
			QBCore.Functions.Notify('You must be clocked into work', 'error')
	end)
end)
RegisterNetEvent('CL-BeanMachine:client:Banana',function ()
	QBCore.Functions.GetPlayerData(function (PlayerData)
		PlayerJob = PlayerData.job
		if PlayerData.job.onduty then
				working = true
				LocalPlayer.state:set("inv_busy", true, true)
				QBCore.Functions.Progressbar('pickup_sla', 'Grabing a Banana', 5000, false, true, {
					disableMovement = true,
					disableCarMovement = false,
					disableMouse = false,
					disableCombat = false,
				},{
					animDict = 'mini@drinking',
					anim = 'shots_barman_b',
					flags = 8,
					}, {}, {}, function()
				working = false
				StopAnimTask(PlayerPedId(), 'mini@drinking' , 'shots_barman_b' , 1.0)
				LocalPlayer.state:set("inv_busy", false, true)
				TriggerServerEvent('CL-BeanMachine:GiveBanana')
				end, function ()
					LocalPlayer.state:set("inv_busy", false, true)
					QBCore.Functions.Notify('Canceled..', 'error')
					working = false
					
				end) 
			else
				
			end
		
			QBCore.Functions.Notify('You must be clocked into work', 'error')
	end)
end)
RegisterNetEvent('CL-BeanMachine:client:Apple',function ()
	QBCore.Functions.GetPlayerData(function (PlayerData)
		PlayerJob = PlayerData.job
		if PlayerData.job.onduty then
				working = true
				LocalPlayer.state:set("inv_busy", true, true)
				QBCore.Functions.Progressbar('pickup_sla', 'Grabing an apple', 5000, false, true, {
					disableMovement = true,
					disableCarMovement = false,
					disableMouse = false,
					disableCombat = false,
				},{
					animDict = 'mini@drinking',
					anim = 'shots_barman_b',
					flags = 8,
					}, {}, {}, function()
				working = false
				StopAnimTask(PlayerPedId(), 'mini@drinking' , 'shots_barman_b' , 1.0)
				LocalPlayer.state:set("inv_busy", false, true)
				TriggerServerEvent('CL-BeanMachine:Giveapple')
				end, function ()
					LocalPlayer.state:set("inv_busy", false, true)
					QBCore.Functions.Notify('Canceled..', 'error')
					working = false
					
				end) 
			else
				
			end
		
			QBCore.Functions.Notify('You must be clocked into work', 'error')
	end)
end)
RegisterNetEvent('CL-BeanMachine:client:Beans',function ()
	QBCore.Functions.GetPlayerData(function (PlayerData)
		PlayerJob = PlayerData.job
		if PlayerData.job.onduty then
				working = true
				LocalPlayer.state:set("inv_busy", true, true)
				QBCore.Functions.Progressbar('pickup_sla', 'Getting Coffee Beans', 5000, false, true, {
					disableMovement = true,
					disableCarMovement = false,
					disableMouse = false,
					disableCombat = false,
				},{
					animDict = 'mini@drinking',
					anim = 'shots_barman_b',
					flags = 8,
					}, {}, {}, function()
				working = false
				StopAnimTask(PlayerPedId(), 'mini@drinking' , 'shots_barman_b' , 1.0)
				LocalPlayer.state:set("inv_busy", false, true)
				TriggerServerEvent('CL-BeanMachine:Givebeans')
				end, function ()
					LocalPlayer.state:set("inv_busy", false, true)
					QBCore.Functions.Notify('Canceled..', 'error')
					working = false
					
				end) 
			else
				
			end
		
			QBCore.Functions.Notify('You must be clocked into work', 'error')
	end)
end)
RegisterNetEvent('CL-BeanMachine:client:orange',function ()
	QBCore.Functions.GetPlayerData(function (PlayerData)
		PlayerJob = PlayerData.job
		if PlayerData.job.onduty then
				working = true
				LocalPlayer.state:set("inv_busy", true, true)
				QBCore.Functions.Progressbar('pickup_sla', 'Grabing an Orange', 5000, false, true, {
					disableMovement = true,
					disableCarMovement = false,
					disableMouse = false,
					disableCombat = false,
				},{
					animDict = 'mini@drinking',
					anim = 'shots_barman_b',
					flags = 8,
					}, {}, {}, function()
				working = false
				StopAnimTask(PlayerPedId(), 'mini@drinking' , 'shots_barman_b' , 1.0)
				LocalPlayer.state:set("inv_busy", false, true)
				TriggerServerEvent('CL-BeanMachine:GiveOrange')
				end, function ()
					LocalPlayer.state:set("inv_busy", false, true)
					QBCore.Functions.Notify('Canceled..', 'error')
					working = false
					
				end) 
			else
				
			end
		
			QBCore.Functions.Notify('You must be clocked into work', 'error')
	end)
end)
RegisterNetEvent('CL-BeanMachine:client:Muffin',function ()
	QBCore.Functions.GetPlayerData(function (PlayerData)
		PlayerJob = PlayerData.job
		if PlayerData.job.onduty then
				working = true
				LocalPlayer.state:set("inv_busy", true, true)
				QBCore.Functions.Progressbar('pickup_sla', 'Grabing a Muffin', 5000, false, true, {
					disableMovement = true,
					disableCarMovement = false,
					disableMouse = false,
					disableCombat = false,
				},{
					animDict = 'mini@drinking',
					anim = 'shots_barman_b',
					flags = 8,
					}, {}, {}, function()
				working = false
				StopAnimTask(PlayerPedId(), 'mini@drinking' , 'shots_barman_b' , 1.0)
				LocalPlayer.state:set("inv_busy", false, true)
				TriggerServerEvent('CL-BeanMachine:Givemuffin')
				end, function ()
					LocalPlayer.state:set("inv_busy", false, true)
					QBCore.Functions.Notify('Canceled..', 'error')
					working = false
					
				end) 
			else
				
			end
		
			QBCore.Functions.Notify('You must be clocked into work', 'error')
	end)
end)
RegisterNetEvent('CL-BeanMachine:client:ChocolateMuffin',function ()
	QBCore.Functions.GetPlayerData(function (PlayerData)
		PlayerJob = PlayerData.job
		if PlayerData.job.onduty then
				working = true
				LocalPlayer.state:set("inv_busy", true, true)
				QBCore.Functions.Progressbar('pickup_sla', 'Grabing a Chocolate Muffin', 5000, false, true, {
					disableMovement = true,
					disableCarMovement = false,
					disableMouse = false,
					disableCombat = false,
				},{
					animDict = 'mini@drinking',
					anim = 'shots_barman_b',
					flags = 8,
					}, {}, {}, function()
				working = false
				StopAnimTask(PlayerPedId(), 'mini@drinking' , 'shots_barman_b' , 1.0)
				LocalPlayer.state:set("inv_busy", false, true)
				TriggerServerEvent('CL-BeanMachine:GiveChocolateMuffin')
				end, function ()
					LocalPlayer.state:set("inv_busy", false, true)
					QBCore.Functions.Notify('Canceled..', 'error')
					working = false
					
				end) 
			else
				
			end
		
			QBCore.Functions.Notify('You must be clocked into work', 'error')
	end)
end)
RegisterNetEvent('CL-BeanMachine:client:BerryMuffin',function ()
	QBCore.Functions.GetPlayerData(function (PlayerData)
		PlayerJob = PlayerData.job
		if PlayerData.job.onduty then
				working = true
				LocalPlayer.state:set("inv_busy", true, true)
				QBCore.Functions.Progressbar('pickup_sla', 'Grabing a Berry Muffin', 5000, false, true, {
					disableMovement = true,
					disableCarMovement = false,
					disableMouse = false,
					disableCombat = false,
				},{
					animDict = 'mini@drinking',
					anim = 'shots_barman_b',
					flags = 8,
					}, {}, {}, function()
				working = false
				StopAnimTask(PlayerPedId(), 'mini@drinking' , 'shots_barman_b' , 1.0)
				LocalPlayer.state:set("inv_busy", false, true)
				TriggerServerEvent('CL-BeanMachine:GiveberryMuffin')
				end, function ()
					LocalPlayer.state:set("inv_busy", false, true)
					QBCore.Functions.Notify('Canceled..', 'error')
					working = false
					
				end) 
			else
		
			end
		
			QBCore.Functions.Notify('You must be clocked into work', 'error')
	end)
end)
RegisterNetEvent('CL-BeanMachine:client:RegularCup',function ()
	QBCore.Functions.GetPlayerData(function (PlayerData)
		PlayerJob = PlayerData.job
		if PlayerData.job.onduty then
			working = true
			LocalPlayer.state:set("inv_busy", true, true)
				QBCore.Functions.Progressbar('pickup_sla', 'Grabing a cup', 5000, false, true, {
					disableMovement = true,
					disableCarMovement = false,
					disableMouse = false,
					disableCombat = false,
				},{
					animDict = 'mini@drinking',
					anim = 'shots_barman_b',
					flags = 8,
					}, {}, {}, function()
				working = false
				StopAnimTask(PlayerPedId(), 'mini@drinking' , 'shots_barman_b' , 1.0)
				LocalPlayer.state:set("inv_busy", false, true)
				TriggerServerEvent('CL-BeanMachine:Givecup')
				end, function ()
					LocalPlayer.state:set("inv_busy", false, true)
					QBCore.Functions.Notify('Canceled..', 'error')
					working = false
				end)
			else
			end
			QBCore.Functions.Notify('You must be clocked into work', 'error')
	end)
end)
RegisterNetEvent('CL-BeanMachine:client:CoffeeGlass',function ()
	QBCore.Functions.GetPlayerData(function (PlayerData)
		PlayerJob = PlayerData.job
		if PlayerData.job.onduty then
			working = true
			LocalPlayer.state:set("inv_busy", true, true)
				QBCore.Functions.Progressbar('pickup_sla', 'Grabing a coffee cup', 5000, false, true, {
					disableMovement = true,
					disableCarMovement = false,
					disableMouse = false,
					disableCombat = false,
				},{
					animDict = 'mini@drinking',
					anim = 'shots_barman_b',
					flags = 8,
					}, {}, {}, function()
				working = false
				StopAnimTask(PlayerPedId(), 'mini@drinking' , 'shots_barman_b' , 1.0)
				LocalPlayer.state:set("inv_busy", false, true)
				TriggerServerEvent('CL-BeanMachine:GiveCoffeeCup')
				end, function ()
					LocalPlayer.state:set("inv_busy", false, true)
					QBCore.Functions.Notify('Canceled..', 'error')
					working = false
				end)
			else
			end
			QBCore.Functions.Notify('You must be clocked into work', 'error')
	end)
end)
RegisterNetEvent('CL-BeanMachine:client:HighCoffeeGlass',function ()
	QBCore.Functions.GetPlayerData(function (PlayerData)
		PlayerJob = PlayerData.job
		if PlayerData.job.onduty then
			working = true
			LocalPlayer.state:set("inv_busy", true, true)
				QBCore.Functions.Progressbar('pickup_sla', 'Grabing a high coffee cup', 5000, false, true, {
					disableMovement = true,
					disableCarMovement = false,
					disableMouse = false,
					disableCombat = false,
				},{
					animDict = 'mini@drinking',
					anim = 'shots_barman_b',
					flags = 8,
					}, {}, {}, function()
				working = false
				StopAnimTask(PlayerPedId(), 'mini@drinking' , 'shots_barman_b' , 1.0)
				LocalPlayer.state:set("inv_busy", false, true)
				TriggerServerEvent('CL-BeanMachine:GiveHighCoffeeGlass')
				end, function ()
					LocalPlayer.state:set("inv_busy", false, true)
					QBCore.Functions.Notify('Canceled..', 'error')
					working = false
				end)
			else
			end
			QBCore.Functions.Notify('You must be clocked into work', 'error')
	end)
end)
RegisterNetEvent('CL-BeanMachine:client:EspressoCup',function ()
	QBCore.Functions.GetPlayerData(function (PlayerData)
		PlayerJob = PlayerData.job
		if PlayerData.job.onduty then
			working = true
			LocalPlayer.state:set("inv_busy", true, true)
				QBCore.Functions.Progressbar('pickup_sla', 'Grabing an Espresso cup', 5000, false, true, {
					disableMovement = true,
					disableCarMovement = false,
					disableMouse = false,
					disableCombat = false,
				},{
					animDict = 'mini@drinking',
					anim = 'shots_barman_b',
					flags = 8,
					}, {}, {}, function()
				working = false
				StopAnimTask(PlayerPedId(), 'mini@drinking' , 'shots_barman_b' , 1.0)
				LocalPlayer.state:set("inv_busy", false, true)
				TriggerServerEvent('CL-BeanMachine:GiveEspressocoffecup')
				end, function ()
					LocalPlayer.state:set("inv_busy", false, true)
					QBCore.Functions.Notify('Canceled..', 'error')
					working = false
				end)
			else
			end
			QBCore.Functions.Notify('You must be clocked into work', 'error')
	end)
end)
RegisterNetEvent('CL-BeanMachine:client:lemonslush',function ()
	QBCore.Functions.GetPlayerData(function (PlayerData)
		PlayerJob = PlayerData.job
		if PlayerData.job.onduty then
			local regularcup = QBCore.Functions.HasItem("bregularcup")
			if regularcup then
				working = true
				LocalPlayer.state:set("inv_busy", true, true)
				QBCore.Functions.Progressbar('pickup_sla', 'Pouring Lemon Slushie', 5000, false, true, {
					disableMovement = true,
					disableCarMovement = false,
					disableMouse = false,
					disableCombat = false,
				},{
					animDict = 'mini@drinking',
					anim = 'shots_barman_b',
					flags = 8,
					}, {}, {}, function()
				working = false
				StopAnimTask(PlayerPedId(), 'mini@drinking' , 'shots_barman_b' , 1.0)
				LocalPlayer.state:set("inv_busy", false, true)
				TriggerServerEvent('CL-BeanMachine:GiveLemonSlush')
				end, function ()
					LocalPlayer.state:set("inv_busy", false, true)
					QBCore.Functions.Notify('Canceled..', 'error')
					working = false
					
				end) 
			else
				QBCore.Functions.Notify('You dont have the correct cup to make this', 'error')
			end
		else
			QBCore.Functions.Notify('You must be clocked into work', 'error')
		end
	end)
end)
RegisterNetEvent('CL-BeanMachine:client:OrangeSlushie',function ()
	QBCore.Functions.GetPlayerData(function (PlayerData)
		PlayerJob = PlayerData.job
		if PlayerData.job.onduty then
			local regularcup = QBCore.Functions.HasItem("bregularcup")
			if regularcup then
				working = true
				LocalPlayer.state:set("inv_busy", true, true)
				QBCore.Functions.Progressbar('pickup_sla', 'Pouring Orange slushie', 5000, false, true, {
					disableMovement = true,
					disableCarMovement = false,
					disableMouse = false,
					disableCombat = false,
				},{
					animDict = 'mini@drinking',
					anim = 'shots_barman_b',
					flags = 8,
					}, {}, {}, function()
				working = false
				StopAnimTask(PlayerPedId(), 'mini@drinking' , 'shots_barman_b' , 1.0)
				LocalPlayer.state:set("inv_busy", false, true)
				TriggerServerEvent('CL-BeanMachine:GiveOrangeSlush')
				end, function ()
					LocalPlayer.state:set("inv_busy", false, true)
					QBCore.Functions.Notify('Canceled..', 'error')
					working = false
					
				end) 
			else
				QBCore.Functions.Notify('You dont have the correct cup to make this', 'error')
			end
		else
			QBCore.Functions.Notify('You must be clocked into work', 'error')
		end
	end)
end)
RegisterNetEvent('CL-BeanMachine:client:GiveSprite',function ()
	QBCore.Functions.GetPlayerData(function (PlayerData)
		PlayerJob = PlayerData.job
		if PlayerData.job.onduty then
			local regularcup = QBCore.Functions.HasItem("bregularcup")
			if  regularcup then
				working = true
				LocalPlayer.state:set("inv_busy", true, true)
				QBCore.Functions.Progressbar('pickup_sla', 'Dispensing Sprite', 5000, false, true, {
					disableMovement = true,
					disableCarMovement = false,
					disableMouse = false,
					disableCombat = false,
				},{
					animDict = 'mini@drinking',
					anim = 'shots_barman_b',
					flags = 8,
					}, {}, {}, function()
				working = false
				StopAnimTask(PlayerPedId(), 'mini@drinking' , 'shots_barman_b' , 1.0)
				LocalPlayer.state:set("inv_busy", false, true)
				TriggerServerEvent('CL-BeanMachine:GiveSprite')
				end, function ()
					LocalPlayer.state:set("inv_busy", false, true)
					QBCore.Functions.Notify('Canceled..', 'error')
					working = false
					
				end) 
			else
				QBCore.Functions.Notify('You dont have the correct cup to make this', 'error')
			end
		else
			QBCore.Functions.Notify('You must be clocked into work', 'error')
		end
	end)
end)
RegisterNetEvent('CL-BeanMachine:client:GiveCola', function ()
	QBCore.Functions.GetPlayerData(function (PlayerData)
		PlayerJob = PlayerData.job
		if PlayerData.job.onduty then
			local regularcup = QBCore.Functions.HasItem("bregularcup")
			if regularcup then
				working = true
				LocalPlayer.state:set("inv_busy", true, true)
				QBCore.Functions.Progressbar('pickup_sla', 'Dispensing CocaCola', 5000, false, true, {
					disableMovement = true,
					disableCarMovement = false,
					disableMouse = false,
					disableCombat = false,
				},{
					animDict = 'mini@drinking',
					anim = 'shots_barman_b',
					flags = 8,
					}, {}, {}, function()
				working = false
				StopAnimTask(PlayerPedId(), 'mini@drinking' , 'shots_barman_b' , 1.0)
				LocalPlayer.state:set("inv_busy", false, true)
				TriggerServerEvent('CL-BeanMachine:GiveCola')
				end, function ()
					LocalPlayer.state:set("inv_busy", false, true)
					QBCore.Functions.Notify('Canceled..', 'error')
					working = false
					
				end) 
			else
				QBCore.Functions.Notify('You dont have the correct cup to make this', 'error')
			end
		else
			QBCore.Functions.Notify('You must be clocked into work', 'error')
		end
	end)
end)
RegisterNetEvent('CL-BeanMachine:client:GivePepper', function ()
	QBCore.Functions.GetPlayerData(function (PlayerData)
		PlayerJob = PlayerData.job
		if PlayerData.job.onduty then
			local regularcup = QBCore.Functions.HasItem("bregularcup")
			if regularcup then
				working = true
				LocalPlayer.state:set("inv_busy", true, true)
				QBCore.Functions.Progressbar('pickup_sla', '', 5000, false, true, {
					disableMovement = true,
					disableCarMovement = false,
					disableMouse = false,
					disableCombat = false,
				},{
					animDict = 'mini@drinking',
					anim = 'shots_barman_b',
					flags = 8,
					}, {}, {}, function()
				working = false
				StopAnimTask(PlayerPedId(), 'mini@drinking' , 'shots_barman_b' , 1.0)
				LocalPlayer.state:set("inv_busy", false, true)
				TriggerServerEvent('CL-BeanMachine:Givedrpepper')
				end, function ()
					LocalPlayer.state:set("inv_busy", false, true)
					QBCore.Functions.Notify('Canceled..', 'error')
					working = false
					
				end) 
			else
				QBCore.Functions.Notify('You dont have the correct cup to make this', 'error')
			end
		else
			QBCore.Functions.Notify('You must be clocked into work', 'error')
		end
	end)
end)
RegisterNetEvent('CL-BeanMachine:client:CloudCafe', function ()
	QBCore.Functions.GetPlayerData(function (PlayerData)
		PlayerJob = PlayerData.job
		if PlayerData.job.onduty then
			local HighCup = QBCore.Functions.HasItem("bhighcoffeeglasscup")
			local milk = QBCore.Functions.HasItem("bmilk")
			local coffeebeans = QBCore.Functions.HasItem("bcoffeebeans")
			local cream = QBCore.Functions.HasItem("bcream")
			if HighCup and milk and coffeebeans and cream then
				working = true
				LocalPlayer.state:set("inv_busy", true, true)
				QBCore.Functions.Progressbar('pickup_sla', 'Making a Cloud Cafe', 5000, false, true, {
					disableMovement = true,
					disableCarMovement = false,
					disableMouse = false,
					disableCombat = false,
				},{
					animDict = 'mini@drinking',
					anim = 'shots_barman_b',
					flags = 8,
					}, {}, {}, function()
				working = false
				StopAnimTask(PlayerPedId(), 'mini@drinking' , 'shots_barman_b' , 1.0)
				LocalPlayer.state:set("inv_busy", false, true)
				TriggerServerEvent('CL-BeanMachine:GiveCloudCafe')
				end, function ()
					LocalPlayer.state:set("inv_busy", false, true)
					QBCore.Functions.Notify('Canceled..', 'error')
					working = false
					
				end) 
			else
				QBCore.Functions.Notify('You dont have the correct Ingredients to make this', 'error')
			end
		else
			QBCore.Functions.Notify('You must be clocked into work', 'error')
		end
	end)
end)
RegisterNetEvent('CL-BeanMachine:client:StrawberryCreamFrap', function ()
	QBCore.Functions.GetPlayerData(function (PlayerData)
		PlayerJob = PlayerData.job
		if PlayerData.job.onduty then
			local cup = QBCore.Functions.HasItem("bhighcoffeeglasscup")
			local beans = QBCore.Functions.HasItem("bcoffeebeans")
			local mix1 = QBCore.Functions.HasItem("bmilk")
			local mix2 = QBCore.Functions.HasItem("bcream")
			local mix3 = QBCore.Functions.HasItem("bstrawberry")
			if cup and beans and mix1 and mix2 and mix3 then
				working = true
				LocalPlayer.state:set("inv_busy", true, true)
				QBCore.Functions.Progressbar('pickup_sla', 'Making Strawberry Cream Frappuccino', 5000, false, true, {
					disableMovement = true,
					disableCarMovement = false,
					disableMouse = false,
					disableCombat = false,
				},{
					animDict = 'mini@drinking',
					anim = 'shots_barman_b',
					flags = 8,
					}, {}, {}, function()
				working = false
				StopAnimTask(PlayerPedId(), 'mini@drinking' , 'shots_barman_b' , 1.0)
				LocalPlayer.state:set("inv_busy", false, true)
				TriggerServerEvent('CL-BeanMachine:GiveStrawberryCreamFrap')
				end, function ()
					LocalPlayer.state:set("inv_busy", false, true)
					QBCore.Functions.Notify('Canceled..', 'error')
					working = false
					
				end) 
			else
				QBCore.Functions.Notify('You dont have the correct Ingredients to make this', 'error')
			end
		else
			QBCore.Functions.Notify('You must be clocked into work', 'error')
		end
	end)
end)
RegisterNetEvent('CL-BeanMachine:client:JavaChipFrap', function ()
	QBCore.Functions.GetPlayerData(function (PlayerData)
		PlayerJob = PlayerData.job
		if PlayerData.job.onduty then
			local cup = QBCore.Functions.HasItem("bhighcoffeeglasscup")
			local beans = QBCore.Functions.HasItem("bcoffeebeans")
			local mix1 = QBCore.Functions.HasItem("bmilk")
			local mix2 = QBCore.Functions.HasItem("bcream")
			if cup and beans and mix1 and mix2 then
				working = true
				LocalPlayer.state:set("inv_busy", true, true)
				QBCore.Functions.Progressbar('pickup_sla', 'Making a Java Chip Frappuccino', 5000, false, true, {
					disableMovement = true,
					disableCarMovement = false,
					disableMouse = false,
					disableCombat = false,
				},{
					animDict = 'mini@drinking',
					anim = 'shots_barman_b',
					flags = 8,
					}, {}, {}, function()
				working = false
				StopAnimTask(PlayerPedId(), 'mini@drinking' , 'shots_barman_b' , 1.0)
				LocalPlayer.state:set("inv_busy", false, true)
				TriggerServerEvent('CL-BeanMachine:GiveJavaChipFrap')
				end, function ()
					LocalPlayer.state:set("inv_busy", false, true)
					QBCore.Functions.Notify('Canceled..', 'error')
					working = false
					
				end) 
			else
				QBCore.Functions.Notify('You dont have the correct Ingredients to make this', 'error')
			end
		else
			QBCore.Functions.Notify('You must be clocked into work', 'error')
		end
	end)
end)
RegisterNetEvent('CL-BeanMachine:client:HotChoc', function ()
	QBCore.Functions.GetPlayerData(function (PlayerData)
		PlayerJob = PlayerData.job
		if PlayerData.job.onduty then
			local cup = QBCore.Functions.HasItem("bcoffeeglass")
			local beans = QBCore.Functions.HasItem("bcoffeebeans")
			local mix1 = QBCore.Functions.HasItem("bmilk")
			local mix2 = QBCore.Functions.HasItem("bcream")
			local mix3 = QBCore.Functions.HasItem("bhotchocolatepowder")
			if cup and beans and mix1 and mix2 and mix3 then
				working = true
				LocalPlayer.state:set("inv_busy", true, true)
				QBCore.Functions.Progressbar('pickup_sla', 'Making Hot Chocolate', 5000, false, true, {
					disableMovement = true,
					disableCarMovement = false,
					disableMouse = false,
					disableCombat = false,
				},{
					animDict = 'mini@drinking',
					anim = 'shots_barman_b',
					flags = 8,
					}, {}, {}, function()
				working = false
				StopAnimTask(PlayerPedId(), 'mini@drinking' , 'shots_barman_b' , 1.0)
				LocalPlayer.state:set("inv_busy", false, true)
				TriggerServerEvent('CL-BeanMachine:GiveHotChoclate')
				end, function ()
					LocalPlayer.state:set("inv_busy", false, true)
					QBCore.Functions.Notify('Canceled..', 'error')
					working = false
					
				end) 
			else
				QBCore.Functions.Notify('You dont have the correct Ingredients to make this', 'error')
			end
		else
			QBCore.Functions.Notify('You must be clocked into work', 'error')
		end
	end)
end)
RegisterNetEvent('CL-BeanMachine:client:Caramelfrap', function ()
	QBCore.Functions.GetPlayerData(function (PlayerData)
		PlayerJob = PlayerData.job
		if PlayerData.job.onduty then
			local cup = QBCore.Functions.HasItem("bhighcoffeeglasscup")
			local beans = QBCore.Functions.HasItem("bcoffeebeans")
			local mix1 = QBCore.Functions.HasItem("bmilk")
			local mix2 = QBCore.Functions.HasItem("bcream")
			local mix3 = QBCore.Functions.HasItem("bcaramelsyrup")
			if cup and beans and mix1 and mix2 and mix3 then
				working = true
				LocalPlayer.state:set("inv_busy", true, true)
				QBCore.Functions.Progressbar('pickup_sla', 'Making a Caramel Frappuccino', 5000, false, true, {
					disableMovement = true,
					disableCarMovement = false,
					disableMouse = false,
					disableCombat = false,
				},{
					animDict = 'mini@drinking',
					anim = 'shots_barman_b',
					flags = 8,
					}, {}, {}, function()
				working = false
				StopAnimTask(PlayerPedId(), 'mini@drinking' , 'shots_barman_b' , 1.0)
				LocalPlayer.state:set("inv_busy", false, true)
				TriggerServerEvent('CL-BeanMachine:GiveCaramelFrap')
				end, function ()
					LocalPlayer.state:set("inv_busy", false, true)
					QBCore.Functions.Notify('Canceled..', 'error')
					working = false
					
				end) 
			else
				QBCore.Functions.Notify('You dont have the correct Ingredients to make this', 'error')
			end
		else
			QBCore.Functions.Notify('You must be clocked into work', 'error')
		end
	end)
end)
RegisterNetEvent('CL-BeanMachine:client:HoneyHazelnutOatLatte', function ()
	QBCore.Functions.GetPlayerData(function (PlayerData)
		PlayerJob = PlayerData.job
		if PlayerData.job.onduty then
			local cup = QBCore.Functions.HasItem("bcoffeeglass")
			local beans = QBCore.Functions.HasItem("bcoffeebeans")
			local mix1 = QBCore.Functions.HasItem("bmilk")
			local mix2 = QBCore.Functions.HasItem("bhoney")
			if cup and beans and mix1 and mix2 then
				working = true
				LocalPlayer.state:set("inv_busy", true, true)
				QBCore.Functions.Progressbar('pickup_sla', 'Making a Honey Hazelnut Oat Latte', 5000, false, true, {
					disableMovement = true,
					disableCarMovement = false,
					disableMouse = false,
					disableCombat = false,
				},{
					animDict = 'mini@drinking',
					anim = 'shots_barman_b',
					flags = 8,
					}, {}, {}, function()
				working = false
				StopAnimTask(PlayerPedId(), 'mini@drinking' , 'shots_barman_b' , 1.0)
				LocalPlayer.state:set("inv_busy", false, true)
				TriggerServerEvent('CL-BeanMachine:GiveHoneyHazelnutOatLatte')
				end, function ()
					LocalPlayer.state:set("inv_busy", false, true)
					QBCore.Functions.Notify('Canceled..', 'error')
					working = false
					
				end) 
			else
				QBCore.Functions.Notify('You dont have the correct Ingredients to make this', 'error')
			end
		else
			QBCore.Functions.Notify('You must be clocked into work', 'error')
		end
	end)
end)
RegisterNetEvent('CL-BeanMachine:client:ColdBrew', function ()
	QBCore.Functions.GetPlayerData(function (PlayerData)
		PlayerJob = PlayerData.job
		if PlayerData.job.onduty then
			local cup = QBCore.Functions.HasItem("bhighcoffeeglasscup")
			local beans = QBCore.Functions.HasItem("bcoffeebeans")
			local mix1 = QBCore.Functions.HasItem("bmilk")
			local mix2 = QBCore.Functions.HasItem("bice")
			if cup and beans and mix1 and mix2 then
				working = true
				LocalPlayer.state:set("inv_busy", true, true)
				QBCore.Functions.Progressbar('pickup_sla', 'Making a Cold Brew Latte', 5000, false, true, {
					disableMovement = true,
					disableCarMovement = false,
					disableMouse = false,
					disableCombat = false,
				},{
					animDict = 'mini@drinking',
					anim = 'shots_barman_b',
					flags = 8,
					}, {}, {}, function()
				working = false
				StopAnimTask(PlayerPedId(), 'mini@drinking' , 'shots_barman_b' , 1.0)
				LocalPlayer.state:set("inv_busy", false, true)
				TriggerServerEvent('CL-BeanMachine:GiveColdBrewLatte')
				end, function ()
					LocalPlayer.state:set("inv_busy", false, true)
					QBCore.Functions.Notify('Canceled..', 'error')
					working = false
					
				end) 
			else
				QBCore.Functions.Notify('You dont have the correct Ingredients to make this', 'error')
			end
		else
			QBCore.Functions.Notify('You must be clocked into work', 'error')
		end
	end)
end)
RegisterNetEvent('CL-BeanMachine:client:StrawberryVanillaOatLatte', function ()
	QBCore.Functions.GetPlayerData(function (PlayerData)
		PlayerJob = PlayerData.job
		if PlayerData.job.onduty then
			local cup = QBCore.Functions.HasItem("bcoffeeglass")
			local beans = QBCore.Functions.HasItem("bcoffeebeans")
			local mix1 = QBCore.Functions.HasItem("bmilk")
			local mix2 = QBCore.Functions.HasItem("bstrawberry")
			if cup and beans and mix1 and mix2 then
				working = true
				LocalPlayer.state:set("inv_busy", true, true)
				QBCore.Functions.Progressbar('pickup_sla', 'Making a Strawberry Vanilla Oat Latte', 5000, false, true, {
					disableMovement = true,
					disableCarMovement = false,
					disableMouse = false,
					disableCombat = false,
				},{
					animDict = 'mini@drinking',
					anim = 'shots_barman_b',
					flags = 8,
					}, {}, {}, function()
				working = false
				StopAnimTask(PlayerPedId(), 'mini@drinking' , 'shots_barman_b' , 1.0)
				LocalPlayer.state:set("inv_busy", false, true)
				TriggerServerEvent('CL-BeanMachine:GiveStrawberryVanillaOatLatte')
				end, function ()
					LocalPlayer.state:set("inv_busy", false, true)
					QBCore.Functions.Notify('Canceled..', 'error')
					working = false
					
				end) 
			else
				QBCore.Functions.Notify('You dont have the correct Ingredients to make this', 'error')
			end
		else
			QBCore.Functions.Notify('You must be clocked into work', 'error')
		end
	end)
end)
RegisterNetEvent('CL-BeanMachine:client:IcedCaffeLatte', function ()
	QBCore.Functions.GetPlayerData(function (PlayerData)
		PlayerJob = PlayerData.job
		if PlayerData.job.onduty then
			local cup = QBCore.Functions.HasItem("bcoffeeglass")
			local beans = QBCore.Functions.HasItem("bcoffeebeans")
			local mix1 = QBCore.Functions.HasItem("bmilk")
			local mix2 = QBCore.Functions.HasItem("bice")
			if cup and beans and mix1 and mix2 then
				working = true
				LocalPlayer.state:set("inv_busy", true, true)
				QBCore.Functions.Progressbar('pickup_sla', 'Maikng an Iced Caffe Latte', 5000, false, true, {
					disableMovement = true,
					disableCarMovement = false,
					disableMouse = false,
					disableCombat = false,
				},{
					animDict = 'mini@drinking',
					anim = 'shots_barman_b',
					flags = 8,
					}, {}, {}, function()
				working = false
				StopAnimTask(PlayerPedId(), 'mini@drinking' , 'shots_barman_b' , 1.0)
				LocalPlayer.state:set("inv_busy", false, true)
				TriggerServerEvent('CL-BeanMachine:GiveIcedCaffeLatte')
				end, function ()
					LocalPlayer.state:set("inv_busy", false, true)
					QBCore.Functions.Notify('Canceled..', 'error')
					working = false
					
				end) 
			else
				QBCore.Functions.Notify('You dont have the correct Ingredients to make this', 'error')
			end
		else
			QBCore.Functions.Notify('You must be clocked into work', 'error')
		end
	end)
end)
RegisterNetEvent('CL-BeanMachine:client:Espresso', function ()
	QBCore.Functions.GetPlayerData(function (PlayerData)
		PlayerJob = PlayerData.job
		if PlayerData.job.onduty then
			local cup = QBCore.Functions.HasItem("bespressocoffeecup")
			local beans = QBCore.Functions.HasItem("bcoffeebeans")
			local mix1 = QBCore.Functions.HasItem("bmilk")
			if cup and beans and mix1 then
				working = true
				LocalPlayer.state:set("inv_busy", true, true)
				QBCore.Functions.Progressbar('pickup_sla', 'Making Espresso', 5000, false, true, {
					disableMovement = true,
					disableCarMovement = false,
					disableMouse = false,
					disableCombat = false,
				},{
					animDict = 'mini@drinking',
					anim = 'shots_barman_b',
					flags = 8,
					}, {}, {}, function()
				working = false
				StopAnimTask(PlayerPedId(), 'mini@drinking' , 'shots_barman_b' , 1.0)
				LocalPlayer.state:set("inv_busy", false, true)
				TriggerServerEvent('CL-BeanMachine:GiveEspresso')
				end, function ()
					LocalPlayer.state:set("inv_busy", false, true)
					QBCore.Functions.Notify('Canceled..', 'error')
					working = false
					
				end) 
			else
				QBCore.Functions.Notify('You dont have the correct Ingredients to make this', 'error')
			end
		else
			QBCore.Functions.Notify('You must be clocked into work', 'error')
		end
	end)
end)
RegisterNetEvent('CL-BeanMachine:client:EspressoMacchiato', function ()
	QBCore.Functions.GetPlayerData(function (PlayerData)
		PlayerJob = PlayerData.job
		if PlayerData.job.onduty then
			local cup = QBCore.Functions.HasItem("bespressocoffeecup")
			local beans = QBCore.Functions.HasItem("bcoffeebeans")
			local mix1 = QBCore.Functions.HasItem("bmilk")
			if cup and beans and mix1 then
				working = true
				LocalPlayer.state:set("inv_busy", true, true)
				QBCore.Functions.Progressbar('pickup_sla', 'Making a Macchiato Espresso', 5000, false, true, {
					disableMovement = true,
					disableCarMovement = false,
					disableMouse = false,
					disableCombat = false,
				},{
					animDict = 'mini@drinking',
					anim = 'shots_barman_b',
					flags = 8,
					}, {}, {}, function()
				working = false
				StopAnimTask(PlayerPedId(), 'mini@drinking' , 'shots_barman_b' , 1.0)
				LocalPlayer.state:set("inv_busy", false, true)
				TriggerServerEvent('CL-BeanMachine:GiveEspressocoffecup')
				end, function ()
					LocalPlayer.state:set("inv_busy", false, true)
					QBCore.Functions.Notify('Canceled..', 'error')
					working = false
					
				end) 
			else
				QBCore.Functions.Notify('You dont have the correct Ingredients to make this', 'error')
			end
		else
			QBCore.Functions.Notify('You must be clocked into work', 'error')
		end
	end)
end)
RegisterNetEvent('CL-BeanMachine:SeperatingEvent')
AddEventHandler('CL-BeanMachine:SeperatingEvent', function(data)
	QBCore.Functions.TriggerCallback('CL-BeanMachine:CheckDuty', function(result)
        if result then
			if data.firstmenu then
				TriggerEvent("CL-BeanMachine:FirstCoffeeMenu")
			elseif data.secondmenu then
				TriggerEvent("CL-BeanMachine:SecondCoffeeMenu")
			end
        else
            QBCore.Functions.Notify("You must be on duty.", "error")
        end
    end)
end)

RegisterNetEvent('CL-BeanMachine:OpenMenu')
AddEventHandler('CL-BeanMachine:OpenMenu', function()
  	SetNuiFocus(false, false)
  	SendNUIMessage({action = 'OpenMenu'})
	Citizen.CreateThread(function()
        while true do
			ShowHelpNotification("Press ~INPUT_FRONTEND_RRIGHT~ To Exit")
			if IsControlJustReleased(0, 177) then
				TriggerEvent("CL-BeanMachine:CloseMenu")
				PlaySoundFrontend(-1, "NO", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
				break
			end
			Citizen.Wait(1)
		end
	end)
end)

RegisterNetEvent('CL-BeanMachine:CloseMenu')
AddEventHandler('CL-BeanMachine:CloseMenu', function()
  	SetNuiFocus(false, false)
  	SendNUIMessage({action = 'CloseMenu'})
end)

----------------
----Menus
----------------
RegisterNetEvent("CL-BeanMachine:DutyMenu", function()
    local DutyMenu = {
        {
            header = "Duty",
            isMenuHeader = true,
        }
    }
	DutyMenu[#DutyMenu+1] = {
        header = Config.Locals["DutyMenu"]["Header"],
		txt = Config.Locals["DutyMenu"]["Txt"],
        params = {
			isServer = true,
            event = "QBCore:ToggleDuty"
        }
    }
    DutyMenu[#DutyMenu+1] = {
        header = "⬅ Close",
        params = {
            event = "qb-menu:client:closemenu"
        }
    }
    exports['qb-menu']:openMenu(DutyMenu)
end)

RegisterNetEvent("CL-BeanMachine:ToastsMenu", function()
	QBCore.Functions.TriggerCallback('CL-BeanMachine:CheckDuty', function(result)
        if result then
			local ToastsMenu = {
				{
					header = "Toasts / Donuts",
					isMenuHeader = true,
				}
			}
			ToastsMenu[#ToastsMenu+1] = {
				header = Config.Locals["ToastsMenu"]["Header"],
				txt = Config.Locals["ToastsMenu"]["Txt"],
				params = {
					event = "CL-BeanMachine:client:Toast",
					args = {
					
					}
				}
			}
			ToastsMenu[#ToastsMenu+1] = {
				header = Config.Locals["DonutsMenu"]["Header"],
				txt = Config.Locals["DonutsMenu"]["Txt"],
				params = {
					event = "CL-BeanMachine:client:donut",
					args = {
					
					}
				}
			}
			ToastsMenu[#ToastsMenu+1] = {
				header = "⬅ Close",
				params = {
					event = "qb-menu:client:closemenu"
				}
			}
			exports['qb-menu']:openMenu(ToastsMenu)
        else
            QBCore.Functions.Notify("You must be on duty.", "error")
        end
    end)
end)

RegisterNetEvent("CL-BeanMachine:FruitsMenu", function()
    local FruitsMenu = {
        {
            header = "Fruits",
            isMenuHeader = true,
        }
    }
	FruitsMenu[#FruitsMenu+1] = {
        header = Config.Locals["BananaFruitMenu"]["Header"],
		txt = Config.Locals["BananaFruitMenu"]["Txt"],
        params = {
			event = "CL-BeanMachine:client:Banana",
			args = {
				
			}
        }
    }
	FruitsMenu[#FruitsMenu+1] = {
        header = Config.Locals["OrangeFruitMenu"]["Header"],
		txt = Config.Locals["OrangeFruitMenu"]["Txt"],
        params = {
			event = "CL-BeanMachine:client:orange",
			args = {
				
			}
        }
    }
	FruitsMenu[#FruitsMenu+1] = {
        header = Config.Locals["AppleFruitMenu"]["Header"],
		txt = Config.Locals["AppleFruitMenu"]["Txt"],
        params = {
			event = "CL-BeanMachine:client:Apple",
			args = {
				
			}
        }
    }
    FruitsMenu[#FruitsMenu+1] = {
        header = "⬅ Close",
        params = {
            event = "qb-menu:client:closemenu"
        }
    }
    exports['qb-menu']:openMenu(FruitsMenu)
end)
RegisterNetEvent('CL-BeanMachine:CupMenu', function ()
	QBCore.Functions.TriggerCallback('CL-BeanMachine:CheckDuty', function(result)
		if result then
			local cupmenu = {
				{
					header = 'Cups',
					isMenuHeader = true,
				}
			}
			cupmenu[#cupmenu+1] = {
				header = 'Regular Cup',
				txt = '',
				params = {
					event = "CL-BeanMachine:client:RegularCup",
					args = {

					}
				}
			}
			exports['qb-menu']:openMenu(cupmenu)
		else
			QBCore.Functions.Notify("You must be on duty.", "error")
		end
	end)
end)
RegisterNetEvent('CL-BeanMachine:GlassesMenu',function ()
	QBCore.Functions.TriggerCallback('CL-BeanMachine:CheckDuty',function (result)
		if result then
			local GlassesMenu = {
				{
					header = 'Coffee Glasses',
					isMenuHeader = true,
				}
			}
			GlassesMenu[#GlassesMenu+1] = {
				header = 'Coffee Cup',
				txt = '',
				params = {
					event = 'CL-BeanMachine:client:CoffeeGlass',
					args = {

					}
				}
			}
			GlassesMenu[#GlassesMenu+1] = {
				header = 'High Coffee Cups',
				txt = '',
				params = {
					event = 'CL-BeanMachine:client:HighCoffeeGlass',
					args = {

					}
				}
			}
			GlassesMenu[#GlassesMenu+1] = {
				header = 'Espresso Cup',
				txt = '',
				params = {
					event = 'CL-BeanMachine:client:EspressoCup',
					args = {

					}
				}
			}
			exports['qb-menu']:openMenu(GlassesMenu)
		else
			QBCore.Functions.Notify("You must be on duty.", "error")
		end
	end)
end)
RegisterNetEvent("CL-BeanMachine:MuffinsMenu", function()
	QBCore.Functions.TriggerCallback('CL-BeanMachine:CheckDuty', function(result)
        if result then
			local MuffinsMenu = {
				{
					header = "Muffins",
					isMenuHeader = true,
				}
			}
			MuffinsMenu[#MuffinsMenu+1] = {
				header = Config.Locals["RegularMuffinMenu"]["Header"],
				txt = Config.Locals["RegularMuffinMenu"]["Txt"],
				params = {
					event = "CL-BeanMachine:client:Muffin",
					args = {
						
					}
				}
			}
			MuffinsMenu[#MuffinsMenu+1] = {
				header = Config.Locals["ChocolateMuffinMenu"]["Header"],
				txt = Config.Locals["ChocolateMuffinMenu"]["Txt"],
				params = {
					event = "CL-BeanMachine:client:ChocolateMuffin",
					args = {
						
					}
				}
			}
			MuffinsMenu[#MuffinsMenu+1] = {
				header = Config.Locals["BerryMuffinMenu"]["Header"],
				txt = Config.Locals["BerryMuffinMenu"]["Txt"],
				params = {
					event = "CL-BeanMachine:client:BerryMuffin",
					args = {
					
					}
				}
			}
			MuffinsMenu[#MuffinsMenu+1] = {
				header = "⬅ Close",
				params = {
					event = "qb-menu:client:closemenu"
				}
			}
			exports['qb-menu']:openMenu(MuffinsMenu)
        else
            QBCore.Functions.Notify("You must be on duty.", "error")
        end
    end)
end)

RegisterNetEvent("CL-BeanMachine:FruitsMenu2", function()
    local FruitsMenu2 = {
        {
            header = "Fruits",
            isMenuHeader = true,
        }
    }
	FruitsMenu2[#FruitsMenu2+1] = {
        header = Config.Locals["OrangeFruitMenu"]["Header"],
		txt = Config.Locals["OrangeFruitMenu"]["Txt"],
        params = {
			event = "CL-BeanMachine:client:orange",
			args = {
			
			}        
		}
    }
	FruitsMenu2[#FruitsMenu2+1] = {
        header = Config.Locals["AppleFruitMenu"]["Header"],
		txt = Config.Locals["AppleFruitMenu"]["Txt"],
        params = {
			event = "CL-BeanMachine:client:Apple",
			args = {
			
			}        
		}
    }
    FruitsMenu2[#FruitsMenu2+1] = {
        header = "⬅ Close",
        params = {
            event = "qb-menu:client:closemenu"
        }
    }
    exports['qb-menu']:openMenu(FruitsMenu2)
end)


RegisterNetEvent("CL-BeanMachine:DrinksMenu", function()
	QBCore.Functions.TriggerCallback('CL-BeanMachine:CheckDuty', function(result)
        if result then
			local DrinksMenu = {
				{
					header = "Drinks Machine",
					txt = "View Drinks",
					params = {
						event = "CL-BeanMachine:DrinksCatalog",
					}
				}
			}
			DrinksMenu[#DrinksMenu+1] = {
				header = "⬅ Close",
				params = {
					event = "qb-menu:client:closeMenu"
				}
			}
			exports['qb-menu']:openMenu(DrinksMenu)
        else
            QBCore.Functions.Notify("You must be on duty.", "error")
        end
    end)
end)

RegisterNetEvent("CL-BeanMachine:DrinksCatalog", function()
	QBCore.Functions.GetPlayerData(function(PlayerData)
		PlayerJob = PlayerData.job
		if PlayerData.job.onduty then
			local colddrinkmainmenu = {
				{	
					header = 'Cold Drinks' ,
					isMenuHeader = true,
				},
				{
					header = '• Sprite',
					txt = 'Required Cup: Regular',
					params = {
						event = 'CL-BeanMachine:client:GiveSprite',
						args = {

						}
					}
				},
				{
					header = '• CocaCola',
					txt =  'Required Cup: Regular',
					params = {
						event = 'Cl-BeanMachine:client:GiveCola',
						args = {

						}
					}
				},
				{
					header = '• Dr. Pepper',
					txt = 'Required Cup: Regular',
					params = {
						event = 'CL-Beanmachine:client:GivePepper',
						args = {

						}
					}
				},
				{
		            header = '『⬅』Go Back',
		            txt = '',
		            params = {
		                event = "CL-BeanMachine:DrinksMenu",
						
		            }
		        },
			}
			exports['qb-menu']:openMenu(colddrinkmainmenu)
		else
			QBCore.Functions.Notify('You must be Clocked into work', 'error')
		end	
	end)
end)

RegisterNetEvent("CL-BeanMachine:SlushsMenu", function()
	QBCore.Functions.TriggerCallback('CL-BeanMachine:CheckDuty', function(result)
        if result then
			local SlushsMenu = {
				{
					header = "Slushs",
					isMenuHeader = true,
				}
			}
			SlushsMenu[#SlushsMenu+1] = {
				header = "Orange Slush",
				txt = "Make Orange Slushs",
				params = {
					event = "CL-BeanMachine:SlushsOrangeMenu"
				}
			}
			SlushsMenu[#SlushsMenu+1] = {
				header = "Lemon Slush",
				txt = "Make Lemon Slushs",
				params = {
					event = "CL-BeanMachine:SlushsLemonMenu"
				}
			}
			SlushsMenu[#SlushsMenu+1] = {
				header = "⬅ Close",
				params = {
					event = "qb-menu:client:closeMenu"
				}
			}
			exports['qb-menu']:openMenu(SlushsMenu)
        else
            QBCore.Functions.Notify("You must be on duty.", "error")
        end
    end)
end)

RegisterNetEvent("CL-BeanMachine:SlushsLemonMenu", function()
    local LemonSlushsMenu = {
        {
            header = "Lemon Slushs",
            isMenuHeader = true,
        }
    }
	for k, v in pairs(Config.LemonSlushs) do
		LemonSlushsMenu[#LemonSlushsMenu+1] = {
			header = v.slushname,
			txt = "Make: " .. v.slushname .. " Needed: " .. v.cupname,
			params = {
				event = "CL-BeanMachine:client:lemonslush",
				args = {
					
				}
			}
		}
	end
    LemonSlushsMenu[#LemonSlushsMenu+1] = {
        header = "⬅ Go Back",
        params = {
			event = "CL-BeanMachine:SlushsMenu"
        }
    }
    exports['qb-menu']:openMenu(LemonSlushsMenu)
end)

RegisterNetEvent("CL-BeanMachine:SlushsOrangeMenu", function()
    local OrangeSlushsMenu = {
        {
            header = "Orange Slushs",
            isMenuHeader = true,
        }
    }
	for k, v in pairs(Config.OrangeSlushs) do
		OrangeSlushsMenu[#OrangeSlushsMenu+1] = {
			header = v.slushname,
			txt = "Make: " .. v.slushname .. " Needed: " .. v.cupname,
			params = {
				event = "CL-BeanMachine:client:OrangeSlushie",
				args = {
				
				}
			}
		}
	end
    OrangeSlushsMenu[#OrangeSlushsMenu+1] = {
        header = "⬅ Go Back",
        params = {
			event = "CL-BeanMachine:SlushsMenu"
        }
    }
    exports['qb-menu']:openMenu(OrangeSlushsMenu)
end)
RegisterNetEvent("CL-BeanMachine:FirstCoffeeMenu", function()
    local FirstCoffeeMenu = {
        {
            header = "Frappuccino Coffee's",
            isMenuHeader = true,
        }
    }
	FirstCoffeeMenu[#FirstCoffeeMenu+1] = {
		header = "<img src=https://cdn.discordapp.com/attachments/926465631770005514/963452543512506398/Untitled-2.png width=30px> ".." ┇ Cloud Cafe",
		txt = "Ingredients: 1X High Coffee Glass 1X Milk 1X Coffee Beans 1X Whipped Cream",
        params = {
			event = "CL-BeanMachine:client:CloudCafe",
			args = {
			}
        }
    }
	FirstCoffeeMenu[#FirstCoffeeMenu+1] = {
		header = "<img src=https://cdn.discordapp.com/attachments/926465631770005514/963446572593582100/unknown.png width=30px> ".."  ┇ Strawberry Cream Frappuccino",
		txt = "Ingredients: 1X High Coffee Glass 1X Strawberrys 1X Milk 1X Coffee Beans 1X Whipped Cream",
        params = {
			event = "CL-BeanMachine:client:StrawberryCreamFrap",
			args = {			
			}
        }
    }
	FirstCoffeeMenu[#FirstCoffeeMenu+1] = {
		header = "<img src=https://cdn.discordapp.com/attachments/926465631770005514/963446621809561620/unknown.png width=30px> ".." ┇ Java Chip Frappuccino",
		txt = "Ingredients: 1X High Coffee Glass 1X Milk 1X Coffee Beans 1X Whipped Cream",
        params = {
			event = "CL-BeanMachine:client:JavaChipFrap",
			args = {

			}
        }
    }
	FirstCoffeeMenu[#FirstCoffeeMenu+1] = {
        header = "<img src=https://cdn.discordapp.com/attachments/926465631770005514/963446803766853662/unknown.png width=30px> ".." ┇ Hot Choc",
		txt = "Ingredients: 1X Coffee Glass 1X Milk 1X Coffee Beans 1X Whipped Cream 1X Hot Chocolate Powder.",
        params = {
			event = "CL-BeanMachine:client:HotChoc",
			args = {
				
			}        
		}
    }
	FirstCoffeeMenu[#FirstCoffeeMenu+1] = {
        header = "<img src=https://cdn.discordapp.com/attachments/930069494066475008/945394895328268419/caremel_frappucino.png width=30px> ".." ┇ Caramel Frappucino",
		txt = "Ingredients: 1X High Coffee Glass 1X Milk 1X Coffee Beans 1X Whipped Cream 1X Caramel Syrup",
        params = {
			event = "CL-BeanMachine:client:Caramelfrap",
			args = {
				
			}        
		}
    }
    FirstCoffeeMenu[#FirstCoffeeMenu+1] = {
        header = "⬅ Close",
        params = {
			event = "qb-menu:client:closemenu"
        }
    }
    exports['qb-menu']:openMenu(FirstCoffeeMenu)
end)

RegisterNetEvent("CL-BeanMachine:SecondCoffeeMenu", function()
    local SecondCoffeeMenu = {
        {
            header = "Latte And Espresso Coffee's",
            isMenuHeader = true,
        }
    }
	SecondCoffeeMenu[#SecondCoffeeMenu+1] = {
		header = "<img src=https://cdn.discordapp.com/attachments/926465631770005514/963446660959199362/unknown.png width=30px> ".." ┇ Honey Hazelnut Oat Latte",
		txt = "Ingredients: 1X Coffee Glass 1X Milk 1X Coffee Beans 1X Honey",
        params = {
			event = "CL-BeanMachine:client:HoneyHazelnutOatLatte",
			args = {
			
			}           
		}
    }
	SecondCoffeeMenu[#SecondCoffeeMenu+1] = {
		header = "<img src=https://cdn.discordapp.com/attachments/930069494066475008/945394893474398238/cold_brew_latte.png width=30px> ".." ┇ Cold Brew Latte",
		txt = "Ingredients: 1X High Coffee Glass 1X Milk 1X Coffee Beans 1X Ice",
        params = {
			event = "CL-BeanMachine:client:ColdBrew",
			args = {
				
			}           
		}
    }
	SecondCoffeeMenu[#SecondCoffeeMenu+1] = {
		header = "<img src=https://cdn.discordapp.com/attachments/930069494066475008/945394940282798201/strawberry_vanilla_oat_latte.png width=30px> ".." ┇ Strawberry Vanilla Oat Latte",
		txt = "Ingredients: 1X Coffee Glass 1X Milk 1X Coffee Beans 1X Strawberry",
        params = {
			event = "CL-BeanMachine:client:StrawberryVanillaOatLatte",
			args = {
				
			}           
		}
    }
	SecondCoffeeMenu[#SecondCoffeeMenu+1] = {
		header = "<img src=https://cdn.discordapp.com/attachments/926465631770005514/963446465416552448/unknown.png width=30px> ".." ┇ Iced Caffe Latte",
		txt = "Ingredients: 1X High Coffee Glass 1X Ice 1X Milk 1X Coffee Beans",
        params = {
			event = "CL-BeanMachine:client:IcedCaffeLatte",
			args = {
				
			}           
		}
    }
	SecondCoffeeMenu[#SecondCoffeeMenu+1] = {
		header = "<img src=https://cdn.discordapp.com/attachments/926465631770005514/963446773735637062/unknown.png width=30px> ".." ┇ Espresso",
		txt = "Ingredients: 1X Espresso Coffee Glass 1X Milk 1X Coffee Beans",
        params = {
			event = "CL-BeanMachine:client:Espresso",
			args = {
				
			}           
		}
    }
	SecondCoffeeMenu[#SecondCoffeeMenu+1] = {
		header = "<img src=https://cdn.discordapp.com/attachments/926465631770005514/963446697059553351/unknown.png width=30px> ".." ┇ Espresso Macchiato",
		txt = "Ingredients: 1X Espresso Coffee Glass 1X Milk 1X Coffee Beans",
        params = {
			event = "CL-BeanMachine:client:EspressoMacchiato",
			args = {
				coffeeevent = "EspressoMacchiato",
				progressbartext = Config.Locals["EspressoMacchiatoProgressBar"]["Txt"],
				progressbartime = Config.Locals["EspressoMacchiatoProgressBar"]["Time"],
				item1 = "bespressocoffeecup",	
				item2 = "bmilk",
				item3 = "bcoffeebeans",
				recieveitem = "bespressomacchiato",
			}            
		}
    }
    SecondCoffeeMenu[#SecondCoffeeMenu+1] = {
        header = "⬅ Close",
        params = {
			event = "qb-menu:client:closemenu",
        }
    }
    exports['qb-menu']:openMenu(SecondCoffeeMenu)
end)

RegisterNetEvent("CL-BeanMachine:BeansMenu", function()
	QBCore.Functions.TriggerCallback('CL-BeanMachine:CheckDuty', function(result)
        if result then
			local BeansMenu = {
				{
					header = "Coffee Beans",
					isMenuHeader = true,
				}
			}
			for k, v in pairs(Config.Beans) do
				BeansMenu[#BeansMenu+1] = {
					header = v.beanimage.. " ┇ " .. v.beanname,
					txt = "Grab: " .. v.beanname,
					params = {
						event = "CL-BeanMachine:client:Beans",
						args = {
							
						}
					}
				}
			end
			BeansMenu[#BeansMenu+1] = {
				header = "⬅ Close",
				params = {
					event = "qb-menu:client:closemenu",
				}
			}
			exports['qb-menu']:openMenu(BeansMenu)
		else
            QBCore.Functions.Notify("You must be on duty.", "error")
        end
    end)
end)



----------------
----Functions
----------------
function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

function ShowHelpNotification(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function LoadModel(model)
	while not HasModelLoaded(model) do
		RequestModel(model)
		Wait(10)
	end
end

function SlushEffect()
	local Player = PlayerPedId()
	StartScreenEffect("MP_Celeb_Win", 3.0, 0)
	SetPedToRagdollWithFall(Player, 1500, 1000, 1, GetEntityForwardVector(Player), 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    Citizen.Wait(5000)
    StopScreenEffect("MP_Celeb_Win")
end

function CoffeeEffect()
	local startStamina = 4
    SetRunSprintMultiplierForPlayer(PlayerId(), 1.80)
    while startStamina > 0 do
        if math.random(5, 100) < 10 then
            RestorePlayerStamina(PlayerId(), 1.0)
        end
        startStamina = startStamina - 1
    end
    startStamina = 0
    SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
end

function CloseMenu()
    exports['qb-menu']:closeMenu()
end

RegisterCommand('removestuckprop', function()
    for k, v in pairs(GetGamePool('CObject')) do
        if IsEntityAttachedToEntity(PlayerPedId(), v) then
            SetEntityAsMissionEntity(v, true, true)
            DeleteObject(v)
            DeleteEntity(v)
		end
    end
end)