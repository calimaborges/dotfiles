case "$(uname -s)" in
  Darwin) alias ls='ls -G' ;;
  Linux) alias ls='ls --color=auto' ;;
esac

alias ll='ls -lh'
alias la='ls -lah'

alias grep='grep --color=auto'

alias ..='cd ..'
alias ...='cd ../..'

alias gst='git status -sb'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git log --oneline --decorate -20'
alias gco='git checkout'
alias gp='git pull'
alias gP='git push'
