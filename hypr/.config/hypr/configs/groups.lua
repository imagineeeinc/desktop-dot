hl.config({
  group = {
    drag_into_group = 2,
    merge_floated_into_tiled_on_groupbar = true,

    col = {
      border_active = c.sapphire,
      border_inactive = c.surface2,
      border_locked_active = c.peach,
      border_locked_inactive = c.peach
    },
    groupbar = {
      enabled = true,
      font_size = 16,
      font_weight_active = "bold",
      height = 24,
      gradients = true,
      indicator_height = 0,
      indicator_gap = 0,

      gradient_rounding = 10,
      text_offset = 2,
      text_color = c.text,
      text_color_inactive = c.subtext0,
      col = {
        active = c.surface0,
        inactive = c.base,
        locked_active = c.surface0,
        locked_inactive = c.base
      },
      keep_upper_gap = false
    }
  }
})
