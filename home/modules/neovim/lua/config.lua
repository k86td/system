-- Main entry point for Neovim configuration
-- This file bootstraps all configuration modules

-- Load basic vim options
require("config.options")

-- Load custom keymaps
require("config.keymaps")

-- Load diagnostic configuration
require("config.diagnostics")

-- Load LSP configurations
require("lsp.ltex")
require("lsp.gopls")
require("lsp.pyright")
require("lsp.rust")
