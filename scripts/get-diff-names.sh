git diff HEAD~1 --name-only | awk -F\, '{cmd="pwd | grep -Po /vaultcx.*$"; cmd | getline mypwd; close(cmd); print mypwd "/" $0}'
