if not string.StartWith(game.GetMap(), "ra") then return
end

hook.Add("OnEntityCreated", "IntelligenceCombineSpecialSpawns", function(InEntity)

	timer.Simple(0.1, function()

		if not IsValid(InEntity) then

			return
		end

		local EntityClass = InEntity:GetClass()

		local EntityName = InEntity:GetName()

		if EntityClass == "npc_combine_s" then

		local CombineSkin = InEntity:GetSkin()

		local CombineOldModel = InEntity:GetModel()

         if CombineOldModel == "models/combine_soldier_prisonguard.mdl" and CombineSkin == 1 then

			InEntity:SetModel("models/combine_super_shotgunner.mdl")

		end

		if CombineOldModel == "models/combine_soldier_prisonguard.mdl" and CombineSkin == 0 then

			local RandomUniform = math.random(1, 8)

			if (RandomUniform == 1) then
				InEntity:SetModel("models/combine_advisor_guard_armored.mdl")
			end
		end

		if CombineOldModel == "models/combine_super_soldier.mdl" then
			InEntity:SetModel("models/combine_advisor_guard_armored.mdl")
		end

		end

		if EntityClass == "npc_metropolice" then
			InEntity:SetModel("models/police.mdl")
		end

		if EntityClass == "item_suit" then
			InEntity:SetModel("models/items/vest.mdl")
		end

	end)
end)