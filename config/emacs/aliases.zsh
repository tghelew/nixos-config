#!/usr/bin/env zsh

e()     { pgrep -i emacs && emacsclient -n "$@" || emacs -nw "$@" }
ediff() { emacs -nw --eval "(ediff-files \"$1\" \"$2\")"; }
eman()  { emacs -nw --eval "(switch-to-buffer (man \"$1\"))"; }
ekill() { emacsclient --eval '(kill-emacs)'; }
edir()  { emacsclient -c -nw --eval "(dired \"$1\")"}
