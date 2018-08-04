#!/bin/bash
################################################################################
##  ln -s ~/bin/PACMAN/update.pacman.sh  ->  ~/bin/update.pacman.sh
##
##
##  DEPENDENCIES:
##    pacman
##    pacmatic
##    reflector
##    yay
##
##
##  USE:  Place on your path (e.g.) in your home bin directory (~/bin)
##        Make executable, run:
##        $ chmod +x update.pacman.sh  &&  ./update.pacman.sh
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
        # read -p "Do you wish to continue updating? [y/n]" yn
        read -p "Do you wish to continue updating?  [Y/y or N/n]: " -n 1 -r
        case "$REPLY" in
            [Yy]* ) echo ""; echo ""; echo "";
                    break
                    ;;
            [Nn]* ) echo "";  echo ""
                    echo "Exiting update.pacman.sh"; echo "";
                    exit 0
                    ;;
            * ) echo "Please answer Y/y or N/n."; echo ""
                ;;
        esac
    done
}

update_question() {
  local _qu="${1}"
  local _fcn="${2}"

  while true; do
    read -p "${_qu}  [Y/y or N/n]: " -n 1 -r
    echo ""

    case "$REPLY" in
        y|Y ) echo "Yes"; echo ""; sleep 0.75;
              $_fcn
              echo ""; echo ""
              break
              ;;
        n|N ) echo "No"; echo ""; sleep 0.75;
              break
              ;;
        * ) echo "Please answer y or n."; echo ""
            ;;
    esac

  done
}


# Output directories
# Dir to save pacman output
PAC_DIR="$HOME/.config/pacman"

# Dir used for information on wiki page
WIKI_DIR="$HOME/Dropbox/TW/SCRIPTS"

# Git dir
GIT_DIR="$HOME/dev/config-pacman"

# Output Files:
# All installed files
ALL="all_pkgs.txt"
# Installed from repos
PAC="pacman_pkgs.txt"
# Installed from repos not in base + base-devel
PAC_USER="pacman_user_pkgs.txt"
# Aur
AUR="aur_pkgs.txt"

#################################################################################
# put the 3 next echo statements into vars and inject them into pause_fcn()
NVerToKeep=10

CACHE="Make sure that only the latest $NVerToKeep versions are cached"
UNINSTALLED="Remove all cached versions of uninstalled packages"
UNUSEDDBS="Remove all cached but not installed pkgs AND the unused sync database"


# Make sure that only the latest Nver versions are cached
echo $CACHE
sudo paccache -rk$NVerToKeep
echo ""; echo ""

# To remove all cached versions of uninstalled packages, re-run paccache with
echo $UNINSTALLED
sudo paccache -ruk0
echo ""; echo ""

# Remove packages that are no longer installed from the cache as well as
# currently unused sync databases
echo $UNUSEDDBS
sudo pacman -Sc
echo ""; echo ""
#################################################################################

#################################################################################
# ARE THERE ANY FAILED PROCESSES? CHECK SYSTEMCTL FOR PROBLEMS
systemctl --failed
echo ""; echo ""
pause_function
#################################################################################

#################################################################################
# Update the mirror list, use HTTPS, US mirrors sync'd in the last 12 hours
# echo "Updating the mirrorlist - Selecting the fastest US mirrors: /etc/pacman.d/mirrorlist"
sudo cp -u /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.orig
sudo reflector --verbose --country 'United States' --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
echo ""; echo ""

# AUDIT URL FILE
nano /etc/pacman.d/mirrorlist
echo ""; echo ""


#################################################################################
pause_function
#################################################################################
# Force refresh and sync and update all packages
echo "Refresh, sync, and update all packages"
# sudo pacmatic -Syu
sudo pacman -Syu
echo ""; echo ""


# Dir to store output
mkdir -p ~/.config/pacman


# List of all installed packages
echo "Creating list of all explicitly installed packages: $PAC_DIR/all_pkgs.txt"
FILE="$ALL"
pacman -Qqe | tee "$GIT_DIR/$FILE" "$PAC_DIR/$FILE" > "$WIKI_DIR/$FILE"
echo ""; echo ""


# Backup the current list of explicitly pacman installed packages
echo "Creating list of all pacman (explicitly) installed packages: $PAC_DIR/pacman_pkgs.txt"
FILE="$PAC"
pacman -Qqen | tee "$GIT_DIR/$FILE" "$PAC_DIR/$FILE" > "$WIKI_DIR/$FILE"
echo ""; echo ""


# List of pacman installed packages *NOT* in base-devel
echo "Creating list of all pacman (explicitly) installed packages NOT in base-devel: $PAC_DIR/pacman_user_pkgs.txt"
FILE="$PAC_USER"
comm -23 <(pacman -Qqne | sort) <(pacman -Qgq base base-devel | sort) | tee  "$GIT_DIR/$FILE" "$PAC_DIR/$FILE" > "$WIKI_DIR/$FILE"
echo ""; echo ""


# Installed packages not available in official repositories
echo -e "Creating a list of all explicitly installed packages not available in official repositories"
FILE="$AUR"
pacman -Qqem | tee "$GIT_DIR/$FILE" "$PAC_DIR/$FILE" > "$WIKI_DIR/$FILE"
echo ""; echo ""


# Creating list of all orphaned packages
echo "All orphaned packages: Packages installed as depedencies but are now not needed"
sudo pacman -Qdt
echo ""; echo ""

# For recursively removing orphans and their configuration files:
update_question "Would you like to remove orphaned packages?" "sudo pacman -Rns $(pacman -Qqtd)"
################################################################################


################################################################################
# Update the packages from the AUR
echo "Update the packages from the AUR"
yay -Syu
echo ""; echo ""


# Cleaning unneeded dependencies (AUR packages)
echo "Cleaning unneeded dependencies (AUR packages)"
yay -Yc
echo ""; echo ""
################################################################################


exit 0

