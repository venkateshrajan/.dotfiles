# Installation scripts

Some useful tool installation scripts

### Scripts:
- #### utils.sh:
    Contains useful utility functions
- #### nvim.sh:
    Installation script for nvim and the required packages

    ```bash
    sudo ./nvim.sh
    ```

    Execute the final command once everything is a success

### Planned implementions/scripts
- [x] Nvchad config installer
- [x] Tmux installer
- [x] Tmux config installer
- [x] A common interactive installer to choose the scripts
- [ ] Split the package installer as a seperate utility
- [ ] Common installer should install findutils (fedora) and dialog
- [ ] Bug: Latest NvChad has issues with the old nvim
- [ ] Grab the post commands from all the individual commands and log it once at the end
- [ ] Add option to install lsd
- [ ] Bug: Observed color issues on debian docker image

