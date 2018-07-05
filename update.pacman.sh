#!/bin/bash
################################################################################
##  ln -s ~/bin/PACMAN/update.pacman.sh  ->  ~/bin/update.pacman.sh
##
##
##  DEPENDENCIES:
##    pacman
##    pacmatic
##    reflector
##    systemd
##
##
##  USE:  Place on your path (e.g) in your home bin directory (~/bin)
##        Make executable, run  $ update.pacman.sh
##
##  TODOs:
##			Create auditable 'archnews.html' file
##
##  NB
################################################################################
pause_function() {
  # print_line and collect imput
  #   read -e -sn 1 -p "Press enter to continue..."
    while true; do
        read -p "Do you wish to continue updating? [y/n]" yn
        case $yn in
            [Yy]* ) break;;
            [Nn]* ) echo "";  echo "Exiting update.pacman.sh"; echo "";  exit;;
            * ) echo "Please answer Y/y or N/n.";;
        esac
    done
}
#################################################################################
# put the 3 next evho statements into vars and inject them into pause_fcn()
CACHE5      = "Make sure that only the latest 5 versions are cached"
UNINSTALLED = "Remove all cached versions of uninstalled packages"
UNUSEDDBS   = "Remove all unused, unsynced databases"


# Make sure that only the latest 5 versions are cached
echo "Make sure that only the latest 5 versions are cached"
sudo paccache -rk 5
echo ""; echo ""

# To remove all cached versions of uninstalled packages, re-run paccache with
echo "Remove all cached versions of uninstalled packages"
sudo paccache -ruk0
echo ""; echo ""

# Remove all the cached packages that are not currently installed:
echo "Remove all unused, unsynced databases"
sudo pacman -Sc
echo ""; echo ""
#################################################################################

#################################################################################
# ARE THERE ANY FAILED PROCESSES? CHECK SYSTEMCTL FOR PROBLEMS
systemctl --failed
pause_function
#################################################################################

#################################################################################
# Update the mirror list, use HTTPS, US mirrors sync'd in the last 12 hours
echo "Updating the mirrorlist - Selecting the fastest US mirrors: /etc/pacman.d/mirrorlist"
sudo cp -u /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.orig
sudo reflector --verbose --country 'United States' --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
echo ""; echo ""

# AUDIT URL FILE
emacs /etc/pacman.d/mirrorlist
echo ""; echo ""

pause_function
#################################################################################

#################################################################################
# Force refresh and sync and update all packages
echo "Refresh, sync, and update all packages"
sudo pacmatic -Syu
echo ""; echo ""


# Backing up list of all installed packages
echo "Creating list of all installed packages in: /home/edward/.config/pacman/installed_pkglist.txt"
mkdir -p /home/edward/.config/pacman
pacman -Qq > /home/edward/.config/pacman/installed_pkglist.txt
cp /home/edward/.config/pacman/installed_pkglist.txt /home/edward/Dropbox/TW/SCRIPTS/installed_pkglist.txt
echo ""; echo ""


# Backup the current list of pacman installed packages: $ pacman -Qqen > pkglist.txt
echo "Creating list of all pacman installed packages in: /home/edward/.config/pacman/pacman_installed_pkglist.txt"
pacman -Qqen > /home/edward/.config/pacman/pacman_installed_pkglist.txt
cp /home/edward/.config/pacman/pacman_installed_pkglist.txt /home/edward/Dropbox/TW/SCRIPTS/pacman_installed_pkglist.txt
echo ""; echo ""


# Installed packages not available in official repositories
echo "All installed packages not available in official repositories "
pacman -Qem
echo ""; echo ""


# Creating list of all orphaned packages
echo "All orphaned packages: Packages that were installed as depedencies but are now not needed"
sudo pacman -Qdt
echo ""; echo ""
################################################################################

################################################################################
# Update the packages from the AUR
echo ""; echo ""
yaourt -Syu --aur
echo ""; echo ""


# Creating list of all yaourt orphaned packages
echo "All orphaned packages: Packages that were installed as depedencies but are now not needed"
yaourt -Qdt
echo ""; echo ""
################################################################################

exit 0
