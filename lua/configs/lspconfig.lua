require("nvchad.configs.lspconfig").defaults()

-- ===== Signature Help Configuration =====
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
  border = "rounded",
  focusable = false,
  close_events = { "CursorMoved", "BufHidden", "InsertCharPre" },
  max_height = 15,
  max_width = 80,
  title = " Signature ",
  title_pos = "center",
})

-- ===== Smart Diagnostic Handler =====
-- Shows all errors when cursor not on error line
-- Shows only current line error when cursor on error line
local smart_ns = vim.api.nvim_create_namespace("smart_diagnostics")
local orig_handlers = vim.diagnostic.handlers

local function get_line_diagnostics(bufnr, lnum)
  return vim.diagnostic.get(bufnr, { lnum = lnum })
end

local function show_all_virtual_text(bufnr)
  vim.diagnostic.show(smart_ns, bufnr, vim.diagnostic.get(bufnr), {
    virtual_text = {
      prefix = function(diag)
        local icons = { [1] = " ", [2] = " ", [3] = " ", [4] = " " }
        return icons[diag.severity] or "• "
      end,
      spacing = 2,
      source = "always",
      severity_sort = true,
    },
  })
end

local function show_current_line_only(bufnr, lnum)
  local line_diags = get_line_diagnostics(bufnr, lnum)
  if #line_diags == 0 then
    vim.diagnostic.hide(smart_ns, bufnr)
    return
  end
  vim.diagnostic.show(smart_ns, bufnr, line_diags, {
    virtual_text = {
      prefix = function(diag)
        local icons = { [1] = " ", [2] = " ", [3] = " ", [4] = " " }
        return icons[diag.severity] or "• "
      end,
      spacing = 2,
      source = "always",
    },
  })
end

local function update_smart_diagnostics()
  local bufnr = vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(bufnr) then return end
  local cursor = vim.api.nvim_win_get_cursor(0)
  local lnum = cursor[1] - 1
  local line_diags = get_line_diagnostics(bufnr, lnum)
  if #line_diags > 0 then
    show_current_line_only(bufnr, lnum)
  else
    show_all_virtual_text(bufnr)
  end
end

vim.diagnostic.config {
  virtual_text = false,  -- disable default, we use smart_ns
  float = {
    border = "rounded",
    header = " Diagnostics ",
    prefix = function(diag)
      local icons = { [1] = " ", [2] = " ", [3] = " ", [4] = " " }
      return icons[diag.severity] or "• "
    end,
    source = "always",
    severity_sort = true,
    focusable = false,
    max_width = 80,
    max_height = 20,
  },
}

-- Auto-update on cursor move and diagnostic change
vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "DiagnosticChanged" }, {
  group = vim.api.nvim_create_augroup("SmartDiagnostics", { clear = true }),
  callback = vim.schedule_wrap(update_smart_diagnostics),
})

-- Initial show
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("SmartDiagnosticsInit", { clear = true }),
  callback = function(args)
    vim.defer_fn(function() update_smart_diagnostics() end, 100)
  end,
})

local on_attach = function(client, bufnr)
  if client.server_capabilities.signatureHelpProvider then
    vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, { buffer = bufnr, desc = "LSP Signature Help" })
    vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, { buffer = bufnr, desc = "LSP Signature Help" })
  end
end

vim.lsp.config("clangd", {
  on_attach = on_attach,
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--fallback-style=LLVM",
    "--all-scopes-completion",
    "--cross-file-rename",
    "--pch-storage=memory",
    "-j=4",
  },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
  root_dir = function(fname)
    return vim.fs.root(fname, { "compile_commands.json", "compile_flags.txt", ".clangd", ".git" })
      or vim.fn.getcwd()
  end,
})

local venv = require "configs.venv"

vim.lsp.config("pyright", {
  on_attach = on_attach,
  settings = {
    python = {
      pythonPath = venv.find_python(),
      analysis = {
        typeCheckingMode = "basic",
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "workspace",
        autoImportCompletions = true,
        diagnosticSeverityOverrides = {
          reportUnusedImport = "information",
          reportUnusedVariable = "information",
          reportMissingImports = "error",
          reportMissingTypeStubs = "information",
        },
      },
    },
  },
})

vim.lsp.config("cmake", { on_attach = on_attach })

vim.lsp.config("html", { on_attach = on_attach })
vim.lsp.config("cssls", { on_attach = on_attach })

vim.lsp.enable { "html", "cssls", "clangd", "pyright", "cmake" }

local filetype_servers = {
  cpp = { "clangd" },
  c = { "clangd" },
  objc = { "clangd" },
  python = { "pyright" },
  cmake = { "cmake" },
  html = { "html" },
  css = { "cssls" },
}

local augroup = vim.api.nvim_create_augroup("NvLspAutoStart", { clear = true })

local function start_server(srv, bufnr)
  local cfg = vim.lsp.config[srv]
  if cfg then
    if srv == "pyright" then
      cfg = vim.tbl_deep_extend("force", {}, cfg)
      cfg.settings.python.pythonPath = venv.find_python(bufnr)
    end
    vim.lsp.start(cfg, { bufnr = bufnr })
  else
    require("lazy").load { plugins = { "nvim-lspconfig" } }
    local cfg2 = vim.lsp.config[srv]
    if cfg2 then
      if srv == "pyright" then
        cfg2 = vim.tbl_deep_extend("force", {}, cfg2)
        cfg2.settings.python.pythonPath = venv.find_python(bufnr)
      end
      vim.lsp.start(cfg2, { bufnr = bufnr })
    end
  end
end

local function sync_pyright_python_path(bufnr, attempts)
  attempts = attempts or 0
  if attempts > 8 then
    return
  end
  local client = vim.lsp.get_clients { name = "pyright", bufnr = bufnr }[1]
  if not client then
    vim.defer_fn(function()
      sync_pyright_python_path(bufnr, attempts + 1)
    end, 300)
    return
  end
  local path = venv.find_python(bufnr)
  if client.settings.python.pythonPath ~= path then
    local new_settings = vim.tbl_deep_extend("force", client.settings, {
      python = { pythonPath = path },
    })
    client.settings = new_settings
    client:notify("workspace/didChangeConfiguration", { settings = new_settings })
  end
end

vim.api.nvim_create_autocmd({ "FileType" }, {
  group = augroup,
  callback = function(args)
    local servers = filetype_servers[vim.bo[args.buf].filetype]
    if not servers then
      return
    end
    for _, srv in ipairs(servers) do
      local client = vim.lsp.get_clients { name = srv, bufnr = args.buf }[1]
      if not client then
        start_server(srv, args.buf)
      end
      if srv == "pyright" then
        vim.defer_fn(function()
          sync_pyright_python_path(args.buf, 0)
        end, 200)
      end
    end
  end,
}) 
