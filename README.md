# Neovim Configuration

A personal Neovim setup built on [lazy.nvim](https://github.com/folke/lazy.nvim),
[Mason](https://github.com/williamboman/mason.nvim) for LSP management, and
[Snacks](https://github.com/folke/snacks.nvim) for the picker/explorer/UI layer.
Tuned primarily for Python (pyright + ruff) and Lua development.

This repository is meant to live at `~/.config/nvim`.

## Requirements

- **Neovim ≥ 0.11** (0.12 / nightly recommended — the config uses `vim.lsp.config`
  and 0.12-era Mason APIs).
- A **Nerd Font** selected in your terminal (for icons).
- Git, and the CLI tools listed below.

### System tools

| Tool | Why it's needed |
| --- | --- |
| `git` | lazy.nvim bootstrap + Snacks git pickers |
| `ripgrep` (`rg`) | Snacks grep / live-grep |
| `fd` | file finder + Python venv picker (`<leader>cv`) |
| `lazygit` | Lazygit UI (`<leader>gg`) |
| `gh` | GitHub issue/PR pickers (`<leader>gi`, `<leader>gp`) |
| `node` + `npm` | runtime for Mason-managed LSPs (pyright, eslint_d, prettier) |
| `yarn` | builds `markdown-preview.nvim` |
| `python3` | pyright/ruff interpreter resolution |
| C compiler + `make` | building plugins with native components |

LSP servers and formatters (`pyright`, `ruff`, `lua_ls`, `harper_ls`, `prettier`,
`stylua`, `eslint_d`) are **not** installed by hand — Mason installs them
automatically the first time you launch Neovim.

## Installation

### 1. Install Neovim

**macOS (Homebrew):**

```sh
brew install neovim
```

**Debian / Ubuntu** (default apt is usually too old — use the unstable PPA):

```sh
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt-get update && sudo apt-get install neovim
```

Or grab a build from the [Neovim releases page](https://github.com/neovim/neovim/releases).

Verify the version:

```sh
nvim --version   # expect v0.11 or newer
```

### 2. Clone this configuration

Back up any existing config first:

```sh
mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null || true
git clone <this-repo-url> ~/.config/nvim
```

### 3. Install dependencies

From the config directory, run the bootstrap script. It detects your OS
(macOS via Homebrew, Debian/Ubuntu via apt), installs everything in the table
above, and is safe to re-run:

```sh
cd ~/.config/nvim
./install.sh
```

If you're on another platform, install the tools from the table manually.

### 4. First launch

```sh
nvim
```

On first launch, lazy.nvim bootstraps itself and installs all plugins, then
Mason installs the LSP servers and formatters. Let it finish, then quit and
reopen. Confirm the environment with:

```
:checkhealth
:Mason        " view / manage LSP servers
:Lazy         " view / manage plugins
```

## Environment setup

### Terminal font

Set your terminal to a Nerd Font (the install script installs *JetBrainsMono
Nerd Font* on macOS). Without one, icons render as boxes or question marks.

### Python projects

The config auto-detects a project's virtualenv for pyright and ruff, in this
priority order:

1. `$VIRTUAL_ENV` (an already-activated shell venv)
2. An in-project venv directory (`.venv`, `venv`, `env`, `.env`), searched
   upward from the file's directory (handles monorepos)
3. System `python3`

To pick a venv manually, press `<leader>cv` and fuzzy-select from any venv
found under the current working directory (requires `fd`).

On save, Python files have their imports organized (isort) and are formatted
with ruff automatically.

### GitHub CLI

Authenticate `gh` once so the GitHub issue/PR pickers work:

```sh
gh auth login
```

## Layout

```
init.lua                     entry point
lua/alix-leon/
├── core/                    options, keymaps, venv detection
├── lazy.lua                 plugin manager bootstrap
└── plugins/
    ├── lsp/                 mason, lspconfig, lazydev
    └── *.lua                one file per plugin
lazy-lock.json               pinned plugin versions
install.sh                   dependency bootstrap
```

## Updating

```
:Lazy sync    " update plugins to the versions in lazy-lock.json
:Mason        " update LSP servers
```

## Troubleshooting

- **Icons show as boxes** — your terminal isn't using a Nerd Font.
- **LSP not attaching** — run `:Mason` to confirm the server installed, and
  `:checkhealth vim.lsp` / `:LspInfo` to inspect.
- **`fd` not found** — on Debian the binary is `fdfind`; the install script
  symlinks it to `fd`, or symlink it yourself.
- **Plugin errors after an update** — `:Lazy restore` reverts to the pinned
  versions in `lazy-lock.json`.
