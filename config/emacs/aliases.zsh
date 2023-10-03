#!/usr/bin/env zsh

e()     { emacsclient -nw "$@" -a ""}
ediff() { emacsclient -a "" -nw --eval "(ediff-files \"$1\" \"$2\")"; }
eman()  { emacsclient -nw --eval "(switch-to-buffer (man \"$1\"))"; }
ekill() { emacsclient --eval '(kill-emacs)'; }
edir()  { emacsclient -c -nw --eval "(dired \"$1\")"}
