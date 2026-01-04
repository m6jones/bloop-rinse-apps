return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`AbilityTracker` encountered an error loading the Darktide Mod Framework.")

		new_mod("AbilityTracker", {
			mod_script       = "scripts/mods/AbilityTracker/AbilityTracker",
			mod_data         = "scripts/mods/AbilityTracker/AbilityTracker_data",
			mod_localization = "scripts/mods/AbilityTracker/AbilityTracker_localization",
		})
	end,
	packages = {},
}