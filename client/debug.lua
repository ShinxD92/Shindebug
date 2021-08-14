

local showdebug = false

ESX = exports['es_extended']:getSharedObject()

function Mytext3d(coords, text,scale,ancho)
	local x,y,z = coords.x, coords.y, coords.z
    SetDrawOrigin(coords)
    SetTextScale(scale, scale)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextDropshadow(0, 0, 0, 0, 155)
    SetTextEdge(1, 0, 0, 0, 250)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry('STRING')
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(0.0, 0.0)
    DrawRect(0.0, 0.0125, 0.025 + text:gsub('~.-~', ''):len() / ancho, 0.04, 41, 0, 41, 120)
    ClearDrawOrigin()
end

RegisterCommand('activedebug', function()
	if showdebug == false then
		showdebug = true
	else
		showdebug = false
	end
	print(showdebug)
end)



RegisterKeyMapping('+coords_at_pointx', 'debug print', 'keyboard', 'i')

RegisterCommand('+coords_at_pointx', function()
    local playerPed = PlayerPedId()
    local hit, coords, entity = RayCastGamePlayCamera(20.0)
	local coordmyX, coordmyY, coordmyZ = table.unpack(GetEntityCoords(PlayerPedId()))
    if hit and coords then
     
		TriggerServerEvent("LRP-debug:logs", "debug", "Debug Print MY ENTITY", "blue","--//// PRINT MY ENTITY ///--\n\n".."MODEL: "..GetEntityModel(PlayerPedId()).."\nCOORDS:"..GetEntityCoords(PlayerPedId()).."\nHEADING: "..GetEntityHeading(entity).."\nHASHKEY: "..GetHashKey(entity))

        if entity and DoesEntityExist(entity) then
            local coords = GetEntityCoords(entity)
			local coordobjsX, coordobjsY, coordobjsZ = table.unpack(GetEntityCoords(entity))


			if #(coords) > 0 then
				SetEntityDrawOutline(entity, true)
				print("isNetworked:",NetworkGetEntityIsNetworked(entity))
				TriggerServerEvent("LRP-debug:logs", "debug", "Debug Print OBJ", "red","--//// PRINT OBJECT ///--\n\n".."MODEL: "..GetEntityModel(entity).."\nCOORDS: "..GetEntityCoords(entity).."\n HEADING: "..GetEntityHeading(entity).."\nHASHKEY: "..GetHashKey(entity))

            end

        end
    end
end, false)



reduceformat = function(value, numDecimalPlaces)
	if numDecimalPlaces then
		local power = 10^numDecimalPlaces
		return math.floor((value * power) + 0.5) / (power)
	else
		return math.floor(value + 0.5)
	end
end
	
Citizen.CreateThread(function()
	
	sleep = true
	while true do
		if showdebug  then
			sleep = false
			local mycoordshin = GetEntityCoords(PlayerPedId())
			local entityobj = ESX.Game.GetClosestObject()
			local entityobjcoord = GetEntityCoords(entityobj)
			local shinh =  GetEntityHeading(PlayerPedId())
			local shinx, shiny, shinz = table.unpack(mycoordshin)
			local nearped = getNPC()
			local veh = GetVehicle()

				Mytext3d(mycoordshin + vector3(0.0, 0.0, 0.9),"X:["..shinx.."] - Y:["..shiny.."] - Z:["..shinz.."] - H:["..shinh.."]",0.52,230)

				if #(mycoordshin - entityobjcoord)< 1.7 then 
					local objhash = GetEntityModel(entityobj)
					local objshinx, objshiny, objshinz = table.unpack(entityobjcoord)
					local objhead =  GetEntityHeading(entityobj)
					local distdraw = #(mycoordshin - entityobjcoord)
					local asd23f = GetDisplayNameFromVehicleModel(objhash)
					local entityobj2 = ESX.Game.GetClosestObject()
		
					if IsEntityTouchingEntity(PlayerPedId(), ESX.Game.GetClosestObject()) then
						Mytext3d(entityobjcoord + vector3(0.0, 0.0, 0.177),"Obj Coords: X:["..objshinx.."] - Y:["..objshiny.."] - Z:["..objshinz.."]".." - H:["..objhead.."]",0.48,240)
						Mytext3d(entityobjcoord + vector3(0.0, 0.0, 0.32),"model: "..objhash .." - HashKey: "..GetHashKey(objhash).." - [en Contacto]",0.48,240)
					else
						Mytext3d(entityobjcoord + vector3(0.0, 0.0, 0.177),"Obj Coords: X:["..objshinx.."] - Y:["..objshiny.."] - Z:["..objshinz.."]".." - H:["..objhead.."]",0.48,240)
						Mytext3d(entityobjcoord + vector3(0.0, 0.0, 0.32),"model: "..objhash .." - HashKey: "..GetHashKey(objhash),0.48,240)
			
					end

					if distdraw < 1.5 then
						SetEntityDrawOutline(entityobj, true)
					else
						SetEntityDrawOutline(entityobj, false)
					end

				end

			if sleep then
				Wait(1000)
			end

		end
		Wait(3)
	end
end)

function RayCastGamePlayCamera(distance)
    local cameraRotation = GetGameplayCamRot()
    local cameraCoord = GetGameplayCamCoord()
    local direction = RotationToDirection(cameraRotation)
    local destination =
    {
        x = cameraCoord.x + direction.x * distance,
        y = cameraCoord.y + direction.y * distance,
        z = cameraCoord.z + direction.z * distance
    }
    local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, PlayerPedId(), 0))
    return b, c, e
end
function RotationToDirection(rotation)
    local adjustedRotation =
    {
        x = (math.pi / 180) * rotation.x,
        y = (math.pi / 180) * rotation.y,
        z = (math.pi / 180) * rotation.z
    }
    local direction =
    {
        x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        z = math.sin(adjustedRotation.x)
    }
    return direction
end
function getNPC()
    local playerped = PlayerPedId()
    local playerCoords = GetEntityCoords(playerped)
    local handle, ped = FindFirstPed()
    local success
    local rped = nil
    local distanceFrom

    repeat
        local pos = GetEntityCoords(ped)
        local distance = #(playerCoords - pos)
	
        if canPedBeUsed(ped) and distance < 5.0 and (distanceFrom == nil or distance < distanceFrom) then
            distanceFrom = distance
            rped = ped


	    	if IsEntityTouchingEntity(PlayerPedId(), ped) then
	    		Mytext3d(GetEntityCoords(ped),"Ped: " .. ped .. " Model: " .. GetEntityModel(ped) .. " Relationship HASH: " .. GetPedRelationshipGroupHash(ped).." [en Contacto]" ,0.48,240)
				SetEntityDrawOutline(ped, true)
			else
	    		Mytext3d(GetEntityCoords(ped),"Ped: " .. ped .. " Model: " .. GetEntityModel(ped) .. " Relationship HASH: " .. GetPedRelationshipGroupHash(ped),0.48,240)
				SetEntityDrawOutline(ped, false)
			end
      
        end
        success, ped = FindNextPed(handle)
    until not success
    EndFindPed(handle)
    return rped
end

function canPedBeUsed(ped)
    if ped == nil then
        return false
    end
    if ped == PlayerPedId() then
        return false
    end
    if not DoesEntityExist(ped) then
        return false
    end
    return true
end

function GetVehicle()

    local playerped = PlayerPedId()
    local playerCoords = GetEntityCoords(playerped)
    local handle, ped = FindFirstVehicle()
    local success
    local rped = nil
    local distanceFrom
    repeat
        local pos = GetEntityCoords(ped)
        local distance = #(playerCoords - pos)
     
		if canPedBeUsed(ped) and distance < 5.0 and (distanceFrom == nil or distance < distanceFrom) then
            distanceFrom = distance
            rped = ped
	    	if IsEntityTouchingEntity(PlayerPedId(), ped) then
	    		Mytext3d(pos+ vector3(0,0,0 +1.0), "Veh: " .. ped .. " Model: " .. GetEntityModel(ped).." [en Contacto ]" .." " ,0.48,240)
				SetEntityDrawOutline(ped, true)
			else
	    		Mytext3d(pos + vector3(0,0,0 +1.0), "Veh: " .. ped .. " Model: " .. GetEntityModel(ped),0.48,240)
				SetEntityDrawOutline(ped, false)
			end
        end
		
        success, ped = FindNextVehicle(handle)
    until not success
    EndFindVehicle(handle)
    return rped
end
