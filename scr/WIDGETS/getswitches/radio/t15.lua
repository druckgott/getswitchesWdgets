return {
  -- Tabelle für die Switches
  sw = {
    -- switch A
    { switchcfgname = "SA", switchcfgpos_x = 20, switchcfgpos_y = 140, u = CHAR_UP, m = '-', d = CHAR_DOWN },
    -- switch B
    { switchcfgname = "SB", switchcfgpos_x = 360, switchcfgpos_y = 140, u = CHAR_UP, m = '-', d = CHAR_DOWN },
    -- switch C
    { switchcfgname = "SC", switchcfgpos_x = 100, switchcfgpos_y = 80, u = CHAR_UP, m = '-', d = CHAR_DOWN },
    -- switch D
    { switchcfgname = "SD", switchcfgpos_x = 280, switchcfgpos_y = 80, u = CHAR_UP, m = '-', d = CHAR_DOWN },
    -- switch E
    { switchcfgname = "SE", switchcfgpos_x = 20, switchcfgpos_y = 20, u = CHAR_UP, d = CHAR_DOWN },
    -- switch F
    { switchcfgname = "SF", switchcfgpos_x = 360, switchcfgpos_y = 20, u = CHAR_UP, d = CHAR_DOWN },
    -- switch G
    --{ switchcfgname = "SG", switchcfgpos_x = 130, switchcfgpos_y = 140, u = CHAR_UP, d = CHAR_DOWN },
    -- switch H
    --{ switchcfgname = "SH", switchcfgpos_x = 150, switchcfgpos_y = 160, u = CHAR_UP, d = CHAR_DOWN },
    -----------------------------------------------------------------------------------------------------
    -- switch SW1
    { switchcfgname = "SW1", switchcfgpos_x = 80, switchcfgpos_y = 250, u = CHAR_UP, d = CHAR_DOWN },
    -- switch SW2
    { switchcfgname = "SW2", switchcfgpos_x = 160, switchcfgpos_y = 250, u = CHAR_UP, d = CHAR_DOWN },
    -- switch SW3
    { switchcfgname = "SW3", switchcfgpos_x = 160, switchcfgpos_y = 225, u = CHAR_UP, d = CHAR_DOWN },
    -- switch SW4
    { switchcfgname = "SW4", switchcfgpos_x = 260, switchcfgpos_y = 225, u = CHAR_UP, d = CHAR_DOWN },
    -- switch SW5
    { switchcfgname = "SW5", switchcfgpos_x = 260, switchcfgpos_y = 250, u = CHAR_UP, d = CHAR_DOWN },
    -- switch SW6
    { switchcfgname = "SW6", switchcfgpos_x = 340, switchcfgpos_y = 250, u = CHAR_UP, d = CHAR_DOWN },
    
  },
  --
  widget_area_x = 480,
  widget_area_y = 275,
  --
  switch_box_size_x = 100,
  switch_box_size_y = 50,
  switch_box_size_radius = 15,
    --
  switch_push_size_x = 60,
  switch_push_size_y = 20,
  switch_push_size_radius = 5,
  --
  pos_switch_offset_up = 0,
  pos_switch_offset_center = 15,
  pos_switch_offset_down = 30,
}