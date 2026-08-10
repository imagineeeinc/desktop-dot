hl.config({
  general = {
    gaps_in  = 5,
    gaps_out = 15,

    border_size = 1,

    col = {
      active_border = {
        colors = {c.blue, c.sapphire, c.sky, c.teal},
        angle = 45
      },
      inactive_border = c.overlay1,
    },
    resize_on_border = true,
    allow_tearing = false,
    layout = "scrolling",
  },

  decoration = {
    rounding = 10,
    rounding_power = 3,

    active_opacity = 1.0,
    inactive_opacity = 1.0,

    shadow = {
      enabled = true,
      range = 10,
      render_power = 10,
      color = c.surface1,
    },
    blur = {
      enabled = true,
      size = 3,
      passes = 2,
      vibrancy = 0.1696,
      vibrancy_darkness = 0,
      input_methods = true
    },
    -- motion_blur = {
    --   enabled = true,
    --   samples = 10
    -- }
  },
  animations = {
    enabled = true,
  },
})
