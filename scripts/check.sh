#!/bin/sh
# The job: start an INTERACTIVE zsh with this repo's setup and check that it loaded —
# Oh My Zsh itself, a bundled plugin, the custom plugin, the custom theme and its prompt.
# Exits 0 when every check passes.
set -u
here=$(cd "$(dirname "$0")/.." && pwd)
export ZDOTDIR="$here/zsh"   # always this repo's setup
export TERM="${TERM:-xterm-256color}"

errfile=$(mktemp)
zsh -i -c '
  fail=0
  ok()   { print -r -- "ok   $1" }
  bad()  { print -r -- "FAIL $1"; fail=1 }
  print -r -- "qode zsh setup $QODE_ZSH_VERSION, zsh $ZSH_VERSION"
  (( $+functions[omz] ))          && ok "oh-my-zsh loaded from $ZSH"   || bad "oh-my-zsh not loaded"
  (( $+aliases[gst] ))            && ok "bundled plugin: git"           || bad "git plugin not loaded"
  (( $+functions[qode_hello] ))   && ok "custom plugin: qode"           || bad "qode plugin not loaded"
  [[ "$(qode_hello)" == "hello from qode" ]] && ok "qode_hello works"   || bad "qode_hello output"
  [[ $ZSH_THEME == qode ]]        && ok "theme: $ZSH_THEME"             || bad "theme is ${ZSH_THEME:-unset}"
  [[ $PROMPT == *qode* ]]         && ok "prompt set by the qode theme"  || bad "prompt not from the theme"
  rendered=$(print -P -- "$PROMPT")
  [[ $rendered == *qode* ]]       && ok "prompt renders"                || bad "prompt does not render"
  print -r -- "prompt renders as: $rendered"
  exit $fail
' 2>"$errfile"
rc=$?
if [ -s "$errfile" ]; then
  echo "FAIL zsh wrote to stderr while loading:"; sed 's/^/  | /' "$errfile"; rc=1
fi
rm -f "$errfile"
[ $rc -eq 0 ] && echo "PASS" || echo "FAILED"
exit $rc
