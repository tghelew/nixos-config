alias dk=docker
alias dkc=docker-compose
alias dkm=docker-machine
alias dkl='dk logs'
alias dkcl='dkc logs'

dkclr() {
  dk stop $(docker ps -a -q)
  dk rm $(docker ps -a -q)
}

dke() {
  dk exec -it "$1" "${@:1}"
}

# d[oc]k[er]t[est]
# example: dkt <program> [<additional command wihtin container>]
dkt() {
  dk run  -e TERM -e COLORTERM -e LC_ALL=C.UTF-8 -it --rm alpine sh -uec '
  apk add git zsh vim \"$1\"
  \"${@:1}\"
  exec zsh'
}
