# README


## Summary
This script provides basic maintenance and updating for pacman (package management) in an Arch Linux installation.  The script has 3 main parts:
1. System maintenance- regulating the contents and size of the pacman cache.
1. Updating the mirrorlist, syncs official repos and updates packages (from the official repos and the AUR).
1. Outputs files that contain lists of installed packages.



## Files
`update.pacman.sh`



## Dependecies
* pacman
* pacmatic (optional)
* reflector
* yay



## Use
Place script on your path (e.g. in ~/bin), make it executable and run it:
>$ chmod +x  update.pacman.sh  
$ ./update.pacman.sh



## NB
Pls customize the various directory and file names.  
This script saves files into git repo and a wiki folder.  This is not necessary.  
To eliminate this, comment out the 'GIT_DIR' and 'WIKI_DIR' (~ line 95) AND alter the latter most part of each output statement.
For example, in the section that saves a list of explicitly installed packages:
>\# List of all installed packages  
>echo "Creating list of all explicitly installed packages: $PAC_DIR/all_pkgs.txt"  
>FILE="$ALL"  
>pacman &emsp; -Qqe &emsp; | &emsp; tee &emsp; "$GIT_DIR/$FILE" &emsp; "$PAC_DIR/$FILE" &emsp; > &emsp; "$WIKI_DIR/$FILE"  

change the last line to
>pacman &emsp; -Qqe &emsp; > &emsp; "$PAC_DIR/$FILE"



## TODOs
The output from pacmatic should be more readable - perhaps saved as an html file and viewed in a browser?



## License
See [LICENSE](LICENSE.md)
