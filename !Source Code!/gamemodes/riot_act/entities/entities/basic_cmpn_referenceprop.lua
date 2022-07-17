
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_entity"

if CLIENT then
	function ENT:Draw()
		return
	end
end

if (not SERVER) then return end

function ENT:Initialize()
	self:DrawShadow(false)
end

function ENT:Use( activator, caller )
	return
end

function ENT:Think()
end
