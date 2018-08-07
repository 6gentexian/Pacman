#!/bin/bash
################################################################################
#  ~/bin/update.pacman.sh
#
# SUMMARY:
#   This script provides basic maintenance and updating for pacman (package
#   management) in an Arch Linux installation.  The script has 3 main parts:
#   1. System maintenance- regulating the contents and size of the pacman cache.
#   2. Updating the mirrorlist, syncs official repos and updates packages (from
#   the official repos and the AUR).
#   3. Outputs files that contain lists of installed packages.
#
# REQUIRES:    pacman
#              pacmatic (optional)
#              reflector
#              yay
#
# REQUIRED BY: N/A
#
# USE:    Place script on your path (e.g. in ~/bin), make it executable and run it:
#         $ chmod +x update.pacman.sh
#         $ ./update.pacman.sh
#
# TODOs:  The output from pacmatic should be more readable -
#         perhaps saved as an html file and viewed in a browser?
#
# NB:     Pls customize the various directory and file names.
#         This script saves files into git repo and a wiki folder.
#         This is not necessary. To eliminate this, comment out the
#         'GIT_DIR' and 'WIKI_DIR' (~ line 95) AND alter the latter most
#         part of each output statement.
#
#         For example, in the section that saves a list of explicitly installed packages:
#           # List of all installed packages
#           echo "Creating list of all explicitly installed packages: $PAC_DIR/all_pkgs.txt"
#           FILE="$ALL"
#           pacman &emsp; -Qqe &emsp; | &emsp; tee &emsp; "$GIT_DIR/$FILE" &emsp; "$PAC_DIR/$FILE" &emsp; > &emsp; "$WIKI_DIR/$FILE"
#
#         change the last line (and similar subsequent lines) to:
#           pacman &emsp; -Qqe &emsp; > &emsp; "$PAC_DIR/$FILE"
#
# CREATED:   7 August 2018
################################################################################

##  Functions, folder and file names  ------------------------------------------
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

##  Functions, folder and file names  ------------------------------------------


#################################################################################
# Put the following 3 statements into vars. This adds emphasis (bold) output to
# the display on my xterm-256.  This is not needed
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
echo "Updating the mirrorlist - Selecting the fastest US mirrors: /etc/pacman.d/mirrorlist"

sudo cp -u /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.orig
sudo reflector --verbose --country 'United States' --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
echo ""; echo ""

# AUDIT URL FILE
nano /etc/pacman.d/mirrorlist
echo ""; echo ""


#################################################################################
pause_function
#################################################################################
# Refresh, sync and update all packages from official repos
echo "Refresh, sync, and update all packages from official repos"
# sudo pacmatic -Syu
sudo pacman -Syu
echo ""; echo ""


# Dir to store output
mkdir -p ~/.config/pacman


##  Output save to three folders  ----------------------------------------------

# List of all installed packages
echo "Creating list of all explicitly installed packages: $PAC_DIR/all_pkgs.txt"
FILE="$ALL"
pacman -Qqe | tee "$GIT_DIR/$FILE" "$PAC_DIR/$FILE" > "$WIKI_DIR/$FILE"
echo ""; echo ""


# List of explicitly pacman installed packages
echo "Creating list of all pacman (explicitly) installed packages: $PAC_DIR/pacman_pkgs.txt"
FILE="$PAC"
pacman -Qqen | tee "$GIT_DIR/$FILE" "$PAC_DIR/$FILE" > "$WIKI_DIR/$FILE"
echo ""; echo ""


# List of pacman installed packages *NOT* in base + base-devel
echo "Creating list of all pacman (explicitly) installed packages NOT in base + base-devel: $PAC_DIR/pacman_user_pkgs.txt"
FILE="$PAC_USER"
comm -23 <(pacman -Qqne | sort) <(pacman -Qgq base base-devel | sort) | tee  "$GIT_DIR/$FILE" "$PAC_DIR/$FILE" > "$WIKI_DIR/$FILE"
echo ""; echo ""


# Installed packages not available in official repositories
echo -e "Creating a list of all explicitly installed packages from the AUR"
FILE="$AUR"
pacman -Qqem | tee "$GIT_DIR/$FILE" "$PAC_DIR/$FILE" > "$WIKI_DIR/$FILE"
echo ""; echo ""


# Creating list of all orphaned packages
echo "All orphaned packages: Packages installed as depedencies but are now not needed"
sudo pacman -Qdt
echo ""; echo ""

# Recursively removing orphans and their configuration files:
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

##  EOF  -----------------------------------------------------------------------

