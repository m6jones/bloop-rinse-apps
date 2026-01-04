local mod = get_mod("AbilityTracker")

-- Data storage
local ability_counts = {}
local player_names = {}

-- =============================================================================
-- DATA MANAGEMENT
-- =============================================================================

local function reset_counts()
    ability_counts = {}
    player_names = {}
end

-- Function to save results to a CSV file in %AppData%
local function save_to_csv()
    local timestamp = os.date("%Y-%m-%d_%H-%M-%S")
    local filename = "ability_stats_" .. timestamp .. ".csv"
    
    -- Retrieve the AppData path from the environment
    local appdata_path = os.getenv("APPDATA")
    local full_path = filename -- Fallback to game dir if env var fails
    
    if appdata_path then
        -- Construct path to Darktide's specific AppData folder
        -- Result: %AppData%/Fatshark/Darktide/ability_stats_...csv
        full_path = appdata_path .. "\\Fatshark\\Darktide\\" .. filename
    end
    
    local file = io.open(full_path, "w")
    if file then
        file:write("PlayerName,AbilityUses\n")
        for id, count in pairs(ability_counts) do
            local safe_id = string.gsub(id, ",", " ")
            file:write(string.format("%s,%d\n", safe_id, count))
        end
        file:close()
        mod:echo("Saved mission results to AppData: " .. filename)
    else
        mod:echo("Error: Could not save CSV to " .. full_path)
    end
end

-- DMF callback for mod reloading
mod.on_reload = function()
    reset_counts()
end

-- Resetting when changing states to ensure clean tracking
mod.on_game_state_changed = function(status, state_name)
    -- Reset when entering the Hub (Mourningstar), Loading screens, or the Main Menu
    if state_name == "StateLoading" or state_name == "StateMainMenu" or state_name == "StateMourningstar" then
        reset_counts()
    end
end

-- =============================================================================
-- HOOKS: Tracking
-- =============================================================================

-- Updated to ensure it captures ability usage from all player units in the session
mod:hook_safe("PlayerUnitAbilityExtension", "use_ability_charge", function(self)
    local player = self._player
    if player then
        local id = player:account_id() or player:name()
        ability_counts[id] = (ability_counts[id] or 0) + 1
        player_names[id] = player:name() or id
    end
end)

-- =============================================================================
-- HOOKS: HUD (VISUAL INJECTION)
-- =============================================================================

mod:hook_safe("HudElementPlayerStatus", "init", function(self, ...)
    local widget = self._widgets and self._widgets.ability_bar
    if widget and not widget.content.ability_tracker_text then
        widget.content.ability_tracker_text = "0"
    end
end)

mod:hook_safe("HudElementPlayerStatus", "update", function(self, dt, t, ui_renderer, render_settings, input_service)
    local player = self._player
    local widget = self._widgets and self._widgets.ability_bar
    if player and widget then
        local id = player:account_id() or player:name()
        local count = ability_counts[id] or 0
        widget.content.ability_tracker_text = tostring(count)
        if not widget.style.ability_tracker_text then
            widget.style.ability_tracker_text = {
                font_type = "proxima_nova_bold",
                font_size = 28,
                text_color = {255, 255, 255, 255},
                offset = {100, 0, 255},
                vertical_alignment = "center",
                horizontal_alignment = "center",
                drop_shadow = true,
            }
        end
        widget.style.ability_tracker_text.visible = mod:get("show_in_hud")
    end
end)

-- =============================================================================
-- HOOKS: End of Round (Scoreboard & CSV Save)
-- =============================================================================

mod:hook_safe("MissionEndView", "on_enter", function(self)
    if mod:get("show_at_end") and next(ability_counts) ~= nil then
        save_to_csv()
    end
end)


-- Draw a custom table at the end of mission screen
mod:hook_safe("MissionEndView", "draw", function(self, dt, t, ui_renderer, render_settings, input_service)
    if not mod:get("show_at_end") or not next(ability_counts) then return end
    local x = 100
    local y = 200
    local row_height = 32
    local header_color = {255, 255, 255, 0}
    local text_color = {255, 255, 255, 255}
    local font_size = 28
    local font_type = "proxima_nova_bold"
    local sorted = {}
    for id, count in pairs(ability_counts) do
        table.insert(sorted, {id = id, name = player_names[id] or id, count = count})
    end
    table.sort(sorted, function(a, b) return a.count > b.count end)
    -- Draw header
    if ui_renderer and ui_renderer.draw_text then
        ui_renderer:draw_text("Player", font_size, font_type, x, y, header_color)
        ui_renderer:draw_text("Abilities Used", font_size, font_type, x + 300, y, header_color)
        for i, entry in ipairs(sorted) do
            ui_renderer:draw_text(entry.name, font_size, font_type, x, y + i * row_height, text_color)
            ui_renderer:draw_text(tostring(entry.count), font_size, font_type, x + 300, y + i * row_height, text_color)
        end
    end
end)

-- Debug Command
mod:command("check_abilities", "Show current ability counts", function()
    mod:echo("--- Ability Tracker Stats ---")
    for id, count in pairs(ability_counts) do
        mod:echo(string.format("%s: %d uses", id, count))
    end
end)