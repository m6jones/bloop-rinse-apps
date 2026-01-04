local mod = get_mod("AbilityTracker")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		{
			setting_id = "show_hud",
			type = "checkbox",
			default_value = true,
			title = mod:localize("show_hud"),
            sub_widgets = {},
        },
        {
			setting_id = "show_scoreboard",
			type = "checkbox",
			default_value = true,
			title = mod:localize("show_scoreboard"),
        },
	},
}
