if not string.StartWith(game.GetMap(), "ra") then return
end

local tab = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0.03,
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 1.2,
	["$pp_colour_colour"] = 2,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}
hook.Add("RenderScreenspaceEffects", "PostProcessingExample", function()
	DrawColorModify( tab ) --Draws Color Modify effect
end )