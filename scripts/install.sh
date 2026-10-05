#!/bin/sh
# Install Oh My Zsh with its OFFICIAL installer (tools/install.sh), pinned to one commit,
# into $ZSH (default ~/.oh-my-zsh). Used by the Dockerfile and by fleet.conf's INSTALL_CMD.
#
# --keep-zshrc + ZDOTDIR=<repo>/zsh: the installer finds this repo's .zshrc and leaves it
# alone instead of writing a stock one into $HOME.
set -eu
OMZ_REF="${OMZ_REF:-d745fbf3bd49a5038e089d7d343ca89db0cbaaff}"
ZSH="${ZSH:-$HOME/.oh-my-zsh}"
here=$(cd "$(dirname "$0")/.." && pwd)
export ZSH ZDOTDIR="$here/zsh"

if [ ! -d "$ZSH/.git" ]; then
  installer=$(mktemp)
  curl -fsSL "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/$OMZ_REF/tools/install.sh" -o "$installer"
  sh "$installer" --unattended --keep-zshrc
  rm -f "$installer"
fi
# the installer clones master; move to the pinned commit
git -C "$ZSH" fetch -q --depth=1 origin "$OMZ_REF"
git -C "$ZSH" -c advice.detachedHead=false checkout -q "$OMZ_REF"
echo "oh-my-zsh at $(git -C "$ZSH" rev-parse --short HEAD) in $ZSH"
