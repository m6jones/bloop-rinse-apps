return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`AbilityTracker` encountered an error loading the Darktide Mod Framework.")

		new_mod("AbilityTracker", {
			mod_script       = "AbilityTracker/AbilityTracker",
			mod_data         = "AbilityTracker/AbilityTracker_data",
			mod_localization = "AbilityTracker/AbilityTracker_localization",
		})
	end,
	packages = {},
}