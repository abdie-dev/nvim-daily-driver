require "nvchad.autocmds"

vim.g.ui_entered = true

vim.api.nvim_del_augroup_by_name "NvFilePost"

local autocmd = vim.api.nvim_create_autocmd

autocmd({ "UIEnter", "BufReadPost", "BufNewFile" }, {
  group = vim.api.nvim_create_augroup("NvFilePostFix", { clear = true }),
  callback = function(args)
    if args.event == "UIEnter" then
      vim.g.ui_entered = true
    end

    if not vim.api.nvim_buf_is_valid(args.buf) then
      return
    end

    local file = vim.api.nvim_buf_get_name(args.buf)
    local buftype = vim.api.nvim_get_option_value("buftype", { buf = args.buf })

    if file ~= "" and buftype ~= "nofile" and vim.g.ui_entered then
      vim.api.nvim_exec_autocmds("User", { pattern = "FilePost", modeline = false })
      vim.api.nvim_del_augroup_by_name "NvFilePostFix"

      vim.schedule(function()
        vim.api.nvim_exec_autocmds("FileType", {})

        if vim.g.editorconfig then
          require("editorconfig").config(args.buf)
        end
      end)
    end
  end,
})
