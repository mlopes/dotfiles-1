local application = require "hs.application"
local window = require "hs.window"
local hotkey = require "hs.hotkey"
local keycodes = require "hs.keycodes"
local fnutils = require "hs.fnutils"
local alert = require "hs.alert"
local screen = require "hs.screen"
local grid = require "hs.grid"
local hints = require "hs.hints"
local appfinder = require "hs.appfinder"

function notify(message)
    hs.notify.new({title="Hammerspoon", informativeText=message}):send():release()
end

function reloadConfig(files)
    doReload = false
    for _,file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
        notify("Config loaded")
    end
end


local definitions = nil
local hyper = nil
local disableKeys = false

local gridset = function(frame)
    return function()
        local win = window.focusedWindow()
        if win then
            grid.set(win, frame, win:screen())
        else
            alert.show("No focused window.")
        end
    end
end

auxWin = nil
function saveFocus()
  auxWin = window.focusedWindow()
  alert.show("Window '" .. auxWin:title() .. "' saved.")
end
function focusSaved()
  if auxWin then
    auxWin:focus()
  end
end

local hotkeys = {}

function createHotkeys()
  for key, fun in pairs(definitions) do
    local mod = hyper
    local hk = hotkey.new(mod, key, fun)
    table.insert(hotkeys, hk)
    hk:enable()
  end
end

function rebindHotkeys()
    if disableKeys then
        for i, hk in ipairs(hotkeys) do
            hk:disable()
        end
        hotkeys = {}
        alert.show("Disabled hotkeys")
    else
        createHotkeys()
        alert.show("Enabled hotkeys")
    end
end

function applyPlace(win, place)
  local scrs = screen:allScreens()
  local scr = scrs[place[1]]
  grid.set(win, place[2], scr)
end

function applyLayout(layout)
  return function()
    for appName, place in pairs(layout) do
      local app = appfinder.appFromName(appName)
      if app then
        for i, win in ipairs(app:allWindows()) do
          applyPlace(win, place)
        end
      end
    end
  end
end

function init()
  createHotkeys()
  keycodes.inputSourceChanged(rebindHotkeys)

  alert.show("Hammerspoon, at your service.")
end

-- config:
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()



hyper = {"alt"}

hs.window.animationDuration = 0.02;
-- Set grid size.
grid.GRIDWIDTH  = 6
grid.GRIDHEIGHT = 8
grid.MARGINX = 0
grid.MARGINY = 0
local gw = grid.GRIDWIDTH
local gh = grid.GRIDHEIGHT

local gomiddle = {x = 1, y = 1, w = 4, h = 6}
local goleft = {x = 0, y = 0, w = gw/2, h = gh}
local goright = {x = gw/2, y = 0, w = gw/2, h = gh}
local gobig = {x = 0, y = 0, w = gw, h = gh}

local fullApps = {
  "Safari","Aurora","Nightly","Xcode","Qt Creator","Google Chrome",
  "Google Chrome Canary", "Eclipse", "Coda 2", "iTunes", "Emacs", "Firefox",
  "Opera Mail"
}
local layout2 = {
  --Airmail = {1, gomiddle},
  --Spotify = {1, gomiddle},
  --Calendar = {1, gomiddle},
  --Dash = {1, gomiddle},
  iTerm = {1, goright},
  --MacRanger = {2, goleft},
}
fnutils.each(fullApps, function(app) layout2[app] = {1, gobig} end)

definitions = {
  [";"] = saveFocus,
  a = focusSaved,

  Down = gridset(gomiddle),
  Left = gridset(goleft),
  Up = grid.maximizeWindow,
  Right = gridset(goright),

  g = applyLayout(layout2),

  d = grid.pushWindowNextScreen,
  r = hs.reload,
--  q = function() appfinder.appFromName("Hammerspoon"):kill() end,

  j = function() hints.windowHints(window.focusedWindow():application():allWindows()) end,
  e = hints.windowHints
}

hotkey.bind(hyper, "\\", function() disableKeys = not disableKeys; rebindHotkeys() end)

-- launch and focus applications
fnutils.each({
  { key = "i", app = "Google Chrome" },
  { key = "o", app = "Emacs" },
  { key = "p", app = "iTerm 2" },
  { key = "[", app = "Opera Mail" },
  { key = "]", app = "Slack" }
}, function(object)
    definitions[object.key] = function()
      application.launchOrFocus(object.app)
    end
end)

init()
