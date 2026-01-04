local mod = get_mod("AbilityTracker")

return {
	name = mod:localize("mod_title"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "show_in_hud",
				type = "checkbox",
				default_value = true,
			},
			{
				setting_id = "show_at_end",
				type = "checkbox",
				default_value = true,
			},
		},
	},
}