-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :( 

---@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "gruvbox",

	hl_override = {
		Comment = { italic = true },
		["@comment"] = { italic = true },

		-- Variables
		["@variable"] = { fg = "#c0caf5" },
		["@variable.builtin"] = { fg = "#f7768e", bold = true },
		["@variable.parameter"] = { fg = "#e0af68", italic = true },
		["@variable.member"] = { fg = "#7dcfff" },

		-- Functions
		["@function"] = { fg = "#7aa2f7", bold = true },
		["@function.builtin"] = { fg = "#bb9af7", bold = true },
		["@function.call"] = { fg = "#7aa2f7" },
		["@function.method"] = { fg = "#7aa2f7", bold = true },
		["@function.method.call"] = { fg = "#7aa2f7" },

		-- Types
		["@type"] = { fg = "#2ac3de", bold = true },
		["@type.builtin"] = { fg = "#2ac3de", bold = true, italic = true },
		["@type.definition"] = { fg = "#2ac3de", bold = true },
		["@type.qualifier"] = { fg = "#f7768e", italic = true },

		-- Constants
		["@constant"] = { fg = "#ff9e64", bold = true },
		["@constant.builtin"] = { fg = "#ff9e64", bold = true },
		["@constant.macro"] = { fg = "#ff9e64" },

		-- Keywords
		["@keyword"] = { fg = "#bb9af7", bold = true, italic = true },
		["@keyword.function"] = { fg = "#bb9af7", bold = true },
		["@keyword.operator"] = { fg = "#bb9af7", bold = true },
		["@keyword.return"] = { fg = "#bb9af7", bold = true, italic = true },
		["@keyword.conditional"] = { fg = "#bb9af7", bold = true, italic = true },
		["@keyword.repeat"] = { fg = "#bb9af7", bold = true, italic = true },
		["@keyword.import"] = { fg = "#bb9af7", italic = true },

		-- Operators
		["@operator"] = { fg = "#89ddff", bold = true },

		-- Strings
		["@string"] = { fg = "#9ece6a" },
		["@string.escape"] = { fg = "#f7768e", bold = true },
		["@string.regex"] = { fg = "#b4f9f8" },

		-- Numbers
		["@number"] = { fg = "#ff9e64" },
		["@number.float"] = { fg = "#ff9e64" },

		-- Properties/Fields
		["@property"] = { fg = "#7dcfff" },
		["@field"] = { fg = "#7dcfff" },

		-- Parameters
		["@parameter"] = { fg = "#e0af68", italic = true },

		-- Namespaces/Modules
		["@module"] = { fg = "#7aa2f7", italic = true },
		["@namespace"] = { fg = "#7aa2f7", italic = true },

		-- Attributes/Annotations
		["@attribute"] = { fg = "#bb9af7", italic = true },
		["@decorator"] = { fg = "#bb9af7", italic = true },

		-- Preprocessor
		["@preproc"] = { fg = "#f7768e" },
		["@define"] = { fg = "#f7768e" },

		-- Tags (JSX/HTML)
		["@tag"] = { fg = "#f7768e" },
		["@tag.attribute"] = { fg = "#7dcfff" },
		["@tag.delimiter"] = { fg = "#545c7e" },

		-- LSP semantic tokens
		["@lsp.type.variable"] = { link = "@variable" },
		["@lsp.type.function"] = { link = "@function" },
		["@lsp.type.method"] = { link = "@function.method" },
		["@lsp.type.class"] = { link = "@type" },
		["@lsp.type.struct"] = { link = "@type" },
		["@lsp.type.interface"] = { link = "@type" },
		["@lsp.type.enum"] = { link = "@type" },
		["@lsp.type.enumMember"] = { link = "@constant" },
		["@lsp.type.parameter"] = { link = "@parameter" },
		["@lsp.type.property"] = { link = "@property" },
		["@lsp.type.namespace"] = { link = "@namespace" },
		["@lsp.type.typeParameter"] = { link = "@type.definition" },
		["@lsp.type.macro"] = { link = "@constant.macro" },
		["@lsp.mod.readonly"] = { italic = true },
		["@lsp.mod.static"] = { bold = true },
		["@lsp.mod.declaration"] = { bold = true },
		["@lsp.mod.definition"] = { bold = true },
	},
}

M.nvdash = { load_on_startup = true }
M.ui = {
  telescope = { style = "bordered" }, -- konsisten dgn float rounded
  tabufline = {
    lazyload = false
  },
  statusline = {
    theme = "minimal",
    separator_style = "round",
    modules = {
      mode = function()
        if vim.api.nvim_get_current_win() ~= vim.g.statusline_winid then
          return ""
        end

        local m = vim.api.nvim_get_mode().mode
        local txt, hl

        if vim.bo.buftype == "terminal" then
          if m == "t" then
            txt, hl = "INSERT", "Terminal"
          else
            txt, hl = "NORMAL", "NTerminal"
          end
        else
          local modes = require("nvchad.stl.utils").modes
          local entry = modes[m]
          if not entry then
            return ""
          end
          txt, hl = entry[1], entry[2]
        end

        return ("%%#St_%sModeSep#\u{e0b6}%%#St_%sMode# \u{e6a6}%%#St_%sModeText# %s %%#St_sep_r#\u{e0b4} %%#ST_EmptySpace#"):format(hl, hl, hl, txt)
      end,
    },
  },
}

-- default global utk semua floating terminal (runner <leader>r, <A-i>, ...).
-- float_opts per-panggilan di-merge di atas ini.
M.term = {
  float = {
    relative = "editor",
    row = 0.16,
    col = 0.14,
    width = 0.72,
    height = 0.65,
    border = "rounded",
  },
}

return M
