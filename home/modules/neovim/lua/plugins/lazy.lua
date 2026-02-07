-- Plugin specifications for lazy.nvim
-- This module returns the spec array directly
return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    keys = {
      {
        "<leader>e",
        "<cmd>Neotree toggle<cr>",
        desc = "Open neo-tree",
      },
      {
        "<leader>s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Toggle flash search",
      },
      {
        "<c-/>",
        mode = { "n", "t" },
        "<cmd>ToggleTerm<cr>",
        desc = "Toggle terminal",
      },
      {
        "<M-/>",
        mode = { "n", "t" },
        function()
          local terms = require('toggleterm.terminal')
          local term = terms.get(1)
          if term and term:is_open() then
            if term.display_name == "fullscreen" then
              term:resize(math.floor(vim.o.lines * 0.3), nil)
              term.display_name = "normal"
            else
              term:resize(vim.o.lines - 2, vim.o.columns)
              term.display_name = "fullscreen"
            end
          end
        end,
        desc = "Toggle terminal fullscreen",
      },

      {
        "<leader>f",
        group = "file"
      },
      {
        "<leader>ff",
        desc = "Find files",
        mode = { "n" },
        function()
          require("telescope.builtin").find_files()
        end
      },
      {
        "<leader>fb",
        desc = "Find buffers",
        mode = { "n" },
        function()
          require("telescope.builtin").buffers()
        end
      },

      {
        "<leader>c",
        group = "code",
      },
      {
        "<leader>cd",
        desc = "Show code diagnostics",
        function()
          vim.diagnostic.open_float()
        end,
      },
      {
        "<leader>ca",
        desc = "Code actions",
        function()
          vim.lsp.buf.code_action()
        end,
      },
      {
        "<leader>cr",
        desc = "LSP rename",
        function()
          vim.lsp.buf.rename()
        end,
      },
      {
        "<C-space>",
        mode = { "i" },
        desc = "Trigger completion",
        function()
          vim.lsp.completion.get()
        end,
      },
      {
        "<leader>cz",
        desc = "Enable Zen mode",
        "<cmd>ZenMode<cr>",
      },
      {
        "<leader>gg",
        desc = "LazyGit",
        "<cmd>LazyGit<cr>",
      },

      {
        "<leader>a",
        group = "AI/Claude Code"
      },
      {
        "<leader>ac",
        "<cmd>ClaudeCode<cr>",
        desc = "Toggle Claude",
      },
      {
        "<leader>ar",
        "<cmd>ClaudeCode --resume<cr>",
        desc = "Resume Claude",
      },
      {
        "<leader>aC",
        "<cmd>ClaudeCode --continue<cr>",
        desc = "Continue Claude",
      },
      {
        "<leader>as",
        "<cmd>ClaudeCodeSend<cr>",
        mode = "v",
        desc = "Send to Claude",
      },
      {
        "<C-,>",
        "<cmd>ClaudeCode<cr>",
        mode = { "n", "t" },
        desc = "Toggle Claude",
      },

    },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    lazy = false,
  },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
  },
  {
    "tris203/precognition.nvim",
    event = "VeryLazy",
    opts = {},
  },
  {
    "nvim-telescope/telescope.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },
  {
    "akinsho/toggleterm.nvim",
    event = "VeryLazy",
    opts = {
      shell = "zsh"
    },
  },
  {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    config = function()
      require("kanagawa").setup()
      vim.cmd("colorscheme kanagawa-dragon")
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    config = function()
      require("nvim-treesitter.configs").setup({
        highlight = {
          enable = true
        },
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    lazy = false,
    config = function()
      require("treesitter-context").setup {}
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    lazy = false,
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "buffer" },
        })
      })

      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      vim.lsp.config("gopls", {
        capabilities = capabilities
      })
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    event = "VeryLazy",
    config = function()
      require('gitsigns').setup {}
    end,
  },
  {
    "m4xshen/autoclose.nvim",
    config = function()
      require("autoclose").setup({})
    end,
    event = "VeryLazy",
  },
  {
    "folke/twilight.nvim",
  },
  {
    "folke/zen-mode.nvim",
  },
  {
    "kdheepak/lazygit.nvim",
    lazy = true,
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim"
    }
  },
  {
    "coder/claudecode.nvim",
    config = true,
    dependencies = {
      "folke/snacks.nvim"
    },
  },
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({})
    end
  },
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        mode = "",
        desc = "Format buffer",
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "isort", "black" },
        go = { "goimports", "gofmt" },
        javascript = { { "prettierd", "prettier" } },
        typescript = { { "prettierd", "prettier" } },
        vue = { { "prettierd", "prettier" } },
        nix = { "nixpkgs-fmt" },
      },
      format_on_save = { timeout_ms = 500, lsp_fallback = true },
    },
  },
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {
      notification = {
        window = {
          winblend = 10,             -- 75% opacity (0 = opaque, 100 = fully transparent)
          normal_hl = "NormalFloat", -- Use Normal highlight group for background
        },
      },
    },
  }
}
