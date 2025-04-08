
def 'g' [...cmds: string] {
  if ($cmds | is-empty) {
    git status --short .
  } else {
    git ...$cmds
  }
}

alias cdg = cd (git rev-parse --show-toplevel)
alias ga = git add
alias gap = git add --patch
alias gb = git branch -av
alias gop = git open
alias gbl = git blame
alias gc  = git commit
alias gcm = git commit -m
alias gca = git commit --amend
alias gcf = git commit --fixup
alias gcl = git clone
alias gco = git checkout
alias gcoo = git checkout --
alias gf = git fetch
alias gi = git init
alias gl = git log --graph --pretty="format:%C(yellow)%h%Creset %C(red)%G?%Creset%C(green)%d%Creset %s %Cblue(%cr) %C(bold blue)<%aN>%Creset"
alias gll = git log --pretty="format:%C(yellow)%h%Creset %C(red)%G?%Creset%C(green)%d%Creset %s %Cblue(%cr) %C(bold blue)<%aN>%Creset"
alias gL = gl --stat
alias gp = git push
alias gpl = git pull --rebase --autostash
alias gs = git status --short .
alias gss = git status
alias gst = git stash
alias gr = git reset HEAD
alias grh = git reset --hard HEAD
alias gv = git rev-parse
