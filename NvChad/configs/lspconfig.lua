local base = require("plugins.configs.lspconfig")
local on_attach = base.on_attach
local capabilities = base.capabilities

local lspconfig = require("lspconfig")

lspconfig.clangd.setup {
  on_attach = function(client, bufnr)
    client.server_capabilities.signatureHelpProvider = false
    on_attach(client, bufnr)
  end,
  capabilities = capabilities,
  -- default file types for clangd
  -- filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" }
  -- removed proto from clangd because bufls better for proto
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda" }
}

lspconfig.bufls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = { "bufls", "serve" },
  filetypes = { "proto" },
}

lspconfig.cmake.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = { "cmake-language-server" },
  filetyps = { "cmake" },
  init_options = { buildDirectory = "build" },
  root_dir = lspconfig.util.root_pattern('CMakePresets.json', "CTestConfig.cmake", '.git', 'build', 'cmake')
}
