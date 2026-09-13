require "nvchad.options"

-- add yours here!

local o = vim.o
o.clipboard = "unnamedplus"

-- ===== calm cmdline & messages =====
o.cmdheight = 0 -- cmdline sembunyi sampai dipakai; pesan lewat notify
o.showmode = false -- mode sudah tampil di statusline
o.pumheight = 10 -- popup completion ramping
o.pumblend = 10 -- popup sedikit transparan
vim.opt.shortmess:append "IW" -- skip intro + "written" messages yg berisik

if vim.fn.has "wsl" == 1 then
  vim.g.clipboard = {
    name = "WslClipboard",
    copy = {
      ["+"] = "clip.exe",
      ["*"] = "clip.exe",
    },
    paste = {
      ["+"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
      ["*"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
    },
    cache_enabled = 0,
  }
end
