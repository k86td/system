{ config, pkgs, lib, ... }: {
  # TODO: install Ltex-ls for grammar correction
  programs.neovim = {
    enable = true;
    withNodeJs = true;

    plugins = with pkgs.vimPlugins; [
      lazy-nvim

      # additional plugins that we want to install need to be specified here
      which-key-nvim
      neo-tree-nvim
      flash-nvim
      toggleterm-nvim
      nui-nvim
      precognition-nvim
      hardtime-nvim
    ];

    extraPackages = with pkgs; [ lua-language-server ltex-ls ];

    extraLuaConfig = ''
      vim.wo.relativenumber = true
      vim.g.mapleader = " "
      vim.opt.rtp:prepend("${pkgs.vimPlugins.lazy-nvim}")

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
                desc = "Toggle terminal",
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
            --event = "VeryLazy",
            opts = {
            -- startVisible = true,
            -- showBlankVirtLine = true,
            -- highlightColor = { link = "Comment" },
            -- hints = {
            --      Caret = { text = "^", prio = 2 },
            --      Dollar = { text = "$", prio = 1 },
            --      MatchingPair = { text = "%", prio = 5 },
            --      Zero = { text = "0", prio = 1 },
            --      w = { text = "w", prio = 10 },
            --      b = { text = "b", prio = 9 },
            --      e = { text = "e", prio = 8 },
            --      W = { text = "W", prio = 7 },
            --      B = { text = "B", prio = 6 },
            --      E = { text = "E", prio = 5 },
            -- },
            -- gutterHints = {
            --     G = { text = "G", prio = 10 },
            --     gg = { text = "gg", prio = 9 },
            --     PrevParagraph = { text = "{", prio = 8 },
            --     NextParagraph = { text = "}", prio = 8 },
            -- },
            -- disabled_fts = {
            --     "startify",
            -- },
            },
          }
        },
      })

      -- TODO: move this to its own LSP plugin
      vim.lsp.config['luals'] = {
        cmd = { 'lua-language-server' },
        filetypes = { 'lua' },
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
    '';
  };

  xdg.configFile."nvim/lua" = {
    recursive = true;
    source = ./lua;
  };
}
