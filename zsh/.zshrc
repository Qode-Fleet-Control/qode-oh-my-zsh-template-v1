# .zshrc — the versioned zsh setup this repo ships. Oh My Zsh lives in $ZSH; everything
# custom (plugin, theme) lives next to this file in ./custom, so the repo is the source.
QODE_ZSH_VERSION="$(<${${(%):-%x}:A:h:h}/VERSION)"

export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
ZSH_CUSTOM="${${(%):-%x}:A:h}/custom"   # this file's own directory + /custom
ZSH_THEME="qode"

# A pinned install: never self-update, never prompt.
zstyle ':omz:update' mode disabled
DISABLE_AUTO_TITLE="true"

plugins=(git qode)

source "$ZSH/oh-my-zsh.sh"

# --- user configuration -----------------------------------------------------------
export EDITOR="${EDITOR:-vi}"
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh_history"
