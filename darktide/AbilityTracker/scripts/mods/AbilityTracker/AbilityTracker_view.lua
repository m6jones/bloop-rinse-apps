local mod = get_mod("AbilityTracker")

local ScriptWorld = require("scripts/foundation/utilities/script_world")
local UIRenderer = require("scripts/managers/ui/ui_renderer")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local BaseView = require("scripts/ui/views/base_view")

AbilityTrackerView = class("AbilityTrackerView", "BaseView")

local definitions = {
    scenegraph_definition = {
        screen = { scale = "fit", size = { 1920, 1080 }, position = { 0, 0, 0 } },
        background = {
            parent = "screen",
            vertical_alignment = "center",
            horizontal_alignment = "center",
            size = { 1000, 600 },
            position = { 0, 0, 100 },
        },
        header = {
            parent = "background",
            vertical_alignment = "top",
            horizontal_alignment = "center",
            size = { 900, 80 },
            position = { 0, 20, 1 },
        },
        list_anchor = {
            parent = "background",
            vertical_alignment = "top",
            horizontal_alignment = "center",
            size = { 900, 500 },
            position = { 0, 120, 1 },
        },
    },
    widget_definitions = {
        background = UIWidget.create_definition({
            {
                pass_type = "rect",
                style = {
                    color = { 200, 0, 0, 0 }, -- Semi-transparent black
                },
            },
            {
                pass_type = "texture",
                value = "content/ui/materials/frames/frame_tile_2px",
                style = {
                    color = UIHudSettings.color_tint_main_1,
                },
            },
        }, "background"),
        header_text = UIWidget.create_definition({
            {
                pass_type = "text",
                value = mod:localize("scoreboard_title"),
                style = {
                    font_type = "machine_medium",
                    font_size = 50,
                    text_vertical_alignment = "center",
                    text_horizontal_alignment = "center",
                    text_color = UIHudSettings.color_tint_main_1,
                },
            },
        }, "header"),
        close_hint = UIWidget.create_definition({
             {
                pass_type = "text",
                value = "Press [ESC] to Close",
                style = {
                    font_type = "proxima_nova_bold",
                    font_size = 24,
                    text_vertical_alignment = "bottom",
                    text_horizontal_alignment = "center",
                    text_color = { 255, 255, 255, 255 },
                    offset = { 0, -20, 0 },
                },
            },
        }, "background"),
    },
}

function AbilityTrackerView:init(settings, context)
    AbilityTrackerView.super.init(self, definitions, settings, context)
    self._pass_draw = false
end

function AbilityTrackerView:on_enter()
    AbilityTrackerView.super.on_enter(self)
    
    -- Create widgets for players dynamically
    self._player_widgets = {}
    
    -- Mock data if not in game or empty (for testing)
    -- mod.ability_usage = mod.ability_usage or { ["test_peer"] = 10 }
    
    local y_offset = 0
    for peer_id, count in pairs(mod.ability_usage) do
        -- Try to get player name
        local name = peer_id
        local player = Managers.player and Managers.player:player_from_peer_id(peer_id)
        if player then
            name = player:name()
        end
        
        local widget_def = UIWidget.create_definition({
            {
                pass_type = "text",
                value = string.format("%s: %d", name, count),
                style = {
                    font_type = "proxima_nova_bold",
                    font_size = 30,
                    text_vertical_alignment = "top",
                    text_horizontal_alignment = "left",
                    text_color = { 255, 255, 255, 255 },
                    offset = { 50, y_offset, 0 },
                },
            },
        }, "list_anchor")
        
        local widget = self:_create_widget("player_" .. peer_id, widget_def)
        table.insert(self._player_widgets, widget)
        
        y_offset = y_offset + 40
    end
    
    -- Allow mouse cursor
    Managers.input:push_cursor("AbilityTrackerView")
end

function AbilityTrackerView:on_exit()
    Managers.input:pop_cursor("AbilityTrackerView")
    AbilityTrackerView.super.on_exit(self)
end

function AbilityTrackerView:update(dt, t, input_service)
    -- Handle input to close
    if input_service:get("toggle_menu") or input_service:get("back") then
        mod:close_scoreboard_view()
    end
    
    return AbilityTrackerView.super.update(self, dt, t, input_service)
end

function AbilityTrackerView:draw(dt, t, input_service, layer)
    local render_scale = self._render_scale
    local render_settings = self._render_settings
    local ui_renderer = self._ui_renderer
    render_settings.start_layer = layer
    render_settings.scale = render_scale
    render_settings.inverse_scale = render_scale and 1 / render_scale
    local ui_scenegraph = self._ui_scenegraph

    UIRenderer.begin_pass(ui_renderer, ui_scenegraph, input_service, dt, render_settings)
    
    for _, widget in ipairs(self._widgets) do
        UIWidget.draw(widget, ui_renderer)
    end
    
    if self._player_widgets then
        for _, widget in ipairs(self._player_widgets) do
            UIWidget.draw(widget, ui_renderer)
        end
    end
    
    UIRenderer.end_pass(ui_renderer)
end

-- Registration
mod:add_view("ability_tracker_view", "AbilityTrackerView", {
    can_interact = true
})

-- Mod helper functions
mod.setup_scoreboard_view = function()
    if not Managers.ui:view_active("ability_tracker_view") then
        Managers.ui:open_view("ability_tracker_view")
    end
end

mod.close_scoreboard_view = function()
    if Managers.ui:view_active("ability_tracker_view") then
        Managers.ui:close_view("ability_tracker_view")
    end
end
