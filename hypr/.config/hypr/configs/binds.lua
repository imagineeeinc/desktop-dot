local mainMod = "SUPER"

function super(inp)
  return mainMod .. " + " .. inp
end

hl.config({
  binds = {
    workspace_back_and_forth = true,
    hide_special_on_workspace_change = true,
    drag_threshold = 30
  }
})
-- Open
hl.bind(super("code:49"), hl.dsp.exec_cmd(terminal)) -- Open terminal
hl.bind(super("E"), hl.dsp.exec_cmd(fileManager)) -- Open file manager
hl.bind(super("space"), hl.dsp.exec_cmd(menu)) -- Open application launcher
hl.bind(super("R"), hl.dsp.exec_cmd("wofi --show run"))

-- Window management
hl.bind(super("W"), hl.dsp.window.close()) -- Close window
hl.bind(super("SHIFT+W"), hl.dsp.window.kill()) -- Kill window
hl.bind(super("Q"), hl.dsp.window.float()) -- Float window
hl.bind(super("H"), hl.dsp.window.pseudo()) -- Dwindle window
hl.bind(super("J"), hl.dsp.layout("togglesplit"))
hl.bind(super("SHIFT+P"), hl.dsp.window.pin({ action = "toggle" }))

-- Menus
hl.bind(super("CTRL+SHIFT+ALT+M"), hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'")) -- Exit Hyprland
hl.bind(super("M"), hl.dsp.exec_cmd("python -m fabric execute Widgets \"toggle_system_menu()\" -j")) -- Open System Menu
hl.bind(super("SHIFT+M"), hl.dsp.exec_cmd("~/.config/hypr/scripts/quickmenu.sh")) -- Open quick settings menu
hl.bind(super("B"), hl.dsp.exec_cmd("swaync-client -t -sw")) -- Open notifiaction pannel
hl.bind("CTRL+ALT+delete", hl.dsp.exec_cmd("wlogout")) -- Open power menu
hl.bind("ALT+space", hl.dsp.exec_cmd("nwg-dock-hyprland")) -- Toggle dock

-- Lock
hl.bind(super("L"), hl.dsp.exec_cmd("hyprlock"))
hl.bind(super("CTRL+SHIFT+L"), hl.dsp.exec_cmd("systemctl suspend"))

-- Suspend apps
hl.bind(super("Home"), hl.dsp.exec_cmd("~/.config/hypr/scripts/freeze.sh freeze")) -- Freeze current window
hl.bind(super("SHIFT+Home"), hl.dsp.exec_cmd("~/.config/hypr/scripts/freeze.sh unfreeze"))

-- Focus
hl.bind(super("left"), hl.dsp.focus({ direction = "left" }))
hl.bind(super("right"), hl.dsp.focus({ direction = "right" }))
hl.bind(super("up"), hl.dsp.focus({ direction = "up" }))
hl.bind(super("down"), hl.dsp.focus({ direction = "down" }))

-- Fullscreen
hl.bind(super("F"), hl.dsp.window.fullscreen()) -- Toggle fullscreen
hl.bind(super("CTRL+SHIFT+F"), hl.dsp.exec_cmd("(killall  waybar && hyprctl --batch \"keyword general:gaps_out 0\") || (hyprctl --batch \"keyword general:gaps_out 15\" && waybar)")) -- Waybar toggle

-- Display menus and options
hl.bind(super("O"), hl.dsp.exec_cmd("python -m fabric execute Widgets \"monitor_resolution.show()\" -j")) -- Open resolucion configuration
hl.bind(super("I"), hl.dsp.exec_cmd("~/.config/hypr/scripts/wofi_wallpaper_selector.sh")) -- Open wallpaper picker
hl.bind(super("P"), hl.dsp.exec_cmd("python -m fabric execute Widgets \"monitor_settings.show()\" -j")) -- Open projection selector
hl.bind(super("SHIFT+ALT+B"), hl.dsp.exec_cmd("hyprctl eval \"hl.monitor({output=\"eDP-1\",mode=\"preferred\",position=\"0x0\",scale=1.0666667,bitdepth=16})'")) -- Set main display as active

-- Clipboard and other pickers
hl.bind(super("V"), hl.dsp.exec_cmd("~/.config/hypr/scripts/wofi_clipboard.sh")) -- Open cliboard history
hl.bind(super("semicolon"), hl.dsp.exec_cmd("flatpak run com.tomjwatson.Emote")) -- Open emoji picker
hl.bind(super("SHIFT+I"), hl.dsp.exec_cmd("hyprpicker | wl-copy")) -- Open colour picker

-- Screenshot
hl.bind("PRINT", hl.dsp.exec_cmd("hyprshot -m output -z")) -- Take a fullscreen screenshot
hl.bind("SHIFT+PRINT", hl.dsp.exec_cmd("hyprshot -m window -z")) -- Take a screenshot of a window
hl.bind(super("SHIFT+S"), hl.dsp.exec_cmd("hyprshot -m region -z")) -- Take a screenshot of a region
hl.bind(super("CTRL+SHIFT+S"), hl.dsp.exec_cmd("hyprshot -m region -z --clipboard-only")) -- Take a screenshot of a region (screenshot only)

--Browser
hl.bind("MOD5+page_up", hl.dsp.send_shortcut({ mods="", key="ALT+left", window=browser })) -- Send alt+left to browser
hl.bind("MOD5+left", hl.dsp.send_shortcut({ mods="", key="ALT+right", window=browser })) -- Send alt+right to browser
hl.bind("ALT+mouse:276", hl.dsp.send_shortcut({ mods="", key="CTRL+tab", window=browser })) -- Send ctrl+tab to browser
hl.bind("ALT+mouse:275", hl.dsp.send_shortcut({ mods="", key="CTRL+SHIFT+tab", window=browser })) -- Send ctrl+shift+tab to browser

-- Music
hl.bind("code:201", hl.dsp.exec_cmd("mpc toggle"), { locked = true, ignore_mods = true}) -- Toggle playing of music from mpd
hl.bind(super("N"), hl.dsp.exec_cmd("python -m fabric execute Widgets \"toggle_music_center()\" -j")) -- Open music center
hl.bind(super("SHIFT+N"), hl.dsp.exec_cmd("kitty --class=rmpc rmpc")) -- Open rmpc

-- Misc
hl.bind(super("SHIFT+F"), hl.dsp.layout("fit active")) -- Fit window

-- Workspace
for i = 1, 10 do
    local key = i % 10
    hl.bind(super(key), hl.dsp.focus({ workspace = i}))
    hl.bind(super("SHIFT+"..key), hl.dsp.window.move({ workspace = i }))
    hl.bind(super("CTRL+"..key), hl.dsp.group.active({ index = i }))
end
hl.bind(super("minus"), hl.dsp.focus({ workspace = 11 }))
hl.bind(super("SHIFT+minus"), hl.dsp.window.move({ workspace = 11 }))
hl.bind(super("equal"), hl.dsp.focus({ workspace = 12 }))
hl.bind(super("equal"), hl.dsp.window.move({ workspace = 12 }))

-- Switch workspace
hl.bind(super("tab"), hl.dsp.focus({ workspace = "r+1" })) -- Go forward a workspace
hl.bind(super("SHIFT+tab"), hl.dsp.focus({ workspace = "r-1" })) -- Go backward a workspace
hl.bind(super("mouse:276"), hl.dsp.focus({ workspace = "r+1" })) -- Go forward a workspace
hl.bind(super("mouse:275"), hl.dsp.focus({ workspace = "r-1" })) -- Go backward a workspace

-- Move window to monitor
hl.bind(super("code:80"), hl.dsp.window.move({ monitor = "u" })) -- Move window to above monitor
hl.bind(super("code:88"), hl.dsp.window.move({ monitor = "d" })) -- Move window to bellow monitor
hl.bind(super("code:85"), hl.dsp.window.move({ monitor = "r" })) -- Move window to right monitor
hl.bind(super("code:83"), hl.dsp.window.move({ monitor = "l" })) -- Move window to left monitor

-- Scratchpad
hl.bind(super("D"), hl.dsp.workspace.toggle_special("magic"))
hl.bind(super("SHIFT+D"), hl.dsp.window.move({ workspace = "special:magic" }))

-- Switch with mouse
hl.bind(super("mouse_down"), hl.dsp.focus({ workspace = "e+1" }))
hl.bind(super("mouse_up"), hl.dsp.focus({ workspace = "e-1" }))
hl.bind(super("mouse_left"), hl.dsp.layout("move -col"))
hl.bind(super("mouse_right"), hl.dsp.layout("move +col"))

-- Move with mouse
hl.bind(super("mouse:272"), hl.dsp.window.drag(), { mouse = true }) -- Move with super+left click
hl.bind(super("mouse:273"), hl.dsp.window.resize(), { mouse = true }) -- Resize with super+right click
hl.bind(super("Control_L"), hl.dsp.window.drag(), { mouse = true }) -- Move with super+ctrl
hl.bind(super("ALT_L"), hl.dsp.window.resize(), { mouse = true }) -- Resize with super+alt

-- Snap
hl.bind(super("CTRL+left"), hl.dsp.exec_cmd("~/.config/hypr/scripts/snap_window.sh left")) -- Snap window left
hl.bind(super("CTRL+left"), hl.dsp.exec_cmd("~/.config/hypr/scripts/snap_window.sh right")) -- Snap window left
hl.bind(super("CTRL+up"), hl.dsp.exec_cmd("~/.config/hypr/scripts/snap_window.sh top")) -- Snap window top
hl.bind(super("CTRL+down"), hl.dsp.exec_cmd("~/.config/hypr/scripts/snap_window.sh bottom")) -- Snap window bottom

-- Group
hl.bind(super("T"), hl.dsp.group.toggle()) -- Toggle grouping
hl.bind("ALT+tab", hl.dsp.group.next()) -- Group next tab
hl.bind("ALT+SHIFT+tab", hl.dsp.group.prev()) -- Group previous tab
hl.bind(super("CTRL+SHIFT+right"), hl.dsp.group.move_window({ forward = true })) -- Group move tab forward
hl.bind(super("CTRL+SHIFT+left"), hl.dsp.group.move_window({ forward = false })) -- Group move tab backwards

-- Scrolling
hl.bind(super("A"), hl.dsp.layout("move +col")) -- Go to next column
hl.bind(super("SHIFT+A"), hl.dsp.layout("move -col")) -- Go to previous column
hl.bind(super("SHIFT+left"), hl.dsp.layout("swapcol l")) -- Swap with left column
hl.bind(super("SHIFT+right"), hl.dsp.layout("swapcol r")) -- Swap with right column
hl.bind(super("SHIFT+Q"), hl.dsp.layout("promote")) -- Make window take up full column
hl.bind(super("CTRL+Home"), hl.dsp.layout("fit tobeg")) -- Fit to first column
hl.bind(super("CTRL+End"), hl.dsp.layout("fit toend")) -- Fit to last column
hl.bind(super("ALT+right"), hl.dsp.layout("colresize +0.1")) -- Increase column width
hl.bind(super("ALT+left"), hl.dsp.layout("colresize -0.1")) -- Decrease column width

-- Functions keys
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s 10%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"), { locked = true, repeating = true })

hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
