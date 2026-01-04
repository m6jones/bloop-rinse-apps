local mod = get_mod("AbilityTracker")

-- Global table to store ability usage counts per player
-- Key: peer_id, Value: count (integer)
mod.ability_usage = {}

-- Initialize usage table
mod.on_game_state_changed = function(status, state_name)
    if state_name == "StateGameScore" and status == "enter" then
        if mod:get("show_scoreboard") then
            mod:setup_scoreboard_view()
        end
    end
end

-- Hook into ability usage
-- We need to find the correct method. Based on experience, `PlayerUnitAbilityExtension._use_ability` is a good candidate.
-- We will hook safe to ensure we don't break game logic.

mod:hook_safe("PlayerUnitAbilityExtension", "_use_ability", function(self, ability_type, ability_component, fixed_t, ...)
    -- Filter for combat ability (F key usually)
    if ability_type ~= "combat_ability" then
        return
    end

    local player = self._player
    if not player then
        return
    end

    local peer_id = player:peer_id()
    if not peer_id then
        return -- Likely a bot or local testing without peer (shouldn't happen in live)
    end
    
    if not mod.ability_usage[peer_id] then
        mod.ability_usage[peer_id] = 0
    end

    mod.ability_usage[peer_id] = mod.ability_usage[peer_id] + 1
    
    -- Debug print
    -- mod:echo(string.format("Player %s used ability. Total: %d", player:name(), mod.ability_usage[peer_id]))
end)

-- Function to get usage for a player
mod.get_ability_usage = function(peer_id)
    return mod.ability_usage[peer_id] or 0
end

-- Reset counts on mission start
mod:hook_safe(Managers.state, "enter_mission", function(...)
    mod.ability_usage = {}
end)

-- Load sub-modules
mod:io_dofile("AbilityTracker/scripts/mods/AbilityTracker/AbilityTracker_hud")
mod:io_dofile("AbilityTracker/scripts/mods/AbilityTracker/AbilityTracker_view")
