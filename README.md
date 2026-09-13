# nvim-daily-driver

Personal Neovim configuration based on [NvChad](https://github.com/NvChad/NvChad) - a beautiful, fast, and feature-rich Neovim setup.

## Features

- **NvChad** base configuration with Lazy.nvim plugin manager
- **LSP** support with nvim-lspconfig, Mason for language server management
- **DAP** debugging support
- **Formatter** integration with conform.nvim
- **Git** integration with gitsigns, lazygit
- **File explorer** with nvim-tree
- **Fuzzy finder** with telescope
- **Statusline** with lualine
- **Syntax highlighting** with treesitter
- **Auto-completion** with nvim-cmp
- **Terminal** integration with toggleterm
- **Session management** with persistence.nvim
- **Custom keybindings** and options

## Screenshots

*Add screenshots here*

## Prerequisites

### All Platforms

- **Neovim** >= 0.9.0
- **Git**
- **Node.js** >= 18 (for LSP servers, formatters)
- **Python** >= 3.10 (for Python LSP, debugpy)
- **Ripgrep** (for telescope live grep)
- **fd** (for telescope file finding)
- **A Nerd Font** (for icons) - [Download here](https://www.nerdfonts.com/font-downloads)

### Language-Specific (Optional)

| Language | Tools |
|----------|-------|
| Python | `python-lsp-server`, `black`, `isort`, `debugpy` |
| TypeScript/JavaScript | `typescript-language-server`, `prettier`, `eslint` |
| Lua | `lua-language-server`, `stylua` |
| Rust | `rust-analyzer`, `rustfmt` |
| Go | `gopls`, `gofumpt` |
| C/C++ | `clangd`, `clang-format` |

## Installation

### Arch Linux / Manjaro / EndeavourOS

```bash
# Install dependencies
sudo pacman -S neovim git nodejs npm python python-pip ripgrep fd unzip wget curl

# Install Nerd Font (choose one)
# Option 1: JetBrainsMono Nerd Font (recommended)
sudo pacman -S ttf-jetbrains-mono-nerd

# Option 2: FiraCode Nerd Font
sudo pacman -S ttf-firacode-nerd

# Option 3: Install from AUR (more font choices)
yay -S nerd-fonts-jetbrains-mono nerd-fonts-fira-code

# Install language servers (optional but recommended)
sudo pacman -S python-lsp-server typescript-language-server lua-language-server rust-analyzer gopls clang

# Install formatters
sudo pacman -S black isort prettier stylua rustfmt gofumpt clang-format

# Clone config
git clone git@github.com:abdie-dev/nvim-daily-driver.git ~/.config/nvim

# Start Neovim - plugins will auto-install on first run
nvim
```

### Fedora / RHEL / CentOS / AlmaLinux / Rocky Linux

```bash
# Enable RPM Fusion (for additional packages)
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Install dependencies
sudo dnf install neovim git nodejs npm python3 python3-pip ripgrep fd-find unzip wget curl

# Install Nerd Font
sudo dnf install jetbrains-mono-fonts-all

# Or install from COPR for more Nerd Fonts
sudo dnf copr enable zawertun/nerd-fonts
sudo dnf install nerd-fonts

# Install language servers
sudo dnf install python3-lsp-server typescript-language-server lua-language-server rust-analyzer gopls clang-tools-extra

# Install formatters
sudo dnf install python3-black python3-isort prettier stylua rustfmt gofumpt clang-format

# Clone config
git clone git@github.com:abdie-dev/nvim-daily-driver.git ~/.config/nvim

# Start Neovim
nvim
```

### Windows (PowerShell as Administrator)

```powershell
# Install dependencies using winget (Windows 10/11)
winget install Neovim.Neovim
winget install Git.Git
winget install OpenJS.NodeJS.LTS
winget install Python.Python.3.11
winget install BurntSushi.ripgrep.MSVC
winget install sharkdp.fd
winget install 7zip.7zip

# Install Nerd Font (JetBrains Mono)
winget install ChrisTitusTech.JetBrainsMono-NF

# Or manually download from https://www.nerdfonts.com/font-downloads
# Extract and install the .ttf files (right-click → Install for all users)

# Install language servers via npm (run in PowerShell)
npm install -g typescript-language-server vscode-langservers-extracted @vscode/css-language-server @vscode/html-language-server @vscode/json-language-server @vscode/tailwindcss-language-server

# Install Python tools
pip install python-lsp-server black isort debugpy

# Install Rust tools (if using Rust)
# rustup component add rust-analyzer rustfmt

# Install Go tools (if using Go)
# go install golang.org/x/tools/gopls@latest
# go install mvdan.cc/gofumpt@latest

# Clone config
git clone git@github.com:abdie-dev/nvim-daily-driver.git $env:LOCALAPPDATA\nvim

# Start Neovim
nvim
```

### Windows (Scoop - Alternative)

```powershell
# Install Scoop if not installed
irm get.scoop.sh | iex

# Install dependencies
scoop install neovim git nodejs-lts python ripgrep fd 7zip
scoop bucket add nerd-fonts
scoop install nerd-fonts/JetBrainsMono-NF

# Install language servers
npm install -g typescript-language-server vscode-langservers-extracted
pip install python-lsp-server black isort debugpy

# Clone config
git clone git@github.com:abdie-dev/nvim-daily-driver.git $env:LOCALAPPDATA\nvim

# Start Neovim
nvim
```

### macOS (Homebrew)

```bash
# Install dependencies
brew install neovim git node python ripgrep fd

# Install Nerd Font
brew install --cask font-jetbrains-mono-nerd-font

# Install language servers
brew install python-lsp-server typescript-language-server lua-language-server rust-analyzer gopls clang-format

# Install formatters
brew install black isort prettier stylua rustfmt gofumpt

# Clone config
git clone git@github.com:abdie-dev/nvim-daily-driver.git ~/.config/nvim

# Start Neovim
nvim
```

## Post-Installation

### First Run

On first launch, Neovim will:
1. Bootstrap `lazy.nvim` plugin manager
2. Install all plugins defined in `lua/plugins/init.lua`
3. Install language servers via Mason (configured in `lua/configs/lspconfig.lua`)

Wait for installation to complete, then restart Neovim.

### Verify Installation

```vim
:checkhealth
```

Check for any errors in:
- `lsp` - Language Server Protocol
- `treesitter` - Syntax highlighting
- `mason` - Package manager

### Update Plugins

```vim
:Lazy sync
```

### Update Mason Packages (LSP servers, formatters, linters)

```vim
:Mason
```
Then press `U` to update all, or navigate to specific packages.

## Configuration Structure

```
~/.config/nvim/
├── init.lua              # Entry point
├── lazy-lock.json        # Locked plugin versions
├── lua/
│   ├── autocmds.lua      # Auto commands
│   ├── chadrc.lua        # NvChad core config
│   ├── mappings.lua      # Key mappings
│   ├── options.lua       # Neovim options
│   ├── configs/
│   │   ├── conform.lua   # Formatters config
│   │   ├── dap.lua       # Debug adapter protocol
│   │   ├── lazy.lua      # Lazy.nvim config
│   │   ├── lspconfig.lua # LSP servers config
│   │   ├── run.lua       # Code runner config
│   │   └── venv.lua      # Python virtual env config
│   └── plugins/
│       └── init.lua      # Plugin specifications
└── .stylua.toml          # Stylua config for Lua formatting
```

## Key Mappings

### Leader Key: `Space`

| Mode | Key | Action |
|------|-----|--------|
| Normal | `<leader>ff` | Find files (Telescope) |
| Normal | `<leader>fw` | Live grep (Telescope) |
| Normal | `<leader>fb` | Buffers (Telescope) |
| Normal | `<leader>fh` | Help tags (Telescope) |
| Normal | `<leader>e` | Toggle file explorer |
| Normal | `<leader>gg` | Toggle Lazygit |
| Normal | `<leader>tt` | Toggle terminal |
| Normal | `<leader>rn` | LSP rename |
| Normal | `<leader>ca` | Code actions |
| Normal | `<leader>f` | Format buffer |
| Normal | `<leader>r` | Run current file (smart runner, see below) |
| Normal | `gd` | Go to definition |
| Normal | `gr` | Go to references |
| Normal | `K` | Hover documentation |
| Normal | `[d` / `]d` | Previous/Next diagnostic |

*See `lua/mappings.lua` for complete mappings*

### Smart Runner (`<leader>r`)

Compiles and runs the current file in a floating terminal. Supported: C/C++ (g++/gcc), C, Python (detected venv), Lua (luajit/lua), Shell (bash/sh), Go (`go run`), Rust (`cargo run` in Cargo projects, else `rustc` single-file).

- **Autosave**: modified file is written automatically before running
- **While running**: animated spinner in the title (`⠋ main.cpp · running…`), yellow border
- **When done**: title becomes `✓ main.cpp · 0.42s` (green border) or `✗ main.cpp · 0.10s` (red border), with a colored footer showing exit code + elapsed time
- **Statusline**: last run result (`✓ 0.42s` / `✗ exit 1`) appears next to diagnostics
- **Closing the float**: `q` (normal mode) or double-`Esc` (terminal mode) — no need to type `exit`. Or just hit `<leader>r` again for a fresh run

## Customization

### Adding Plugins

Edit `lua/plugins/init.lua` and add your plugin spec:

```lua
{
  "author/plugin-name",
  event = "VeryLazy", -- or specific event
  config = function()
    require("plugin-name").setup({ ... })
  end,
}
```

Then run `:Lazy sync`.

### Changing Theme

Edit `lua/chadrc.lua`:

```lua
M.ui = {
  theme = "catppuccin", -- or "tokyonight", "gruvbox", etc.
  -- theme_toggle = { "catppuccin", "one_light" },
}
```

Available themes: `catppuccin`, `tokyonight`, `gruvbox`, `onedark`, `nord`, `rosepine`, `kanagawa`, and more.

### LSP Configuration

Edit `lua/configs/lspconfig.lua` to add/configure language servers:

```lua
local servers = {
  "pyright",       -- Python
  "ts_ls",         -- TypeScript/JavaScript
  "lua_ls",        -- Lua
  "rust_analyzer", -- Rust
  "gopls",         -- Go
  "clangd",        -- C/C++
}
```

### Formatters

Edit `lua/configs/conform.lua`:

```lua
formatters_by_ft = {
  lua = { "stylua" },
  python = { "isort", "black" },
  javascript = { "prettier" },
  typescript = { "prettier" },
  rust = { "rustfmt" },
  go = { "gofumpt" },
  cpp = { "clang_format" },
}
```

## Troubleshooting

### Plugins not installing

```vim
:Lazy clean
:Lazy sync
```

### LSP not working

```vim
:Mason
```
Ensure the language server is installed. Check logs with `:LspLog`.

### Treesitter parsers missing

```vim
:TSInstall all
:TSUpdate
```

### Font icons not showing

- Ensure you're using a **Nerd Font** in your terminal
- Configure terminal to use the Nerd Font (e.g., "JetBrainsMono Nerd Font")
- Restart terminal

### Python venv not detected

The config auto-detects virtual environments. Ensure:
- `venv` folder exists in project root, OR
- `VIRTUAL_ENV` environment variable is set

## Uninstall

```bash
# Remove config
rm -rf ~/.config/nvim

# Remove data (plugins, cache, Mason packages)
rm -rf ~/.local/share/nvim
rm -rf ~/.cache/nvim
rm -rf ~/.local/state/nvim
```

## License

MIT License - see [LICENSE](LICENSE) file.

## Credits

- [NvChad](https://github.com/NvChad/NvChad) - Base configuration
- [LazyVim](https://github.com/LazyVim/LazyVim) - Inspiration for starter structure
- All plugin authors listed in `lua/plugins/init.lua`