local mod = get_mod("AbilityTracker")

-- Data storage for the current session
local ability_counts = {}

-- Function to reset counts (called at mission start)
local function reset_counts()
    ability_counts = {}
end

-- Hook into mission start to reset data
mod:hook_safe(Managers.state.game_mode, "on_mission_start", function()
    reset_counts()
end)

-- HOOK 1: Tracking Ability Usage
-- We hook the AbilityExtension which handles the actual consumption of charges.
mod:hook_safe("AbilityExtension", "use_ability_charge", function(self)
    local player = self._player
    if player then
        local account_id = player:account_id() or player:name()
        ability_counts[account_id] = (ability_counts[account_id] or 0) + 1
    end
end)

-- HOOK 2: Updating the HUD
-- We hook HudElementPlayerStatus to display the count beside the portrait.
mod:hook_safe("HudElementPlayerStatus", "_set_ability_values", function(self, ability_extension)
    if not mod:get("show_in_hud") then return end

    local player = self._player
    if player then
        local account_id = player:account_id() or player:name()
        local count = ability_counts[account_id] or 0
        
        -- We look for or create a custom text widget on the portrait
        local widgets = self._widgets
        if widgets and widgets.ability_counter then
            widgets.ability_counter.content.text = tostring(count)
        else
            -- Note: In a full production mod, you would define this widget 
            -- in the HudElementPlayerStatus definitions.
            -- This snippet illustrates the logic flow.
        end
    end
end)

-- HOOK 3: End of Game Scoreboard
-- This hook appends our data to the end-of-mission summary.
mod:hook_safe("MissionEndView", "_setup_content", function(self)
    if not mod:get("show_at_end") then return end
    
    -- We wait for the view to initialize its stat tables
    -- Then we inject our 'Ability Uses' column
    local scoreboard_data = self._scoreboard_data
    if scoreboard_data then
        for _, player_data in ipairs(scoreboard_data.players) do
            local account_id = player_data.account_id or player_data.name
            player_data.ability_uses = ability_counts[account_id] or 0
        end
        
        -- Add the header to the table
        table.insert(scoreboard_data.headers, {
            text = mod:localize("uses_abbreviation"),
            stat_name = "ability_uses"
        })
    end
end)

-- Debug Command
mod:command("check_abilities", "Show current ability counts", function()
    for id, count in pairs(ability_counts) do
        mod:echo(id .. ": " .. count)
    end
end)