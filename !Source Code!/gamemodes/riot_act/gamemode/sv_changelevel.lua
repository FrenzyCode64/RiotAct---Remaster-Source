
CreateConVar("basic_campaign_enableTransitionLogging", 1)

local BasicCampaign_ClassBlacklist = {
	["physical_bullet"] = {
		["basic_campaign"] = true
	},
	["env_projectedtexture"] = {
		["basic_campaign"] = function(ent)
			if ent:GetNWBool("TPF_IsFlashlight", false) then
				return true
			end
			
			return false
		end
	},
	["basic_cmpn_trigger_changelevel"] = {
		["basic_campaign"] = true
	},
}

BasicCampaign = {}

function BasicCampaign.AddClassNoSave(class, key, condition)
	if (not BasicCampaign_ClassBlacklist[class]) then
		BasicCampaign_ClassBlacklist[class] = {}
	end
	
	if (BasicCampaign_ClassBlacklist[class][key] == nil) then
		BasicCampaign_ClassBlacklist[class][key] = condition
	else
		print("Basic Campaign - Cannot add save exclusion. A save exclusion with the same name already exists.")
		
		return
	end
end

function BasicCampaign.RemoveClassNoSave(class, key)
	if (not BasicCampaign_ClassBlacklist[class]) then
		print("Basic Campaign - Cannot remove save exclusion. A save exclusion under this class does not exist.")
		
		return
	elseif (BasicCampaign_ClassBlacklist[class][key] == nil) then
		print("Basic Campaign - Cannot remove save exclusion. A save exclusion under this key does not exist.")
		
		return
	end
	
	BasicCampaign_ClassBlacklist[class][key] = nil
	
	if (#BasicCampaign_ClassBlacklist[class] <= 0) then
		BasicCampaign_ClassBlacklist[class] = nil
	end
end

function BasicCampaign.ClassNoSaveExists(class, key)
	if (not BasicCampaign_ClassBlacklist[class]) then
		return true
	elseif (BasicCampaign_ClassBlacklist[class][key] == nil) then
		return true
	end
	
	return false
end

function BasicCampaign.GetClassNoSave(class, key)
	if (not BasicCampaign_ClassBlacklist[class]) then
		print("Basic Campaign - Cannot get save exclusion. A save exclusion under this class does not exist.")
		
		return
	elseif (BasicCampaign_ClassBlacklist[class][key] == nil) then
		print("Basic Campaign - Cannot get save exclusion. A save exclusion under this key does not exist.")
	end
	
	return BasicCampaign_ClassBlacklist[class][key]
end

local BasicCampaign_SavedEnts = {}

local BasicCampaign_LoadedEnts

local BasicCampaign_CanLoad = false

local BasicCampaign_ChangingLevel = false

local BasicCampaign_CrouchingPlayers = {}

local function SaveGame()
	if BasicCampaign_SavedEnts then
		local entTable = {}
		
		entTable.Map = game.GetMap()
		
		local refProp = ents.FindByClass("basic_cmpn_referenceprop")[1]
		
		if (not refProp) then return end
		
		local excludedEnts = {}
		
		for k, v in pairs(ents.GetAll()) do
			if v:IsValid() then
				if ((not v:IsWorld()) and (not v:IsPlayer())) then
					local class = v:GetClass()
					
					if BasicCampaign_ClassBlacklist[class] then
						local whitelist = true
						
						for i, j in pairs(BasicCampaign_ClassBlacklist[class]) do
							if j then
								if isfunction(j) then
									if j(v) then
										whitelist = false
										
										break
									end
								else
									whitelist = false
									
									break
								end
							end
						end
						
						if (not whitelist) then
							excludedEnts[v:EntIndex()] = true
						end
					end
				end
			end
		end
		
		local nonPlayerTable = {}
		
		for k, v in pairs(BasicCampaign_SavedEnts) do
			if (not v:IsPlayer()) then
				table.insert(nonPlayerTable, v)
			end
		end
		
		local playerTable = {}
		
		for k, v in pairs(BasicCampaign_SavedEnts) do
			if v:IsPlayer() then
				table.insert(playerTable, v)
			end
		end
		
		entTable.NonPlayers = {}
		entTable.Players = {}
		entTable.AccountedVehicles = {}
		entTable.ExcludedEnts = excludedEnts
		
		for k, v in ipairs(nonPlayerTable) do
			local saveTable = {}
			
			saveTable.Entity = v:EntIndex()
			
			local validPhys = v:GetPhysicsObject():IsValid()
			
			local isVehicle = v:IsVehicle()
			
			saveTable.IsVehicle = isVehicle
			
			if isVehicle then
				entTable.AccountedVehicles[v:EntIndex()] = true
			end
			
			if validPhys then
				local locPos, locAngles = WorldToLocal(v:GetPos(), v:GetAngles(), refProp:GetPos(), refProp:GetAngles())
				local locVel, _ = WorldToLocal(v:GetVelocity(), Angle(0, 0, 0), Vector(0, 0, 0), refProp:GetAngles())
				
				saveTable.LocalPos = locPos
				saveTable.LocalAngles = locAngles
				saveTable.LocalVel = locVel
				saveTable.Angvel = v:GetPhysicsObject():GetAngleVelocity()
				
				local physCount = v:GetPhysicsObjectCount()
				
				saveTable.PhysObjects = {}
				
				for i = 1, physCount do
					local currPhysTable = {}
					local currPhys = v:GetPhysicsObjectNum(i - 1)
					
					local locPos, locAngles = WorldToLocal(currPhys:GetPos(), currPhys:GetAngles(), refProp:GetPos(), refProp:GetAngles())
					local locVel, _ = WorldToLocal(currPhys:GetVelocity(), Angle(0, 0, 0), Vector(0, 0, 0), refProp:GetAngles())
					
					currPhysTable.LocalPos = locPos
					currPhysTable.LocalAngles = locAngles
					currPhysTable.LocalVel = locVel
					currPhysTable.Angvel = currPhys:GetAngleVelocity()
					
					table.insert(saveTable.PhysObjects, currPhysTable)
				end
			else
				local locPos, locAngles = WorldToLocal(v:GetPos(), v:GetAngles(), refProp:GetPos(), refProp:GetAngles())
				
				saveTable.LocalPos = locPos
				saveTable.LocalAngles = locAngles
			end
			
			table.insert(entTable.NonPlayers, saveTable)
		end
		
		for k, v in ipairs(playerTable) do
			if v:Alive() then
				local saveTable = {}
				
				local locPos, locAngles = WorldToLocal(v:GetPos(), v:EyeAngles(), refProp:GetPos(), refProp:GetAngles())
				local locVel, _ = WorldToLocal(v:GetVelocity(), Angle(0, 0, 0), Vector(0, 0, 0), refProp:GetAngles())
				
				saveTable.LocalPos = locPos
				saveTable.LocalAngles = locAngles
				saveTable.LocalVel = locVel
				saveTable.Health = v:Health()
				saveTable.Armor = v:Armor()
				
				if v:GetActiveWeapon():IsValid() then
					saveTable.ActiveWeapon = v:GetActiveWeapon():GetClass()
				end
				
				if v.BasicCampaign_PrevWeapon then
					saveTable.PrevWeapon = v.BasicCampaign_PrevWeapon
				end
				
				saveTable.Crouching = v:Crouching()
				saveTable.FlashlightIsOn = v:FlashlightIsOn()
				
				local plyWeapons = v:GetWeapons()
				
				saveTable.Weapons = {}
				saveTable.Ammo = {}
				
				for j, wep in pairs(plyWeapons) do
					local currWeaponTable = {}
					
					currWeaponTable.Class = wep:GetClass()
					
					currWeaponTable.PrimAmmoType = wep:GetPrimaryAmmoType()
					currWeaponTable.SecAmmoType = wep:GetSecondaryAmmoType()
					
					currWeaponTable.Clip1 = wep:Clip1()
					currWeaponTable.Clip2 = wep:Clip2()
					
					local currPrimAmmo = {}
					
					currPrimAmmo.Type = currWeaponTable.PrimAmmoType
					currPrimAmmo.Count = v:GetAmmoCount(currWeaponTable.PrimAmmoType)
					
					local currSecAmmo = {}
					
					currSecAmmo.Type = currWeaponTable.SecAmmoType
					currSecAmmo.Count = v:GetAmmoCount(currWeaponTable.SecAmmoType)
					
					table.insert(saveTable.Weapons, currWeaponTable)
					table.insert(saveTable.Ammo, currPrimAmmo)
					table.insert(saveTable.Ammo, currSecAmmo)
				end
				
				local plyVehicle = v:GetVehicle()
				
				if plyVehicle:IsValid() then
					local vehicleTable = {}
					
					vehicleTable.Entity = plyVehicle:EntIndex()
					
					local locPos, locAngles = WorldToLocal(plyVehicle:GetPos(), plyVehicle:GetAngles(), refProp:GetPos(), refProp:GetAngles())
					local locVel, _ = WorldToLocal(plyVehicle:GetVelocity(), Angle(0, 0, 0), Vector(0, 0, 0), refProp:GetAngles())
					
					vehicleTable.LocalPos = locPos
					vehicleTable.LocalAngles = locAngles
					vehicleTable.LocalVel = locVel
					vehicleTable.Angvel = plyVehicle:GetPhysicsObject():GetAngleVelocity()
					
					local physCount = plyVehicle:GetPhysicsObjectCount()
					
					vehicleTable.PhysObjects = {}
					
					for i = 1, physCount do
						local currPhysTable = {}
						local currPhys = plyVehicle:GetPhysicsObjectNum(i - 1)
						
						local locPos, locAngles = WorldToLocal(currPhys:GetPos(), currPhys:GetAngles(), refProp:GetPos(), refProp:GetAngles())
						local locVel, _ = WorldToLocal(currPhys:GetVelocity(), Angle(0, 0, 0), Vector(0, 0, 0), refProp:GetAngles())
						
						currPhysTable.LocalPos = locPos
						currPhysTable.LocalAngles = locAngles
						currPhysTable.LocalVel = locVel
						currPhysTable.Angvel = currPhys:GetAngleVelocity()
						
						table.insert(vehicleTable.PhysObjects, currPhysTable)
					end
					
					saveTable.Vehicle = vehicleTable
				end
				
				table.insert(entTable.Players, saveTable)
			end
		end
		
		if (not file.IsDir("basic_campaign", "DATA")) then
			file.CreateDir("basic_campaign")
		end
		
		local transitionData = util.TableToJSON(entTable, true)
		
		file.Write("basic_campaign/transition_data.txt", transitionData)
		
		if (GetConVarNumber("basic_campaign_enableTransitionLogging") != 0) then
			file.Write("basic_campaign/transition_data_log.txt", transitionData)
		end
	end
end

local function SetEntPos(ent, pos)
	if (not HL2SaveSys) then
		ent:SetPos(pos)
	else
		ent:HL2SaveSys_SetPos_Override(pos)
	end
end

local function Initialize()
	local entTable
	if file.Exists("basic_campaign/transition_data.txt", "DATA") then
		entTable = util.JSONToTable(file.Read("basic_campaign/transition_data.txt", "DATA"))
		
		file.Delete("basic_campaign/transition_data.txt")
	end
	
	if entTable then
		local excludedEnts = entTable.ExcludedEnts
		
		for k, v in pairs(excludedEnts) do
			if v then
				local ent = ents.GetByIndex(k)
				
				if ent:IsValid() then
					if ((not ent:IsWorld()) and (not ent:IsPlayer())) then
						local class = ent:GetClass()
						
						if BasicCampaign_ClassBlacklist[class] then
							local whitelist = true
							
							for i, j in pairs(BasicCampaign_ClassBlacklist[class]) do
								if j then
									whitelist = false
									
									break
								end
							end
							
							if (not whitelist) then
								ent:Remove()
							end
						end
					end
				end
			end
		end
		
		BasicCampaign_LoadedEnts = entTable
	end
end

local function Think()
	if BasicCampaign_CanLoad then
		local entTable = BasicCampaign_LoadedEnts
		
		if entTable then
			local ReferenceProp = ents.FindByClass("basic_cmpn_referenceprop")[1] or NULL
			
			if ReferenceProp:IsValid() then
				for k, v in pairs(entTable.NonPlayers) do
					local currEnt = (ents.GetByIndex(v.Entity) or NULL)
					
					if currEnt:IsValid() then
						if currEnt:GetPhysicsObject():IsValid() then
							local globalPos, globalAngles = LocalToWorld(v.LocalPos, v.LocalAngles, ReferenceProp:GetPos(), ReferenceProp:GetAngles())
							local globalVel, _ = LocalToWorld(v.LocalVel, Angle(0, 0, 0), Vector(0, 0, 0), ReferenceProp:GetAngles())
							
							currEnt:SetPos(globalPos)
							currEnt:SetAngles(globalAngles)
							currEnt:SetVelocity(globalVel)
							currEnt:GetPhysicsObject():AddAngleVelocity(v.Angvel - currEnt:GetPhysicsObject():GetAngleVelocity())
							
							for j, phys in pairs(v.PhysObjects) do
								local currPhys = currEnt:GetPhysicsObjectNum(j - 1)
								
								if (currPhys and currPhys:IsValid()) then
									local globalPos, globalAngles = LocalToWorld(phys.LocalPos, phys.LocalAngles, ReferenceProp:GetPos(), ReferenceProp:GetAngles())
									local globalVel, _ = LocalToWorld(phys.LocalVel, Angle(0, 0, 0), Vector(0, 0, 0), ReferenceProp:GetAngles())
									
									currPhys:SetPos(globalPos)
									currPhys:SetAngles(globalAngles)
									currPhys:SetVelocityInstantaneous(globalVel)
									currPhys:AddAngleVelocity(phys.Angvel - currPhys:GetAngleVelocity())
								end
							end
						else
							local globalPos, globalAngles = LocalToWorld(v.LocalPos, v.LocalAngles, ReferenceProp:GetPos(), ReferenceProp:GetAngles())
							
							currEnt:SetPos(globalPos)
							currEnt:SetAngles(globalAngles)
						end
					end
				end
				
				local allPlayers = player.GetAll()
				
				for k, v in pairs(entTable.Players) do
					local ply = allPlayers[k]
					
					if ply then
						local globalPos, globalAngles = LocalToWorld(v.LocalPos, v.LocalAngles, ReferenceProp:GetPos(), ReferenceProp:GetAngles())
						local globalVel, _ = LocalToWorld(v.LocalVel, Angle(0, 0, 0), Vector(0, 0, 0), ReferenceProp:GetAngles())
						
						SetEntPos(ply, globalPos)
						ply:SetEyeAngles(globalAngles)
						ply:SetVelocity(globalVel - ply:GetVelocity())
						ply:SetHealth(v.Health)
						ply:SetArmor(v.Armor)
						
						if v.Crouching then
							BasicCampaign_CrouchingPlayers[k] = true
						end
						
						if v.FlashlightIsOn then
							if (not ply:FlashlightIsOn()) then
								ply:Flashlight(true)
							end
						else
							if ply:FlashlightIsOn() then
								ply:Flashlight(false)
							end
						end
						
						ply:StripWeapons()
						
						for j, wep in pairs(v.Weapons) do
							local currWeapon = ply:Give(wep.Class, true)
							
							currWeapon:SetClip1(wep.Clip1)
							currWeapon:SetClip2(wep.Clip2)
						end
						
						for j, ammo in pairs(v.Ammo) do
							ply:SetAmmo(ammo.Count, ammo.Type)
						end
						
						if v.PrevWeapon then
							ply:SelectWeapon(v.PrevWeapon)
						end
						
						if v.ActiveWeapon then
							ply:SelectWeapon(v.ActiveWeapon)
						end
						
						if v.PrevWeapon then
							ply.BasicCampaign_PrevWeapon = v.PrevWeapon
						end
						
						if v.Vehicle then
							local plyVehicle
							
							if v.Vehicle.Entity then
								plyVehicle = (ents.GetByIndex(v.Vehicle.Entity) or NULL)
							end
							
							if plyVehicle:IsValid() then
								if (not entTable.AccountedVehicles[v.Vehicle.Entity]) then
									local globalPos, globalAngles = LocalToWorld(v.Vehicle.LocalPos, v.Vehicle.LocalAngles, ReferenceProp:GetPos(), ReferenceProp:GetAngles())
									local globalVel, _ = LocalToWorld(v.Vehicle.LocalVel, Angle(0, 0, 0), Vector(0, 0, 0), ReferenceProp:GetAngles())
									
									plyVehicle:SetPos(globalPos)
									plyVehicle:SetAngles(globalAngles)
									plyVehicle:SetVelocity(globalVel)
									plyVehicle:GetPhysicsObject():AddAngleVelocity(v.Vehicle.Angvel - plyVehicle:GetPhysicsObject():GetAngleVelocity())
									
									for j, phys in pairs(v.Vehicle.PhysObjects) do
										local currPhys = plyVehicle:GetPhysicsObjectNum(j - 1)
										
										if (currPhys and currPhys:IsValid()) then
											local globalPos, globalAngles = LocalToWorld(phys.LocalPos, phys.LocalAngles, ReferenceProp:GetPos(), ReferenceProp:GetAngles())
											local globalVel, _ = LocalToWorld(phys.LocalVel, Angle(0, 0, 0), Vector(0, 0, 0), ReferenceProp:GetAngles())
											
											currPhys:SetPos(globalPos)
											currPhys:SetAngles(globalAngles)
											currPhys:SetVelocityInstantaneous(globalVel)
											currPhys:AddAngleVelocity(phys.Angvel - currPhys:GetAngleVelocity())
										end
									end
								end
							end
						end
					end
				end
				
				for k, v in pairs(ents.FindByClass("basic_cmpn_referenceprop")) do
					v:Remove()
				end
				
				BasicCampaign_CanLoad = false
			end
		end
	end
	
	for id, ent in pairs(ents.GetAll()) do
		if (ent:GetClass() == "trigger_changelevel") then
			local basicCmpnTrigger = (ent.BasicCampaign_Trigger or NULL)
			
			if (not basicCmpnTrigger:IsValid()) then
				ent:SetTrigger(false)
				
				local mins, maxs = ent:GetCollisionBounds()
				
				local newTrigger = ents.Create("basic_cmpn_trigger_changelevel")
				
				newTrigger:SetupTrigger(ent:GetPos(), ent:GetAngles(), (mins - ent:GetPos()), (maxs - ent:GetPos()), true)
				
				newTrigger.BasicCampaign_OrigTrigger = ent
				
				ent.BasicCampaign_Trigger = newTrigger
			end
		end
	end
	
	for id, ent in pairs(ents.GetAll()) do
		if (ent:GetClass() == "basic_cmpn_trigger_changelevel") then
			if (not ent.BasicCampaign_OrigTrigger) then
				ent:Remove()
			elseif (not ent.BasicCampaign_OrigTrigger:IsValid()) then
				ent:Remove()
			end
		end
	end
end

function BasicCampaign_ChangeLevel(trigger, objects)
	if (not (trigger and istable(objects))) then return end
	if (not trigger:IsValid()) then return end
	
	if BasicCampaign_ChangingLevel then return end
	
	BasicCampaign_ChangingLevel = true
	
	for k, v in pairs(ents.FindByClass("basic_cmpn_referenceprop")) do
		v:Remove()
	end
	
	local mins, maxs = trigger:GetCollisionBounds()
	
	local refProp = ents.Create("basic_cmpn_referenceprop")
	refProp:SetPos((mins + maxs) / 2)
	refProp:SetAngles(trigger:GetAngles())
	refProp:Spawn()
	refProp:Activate()
	
	BasicCampaign_SavedEnts = objects
	
	SaveGame()
end

local function PlayerTick(ply, move)
	local playerID = 1
	
	for k, v in pairs(player.GetAll()) do
		if (v == ply) then
			playerID = k
			break
		end
	end
	
	if BasicCampaign_CrouchingPlayers[playerID] then
		if (not move:KeyDown(IN_DUCK)) then
			move:AddKey(IN_DUCK)
		end
		
		BasicCampaign_CrouchingPlayers[playerID] = nil
	end
end

local function VehicleMove(ply, vehicle, move)
	local playerID = 1
	
	for k, v in pairs(player.GetAll()) do
		if (v == ply) then
			playerID = k
			break
		end
	end
	
	BasicCampaign_CrouchingPlayers[playerID] = nil
end

local function PlayerSwitchWeapon(ply, oldWeapon, newWeapon)
	if oldWeapon:IsValid() then
		ply.BasicCampaign_PrevWeapon = oldWeapon:GetClass()
	end
end

local function PlayerSpawn(ply)
	BasicCampaign_CanLoad = true
end

hook.Add("Initialize", "BasicCampaign_Initialize", Initialize)
hook.Add("Think", "BasicCampaign_Think", Think)
hook.Add("PlayerTick", "BasicCampaign_PlayerTick", PlayerTick)
hook.Add("VehicleMove", "BasicCampaign_VehicleMove", VehicleMove)
hook.Add("PlayerSwitchWeapon", "BasicCampaign_PlayerSwitchWeapon", PlayerSwitchWeapon)
hook.Add("PlayerSpawn", "BasicCampaign_PlayerSpawn", PlayerSpawn)
