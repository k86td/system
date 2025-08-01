{ config, pkgs, lib, ... }: {

  programs.neovide = {
    enable = true;
  };

  # TODO: install Ltex-ls for grammar correction
  programs.neovim = {
    enable = true;
    withNodeJs = true;

    plugins = with pkgs.vimPlugins; [
      lazy-nvim
      nvim-lspconfig
      kanagawa-nvim
      nvim-web-devicons
      mini-icons
      snacks-nvim
      nvim-treesitter-context
      gitsigns-nvim

      claudecode-nvim

      # dependencies
      plenary-nvim
      nui-nvim

      # auto-completion
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path

      # additional plugins that we want to install need to be specified here
      lazygit-nvim
      twilight-nvim
      zen-mode-nvim
      which-key-nvim
      neo-tree-nvim
      flash-nvim
      toggleterm-nvim
      precognition-nvim
      hardtime-nvim
      telescope-nvim
      nvim-treesitter.withAllGrammars
      autoclose-nvim
      nvim-surround
      conform-nvim
    ];

    extraPackages = with pkgs; [ lua-language-server ltex-ls ripgrep lazygit claude-code pyright ];

    extraLuaConfig = ''
      vim.wo.relativenumber = true
      vim.g.mapleader = " "
      vim.opt.rtp:prepend("${pkgs.vimPlugins.lazy-nvim}")

      if vim.g.neovide then
        vim.g.neovide_scale_factor = 0.75
        vim.o.guifont = "Hurmit Nerd Font:h14"
      end

      -- TODO: move this into toggleterm configuration
      -- allows to exit TERMINAL mode inside toggleterm with Esc (but not lazygit or claudecode)
      vim.keymap.set('t', '<Esc>', function()
        if vim.bo.filetype == 'lazygit' then
          return '<Esc>'
        else
          return [[<C-\><C-n>]]
        end
      end, { noremap = true, silent = true, expr = true })
      vim.o.mouse = ""


      vim.opt.tabstop = 2
      vim.opt.shiftwidth = 2
      vim.opt.expandtab = true
      vim.bo.softtabstop = 2

      require("lazy").setup({
        performance = {
          reset_packpath = false,
          rtp = {
            reset = false,
          },
        },
        dev = {
          path = "${
            pkgs.vimUtils.packDir
            config.programs.neovim.finalPackage.passthru.packpathDirs
          }/pack/myNeovimPackages/start",
          patterns = {""},
        },
        install = {
          missing = false,
        },
        spec = {
          -- here's where you want to add plugins and stuffies
          -- { import = "plugins" },
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
                mode =  { "n", "x", "o" },
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
            event = VeryLazy,
          },
          {
            "m4xshen/hardtime.nvim",
            lazy = false,
            dependencies = { "MunifTanjim/nui.nvim" },
            opts = {},
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
              vim.cmd("colorscheme kanagawa-wave")
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
              require("treesitter-context").setup{}
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
              require('gitsigns').setup{}
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
                nix = { "nixpkgs-fmt" },
              },
              format_on_save = { timeout_ms = 500, lsp_fallback = true },
            },
          }
        },
      })

      -- TODO: move this to its own LSP plugin
      local lspconfig = require("lspconfig")
      vim.lsp.config['luals'] = {
        cmd = { 'lua-language-server' },
        filetypes = { 'lua' },
        capabilities = capabilities,
      }
      vim.lsp.enable('luals')

      vim.lsp.config['ltex'] = {
        cmd = { 'ltex-ls' },
        filetypes = { "typst", "markdown" },
        settings = {
          ltex = {
            language = "fr",
          },
        },
      }
      vim.lsp.enable('ltex')

      require'lspconfig'.terraformls.setup{}

      vim.lsp.config['gopls'] = {
        cmd = { 'gopls' },
        filetypes = { 'go' },
        capabilities = capabilities,
      }
      vim.lsp.enable('gopls')

      vim.lsp.config['pyright'] = {
        cmd = { 'pyright-langserver', '--stdio' },
        filetypes = { 'python' },
        capabilities = capabilities,
      }
      vim.lsp.enable('pyright')

      vim.diagnostic.config({
        virtual_text = {
          prefix = "●",  -- You can use "", "●", "■", "▶", etc.
          spacing = 4,   -- Space between code and the message
        },
        signs = true,     -- Keeps the sign column indicators
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })

    '';
  };

  xdg.configFile."nvim/lua" = {
    recursive = true;
    source = ./lua;
  };
}
