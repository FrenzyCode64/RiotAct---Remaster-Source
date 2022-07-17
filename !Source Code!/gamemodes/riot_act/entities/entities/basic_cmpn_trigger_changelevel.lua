
AddCSLuaFile()

ENT.Type			= "brush"
ENT.Base 			= "base_entity"

if (not SERVER) then return end

DEFINE_BASECLASS("base_entity")

function ENT:GetTouchingObjects()
	local entTable = {}
	
	for k, v in pairs(self.BasicCampaign_TouchingObjects) do
		if v:IsValid() then
			table.insert(entTable, v)
		end
	end
	
	return entTable
end

function ENT:OnTrigger()
	local objects = self:GetTouchingObjects()
	
	local accountedPlayers = 0
	
	for k, v in pairs(objects) do
		if v:IsValid() then
			if v:IsPlayer() then
				if v:Alive() then
					accountedPlayers = accountedPlayers + 1
				end
			elseif v:IsVehicle() then
				local driver = v:GetDriver()
				
				if driver:IsValid() then
					if driver:IsPlayer() then
						if driver:Alive() then
							accountedPlayers = accountedPlayers + 1
						end
					end
				end
				
				local accountedPassengers = {}
				local finished = false
				local currPassenger = 1
				
				while (not finished) do
					local passenger = v:GetPassenger(currPassenger)
					
					if (passenger:IsValid() and (not accountedPassengers[passenger])) then
						if passenger:IsPlayer() then
							if passenger:Alive() then
								accountedPlayers = accountedPlayers + 1
							end
						end
						
						accountedPassengers[passenger] = true
					else
						finished = true
					end
				end
			end
		end
	end
	
	if (accountedPlayers >= player.GetCount()) then
		BasicCampaign_ChangeLevel(self, objects)
		
		local targetTrigger = self.BasicCampaign_OrigTrigger or NULL
		
		if targetTrigger:IsValid() then
			targetTrigger:SetTrigger(true)
			
			self.Triggered = true
		end
	end
end

function ENT:Think()
	local targetTrigger = self.BasicCampaign_OrigTrigger or NULL
	
	if targetTrigger:IsFlagSet(FL_DONTTOUCH) then
		if (not self:IsFlagSet(FL_DONTTOUCH)) then
			self:AddFlags(FL_DONTTOUCH)
		end
	else
		if self:IsFlagSet(FL_DONTTOUCH) then
			self:RemoveFlags(FL_DONTTOUCH)
		end
	end
	
	if (not self.Triggered) then
		if targetTrigger:IsValid() then
			targetTrigger:SetTrigger(false)
		end
	else
		self.Triggered = false
	end
	
	self:NextThink(CurTime())
end

function ENT:StartTouch(entity)
	self.BasicCampaign_TouchingObjects[entity:EntIndex()] = entity
	
	if entity:IsPlayer() then
		self:OnTrigger()
	end
end

function ENT:Touch(entity)
end

function ENT:EndTouch(entity)
	self.BasicCampaign_TouchingObjects[entity:EntIndex()] = nil
end

function ENT:SetupTrigger(pos, ang, mins, maxs, spawn)
	self:SetPos(pos)
	self:SetAngles(ang)
	self:SetTrigger(true)
	
	if ((spawn == nil) or spawn) then
		self:Spawn()
	end
	
	self:SetCollisionBounds(mins, maxs)
end

function ENT:ResizeTriggerBox(mins, maxs)
	self:SetTrigger(true)
	self:SetCollisionBounds(mins, maxs)
end

function ENT:Initialize()
	BaseClass.Initialize(self)
	
	self:SetSolid(SOLID_BBOX)
	self:SetTrigger(true)
	self:SetNoDraw(true)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	
	self.BasicCampaign_TouchingObjects = {}
end
