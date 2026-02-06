require("nvchad.configs.lspconfig").defaults()

local servers = { "html", "cssls", "clangd", "rust_analyzer" }

vim.lsp.enable(servers)
