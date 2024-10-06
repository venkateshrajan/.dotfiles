require "nvchad.mappings"

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map("n", "<leader>a", function ()
  require("harpoon.mark").add_file()
end, {desc = "󱡁 Harpoon Add file"})

map("n", "<C-e>", function ()
  require("harpoon.ui").toggle_quick_menu()
end, {desc = "󱠿 Harpoon Menu"})

map("n", "<C-h>", function ()
  require("harpoon.ui").nav_file(1)
end, {desc = "󱪼 Navigate to file 1"})

map("n", "<C-j>", function ()
  require("harpoon.ui").nav_file(2)
end, {desc = "󱪼 Navigate to file 2"})

map("n", "<C-k>", function ()
  require("harpoon.ui").nav_file(3)
end, {desc = "󱪼 Navigate to file 3"})

map("n", "<C-l>", function ()
  require("harpoon.ui").nav_file(4)
end, {desc = "󱪼 Navigate to file 4"})

map("n", "<leader>gs", "<cmd> Git <CR>", {desc = "Open Fugitive"})

-- For terminal splits
map("t", "<C-w>", "<C-\\><C-n><C-w>", {desc = "C-w for terminal"})
