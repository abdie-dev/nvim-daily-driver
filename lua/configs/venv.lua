local M = {}

local function venv_python_for(dir)
  if type(dir) ~= "string" or dir == "" then
    return nil
  end
  local root = vim.fs.root(dir, ".venv")
  if not root then
    return nil
  end
  local candidate = root .. "/.venv/bin/python"
  if vim.uv.fs_stat(candidate) then
    return candidate
  end
  return nil
end

local function buf_dir(bufnr)
  bufnr = bufnr or 0
  if vim.api.nvim_buf_is_valid(bufnr) then
    local name = vim.api.nvim_buf_get_name(bufnr)
    if name ~= "" then
      return vim.uv.fs_realpath(vim.fn.fnamemodify(name, ":h"))
    end
  end
  return nil
end

function M.find_python(bufnr)
  bufnr = bufnr or 0

  local venv = vim.env.VIRTUAL_ENV
  if venv and venv ~= "" then
    local candidate = venv .. "/bin/python"
    if vim.uv.fs_stat(candidate) then
      return candidate
    end
  end

  local dir = buf_dir(bufnr)
  if dir then
    local p = venv_python_for(dir)
    if p then
      return p
    end
  end

  local cwd = vim.uv.fs_realpath(vim.fn.getcwd())
  if cwd then
    local p = venv_python_for(cwd)
    if p then
      return p
    end
  end

  return vim.fn.exepath "python3" or "python3"
end

return M