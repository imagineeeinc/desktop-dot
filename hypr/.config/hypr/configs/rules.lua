top_right = {"monitor_w - window_w - 23", 65}
panels = "org.pulseaudio.pavucontrol|blueman-manager"
-- Window rules
hl.window_rule({match={pin=true},border_color={colors={c.peach, c.yellow}}})
hl.window_rule({match={class="scrcpy"},keep_aspect_ratio=true,border_size=0,no_shadow=true})
hl.window_rule({match={class="kitty"},xray=true})
hl.window_rule({match={class="kitty", float=true},border_size=0})
hl.window_rule({match={title="Copying — Dolphin"}, move={"monitor_w - window_w - 23", "monitor_h - window_h - 23"}})
hl.window_rule({match={class="wofi"}, border_size=0, no_shadow=true})
hl.window_rule({match={title="Bitwarden - Vivaldi"}, float=true, size={500, 700}, move=top_right})
hl.window_rule({match={class="rmpc"}, xray=true, float=true, border_size=0, no_shadow=true, size={"monitor_w * 0.75", "monitor_h * 0.75"}})
hl.window_rule({match={class="Waydroid"}, float=true, fullscreen=true})

hl.window_rule({match={class="Teddy|MateEngineX.x86_64"},border_size=0,no_shadow=true,no_blur=true})
hl.window_rule({match={title="Friends List"}, float=true, size={"monitor_w/2-15", "monitor_h-80"}, move={15, 63}})
hl.window_rule({match={title="Picture in picture"}, float=true})
hl.window_rule({match={class="codium"}, opacity=0.9})
hl.window_rule({match={class="org.gnome.Calculator"}, float=true, size={700, 620}})
hl.window_rule({match={class=panels}, float=true, border_size=0, size={650, 550}, move=top_right, no_shadow=true, pin=true})
hl.window_rule({match={class="org.wails.netbird"}, border_size=0, size={650, 550}, move=top_right, no_shadow=true, pin=true})
hl.window_rule({match={class="wifitui"}, float=true, border_size=0, size={500, "monitor_h - 83"}, move=top_right, no_shadow=true, pin=true})

hl.window_rule({match={class="fusion360.exe"}, opaque=false, no_blur=true})

-- Layer rules
hl.layer_rule({
  match = {
    namespace = "waybar|quickshell|nwg-dock|wofi|launcher|top|logout_dialog|resolution-settings|brightness-settings|monitor-settings|system-menu|music-center|swaync-control-center|swaync-notification-window|nm-sidebar"
  },
  ignore_alpha = false,
  blur = true
})

-- Xwayland
hl.window_rule({
    name = "xwayland-video-bridge-fixes",
    match = {
     class = "xwaylandvideobridge",
    },

    no_initial_focus = true,
    no_focus = true,
    no_anim = true,
    no_blur = true,
    max_size = "1 1",
    opacity = 0.0
})
hl.window_rule({
  name  = "fix-xwayland-drags",
  match = {
    class      = "^$",
    title      = "^$",
    xwayland   = true,
    float      = true,
    fullscreen = false,
    pin        = false,
  },

  no_focus = true,
})
