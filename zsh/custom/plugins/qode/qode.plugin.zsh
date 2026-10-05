# qode — the template's own Oh My Zsh plugin. Lives in $ZSH_CUSTOM/plugins/qode and is
# enabled by `plugins=(... qode)` in .zshrc.

qode_hello() {
  print -r -- "hello from qode"
}

# mkcd DIR — make a directory and cd into it
mkcd() {
  mkdir -p -- "$1" && cd -- "$1"
}

alias ll='ls -lah'
