{ config, pkgs, lib, ... }: {
  # TODO: install Ltex-ls for grammar correction
  programs.neovim = {
    enable = true;
    withNodeJs = true;

    plugins = with pkgs.vimPlugins; [
      lazy-nvim
      nvim-lspconfig
      onedark-nvim

      # dependencies
      plenary-nvim
      nui-nvim

      # auto-completion
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path

      # additional plugins that we want to install need to be specified here
      which-key-nvim
      neo-tree-nvim
      flash-nvim
      toggleterm-nvim
      precognition-nvim
      hardtime-nvim
      telescope-nvim
      nvim-treesitter.withAllGrammars
      autoclose-nvim
    ];

    extraPackages = with pkgs; [ lua-language-server ltex-ls ripgrep ];

    extraLuaConfig = ''
      vim.wo.relativenumber = true
      vim.g.mapleader = " "
      vim.opt.rtp:prepend("${pkgs.vimPlugins.lazy-nvim}")
      vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], { noremap = true, silent = true })


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
            config = true,
          },
          {
            "navarasu/onedark.nvim",
            priority = 1000,
            config = function()
              require("onedark").setup({
                style = "deep"
              })
              require("onedark").load()
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
            "m4xshen/autoclose.nvim",
            config = function()
              require("autoclose").setup({})
            end,
            event = "VeryLazy",
          },
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

      vim.lsp.config['gopls'] = {
        cmd = { 'gopls' },
        filetypes = { 'go' },
        capabilities = capabilities,
      }
      vim.lsp.enable('gopls')

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
