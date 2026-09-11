require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- LSP keymaps
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
map("n", "gr", vim.lsp.buf.references, { desc = "Go to references" })
map("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
map("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation" })
map({ "n", "i" }, "<C-k>", vim.lsp.buf.signature_help, { desc = "Signature help" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code actions" })
map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
map("n", "<leader>fm", function()
  require("conform").format { async = true, lsp_fallback = true }
end, { desc = "Format buffer" })
map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, { desc = "Add workspace folder" })
map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, { desc = "Remove workspace folder" })
map("n", "<leader>wl", function()
  print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
end, { desc = "List workspace folders" })

-- Diagnostics
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostics" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })

-- Trouble (daftar diagnostik penuh)
map("n", "<leader>tx", function()
  require("trouble").toggle "diagnostics"
end, { desc = "Toggle diagnostics list (trouble)" })
map("n", "<leader>tX", function()
  require("trouble").toggle "diagnostics" { filter = { severity = vim.diagnostic.severity.ERROR } }
end, { desc = "Toggle only errors (trouble)" })

-- DAP
map("n", "<leader>db", "<cmd> DapToggleBreakpoint <CR>", { desc = "Toggle breakpoint" })
map("n", "<leader>dc", "<cmd> DapContinue <CR>", { desc = "Continue/Start debugging" })
map("n", "<leader>dr", "<cmd> DapToggleRepl <CR>", { desc = "Toggle REPL" })
map("n", "<leader>dso", "<cmd> DapStepOver <CR>", { desc = "Step over" })
map("n", "<leader>dsi", "<cmd> DapStepInto <CR>", { desc = "Step into" })
map("n", "<leader>dui", "<cmd> DapUIToggle <CR>", { desc = "Toggle DAP UI" })

-- Terminal
map("n", "<leader>h", function()
  require("nvchad.term").new { pos = "sp" }
end, { desc = "New horizontal terminal" })

map("n", "<leader>v", function()
  require("nvchad.term").new { pos = "vsp" }
end, { desc = "New vertical terminal" })

map("t", "<C-x>", "<C-\\><C-N>", { desc = "Terminal escape to normal mode" })

map({ "n", "t" }, "<A-h>", function()
  require("nvchad.term").toggle { pos = "sp", id = "htoggleTerm" }
end, { desc = "Toggle horizontal terminal" })

map({ "n", "t" }, "<A-v>", function()
  require("nvchad.term").toggle { pos = "vsp", id = "vtoggleTerm" }
end, { desc = "Toggle vertical terminal" })

map({ "n", "t" }, "<A-i>", function()
  require("nvchad.term").toggle { pos = "float", id = "floatTerm" }
end, { desc = "Toggle floating terminal" })

-- Run current file (smart: C/C++ compile+run, Python via venv)
map("n", "<leader>r", function()
  require("configs.run").run()
end, { desc = "Run current file (smart)" })
