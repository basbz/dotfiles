#export PS1="\h:\W \u ⚡ "

# if not running interactively, don't do anything
[ -z "$PS1" ] && return

set_prompt_style () {
  if [ -n "$SSH_CLIENT" ]; then
    PS1="┌─[\[\e[0;34m\]\h\[\e[0m\] \[\e[1;33m\]\w:\[\e[0m\] \[\e[1;31m\]SSH\[\e[0m\]]\n└─╼ "
  else
    PS1="┌─[\[\e[34m\]\h\[\e[0m\] \[\e[32m\]\w\[\e[0m\]]\n└─╼ "
  fi
}

set_prompt_style
