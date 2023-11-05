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

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.colorcolumn = "80"

-- auto-reload files when modified externally
-- https://unix.stackexchange.com/a/383044
vim.opt.autoread = true
-- vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "CursorHoldI", "FocusGained" }, {
-- 	command = "if mode() != 'c' | checktime | endif",
-- 	pattern = { "*" },
-- })

return M
