return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = require "configs.conform",
  },

  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim", "lua", "vimdoc",
        "html", "css",
        "cpp", "c", "cmake",
        "python", "toml",
        "json", "yaml", "markdown",
      },
    },
  },

  {
    "shellRaining/hlchunk.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("hlchunk").setup {
        chunk = {
          enable = true,
          style = { { fg = "#806d9c" } },
          use_treesitter = true,
          chars = {
            horizontal_line = "─",
            vertical_line = "│",
            left_top = "╭",
            left_bottom = "╰",
            right_arrow = "->",
          },
          duration = 200,
          delay = 100,
        },
        indent = {
          enable = true,
          style = { { fg = "#3b4261" } },
        },
        line_num = {
          enable = true,
        },
        blank = {
          enable = false,
        },
      }
    end,
  },

  {
    "mfussenegger/nvim-dap",
    config = function()
      require "configs.dap"
    end,
  },

  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    config = function()
      require("dapui").setup()
    end,
  },

  {
    "theHamsta/nvim-dap-virtual-text",
    config = function()
      require("nvim-dap-virtual-text").setup()
    end,
  },

  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = { "mason-org/mason.nvim", "mfussenegger/nvim-dap" },
    opts = {
      ensure_installed = { "codelldb", "debugpy" },
      automatic_installation = true,
    },
  },

  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = {
        "clangd",
        "pyright",
        "html-lsp",
        "css-lsp",
        "cmake-language-server",
        "clang-format",
        "ruff",
        "codelldb",
        "debugpy",
        "stylua",
      },
      auto_update = false,
      run_on_start = false,
    },
  },

  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
  },

  {
    "chikko80/error-lens.nvim",
    lazy = false,
    enabled = false,  -- disabled: replaced by smart diagnostic handler
    config = function()
      require("error-lens").setup {
        enabled = true,
        auto_adjust = { enable = false },
      }
      vim.api.nvim_create_autocmd("VimEnter", {
        once = true,
        callback = function()
          vim.diagnostic.config { error_lens = true, virtual_text = false }
        end,
      })
    end,
  },

  {
    "ray-x/lsp_signature.nvim",
    event = "LspAttach",
    opts = {
      bind = true,
      handler_opts = { border = "rounded" },
      hint_enable = true,
      hint_prefix = "󰊕 ",
      hint_scheme = "Comment",
      hi_parameter = "LspSignatureActiveParameter",
      max_height = 15,
      max_width = 80,
      floating_window = true,
      floating_window_above_cur_line = true,
      fix_pos = false,
      always_trigger = false,
      auto_close_after = nil,
      extra_trigger_chars = { "(", ",", "=" },
      zindex = 200,
      padding = " ",
      transparency = 10,
      shadow_blend = 36,
      shadow_guibg = "Black",
      timer_interval = 200,
      toggle_key = "<C-k>",
      select_signature_key = "<C-n>",
      move_cursor_key = "<C-p>",
    },
    config = function(_, opts)
      require("lsp_signature").setup(opts)
    end,
  },
}
