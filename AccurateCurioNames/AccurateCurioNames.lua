-- AccurateCurioNames.lua

local mod = get_mod("AccurateCurioNames")

local MasterItems = require("scripts/backend/master_items")
local get_item	  = MasterItems.get_item

-- ===============================================================================
-- Effects Table
--	 abbr — localization key for the abbreviation ("HP", "VNS")
--	 word — localization key for the short description ("to Health", "Wound")
--
-- The format is selected via the blessing_format setting:
--	 standard	 → full in-game description (compatible with Enhanced Descriptions)
--	 short		 → value + short description
--	 very_short	 → value + abbreviation
-- Perks ALWAYS use abbr regardless of the setting.
-- ===============================================================================
local LABELS = {
-- BLESSINGS
	-- Health
	["loc_inate_gadget_health_desc"] = {
		abbr = "acu_health_abbr",
		word = "acu_health_word",
	},
	-- Stamina
	["loc_inate_gadget_stamina_desc"] = {
		abbr = "acu_stamina_abbr",
		word = "acu_stamina_word",
	},
	-- Toughness
	["loc_inate_gadget_toughness_desc"] = {
		abbr = "acu_toughness_abbr",
		word = "acu_toughness_word",
	},
	-- Wound
	["loc_inate_gadget_health_segment_desc"] = {
		abbr = "acu_wound_abbr",
		word = "acu_wound_word",
	},

-- PERKS
	-- Ally Revive Speed
	["loc_gadget_revive_speed_desc"] = {
		abbr = "acu_revive_spd_abbr",
		word = "acu_revive_spd_word",
	},
	-- Block Cost Reduction
	["loc_gadget_block_cost_reduction_desc"] = {
		abbr = "acu_block_cost_abbr",
		word = "acu_block_cost_word",
	},
	-- Combat Ability Regeneration
	["loc_gadget_cooldown_desc"] = {
		abbr = "acu_cooldown_abbr",
		word = "acu_cooldown_word",
	},
	-- Corruption Resistance
	["loc_gadget_corruption_resistance_desc"] = {
		abbr = "acu_corruption_res_abbr",
		word = "acu_corruption_res_word",
	},
	-- Corruption Resistance from Grimoires
	["loc_gadget_grim_corruption_resistance_desc"] = {
		abbr = "acu_grim_res_abbr",
		word = "acu_grim_res_word",
	},
	-- Curio as Mission Reward
	["loc_trait_gadget_mission_reward_gear_instead_of_weapon_increase_desc"] = {
		abbr = "acu_curio_chance_abbr",
		word = "acu_curio_chance_word",
	},
	-- Damage Resistance vs Bombers
	["loc_trait_gadget_dr_vs_grenadiers_desc"] = {
		abbr = "acu_bomber_res_abbr",
		word = "acu_bomber_res_word",
	},
	-- Damage Resistance vs Flamers
	["loc_trait_gadget_dr_vs_flamer_desc"] = {
		abbr = "acu_flamer_res_abbr",
		word = "acu_flamer_res_word",
	},
	-- Damage Resistance vs Gunners
	["loc_trait_gadget_dr_vs_gunners_desc"] = {
		abbr = "acu_gunner_res_abbr",
		word = "acu_gunner_res_word",
	},
	-- Damage Resistance vs Mutants
	["loc_trait_gadget_dr_vs_mutants_desc"] = {
		abbr = "acu_mutant_res_abbr",
		word = "acu_mutant_res_word",
	},
	-- Damage Resistance vs Pox Hounds
	["loc_trait_gadget_dr_vs_hounds_desc"] = {
		abbr = "acu_hound_res_abbr",
		word = "acu_hound_res_word",
	},
	-- Damage Resistance vs Snipers
	["loc_trait_gadget_dr_vs_snipers_desc"] = {
		abbr = "acu_sniper_res_abbr",
		word = "acu_sniper_res_word",
	},
	-- Experience
	["loc_trait_gadget_mission_xp_increase_desc"] = {
		abbr = "acu_xp_abbr",
		word = "acu_xp_word",
	},
	-- Health
	["loc_trait_gadget_health_increase_desc"] = {
		abbr = "acu_health_abbr",
		word = "acu_health_word",
	},
	-- Ordo Dockets
	["loc_trait_gadget_mission_credits_increase_desc"] = {
		abbr = "acu_dockets_abbr",
		word = "acu_dockets_word",
	},
	-- Stamina Sprint Cost Reduction
	["loc_gadget_sprint_cost_reduction_desc"] = {
		abbr = "acu_stam_sprint_abbr",
		word = "acu_stam_sprint_word",
	},
	-- Stamina Regeneration
	["loc_gadget_stamina_regeneration_desc"] = {
		abbr = "acu_stam_regen_abbr",
		word = "acu_stam_regen_word",
	},
	-- Toughness
	["loc_trait_gadget_toughness_increase_desc"] = {
		abbr = "acu_toughness_abbr",
		word = "acu_toughness_word",
	},
	-- Toughness Regeneration Speed
	["loc_gadget_toughness_regen_delay_desc"] = {
		abbr = "acu_tn_regen_abbr",
		word = "acu_tn_regen_word",
	},
}

-- ===============================================================================
-- Settings cache. Invalidated via mod.on_setting_changed.
-- ===============================================================================
local cached_show_perks			= false
local cached_other_mod_override = true
local cached_blessing_format	= "very_short"

local function refresh_settings()
	cached_show_perks			= mod:get("show_perks")			== true
	cached_other_mod_override	= mod:get("other_mod_override")	== true
	cached_blessing_format		= mod:get("blessing_format")	or "very_short"
end

mod.on_setting_changed = function(setting_id)
	if setting_id == "show_perks"
		or setting_id == "other_mod_override"
		or setting_id == "blessing_format" then
		refresh_settings()
	end
end

mod.on_settings_reset = refresh_settings

-- ===============================================================================
-- Utilities
-- ===============================================================================

-- Retrieves the trait description's loc_key.
-- If it is missing for some reason, construct it from the display_name.
local function get_desc_key(trait_item)
	local desc = trait_item.description
	if type(desc) == "string" and desc ~= "" then
		return desc
	end

	local name = trait_item.display_name
	if type(name) == "string" then
		return name .. "_desc"
	end

	return nil
end

-- Extracts a numeric value from a formatted description string.
-- First, it strips color tags ({#color(...)}, {#reset()}), then
-- matches the first number with a sign and/or percentage: "+21%", "+3", "+1".
local function extract_value(text)
	local stripped = text:gsub("{#.-}", "")
	return stripped:match("([%+%-]?%d+%.?%d*%%?)")
end

-- ===============================================================================
-- Hook display_name
-- ===============================================================================
mod.on_all_mods_loaded = function()
	refresh_settings()

	mod:hook_require("scripts/utilities/items", function(Items)
		local original_display_name = Items.display_name
		local trait_description		= Items.trait_description
		local is_gadget				= Items.is_gadget

		-- Formats a single trait. is_perk=true → always abbr (very_short).
		local function format_trait(trait_item, rarity, value, is_perk)
			local full_desc = trait_description(trait_item, rarity, value)
			if type(full_desc) ~= "string" or full_desc == "" then
				return nil
			end

			-- Standard (for blessings only) - provide the full description exactly as is.
			if not is_perk and cached_blessing_format == "standard" then
				return full_desc
			end

			local desc_key = get_desc_key(trait_item)
			local entry	   = desc_key and LABELS[desc_key]
			if not entry then
				return full_desc
			end

			local label_key
			if is_perk or cached_blessing_format == "very_short" then
				label_key = entry.abbr
			else
				-- short
				label_key = entry.word or entry.abbr
			end

			local word = mod:localize(label_key)
			if type(word) ~= "string" or word == "" then
				return full_desc
			end

			local num = extract_value(full_desc)
			if not num then
				return full_desc
			end

			return num .. " " .. word
		end

		Items.display_name = function(item)
			if not item then return "n/a" end

			local original_result = original_display_name(item)

			if not is_gadget(item.item_type) then
				return original_result
			end

			-- Respect custom names from other mods (Name It, etc.).
			if cached_other_mod_override then
				local display_name = item.display_name
				if display_name then
					local localized = Localize(display_name)
					if localized and localized ~= original_result then
						return original_result
					end
				end
			end

			local traits = item.traits
			local trait	 = traits and traits[1]
			if not trait or not trait.id then
				return original_result
			end

			local trait_item = get_item(trait.id)
			if not trait_item then
				return original_result
			end

			local parts = {}

			local main = format_trait(trait_item, trait.rarity, trait.value, false)
			if main then parts[#parts + 1] = main end

			if cached_show_perks and item.perks then
				local perks = item.perks
				local n = #perks
				for i = 1, n do
					local perk		= perks[i]
					local perk_item = get_item(perk.id)
					if perk_item then
						local p = format_trait(perk_item, perk.rarity, perk.value, true)
						if p then parts[#parts + 1] = p end
					end
				end
			end

			if #parts == 0 then
				return original_result
			end

			return table.concat(parts, " ")
		end
	end)
end
