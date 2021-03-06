if CLIENT then
	
	ExtendedRender.SunLensFlare = {}
	ExtendedRender.SunLensFlare.vis = 0
	ExtendedRender.SunLensFlare.materials = {
		["iris"] = {
			textureID = "effects/extended_render/iris"
		},
		["color_ring"] = {
			textureID = "effects/extended_render/color_ring"
		}
	}
	ExtendedRender.SunLensFlare.elements = {
		[1] = {
			material = "color_ring",
			offsetX = 0.5,
			offsetY = 0.5,
			scale = 0.9
		},
		[2] = {
			material = "iris",
			offsetX = 1.8,
			offsetY = 1.8,
			scale = 0.15
		},
		[3] = {
			material = "iris",
			offsetX = 1.82,
			offsetY = 1.82,
			scale = 0.1
		},
		[4] = {
			material = "iris",
			offsetX = 1.5,
			offsetY = 1.5,
			scale = 0.05
		},
		[5] = {
			material = "iris",
			offsetX = 0.6,
			offsetY = 0.6,
			scale = 0.05
		},
		[6] = {
			material = "iris",
			offsetX = 0.59,
			offsetY = 0.59,
			scale = 0.15
		},
		[7] = {
			material = "iris",
			offsetX = 0.3,
			offsetY = 0.3,
			scale = 0.1
		},
		[8] = {
			material = "iris",
			offsetX = -0.7,
			offsetY = -0.7,
			scale = 0.1
		},
		[9] = {
			material = "iris",
			offsetX = -0.72,
			offsetY = -0.72,
			scale = 0.15
		},
		[10] = {
			material = "iris",
			offsetX = -0.73,
			offsetY = -0.73,
			scale = 0.05
		},
		[11] = {
			material = "iris",
			offsetX = -0.9,
			offsetY = -0.9,
			scale = 0.1
		},
		[12] = {
			material = "iris",
			offsetX = -0.92,
			offsetY = -0.92,
			scale = 0.05
		},
		[13] = {
			material = "iris",
			offsetX = -1.3,
			offsetY = -1.3,
			scale = 0.15
		},
		[14] = {
			material = "iris",
			offsetX = -1.5,
			offsetY = -1.5,
			scale = 0
		},
		[15] = {
			material = "iris",
			offsetX = -1.7,
			offsetY = -1.7,
			scale = 0.1
		},
	}
	
	function ExtendedRender.SunLensFlare:Init()
		ExtendedRender.Util:LoadMaterials( self )
	end
	
	function ExtendedRender.SunLensFlare:Render()
		local sun = util.GetSunInfo()
		
		if sun then
			local pos = ( EyePos() + sun.direction * 4096 ):ToScreen()
			local dot = ( sun.direction:Dot( EyeVector() ) - 0.8) * 5
			local rSz = ScrW() * 1.15
			local aMul = math.Clamp( ( sun.direction:Dot( EyeVector() ) - 0.4 ) * ( 1 - math.pow( 1 - sun.obstruction, 2 ) ), 0, 1)
			
			self.vis = Lerp( math.min( FrameTime() * 8, 1 ), self.vis, aMul )
			
			if self.vis != 0 and sun.obstruction != 0 then
				for i, element in pairs( self.elements ) do
					local size = rSz * element.scale
					local x = ExtendedRender.Util:MultiplyPosition( pos.x, ScrW(), element.offsetX )
					local y = ExtendedRender.Util:MultiplyPosition( pos.y, ScrH(), element.offsetY )
					
					surface.SetDrawColor( 255, 255, 255, 120 * math.pow( self.vis, 1) )
					surface.SetMaterial( self.materials[element.material].material )
					surface.DrawTexturedRect( x - ( size / 2 ), y - ( size / 2 ), size, size )
				end
			end
		end
	end
	
	ExtendedRender.SunLensFlare:Init()
	
	hook.Add("GetMotionBlurValues", "ExtendedRender_GetMotionBlurValues", function( h, v, f, r )
		local mul = GetConVar("r_extended_motion_blur_multiplier"):GetFloat()

		f = f * mul
		h = h * mul
		v = v * mul
		r = r * mul
		
		return h, v, f, r
	end )

	hook.Add("RenderScreenspaceEffects", "ExtendedRender_RenderScreenspaceEffects", function()
		if GetConVar("r_extended_brightness"):GetBool() then
			local tab = {
				[ "$pp_colour_addr" ] = 0,
				[ "$pp_colour_addg" ] = 0,
				[ "$pp_colour_addb" ] = 0,
				[ "$pp_colour_brightness" ] = 0.1,
				[ "$pp_colour_contrast" ] = 0.9,
				[ "$pp_colour_colour" ] = 1.2,
				[ "$pp_colour_mulr" ] = 0,
				[ "$pp_colour_mulg" ] = 0,
				[ "$pp_colour_mulb" ] = 0
			}
			
			DrawColorModify( tab )
		end

		if GetConVar("r_extended_sun_lensflare"):GetBool() then
			ExtendedRender.SunLensFlare:Render()
		end
	end )
end