hook.Add( "CanPlayerSuicide", "AllowOwnerSuicide", function( ply )
	return false
end )

hook.Add("EntityTakeDamage", "IntelligenceLastTakeDamageTime", function(InTargetEntity, InDamageInfo)

	if InTargetEntity:IsPlayer() then

		InTargetEntity.LastTakeDamage = CurTime()
	end
end)

timer.Create("IntelligenceHealthRegeneration", 0.5, 0, function()

	ID_DoForAllPlayers(function(InPlayer)

		if InPlayer:Alive() and CurTime() - (InPlayer.LastTakeDamage or 0.0) > 5.0 and InPlayer:Health() < 80 then

			InPlayer:SetHealth(InPlayer:Health() + 1)
		end
	end)
end)

function ID_DoForAllPlayers(InFunction)

	local AllPlayers = player.GetAll()

	for Index, SamplePlayer in ipairs(AllPlayers) do

		if IsValid(SamplePlayer) then

			InFunction(SamplePlayer)
		end
	end
end