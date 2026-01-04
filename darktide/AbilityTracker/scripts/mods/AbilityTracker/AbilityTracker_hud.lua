local mod = get_mod("AbilityTracker")

local UIWidget = require("scripts/managers/ui/ui_widget")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local HudElementTeamPlayerPanelSettings = require("scripts/ui/hud/elements/team_player_panel/hud_element_team_player_panel_settings")

local TEAM_HUD_DEF_PATH = "scripts/ui/hud/elements/team_player_panel/hud_element_team_player_panel_definitions"

-- Inject widget definition
mod:hook_require(TEAM_HUD_DEF_PATH, function(instance)
    local size = { 40, 40 }
    
    -- Position relative to the panel. We'll place it above or below the health bar or near the portrait.
    -- TalentUI places it offset by some amount.
    -- Let's try placing it to the right of the panel for now, or use similar offsets.
    local offset_x = 0 
    local offset_y = -50 -- Try to put it above

    instance.widget_definitions["ability_tracker_count"] = UIWidget.create_definition({
        {
            pass_type = "text",
            style_id = "text",
            value_id = "text",
            value = "",
            style = {
                font_type = "machine_medium",
                font_size = 20,
                text_vertical_alignment = "center",
                text_horizontal_alignment = "center",
                text_color = UIHudSettings.color_tint_main_1,
                offset = { 0, 0, 100 }, -- High Z to be on top
                size = size,
            },
        },
        -- Optional: Icon
        -- {
        --     pass_type = "texture",
        --     style_id = "icon",
        --     value = "content/ui/materials/icons/abilities/combat/combat_ability_01", -- Placeholder
        -- },
    }, "bar") -- Parent to 'bar' or similar anchor
end)


-- Update loop
mod:hook_safe("HudElementTeamPlayerPanel", "_update_player_features", function(self, dt, t, player, ui_renderer)
    if not mod:get("show_hud") then
        if self._widgets_by_name.ability_tracker_count then
            self._widgets_by_name.ability_tracker_count.visible = false
        end
        return
    end

    local widget = self._widgets_by_name.ability_tracker_count
    if not widget then
        return
    end

    local peer_id = player:peer_id()
    if not peer_id then
        widget.visible = false
        return
    end

    local count = mod.get_ability_usage(peer_id)
    
    -- Format: "(5)" or just "5"
    widget.content.text = string.format("(%d)", count)
    widget.visible = true
    
    -- Adjust position dynamically if needed (e.g. based on other mods)
    -- specific positioning logic can be refined here.
    
    -- Use specific styles/offsets if available in self._style or settings
    -- For now stick to the static definition location.
end)
