return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`AbilityTracker` encountered an error loading the Darktide Mod Framework.")

		new_mod("AbilityTracker", {
			mod_script       = "AbilityTracker/scripts/mods/AbilityTracker/AbilityTracker",
			mod_data         = "AbilityTracker/scripts/mods/AbilityTracker/AbilityTracker_data",
			mod_localization = "AbilityTracker/scripts/mods/AbilityTracker/AbilityTracker_localization",
		})
	end,
	packages = {},
}
