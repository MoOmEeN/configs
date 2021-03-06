---[[                                          ]]--
--                                               -
--    Powearrow Darker Awesome WM 3.5.+ config   --
--           github.com/copycat-killer           --
--                                               -
--[[                                           ]]--


-- {{{ Required Libraries

local gears 	        = require("gears")
local awful           = require("awful")
awful.rules           = require("awful.rules")
awful.autofocus       = require("awful.autofocus")
local wibox           = require("wibox")
local beautiful       = require("beautiful")
local naughty         = require("naughty")
local vicious         = require("vicious")
local scratch         = require("scratch")

local couth           = require("couth.couth")
couth.alsa            = require("couth.alsa")
-- }}}

-- {{{ Autostart

function run_once(cmd)
  findme = cmd
  firstspace = cmd:find(" ")
  if firstspace then
     findme = cmd:sub(0, firstspace-1)
  end
  awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
 end 

run_once("urxvtd")
run_once("unclutter -idle 10")

run_once("xcompmgr &")
run_once("conky -c ~/.conky/conkyrc_grey")
run_once("xflux -l 46.050569 -g 14.515171")
run_once("clipit")
run_once("volumeicon")
run_once("dropbox start")
run_once("gnome-settings-daemon &")
run_once("wicd-client")
-- }}}

-- {{{ Localization

os.setlocale(os.getenv("LANG"))

-- }}}

-- {{{ Error Handling

-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
  in_error = false
  awesome.connect_signal("debug::error", function (err)
    -- Make sure we don't go into an endless error loop
    if in_error then return end
    in_error = true

    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, an error happened!",
                     text = err })
    in_error = false
  end)
end

-- }}}

-- {{{ Variable Definitions

-- Useful Paths
home = os.getenv("HOME")
confdir = home .. "/.config/awesome"
scriptdir = confdir .. "/scripts/"
themes = confdir .. "/themes"
active_theme = themes .. "/powerarrow"

-- Themes define colours, icons, and wallpapers
beautiful.init(active_theme .. "/theme.lua")

terminal = "urxvtc"
editor = os.getenv("EDITOR") or 'vim'
editor_cmd = terminal .. " -e " .. editor

gui_editor = "subl -ps"
browser = "chromium"
mail = terminal .. " -e mutt "
chat = terminal .. " -e irssi "
tasks = terminal .. " -e htop "
iptraf = terminal .. " -g 180x54-20+34 -e sudo iptraf-ng -i all "
musicplr = terminal .. " -g 130x34-320+16 -e ncmpcpp "

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod1"
-- altkey = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
  awful.layout.suit.floating,             -- 1
  awful.layout.suit.tile,                 -- 2
  awful.layout.suit.tile.left,            -- 3
  awful.layout.suit.tile.bottom,          -- 4
  awful.layout.suit.tile.top,             -- 5
  awful.layout.suit.fair,                 -- 6
  awful.layout.suit.fair.horizontal,      -- 7
  awful.layout.suit.spiral,               -- 8
  awful.layout.suit.spiral.dwindle,       -- 9
  awful.layout.suit.max,                  -- 10
  --awful.layout.suit.max.fullscreen,     -- 11
  --awful.layout.suit.magnifier           -- 12
}

-- }}}

-- {{{ Wallpaper

if beautiful.wallpaper then
  for s = 1, screen.count() do
    gears.wallpaper.maximized(beautiful.wallpaper, s, true)
  end
end

-- }}}
                
-- {{{ Tags

-- Define a tag table which hold all screen tags.
tags = {
       names = { "Term", "Web", "Code", "Tools"},
       layout = { layouts[10], layouts[10], layouts[10], layouts[10], layouts[10] }
       }
for s = 1, screen.count() do
-- Each screen has its own tag table.
--  tags[s] = awful.tag({1,2,3,4,5}, s, layouts[10])
  tags[s] = awful.tag({"(","-","_","-",")"}, s, layouts[10])
end
-- }}}
                                          
-- {{{ Menu

require('freedesktop.utils')
freedesktop.utils.terminal = terminal  -- default: "xterm"
freedesktop.utils.icon_theme = 'Faenza' -- look inside /usr/share/icons/, default: nil (don't use icon theme)
require('freedesktop.menu')


menu_items = {}--freedesktop.menu.new()
myawesomemenu = {
   { "manual", terminal .. " -e man awesome", freedesktop.utils.lookup_icon({ icon = 'help' }) },
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua", freedesktop.utils.lookup_icon({ icon = 'package_settings' }) },
   { "restart", awesome.restart, freedesktop.utils.lookup_icon({ icon = 'gtk-refresh' }) },
   { "quit", awesome.quit, freedesktop.utils.lookup_icon({ icon = 'gtk-quit' }) }
}
table.insert(menu_items, { "awesome", myawesomemenu, beautiful.awesome_icon })
table.insert(menu_items, { "open terminal", terminal, freedesktop.utils.lookup_icon({icon = 'terminal'}) })

mymainmenu = awful.menu.new({ items = menu_items, width = 150 })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                   menu = mymainmenu })


-- }}}

-- {{{ Wibox

-- Colours
coldef  = "</span>"
colwhi  = "<span color='#b2b2b2'>"
red = "<span color='#e54c62'>"

-- Textclock widget
clockicon = wibox.widget.imagebox()
clockicon:set_image(beautiful.widget_clock)
mytextclock = awful.widget.textclock("<span font=\"Terminus 12\"><span font=\"Terminus 9\" color=\"#DDDDFF\">%H:%M</span></span>")

-- MEM widget
memicon = wibox.widget.imagebox()
memicon:set_image(beautiful.widget_mem)
memwidget = wibox.widget.textbox()
vicious.register(memwidget, vicious.widgets.mem, ' $2MB ', 13)

-- CPU widget
cpuicon = wibox.widget.imagebox()
cpuicon:set_image(beautiful.widget_cpu)
cpuwidget = wibox.widget.textbox()
vicious.register(cpuwidget, vicious.widgets.cpu, '<span background="#313131" font="Terminus 13" rise="2000"> <span font="Terminus 9">$1% </span></span>', 3)
cpuicon:buttons(awful.util.table.join(awful.button({ }, 1, function () awful.util.spawn(tasks, false) end)))

-- Temp widget
-- tempicon = wibox.widget.imagebox()
-- tempicon:set_image(beautiful.widget_temp)
-- tempicon:buttons(awful.util.table.join(awful.button({ }, 1, function () awful.util.spawn(terminal .. " -e sudo powertop ", false) end)))
-- tempwidget = wibox.widget.textbox()
-- vicious.register(tempwidget, vicious.widgets.thermal, '<span font="Terminus 9">$1°C </span>', 9, {"coretemp.0", "core"} )

-- Volume widget
volicon = wibox.widget.imagebox()
volicon:set_image(beautiful.widget_vol)
volumewidget = wibox.widget.textbox()
vicious.register(volumewidget, vicious.widgets.volume,  
function (widget, args)
  if (args[2] ~= "♩" ) then 
    if (args[1] == 0) then volicon:set_image(beautiful.widget_vol_no)
    elseif (args[1] <= 50) then  volicon:set_image(beautiful.widget_vol_low)
    else volicon:set_image(beautiful.widget_vol)
    end
  else volicon:set_image(beautiful.widget_vol_mute) 
  end
  return '<span font="Terminus 9">' .. args[1] .. '% </span>'
end, 1, "Master")

-- Net widget
netwidget = wibox.widget.textbox()
vicious.register(netwidget, vicious.widgets.net, '<span background="#313131" font="Terminus 13" rise="2000"> <span font="Terminus 9" color="#7fb219">${eth0 down_kb}</span> <span font="Terminus 7" color="#EEDDDD">↓↑</span> <span font="Terminus 9" color="#6c9eab">${eth0 up_kb} </span></span>', 3)
neticon = wibox.widget.imagebox()
neticon:set_image(beautiful.widget_net)
netwidget:buttons(awful.util.table.join(awful.button({ }, 1, function () awful.util.spawn_with_shell(iptraf) end)))

-- Separators
spr = wibox.widget.textbox(' ')
arrl = wibox.widget.imagebox()
arrl:set_image(beautiful.arrl)
arrl_dl = wibox.widget.imagebox()
arrl_dl:set_image(beautiful.arrl_dl)
arrl_ld = wibox.widget.imagebox()
arrl_ld:set_image(beautiful.arrl_ld)

-- }}}

-- {{{ Layout

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                c.minimized = true
                                              else
                                                -- Without this, the following
                                                -- :isvisible() makes no sense
                                                c.minimized = false
                                                if not c:isvisible() then
                                                    awful.tag.viewonly(c:tags()[1])
                                                end
                                                -- This will also un-minimize
                                                -- the client, if needed
                                                client.focus = c
                                                c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                instance:hide()
                                                instance = nil
                                              else
                                                instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
  
  -- Create a promptbox for each screen
  mypromptbox[s] = awful.widget.prompt()

  -- We need one layoutbox per screen.
  mylayoutbox[s] = awful.widget.layoutbox(s)
  mylayoutbox[s]:buttons(awful.util.table.join(
                          awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                          awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                          awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                          awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))

  -- Create a taglist widget
  mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

  -- Create a tasklist widget
  mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

  -- Create the upper wibox
  mywibox[s] = awful.wibox({ position = "top", screen = s, height = 18 }) 
      
  -- Widgets that are aligned to the upper left
  local left_layout = wibox.layout.fixed.horizontal()
  left_layout:add(mylauncher)
  left_layout:add(spr)
  left_layout:add(mytaglist[s])
  left_layout:add(mypromptbox[s])
  left_layout:add(spr)

  -- Widgets that are aligned to the upper right
  local right_layout = wibox.layout.fixed.horizontal()
  if s == 2 or screen.count() == 1 then right_layout:add(wibox.widget.systray()) end
--  if s == 1 then right_layout:add(wibox.widget.systray()) end
--  right_layout:add(wibox.widget.systray()) 
  right_layout:add(spr)
--  right_layout:add(arrl)
-- right_layout:add(arrl_ld)
  --right_layout:add(mpdicon)
  --right_layout:add(mpdwidget)
--  right_layout:add(arrl_dl)
--  right_layout:add(volicon)
--  right_layout:add(volumewidget)
  right_layout:add(arrl_ld)
  right_layout:add(cpuicon)
  right_layout:add(cpuwidget)
  right_layout:add(arrl_dl)
  right_layout:add(memicon)
  right_layout:add(memwidget)
    
--  right_layout:add(arrl_dl)
--  right_layout:add(tempicon)
--  right_layout:add(tempwidget)
  right_layout:add(arrl_ld)
  right_layout:add(neticon)
  right_layout:add(netwidget)
  right_layout:add(arrl_dl)
  right_layout:add(mytextclock)
  right_layout:add(spr)
  right_layout:add(arrl_ld)
  right_layout:add(mylayoutbox[s])

  -- Now bring it all together (with the tasklist in the middle)
  local layout = wibox.layout.align.horizontal()
  layout:set_left(left_layout)
  layout:set_middle(mytasklist[s])
  layout:set_right(right_layout)    
  mywibox[s]:set_widget(layout)

end

-- }}}

-- {{{ Mouse Bindings

root.buttons(awful.util.table.join(
  awful.button({ }, 4, awful.tag.viewnext),
  awful.button({ }, 5, awful.tag.viewprev)
))

-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(

    -- Capture a screenshot
    awful.key({ }, "Print", function () awful.util.spawn("scrot -e 'mv $f ~/screenshots/ 2>/dev/null'") end),

    -- Move clients
    --awful.key({ altkey }, "Next",  function () awful.client.moveresize( 1,  1, -2, -2) end),
   -- awful.key({ altkey }, "Prior", function () awful.client.moveresize(-1, -1,  2,  2) end),
   -- awful.key({ altkey }, "Down",  function () awful.client.moveresize(  0,  1,   0,   0) end),
   -- awful.key({ altkey }, "Up",    function () awful.client.moveresize(  0, -1,   0,   0) end),
   -- awful.key({ altkey }, "Left",  function () awful.client.moveresize(-1,   0,   0,   0) end),
   -- awful.key({ altkey }, "Right", function () awful.client.moveresize( 1,   0,   0,   0) end),
--    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
--    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
--    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

    -- Show/Hide Wibox
    awful.key({ modkey }, "b", function ()
    mywibox[mouse.screen].visible = not mywibox[mouse.screen].visible
    end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
               client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
--    awful.key({ modkey, "Shift"   }, "q", awesome.quit),
    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)     end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)     end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)       end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)       end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)          end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)          end),
--    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1)  end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1)  end),
    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Dropdown terminal
    awful.key({ modkey,	          }, "z",     function () scratch.drop(terminal) end),

    -- Volume control

    awful.key({ }, "XF86AudioLowerVolume",   function () couth.notifier:notify( couth.alsa:setVolume('Master','3dB-')) end),
    awful.key({ }, "XF86AudioRaiseVolume",   function () couth.notifier:notify( couth.alsa:setVolume('Master','3dB+')) end),
    awful.key({ }, "XF86AudioMute",          function () couth.notifier:notify( couth.alsa:setVolume('Master','toggle')) end),
    awful.key({ }, "XF86MonBrightnessDown", function () awful.util.spawn("xbacklight -dec 10") end),
    awful.key({ }, "XF86MonBrightnessUp", function () awful.util.spawn("xbacklight -inc 10") end),

    --[[
    awful.key({ "Control" }, "Up", function ()
                                       awful.util.spawn("amixer set Master playback 1%+", false )
                                       vicious.force({ volumewidget })
                                   end),
    awful.key({ "Control" }, "Down", function ()
                                       awful.util.spawn("amixer set Master playback 1%-", false )
                                       vicious.force({ volumewidget })
                                     end),
    awful.key({ "Control" }, "m", function ()
                                       awful.util.spawn("amixer set Master playback mute", false )
                                       vicious.force({ volumewidget })
                                     end),
    awful.key({ "Control" }, "u", function () 
                                      awful.util.spawn("amixer set Master playback unmute", false )
                                       vicious.force({ volumewidget })
                                  end),
    awful.key({ altkey, "Control" }, "m", function () 
                                              awful.util.spawn("amixer set Master playback 100%", false )
                                              vicious.force({ volumewidget })
                                          end),
    ]]--

    -- Music control
    awful.key({ altkey, "Control" }, "Up", function () 
                                              awful.util.spawn( "mpc toggle", false ) 
                                              vicious.force({ mpdwidget } )
                                           end),
    awful.key({ altkey, "Control" }, "Down", function () 
                                                awful.util.spawn( "mpc stop", false ) 
                                                vicious.force({ mpdwidget } )
                                             end ),
    awful.key({ altkey, "Control" }, "Left", function ()
                                                awful.util.spawn( "mpc prev", false )
                                                vicious.force({ mpdwidget } )
                                             end ),
    awful.key({ altkey, "Control" }, "Right", function () 
                                                awful.util.spawn( "mpc next", false )
                                                vicious.force({ mpdwidget } )
                                              end ),

    -- Copy to clipboard
    --awful.key({ modkey,        }, "c",      function () os.execute("xsel -p -o | xsel -i -b") end),

    -- User programs
    awful.key({ modkey,        }, "s",      function () awful.util.spawn(gui_editor) end),

    
    -- Prompt
    awful.key({ modkey }, "space", function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
 awful.key({modkey,            }, "F1",     function () awful.screen.focus(1) end),
 awful.key({modkey,            }, "F2",     function () awful.screen.focus(2) end)

)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, 	  }, "q",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        screen = mouse.screen
                        if tags[screen][i] then
                          awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      screen = mouse.screen
                      if tags[screen][i] then
                        awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                        awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                        awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)

-- }}}

-- {{{ Rules

awful.rules.rules = {
     -- All clients will match this rule.
     { rule = { },
       properties = { border_width = beautiful.border_width,
                      border_color = beautiful.border_normal,
                      focus = true,
                      keys = clientkeys,
                      buttons = clientbuttons,
	                    size_hints_honor = false
                     }
    },

    { rule = { class = "Chromium" },  properties = {tag = tags[1][2]}},
    { rule = { class = "sublime-text"}, properties = {tag = tags[1][3]}},
}

-- }}}

-- {{{ Signals

-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
      if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
      end
    end)

    if not startup then
      -- Set the windows at the slave,
      -- i.e. put it at the end of others instead of setting it master.
      -- awful.client.setslave(c)

      -- Put windows in a smart way, only if they does not set an initial position.
      if not c.size_hints.user_position and not c.size_hints.program_position then
        awful.placement.no_overlap(c)
        awful.placement.no_offscreen(c)
      end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
      -- buttons for the titlebar
      local buttons = awful.util.table.join(
              awful.button({ }, 1, function()
                client.focus = c
                c:raise()
                awful.mouse.client.move(c)
              end),
              awful.button({ }, 3, function()
                client.focus = c
                c:raise()
                awful.mouse.client.resize(c)
              end)
            )
      -- Widgets that are aligned to the left
      local left_layout = wibox.layout.fixed.horizontal()
      left_layout:add(awful.titlebar.widget.iconwidget(c))
      left_layout:buttons(buttons)

      -- Widgets that are aligned to the right
      local right_layout = wibox.layout.fixed.horizontal()
      right_layout:add(awful.titlebar.widget.floatingbutton(c))
      right_layout:add(awful.titlebar.widget.maximizedbutton(c))
      right_layout:add(awful.titlebar.widget.stickybutton(c))
      right_layout:add(awful.titlebar.widget.ontopbutton(c))
      right_layout:add(awful.titlebar.widget.closebutton(c))

      -- The title goes in the middle
      local middle_layout = wibox.layout.flex.horizontal()
      local title = awful.titlebar.widget.titlewidget(c)
      title:set_align("center")
      middle_layout:add(title)
      middle_layout:buttons(buttons)

      -- Now bring it all together
      local layout = wibox.layout.align.horizontal()
      layout:set_left(left_layout)
      layout:set_right(right_layout)
      layout:set_middle(middle_layout)

      awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- }}}
