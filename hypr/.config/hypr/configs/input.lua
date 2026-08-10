hl.config({
  input = {
    kb_layout  = "gb",
    kb_variant = "",
    kb_model   = "",
    kb_options = "",
    kb_rules   = "",
    numlock_by_default = true,

    follow_mouse = 1,
    follow_mouse_shrink = 10,

    sensitivity = 0,
    special_fallthrough = true,
    emulate_discrete_scroll = 1,
    scroll_factor = 1,
    -- force_no_accel = true,
    touchpad = {
      natural_scroll = true,
      scroll_factor = 0.7,
      disable_while_typing = false
    },
  },
  gestures = {
    workspace_swipe_distance = 200,
    workspace_swipe_cancel_ratio = 0.2,
    workspace_swipe_forever = true,
    workspace_swipe_direction_lock_threshold = 1920
  }
})

hl.gesture({
  fingers = 4,
  direction = "horizontal",
  action = "workspace",
})
hl.gesture({
  fingers = 3,
  direction = "horizontal",
  action = "scroll_move",
})
hl.gesture({
  fingers = 3,
  direction = "pinch",
  mods = "SUPER",
  action = "float",
})
hl.gesture({
  fingers = 4,
  direction = "swipe",
  mods = "SUPER",
  action = "move",
})
hl.gesture({
  fingers = 3,
  direction = "swipe",
  mods = "SUPER",
  action = "resize",
})
