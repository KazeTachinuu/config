# config

Personal configuration files.

- **`pie/`**: EPITA PIE starter kit: vim (clangd LSP), bash, gdb, tmux and
  readline configs, auto-installed at every PIE login, plus a docker
  harness and bats suite for testing. See [pie/README.md](pie/README.md).
- **`clang-format`**: the EPITA style the moulinette grades against.
- **`starship.toml`**: prompt config. Plain text labels, ANSI colors, no
  Nerd Font. Install and enable:

  ```sh
  install -Dm644 starship.toml ~/.config/starship.toml
  eval "$(starship init bash)"   # or zsh / fish, in your shell rc
  ```
