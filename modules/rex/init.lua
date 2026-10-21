-- Preserve the tmux navigation and prefix bindings used elsewhere in these
-- dotfiles while leaving Rex's native shortcuts available.
local prefix = "ctrl+s>"

-- Keep the color scheme reproducible while using Rex's supported Ghostty
-- theme importer. This action can be run again after the theme changes.
rex.action({
  name = "apply_dotfiles_theme",
  title = "Apply Dotfiles Theme",
  category = "View",
  run = function()
    local home = os.getenv("HOME")
    if home == nil then
      error("HOME is not set", 0)
    end

    rex.client.queue("client.theme.import", {
      path = home .. "/.config/rex/themes/joncarl",
    })
  end,
})

-- Pane navigation. tmux stops at the edge, so disable Rex's default wrapping.
rex.bind("ctrl+h", "pane.focus", { direction = "left", wrap = false })
rex.bind("ctrl+j", "pane.focus", { direction = "down", wrap = false })
rex.bind("ctrl+k", "pane.focus", { direction = "up", wrap = false })
rex.bind("ctrl+l", "pane.focus", { direction = "right", wrap = false })

-- Fine and coarse pane resizing. Rex measures amounts as percentages rather
-- than terminal cells, so these retain the relative small/large steps.
rex.bind("alt+left", "pane.resize", { direction = "left", amount = 2 })
rex.bind("alt+right", "pane.resize", { direction = "right", amount = 2 })
rex.bind("alt+down", "pane.resize", { direction = "down", amount = 2 })
rex.bind("alt+up", "pane.resize", { direction = "up", amount = 2 })

rex.bind("ctrl+left", "pane.resize", { direction = "left", amount = 10 })
rex.bind("ctrl+right", "pane.resize", { direction = "right", amount = 10 })
rex.bind("ctrl+down", "pane.resize", { direction = "down", amount = 5 })
rex.bind("ctrl+up", "pane.resize", { direction = "up", amount = 5 })

-- tmux-compatible prefix sequences.
rex.bind(prefix .. "c", "client.tab.new")
rex.bind(prefix .. "n", "client.tab.next")
rex.bind(prefix .. "p", "client.tab.previous")
for index = 1, 9 do
  rex.bind(prefix .. tostring(index), "client.tab.goto", { index = index })
end
rex.bind(prefix .. "-", "pane.split", { direction = "down" })
rex.bind(prefix .. "[Backslash]", "pane.split", { direction = "right" })
rex.bind(prefix .. "z", "pane.zoom")
rex.bind(prefix .. "x", "pane.close")
rex.bind(prefix .. "b", "pane.move_to_new_tab")
rex.bind(prefix .. "ctrl+j", "session.switch")

-- Once Ctrl+S starts a sequence, provide a way to send it to the terminal.
rex.bind(prefix .. "ctrl+s", "pane.send_key", { key = "ctrl+s" })
