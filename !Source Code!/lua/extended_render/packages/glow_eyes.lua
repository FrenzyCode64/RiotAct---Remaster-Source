if CLIENT then
	CreateClientConVar( "r_extended_eyes", 1, true, true )
end

local data = {
	["combine_soldier_player"] = {
		["filter"] = {
			[0] = { class = "player", model = "models/player/combine_soldier.mdl", skin = 0 },
			[1] = { class = "player", model = "models/player/combine_soldier.mdl", skin = 1 }
		},
		["parts"] = {
			[0] = {
				name = "Glow",
				command = "r_extended_eyes",
				transform = {
					world = {
						pos = Vector(0, 2, 0)
					}
				},
				trail = true,
				size = 8,
				color = Vector(255, 0, 0),
				bone = "eyes",
				Init = function(self) 
					local color = self:GetParent():GetPlayerColor() 
					self.color = Vector( color*255, color*255, color*255 ) 
				end
			},
			[1] = {
				name = "Glow",
				command = "r_extended_eyes",
				transform = {
					world = {
						pos = Vector(0, -2, 0)
					}
				},
				trail = true,
				size = 8,
				color = Vector(255, 0, 0),
				bone = "eyes",
				Init = function(self)
					local color = self:GetParent():GetPlayerColor() 
					self.color = Vector( color*255, color*255, color*255 ) 
				end
			},
			[2] = {
				name = "Light",
				command = "r_extended_eyes",
				brightness = 3,
				size = 20,
				color = Vector(255, 0, 0),
				renderInView = true,
				bone = "eyes",
				Init = function(self) 
					local color = self:GetParent():GetPlayerColor() 
					self.color = Vector( color*255, color*255, color*255 ) 
				end
			}
		}
	},
	["combine_soldier_red"] = {
		["filter"] = {
			[0] = { model = "models/combine_soldier_prisonguard.mdl", skin = 1 },
			[1] = { model = "models/combine_soldier.mdl", skin = 1 },
			[2] = { model = "models/player/combine_soldier_prisonguard.mdl", skin = 1 }
		},
		["parts"] = {
			[0] = {
				name = "Glow",
				command = "r_extended_eyes",
				transform = {
					world = {
						pos = Vector(0, 2, 0)
					}
				},
				trail = true,
				size = 8,
				color = Vector(255, 0, 0),
				bone = "eyes"
			},
			[1] = {
				name = "Glow",
				command = "r_extended_eyes",
				transform = {
					world = {
						pos = Vector(0, -2, 0)
					}
				},
				trail = true,
				size = 8,
				color = Vector(255, 0, 0),
				bone = "eyes"
			}
		}
	},
	["combine_soldier_yellow"] = {
		["filter"] = {
			[0] = { model = "models/combine_soldier_prisonguard.mdl", skin = 0 },
			[1] = { model = "models/player/combine_soldier_prisonguard.mdl", skin = 0 }
		},
		["parts"] = {
			[0] = {
				name = "Glow",
				command = "r_extended_eyes",
				transform = {
					world = {
						pos = Vector(0, 2, 0)
					}
				},
				trail = true,
				size = 8,
				color = Vector(255, 240, 0),
				bone = "eyes"
			},
			[1] = {
				name = "Glow",
				command = "r_extended_eyes",
				transform = {
					world = {
						pos = Vector(0, -2, 0)
					}
				},
				trail = true,
				size = 8,
				color = Vector(255, 240, 0),
				bone = "eyes"
			}
		}
	},
	["combine_soldier_blue"] = {
		["filter"] = {
			[0] = { model = "models/combine_soldier.mdl", skin = 0 }
		},
		["parts"] = {
			[0] = {
				name = "Glow",
				command = "r_extended_eyes",
				transform = {
					world = {
						pos = Vector(-0.5, 1.9, -0.2)
					}
				},
				size = 12,
				shimmer = true,
				color = Vector(0, 120, 140),
				bone = "eyes"
			},
			[1] = {
				name = "Glow",
				command = "r_extended_eyes",
				transform = {
					world = {
						pos = Vector(-0.5, -1.9, -0.2)
					}
				},
				size = 12,
				shimmer = true,
				color = Vector(0, 120, 140),
				bone = "eyes"
			}
		}
	},
	["combine_elite"] = {
		["filter"] = {
			[0] = { model = "models/combine_super_soldier.mdl" }
		},
		["parts"] = {
			[0] = {
				name = "Glow",
				command = "r_extended_eyes",
				transform = {
					world = {
						pos = Vector(-1.5, 0, 0.3)
					}
				},
				trail = true,
				size = 16,
				opacity = 255,
				shimmer = true,
				color = Vector(255, 0, 0),
				bone = "eyes"
			},
			[1] = {
				name = "Light",
				command = "r_extended_eyes",
				brightness = 3,
				size = 20,
				color = Vector(255, 0, 0),
				renderInView = true,
				bone = "eyes"
			}
		}
	},
	["combine_elite_player"] = {
		["filter"] = {
			[0] = { class = "player", model = "models/player/combine_super_soldier.mdl" }
		},
		["parts"] = {
			[0] = {
				name = "Glow",
				command = "r_extended_eyes",
				transform = {
					world = {
						pos = Vector(-1.5, 0, 0.3)
					}
				},
				trail = true,
				size = 16,
				opacity = 255,
				shimmer = true,
				color = Vector(255, 0, 0),
				bone = "eyes",
				Init = function(self) 
					local color = self:GetParent():GetPlayerColor()
					self.color = Vector( color*255, color*255, color*255 ) 
				end
			},
			[1] = {
				name = "Light",
				command = "r_extended_eyes",
				brightness = 3,
				size = 20,
				color = Vector(255, 0, 0),
				renderInView = true,
				bone = "eyes",
				Init = function(self) 
					local color = self:GetParent():GetPlayerColor() 
					self.color = Vector( color*255, color*255, color*255 ) 
				end
			}
		}
	},
	["hunter"] = {
		["filter"] = {
			[0] = { model = "models/hunter.mdl" }
		},
		["parts"] = {
			[0] = {
				name = "Glow",
				command = "r_extended_eyes",
				transform = {
					world = {
						pos = Vector(-7, 0, 0)
					}
				},
				trail = true,
				size = 24,
				shimmer = true,
				color = Vector(0, 120, 140),
				bone = "top_eye"
			},
			[1] = {
				name = "Glow",
				command = "r_extended_eyes",
				transform = {
					world = {
						pos = Vector(-7, 0, 0)
					}
				},
				trail = true,
				size = 24,
				shimmer = true,
				color = Vector(0, 120, 140),
				bone = "bottom_eye"
			},
			[2] = {
				name = "Light",
				command = "r_extended_eyes",
				transform = {
					world = {
						pos = Vector(0, 0, 25)
					}
				},
				brightness = 4,
				size = 54,
				color = Vector(0, 120, 140),
				renderInView = true,
				bone = "head_center"
			},
			[3] = {
				name = "Glow",
				command = "r_extended_eyes",
				transform = {
					world = {
						pos = Vector(0, 0, 35)
					}
				},
				size = 264,
				opacity = 25,
				color = Vector(0, 120, 140),
				bone = "head_center"
			},
		}
	}
}

ExtendedRender.Data:Include( "Packages", data )