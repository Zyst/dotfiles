-- BAR hotkey config file: ergokeys for grid menu, 60% keyboards
-- Based on https://github.com/beyond-all-reason/Beyond-All-Reason/blob/45b383a1aebf3cb95fdc2b4132823ad5939e1b2f/luaui/configs/bar_hotkeys_grid_60.lua
-- remap F-keys to use meta+ (spacebar) and ` to Q with modifiers
local bindings = {
   {            "esc", "select", "AllMap++_ClearSelection+" },
   {            "esc", "quitmessage"                },
   {      "Shift+esc", "quitmenu"                   },
   { "Ctrl+Shift+esc", "quitforce"                  },
   {  "Alt+Shift+esc", "reloadforce"                },
   {     "Any+escape", "edit_escape"                },
   {      "Any+pause", "pause"                      },
   {            "esc", "teamstatus_close"           },
   {            "esc", "customgameinfo_close"       },
   {            "esc", "buildmenu_pregame_deselect" },

   {  "Any+sc_x", "selectbox_same"     }, -- select only units that share type with current selection modifier | Smart Select Widget
   { "Any+space", "selectbox_idle"     }, -- select only idle units modifier | Smart Select Widget
   { "Any+shift", "selectbox_all"      }, -- select all units modifier | Smart Select Widget
   {  "Any+ctrl", "selectbox_deselect" }, -- remove units from current selection modifier | Smart Select Widget
   {   "Any+alt", "selectbox_mobile"   }, -- select only mobile units modifier | Smart Select Widget

   {      "Any+space", "selectloop"        }, -- activate select shape | Loop Select Widget
   {       "Any+ctrl", "selectloop_invert" }, -- select units not present in current selection modifier | Loop Select Widget
   {      "Any+shift", "selectloop_add"    }, -- add to selection modifier | Loop Select Widget

   {           "sc_x", "gridmenu_category 1" },
   {           "sc_c", "gridmenu_category 2" },
   {           "sc_d", "gridmenu_category 3" },
   {           "sc_v", "gridmenu_category 4" },
   {     "Shift+sc_x", "gridmenu_category 1" },
   {     "Shift+sc_c", "gridmenu_category 2" },
   {     "Shift+sc_d", "gridmenu_category 3" },
   {     "Shift+sc_v", "gridmenu_category 4" },
   {       "Any+sc_x", "gridmenu_key 1 1"    },
   {       "Any+sc_c", "gridmenu_key 1 2"    },
   {       "Any+sc_d", "gridmenu_key 1 3"    },
   {       "Any+sc_v", "gridmenu_key 1 4"    },
   {       "Any+sc_a", "gridmenu_key 2 1"    },
   {       "Any+sc_r", "gridmenu_key 2 2"    },
   {       "Any+sc_s", "gridmenu_key 2 3"    },
   {       "Any+sc_t", "gridmenu_key 2 4"    },
   {       "Any+sc_q", "gridmenu_key 3 1"    },
   {       "Any+sc_w", "gridmenu_key 3 2"    },
   {       "Any+sc_f", "gridmenu_key 3 3"    },
   {       "Any+sc_p", "gridmenu_key 3 4"    },
   {           "sc_z", "gridmenu_next_page"  },
   {           "sc_k", "gridmenu_prev_page"  },

   -- { "Any+"..H, "sharedialog"    }, deprecated by player list sharing
   -- { "Shift+backspace", "togglecammode" },
   -- {         "Any+"..P, "toggleoverview" },

   {     "Any+enter", "chat"           },
   {  "Alt+ctrl+sc_a", "chatswitchally" },
   {  "Alt+ctrl+sc_r", "chatswitchspec" },

   {       "Any+tab", "edit_complete"  },
   { "Any+backspace", "edit_backspace" },
   {    "Any+delete", "edit_delete"    },
   {      "Any+home", "edit_home"      },
   {      "Alt+left", "edit_home"      },
   {       "Any+end", "edit_end"       },
   {     "Alt+right", "edit_end"       },
   {        "Any+up", "edit_prev_line" },
   {      "Any+down", "edit_next_line" },
   {      "Any+left", "edit_prev_char" },
   {     "Any+right", "edit_next_char" },
   {     "Ctrl+left", "edit_prev_word" },
   {    "Ctrl+right", "edit_next_word" },
   {     "Any+enter", "edit_return"    },

   { "Ctrl+v", "pastetext" },

   { "Alt+sc_=",    "increasespeed" },
   { "Alt+sc_-",    "decreasespeed" },
   { "Alt+numpad+", "increasespeed" },
   { "Alt+numpad-", "decreasespeed" },

   {       "sc_[", "buildfacing" , "inc" },
   { "Shift+sc_[", "buildfacing" , "inc" },
   {       "sc_]", "buildfacing" , "dec" },
   { "Shift+sc_]", "buildfacing" , "dec" },

   {       "Alt+sc_x", "buildspacing", "inc" },
   { "Shift+Alt+sc_x", "buildspacing", "inc" },
   {       "Alt+sc_c", "buildspacing", "dec" },
   { "Shift+Alt+sc_c", "buildspacing", "dec" },

   {            "sc_a", "attack"          },
   {      "Shift+sc_a", "attack"          },
   {       "Ctrl+sc_a", "areaattack"      },
   { "Ctrl+Shift+sc_a", "areaattack"      },
   {            "sc_z", "onoff"           },
   {      "Shift+sc_z", "onoff"           },
   {       "Ctrl+sc_z", "selfd"           },
   { "Ctrl+Shift+sc_z", "selfd", "queued" },
   {            "sc_s", "manualfire"      },
   {      "Shift+sc_s", "manualfire"      },
   {            "sc_s", "manuallaunch"    },
   {      "Shift+sc_s", "manuallaunch"    },
   {            "sc_f", "reclaim"         },
   {      "Shift+sc_f", "reclaim"         },
   {            "sc_t", "fight"           },
   {      "Shift+sc_t", "fight"           },
   {        "Alt+sc_t", "forcestart"      },
   {            "sc_g", "stopproduction"  },
   {      "Shift+sc_g", "stopproduction"  },
   {            "sc_g", "stop"            },
   {      "Shift+sc_g", "stop"            },
   {            "sc_m", "patrol"          },
   {      "Shift+sc_m", "patrol"          },
   {            "sc_u", "unit_stats"      },
   {       "Ctrl+sc_u", "customgameinfo"  },
   {            "sc_n", "loadunits"       },
   {      "Shift+sc_n", "loadunits"       },
   {            "sc_e", "cloak"           },
   {      "Shift+sc_e", "cloak"           },
   {            "sc_e", "wantcloak"       },
   {        "Any+sc_e", "wantcloak"       },
   {            "sc_i", "firestate"       },
   {      "Shift+sc_i", "firestate"       },
   {            "sc_o", "movestate"       },
   {      "Shift+sc_o", "movestate"       },
   {            "sc_h", "restore"         },
   {      "Shift+sc_h", "restore"         },
   {            "sc_k", "settargetnoground" },
   {            "sc_y", "guard"           },
   {      "Shift+sc_y", "guard"           },
   {        "Alt+sc_y", "cameraflip"      },
   {            "sc_p", "repair"          },
   {      "Shift+sc_p", "repair"          },
   {            "sc_r", "settarget"       },
   {       "Ctrl+sc_r", "canceltarget"    },
   {            "sc_b", "repeat"          },
   {      "Shift+sc_b", "repeat"          },
   {            "sc_l", "unloadunits"     },
   {      "Shift+sc_l", "unloadunits"     },
   {            "sc_w", "resurrect"       },
   {      "Shift+sc_w", "resurrect"       },
   {            "sc_w", "capture"         },
   {      "Shift+sc_w", "capture"         },
   {            "sc_j", "wait"            },
   {      "Shift+sc_j", "wait", "queued"  },
   {       "Ctrl+sc_x", "areamex"         },

   { "Any+sc_'", "togglelos"             },
   { "Any+sc_'", "losradar"              },

   { "meta+1", "LastMsgPos"             },
   { "meta+2", "ShowPathTraversability" },
   { "meta+3", "ShowMetalMap"           },
   { "meta+4", "ShowElevation"          },
   { "meta+5", "viewta"                 },
   { "meta+6", "viewspring"             },

   {    "f11" , "luaui selector"         },
   { "Any+f12", "screenshot"     , "png" },
   { "Alt+backspace", "fullscreen"       },

   {      "Ctrl+meta+sc_q", "group unset"           },
   {            "Alt+sc_q", "remove_from_autogroup" },
   { "meta+sc_q,meta+sc_q", "drawlabel"             },
   {           "meta+sc_q", "drawinmap"             },

   { "Any+up",       "moveforward"  },
   { "Any+down",     "moveback"     },
   { "Any+right",    "moveright"    },
   { "Any+left",     "moveleft"     },
   { "Any+pageup",   "moveup"       },
   { "Any+pagedown", "movedown"     },

   { "Any+alt",   "movereset"  }, -- fast camera reset on mousewheel
   { "Any+alt",   "moverotate" }, -- rotate on x,y with mmb hold + move (Spring Camera)
   { "Any+ctrl",  "movetilt"   }, -- rotate on x with mousewheel

   { "Ctrl+sc_f",    "select", "AllMap++_ClearSelection_SelectAll+"                                                                                       },
   {      "sc_q",    "select", "Visible+_InPrevSel+_ClearSelection_SelectAll+"                                                                            },
   { "Ctrl+sc_q",    "select", "PrevSelection++_ClearSelection_SelectPart_50+"                                                                            },
   { "Ctrl+sc_w",    "select", "AllMap+_InPrevSel+_ClearSelection_SelectAll+"                                                                             },

   -- We steal Tab behavior from default keymap, and rebind select
   -- commander/idle worker to other keys instead
   { "Any+tab", "toggleoverview" },

   { "Ctrl+sc_d", "select", "AllMap+_Builder_Idle+_ClearSelection_SelectOne+"                                                                       },
   { "Ctrl+sc_c", "select", "AllMap+_ManualFireUnit_Not_IdMatches_cordecom_Not_IdMatches_armdecom_Not_IdMatches_armthor+_ClearSelection_SelectOne+" },

   -- numpad movement
   { "numpad2", "moveback"    },
   { "numpad6", "moveright"   },
   { "numpad4", "moveleft"    },
   { "numpad8", "moveforward" },
   { "numpad9", "moveup"      },
   { "numpad3", "movedown"    },
   { "numpad1", "movefast"    },

   -- snd_volume_osd
   { "backspace", "MuteSound" },
   { "numpad+", "snd_volume_increase" },
   { "   sc_=", "snd_volume_increase" },
   { "   sc_-", "snd_volume_decrease" },
   { "numpad-", "snd_volume_decrease" },
}

--	table.insert(bindings,  })
for i = 0, 9 do
   table.insert(bindings, { 'Alt+'..i , "add_to_autogroup", i })

   table.insert(bindings, { i               , "group", i                  })
   table.insert(bindings, { 'Ctrl+'..i      , "group", "set "..i          })
   table.insert(bindings, { 'Shift+'..i     , "group", "add "..i    })
   table.insert(bindings, { 'Ctrl+Shift+'..i, "group", "selectadd "..i          })
   table.insert(bindings, { 'Ctrl+Alt+'..i  , "group", "selecttoggle "..i })

end

--camera anchors in default 60% Grid, commented out, we use 1-4 for map/game controls
-- for i = 1, 4 do
--    table.insert(bindings, { 'Ctrl+meta+'..i , "set_camera_anchor", i })
--    table.insert(bindings, { 'meta+'..i , "focus_camera_anchor", i })

-- end

return bindings
