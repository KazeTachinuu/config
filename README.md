# config

Personal configuration files, centered on the EPITA PIE starter kit.

## EPITA PIE starter kit (`pie/`)

A minimal, tested dev environment for the C piscine: vim (with clangd
LSP), bash, gdb, tmux and readline configs, auto-installed at every PIE
login through the AFS `.confs/install.sh` hook, plus a docker harness
that replays real PIE sessions for testing and a bats suite. Exam
survival included: a 3-line vimrc to memorize.

See [pie/README.md](pie/README.md) for the one-command install and the
full documentation. Research and design rationale live in
[pie/RESEARCH.md](pie/RESEARCH.md).

The EPITA `clang-format` at the repo root is the style the moulinette
grades against.

## Starship prompt

The Starship configuration is independent from the legacy shell installer above.
It uses plain text labels, terminal ANSI colors, and contextual modules. Language
versions, Git state, containers, SSH identity, failures, long commands, and
background jobs appear only when relevant.

Requirements:

- A current [Starship](https://starship.rs/) release
- Zsh, Bash, Fish, or another Starship-supported shell
- No Nerd Font or icon font

### Per-user installation

```sh
install -Dm644 starship.toml ~/.config/starship.toml
```

Initialize Starship in the appropriate shell startup file:

```sh
# Zsh
eval "$(starship init zsh)"

# Bash
eval "$(starship init bash)"

# Fish
starship init fish | source
```

### One shared configuration for users and root

Install one root-owned copy:

```sh
sudo install -Dm644 starship.toml /etc/starship.toml
```

Add this before Starship initialization for every account that should use it,
including root:

```sh
export STARSHIP_CONFIG=/etc/starship.toml
```

The shared file is intentionally root-owned. Update it with the same `install`
command after changing the repository copy. Do not point root at a user-writable
configuration.

### Optional transient prompt for Zsh

The included `transient` profile reduces completed prompts to `$ ` while keeping
the active prompt fully detailed. Install
[zsh-transient-prompt](https://github.com/olets/zsh-transient-prompt), then add:

```zsh
source /path/to/zsh-transient-prompt/transient-prompt.plugin.zsh
TRANSIENT_PROMPT_TRANSIENT_PROMPT='$(starship prompt --profile transient)'
```

Transient behavior belongs to the shell integration, so it is optional and does
not affect users who only install `starship.toml`.
