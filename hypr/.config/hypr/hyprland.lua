c = require("mocha")

terminal    = "kitty"
fileManager = "dolphin"
menu        = "tofi-drun"
browser     = "Vivaldi-flatpak"

require("configs/monitors")
require("configs/autostart")
require("configs/env")
require("configs/layouts")
require("configs/decorations")
require("configs/animations")
require("configs/input")
require("configs/device")
require("configs/groups")
require("configs/binds")
require("configs/rules")
require("configs/plugins")

hl.config({
  misc = {
    force_default_wallpaper = -1,
    disable_hyprland_logo = false,
    font_family = "SpaceMono Nerd Font",
    middle_click_paste = false,
    mouse_move_enables_dpms = false,
    key_press_enables_dpms = true,
    exit_window_retains_fullscreen = true
  },
  xwayland = {
    force_zero_scaling = true
  }
})
-- Ref https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- "Smart gaps" / "No gaps when only"
-- uncomment all if you wish to use that.
-- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
-- hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
-- hl.window_rule({
--     name  = "no-gaps-wtv1",
--     match = { float = false, workspace = "w[tv1]" },
--     border_size = 0,
--     rounding    = 0,
-- })
-- hl.window_rule({
--     name  = "no-gaps-f1",
--     match = { float = false, workspace = "f[1]" },
--     border_size = 0,
--     rounding    = 0,
-- })

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

-- local suppressMaximizeRule = hl.window_rule({
--     -- Ignore maximize requests from all apps. You'll probably like this.
--     name  = "suppress-maximize-events",
--     match = { class = ".*" },
--
--     suppress_event = "maximize",
-- })
-- suppressMaximizeRule:set_enabled(false)

-- Layer rules also return a handle.
-- local overlayLayerRule = hl.layer_rule({
--     name  = "no-anim-overlay",
--     match = { namespace = "^my-overlay$" },
--     no_anim = true,
-- })
-- overlayLayerRule:set_enabled(false)
