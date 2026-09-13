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

local function find_smartrun_buf()
  for _, t in pairs(vim.g.nvchad_terms or {}) do
    if t.id == "smartrun" then
      return t.buf
    end
  end
end

-- deteksi program yang butuh input terminal (cin/scanf/getchar/getline/fgets / input())
-- kalau iya: stdin dibiarkan dari terminal (menunggu Enter), bukan dipaksa EOF
local function uses_stdin()
  local ft = vim.bo.filetype
  local text = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), " ")

  if ft == "python" then
    return text:find("input%s*%(") ~= nil
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

local function find_smartrun_buf()
  for _, t in pairs(vim.g.nvchad_terms or {}) do
    if t.id == "smartrun" then
      return t.buf
    end
  end
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

  return nil, "Belum ada runner untuk filetype: " .. ft
end

function M.run()
  local cmd, err = M.build_command()
  if not cmd then
    vim.notify(err, vim.log.levels.WARN)
    return
  end

  -- satu float run dalam satu waktu: hapus float lama biar tenang, tiap tekan = run baru
  local old = find_smartrun_buf()
  if old and vim.api.nvim_buf_is_valid(old) then
    pcall(vim.api.nvim_buf_delete, old, { force = true })
  end

  local name = vim.fn.fnamemodify(vim.fn.expand "%:p", ":t")
  -- %%s dibiarkan untuk printf shell (diisi "$rc"), %s lainnya diisi Lua
  local wrapped = ("printf '\\n── 󰜎 %s ──\\n\\n' ; %s ; rc=$? ; printf '\\n── [exit: %%s] ──\\n' \"$rc\"")
    :format(name:gsub("'", "'\\''"), cmd)

  require("nvchad.term").new {
    pos = "float",
    id = "smartrun",
    cmd = wrapped,
    -- float_opts digabung ke nvconfig.term.float; title + border rounded biar konsisten dgn float LSP
    float_opts = {
      width = 0.72,
      height = 0.65,
      row = 0.16,
      col = 0.14,
      border = "rounded",
      title = (" 󰜎 %s "):format(name),
      title_pos = "center",
    },
    winopts = { winblend = 8 },
  }
end

return M