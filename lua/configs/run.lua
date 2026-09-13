local M = {}

local function shq(s)
  return "'" .. s:gsub("'", "'\\''") .. "'"
end

local function pick(candidates)
  for _, c in ipairs(candidates) do
    if vim.fn.executable(c) == 1 then
      return c
    end
  end
end

-- hasil run terakhir, dibaca statusline. nil = belum pernah run.
M.last = nil

-- deteksi program yang butuh input terminal (cin/scanf/getchar/getline/fgets / input() / ...)
-- kalau iya: stdin dibiarkan dari terminal (menunggu Enter), bukan dipaksa EOF
local function uses_stdin()
  local ft = vim.bo.filetype
  local text = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), " ")

  if ft == "python" then
    return text:find("input%s*%(") ~= nil
  end

  if ft == "lua" then
    return text:find("io%.read") ~= nil
  end

  if ft == "go" then
    return text:find("Scan") ~= nil
  end

  if ft == "rust" then
    return text:find("read_line") ~= nil or text:find("stdin%s*%(") ~= nil
  end

  if ft == "sh" or ft == "bash" then
    return text:find("%f[%w_]read%f[^%w_]") ~= nil
  end

  return text:find("%f[%w_]cin%f[^%w_]") ~= nil
    or text:find("getline") ~= nil
    or text:find("scanf") ~= nil
    or text:find("getchar") ~= nil
    or text:find("fgets") ~= nil
end

local function io_redirect()
  return uses_stdin() and "" or " < /dev/null"
end

-- benar-benar meng-#include header lokal (dir punya file itu)? -> perlu link file sekawan
local function has_local_include(dir)
  local text = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), " ")
  for inc in text:gmatch('#%s*include%s+"([^"]+)"') do
    if vim.fn.filereadable(dir .. "/" .. inc) == 1 then
      return true
    end
  end
  return false
end

local suffix_ext = {
  cpp = { ".cpp", ".cc", ".cxx", ".c++" },
  c = { ".c" },
}

local function sibling_sources(dir, kind)
  local exts = suffix_ext[kind]
  local out = {}
  for name in vim.fs.dir(dir) do
    local e = name:match("%.[^.]+$")
    for _, x in ipairs(exts) do
      if e == x then
        out[#out + 1] = dir .. "/" .. name
        break
      end
    end
  end
  return out
end

function M.build_command()
  local ft = vim.bo.filetype
  local file = vim.fn.expand("%:p")
  local dir = vim.fn.expand("%:p:h")

  if file == "" or file == vim.fn.getcwd() then
    return nil, "File belum disimpan. Simpan dulu lalu tekan <leader>r"
  end

  if ft == "h" then
    ft = (#sibling_sources(dir, "cpp") > 0) and "cpp" or "c"
  end

  if vim.tbl_contains({ "cpp", "cc", "cxx", "c++" }, ft) then
    local compiler = pick { "g++", "clang++" }
    if not compiler then
      return nil, "Compiler C++ (g++/clang++) tidak ditemukan"
    end
    local out = "/tmp/nvim-run-" .. vim.fn.fnamemodify(file, ":t")
    local srcs = has_local_include(dir) and sibling_sources(dir, "cpp") or { file }
    local srcstr = table.concat(vim.tbl_map(shq, srcs), " ")
    local cmd = ("cd %s && %s -std=c++20 -Wall -Wextra -O2 -o %s %s && %s%s")
      :format(shq(dir), compiler, shq(out), srcstr, shq(out), io_redirect())
    return cmd
  end

  if ft == "c" then
    local compiler = pick { "gcc", "clang" }
    if not compiler then
      return nil, "Compiler C (gcc/clang) tidak ditemukan"
    end
    local out = "/tmp/nvim-run-" .. vim.fn.fnamemodify(file, ":t")
    local srcs = has_local_include(dir) and sibling_sources(dir, "c") or { file }
    local srcstr = table.concat(vim.tbl_map(shq, srcs), " ")
    local cmd = ("cd %s && %s -std=c17 -Wall -Wextra -O2 -o %s %s && %s%s")
      :format(shq(dir), compiler, shq(out), srcstr, shq(out), io_redirect())
    return cmd
  end

  if ft == "python" then
    local py = require("configs.venv").find_python(0)
    return ("cd %s && %s %s%s"):format(shq(dir), shq(py), shq(file), io_redirect())
  end

  if ft == "lua" then
    local interp = pick { "luajit", "lua" }
    if not interp then
      return nil, "Interpreter Lua (luajit/lua) tidak ditemukan"
    end
    return ("cd %s && %s %s%s"):format(shq(dir), interp, shq(file), io_redirect())
  end

  if ft == "sh" or ft == "bash" then
    local sh = pick { "bash", "sh" }
    return ("cd %s && %s %s%s"):format(shq(dir), sh, shq(file), io_redirect())
  end

  if ft == "go" then
    if vim.fn.executable "go" == 0 then
      return nil, "Go toolchain tidak ditemukan"
    end
    return ("cd %s && go run %s%s"):format(shq(dir), shq(file), io_redirect())
  end

  if ft == "rust" then
    if vim.fn.filereadable(dir .. "/Cargo.toml") == 1 then
      if vim.fn.executable "cargo" == 0 then
        return nil, "Cargo tidak ditemukan"
      end
      return ("cd %s && cargo run --quiet%s"):format(shq(dir), io_redirect())
    end
    local rustc = pick { "rustc" }
    if not rustc then
      return nil, "Compiler Rust (rustc/cargo) tidak ditemukan"
    end
    local out = "/tmp/nvim-run-" .. vim.fn.fnamemodify(file, ":t")
    return ("cd %s && %s -O -o %s %s && %s%s")
      :format(shq(dir), rustc, shq(out), shq(file), shq(out), io_redirect())
  end

  return nil, "Belum ada runner untuk filetype: " .. ft
end

-- ===== dynamic runner UI: spinner + status title + border tint =====
-- float dibuat sendiri (bukan nvchad.term.new) supaya tidak ada `; shell` nyangkut:
-- program selesai = job selesai = on_exit Lua asli. Tidak perlu ketik `exit`.
vim.api.nvim_set_hl(0, "RunFloatOk", { link = "DiagnosticOk", default = true })
vim.api.nvim_set_hl(0, "RunFloatFail", { link = "DiagnosticError", default = true })
vim.api.nvim_set_hl(0, "RunFloatBusy", { link = "DiagnosticWarn", default = true })

local spin_frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
local spin = { timer = nil, i = 0 }

local function spin_stop()
  if spin.timer then
    pcall(function()
      spin.timer:stop()
      spin.timer:close()
    end)
    spin.timer = nil
  end
end

local function spin_start(win, name)
  spin_stop()
  local timer = vim.uv.new_timer()
  spin.timer = timer
  timer:start(0, 100, vim.schedule_wrap(function()
    if not (win and vim.api.nvim_win_is_valid(win)) then
      spin_stop()
      return
    end
    spin.i = spin.i % #spin_frames + 1
    pcall(vim.api.nvim_win_set_config, win, {
      title = (" %s %s · running… "):format(spin_frames[spin.i], name),
      title_pos = "center",
    })
  end))
end

local function close_run()
  spin_stop()
  local r = M._run
  M._run = nil
  if r and r.win and vim.api.nvim_win_is_valid(r.win) then
    pcall(vim.api.nvim_win_close, r.win, true)
  end
end

-- handler selesai: dipanggil langsung Neovim via termopen on_exit (tanpa subprocess)
local function handle_exit(code)
  spin_stop()
  local r = M._run
  if not (r and r.win and vim.api.nvim_win_is_valid(r.win)) then
    return
  end
  local secs = ("%.2fs"):format((vim.uv.hrtime() - r.t0) / 1e9)
  local ok = code == 0
  M.last = { code = code, secs = secs, name = r.name }
  local hl = ok and "RunFloatOk" or "RunFloatFail"
  local mark = ok and "✓" or "✗"
  pcall(vim.api.nvim_win_set_config, r.win, {
    title = (" %s %s · %s "):format(mark, r.name, secs),
    title_pos = "center",
  })
  vim.wo[r.win].winhl = "FloatBorder:" .. hl .. ",FloatTitle:" .. hl
  vim.cmd "redrawstatus"
end

local function open_float(name)
  -- hormati default global M.term (chadrc), timpa dgn ukuran runner
  local term_cfg = require("nvconfig").term
  local opts = vim.tbl_deep_extend("force", term_cfg.float, {
    width = 0.72,
    height = 0.65,
    row = 0.16,
    col = 0.14,
    border = "rounded",
    title = (" ⟳ %s "):format(name),
    title_pos = "center",
  })
  opts.width = math.ceil(opts.width * vim.o.columns)
  opts.height = math.ceil(opts.height * vim.o.lines)
  opts.row = math.ceil(opts.row * vim.o.lines)
  opts.col = math.ceil(opts.col * vim.o.columns)

  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, opts)
  vim.bo[buf].buflisted = false
  vim.bo[buf].bufhidden = "wipe" -- tutup window = buffer hilang, tidak menumpuk
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].winblend = 8
  vim.wo[win].winhl = "FloatBorder:RunFloatBusy,FloatTitle:RunFloatBusy"
  return buf, win
end

-- bangun command terbungkus: header + timing + footer berwarna.
-- dipisah biar gampang dites tanpa buka UI.
function M.build_wrapped(cmd, name)
  local safe = name:gsub("'", "'\\''")
  return "printf '\\n── 󰜎 " .. safe .. " ──\\n\\n' ; "
    .. "t0=$(date +%s%N 2>/dev/null || echo 0) ; "
    .. cmd .. " ; rc=$? ; "
    .. "t1=$(date +%s%N 2>/dev/null || echo 0) ; ms=$(( (t1 - t0) / 1000000 )) ; "
    .. "secs=$(awk -v ms=\"$ms\" 'BEGIN { printf \"%.2fs\", (ms < 0 ? 0 : ms) / 1000 }') ; "
    .. "if [ \"$rc\" -eq 0 ]; then c=32; mark='✓'; else c=31; mark='✗'; fi ; "
    .. "printf '\\n── \\033[%sm%s exit: %s · %s\\033[0m ──\\n' \"$c\" \"$mark\" \"$rc\" \"$secs\""
end

function M.run()
  -- autosave: tidak perlu :w manual
  if vim.bo.modified and vim.fn.expand "%:p" ~= "" then
    vim.cmd "silent! write"
  end

  local cmd, err = M.build_command()
  if not cmd then
    vim.notify(err, vim.log.levels.WARN)
    return
  end

  -- satu float run dalam satu waktu, tiap tekan = run baru
  close_run()

  local name = vim.fn.fnamemodify(vim.fn.expand "%:p", ":t")
  local buf, win = open_float(name)
  M._run = { buf = buf, win = win, name = name, t0 = vim.uv.hrtime() }
  spin_start(win, name)

  -- q (normal) / double-Esc (terminal): tutup float, tanpa ketik exit
  vim.keymap.set("n", "q", close_run, { buffer = buf, nowait = true, desc = "Close run float" })
  vim.keymap.set("t", "<Esc><Esc>", close_run, { buffer = buf, nowait = true, desc = "Close run float" })

  vim.cmd "startinsert"
  vim.fn.termopen({ vim.o.shell, "-c", M.build_wrapped(cmd, name) }, {
    on_exit = function(_, code)
      vim.schedule(function()
        handle_exit(code)
      end)
    end,
  })
end

return M