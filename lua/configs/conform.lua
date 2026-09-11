local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    cpp = { "clang-format" },
    c = { "clang-format" },
    python = { "ruff_format", "ruff_organize_imports" },
    cmake = { "cmake_format" },
  },

  format_on_save = {
    timeout_ms = 2000,
    lsp_fallback = true,
  },

  formatters = {
    clang_format = {
      prepend_args = { "--style=file", "--fallback-style=LLVM" },
    },
  },
}

return options
