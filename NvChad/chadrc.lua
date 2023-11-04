---@type ChadrcConfig
local M = {}

M.ui = {
  theme = 'rosepine',
  transparency = true,
  telescope = { style = "bordered" }, -- borderless / bordered

  -- I don't need tabls
  tabufline = {
    show_numbers = false,
    enabled = false,
    lazyload = false,
    overriden_modules = nil,
  },
}

M.plugins = "custom.plugins"
M.mappings = require "custom.mappings"

return M
