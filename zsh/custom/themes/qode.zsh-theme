# qode.zsh-theme — a small two-segment prompt: "qode <cwd> <git>%".
ZSH_THEME_GIT_PROMPT_PREFIX="%F{magenta}("
ZSH_THEME_GIT_PROMPT_SUFFIX=")%f "
ZSH_THEME_GIT_PROMPT_DIRTY="*"
ZSH_THEME_GIT_PROMPT_CLEAN=""

PROMPT='%F{cyan}qode%f %F{blue}%~%f $(git_prompt_info)%(?.%F{green}.%F{red})%#%f '
RPROMPT=''
