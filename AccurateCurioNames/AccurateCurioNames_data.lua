-- AccurateCurioNames_data.lua

local mod = get_mod("AccurateCurioNames")

return {
	name		 = mod:localize("mod_name"),
	description	 = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			-- =============================================================
			-- Respect custom names
			-- =============================================================
			{
				setting_id	  = "other_mod_override",
				type		  = "checkbox",
				default_value = true,
			},

			-- =============================================================
			-- Show perks in the curio name
			-- =============================================================
			{
				setting_id	  = "show_perks",
				type		  = "checkbox",
				default_value = false,
			},

			-- =============================================================
			-- Blessing name format
			-- =============================================================
			{
				setting_id	  = "blessing_format",
				type		  = "dropdown",
				default_value = "very_short",
				options = {
					{ value = "standard",	text = "blessing_format_standard"	},
					{ value = "short",		text = "blessing_format_short"		},
					{ value = "very_short", text = "blessing_format_very_short" },
				},
			},
		},
	},
}
