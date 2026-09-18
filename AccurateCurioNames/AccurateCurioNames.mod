return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`AccurateCurioNames` encountered an error loading the Darktide Mod Framework.")

		new_mod("AccurateCurioNames", {
			mod_script		 = "AccurateCurioNames/AccurateCurioNames",
			mod_data		 = "AccurateCurioNames/AccurateCurioNames_data",
			mod_localization = "AccurateCurioNames/AccurateCurioNames_localization",
		})
	end,
	packages = {},
}
