alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias q=exit
alias c=clear
if (( $+commands[doas] )); then
  alias _='doas '
else
  alias _='sudo '
fi
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -pv'
alias wget='wget -c'
alias path='echo -e ${PATH//:/\\n}'
alias ports='netstat -tulanp'
alias sports='_ netstat -tulanp'

alias mk=make
alias gurl='curl --compressed'

alias shutdown='_ shutdown'
alias reboot='_ reboot'

# An rsync that respects gitignore
rcp() {
  # -a = -rlptgoD
  #   -r = recursive
  #   -l = copy symlinks as symlinks
  #   -p = preserve permissions
  #   -t = preserve mtimes
  #   -g = preserve owning group
  #   -o = preserve owner
  # -z = use compression
  # -P = show progress on transferred file
  # -J = don't touch mtimes on symlinks (always errors)
  rsync -azPJ \
    --include=.git/ \
    --filter=':- .gitignore' \
    --filter=":- $XDG_CONFIG_HOME/git/ignore" \
    "$@"
}; compdef rcp=rsync

alias rcpd='rcp --delete --delete-after'
alias rcpu='rcp --chmod=go='
alias rcpdu='rcpd --chmod=go='

if (( $+commands[journalctl] )); then
  alias jc='journalctl -xe'
  alias jcu='journalctl --user -xe'
  alias jcf='journalctl -f'
  alias sc=systemctl
  alias scu='systemctl --user'
  alias ssc='_ systemctl'
fi

if (( $+commands[eza] )); then
  alias eza="eza --group-directories-first --git";
  alias l="eza -blF";
  alias ll="eza -abghilmu";
  alias llm='ll --sort=modified'
  alias la="LC_COLLATE=C eza -abhlF";
  alias tree='eza --tree'
fi

if (( $+commands[fasd] )); then
  # fuzzy completion with 'zs' when called without args
  function zs {
    [ $# -gt 0 ] && z "$*" && return
    cd "$(z -l 2>&1 | fzf --height 40% --reverse --info=inline --tac | sed 's/^[0-9,.]* *//')"
  }
fi

if (( $+commands[kitten] && ! $+command[ghostty])); then
 alias ssh="kitten ssh"
fi

autoload -U zmv

function take {
  mkdir "$1" && cd "$1";
}; compdef take=mkdir

function zman {
  PAGER="less -g -I -s '+/^       "$1"'" man zshall;
}

# Create a reminder with human-readable durations, e.g. 15m, 1h, 40s, etc
if (( $+commands[notify-send] )); then
  function r {
    local time=$1; shift
    sched "$time" "notify-send --urgency=critical 'Reminder' '$@'";
  }; compdef r=sched
fi


function alval {
  alias | grep -i $1 | fzf -i --info=inline
}

if (( $+commands[wev] )); then
  function wl-showkeys {
      wev -f wl_keyboard:key
  }
fi

if (( $+commands[rg] )); then
  alias search=rg
else
  alias search=grep
fi

# Global aliases
alias -g G='| search '
alias -g L='| less -ei '

# NIX_PATH
function nix-path {
  if [[ $# !=  1 ]]; then
    echo "nix-path require one parameter." >&2
    return 1
  fi
  local pattern="${1//=/}="
  env | grep -i "${pattern}" | tr ":" "\n" | awk -F'='  "/${pattern}/{print\$2}"
}

alias history-stat="history 0 | awk '{print \$2}' | sort | uniq -c | sort -r -n | head"

#TODO: Add get aliases (using zstyle)?
#TODO: Add Darwin Aliases
