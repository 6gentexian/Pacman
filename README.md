# README


## Summary
This script provides basic maintenance and updating for pacman (package management) in an Arch Linux installation.  The scripts has 3 main parts:
1. System maintenance- regulating the contents and size of the pacman cache.
2. Updates the mirrorlist, syncs official repos and updates packages from the official repos and the AUR.
3. Outputs files that contain lists of packages explicitly installed on the machine.



## Files
`update.pacman.sh`



## Dependecies
* pacman
* pacmatic
* reflector
* yay



## Use
Place script on your path (e.g. in ~/bin), make it executable and run it:
>$ chmod +x  update.pacman.sh  
$ ./update.pacman.sh



## NB
Pls customize the various directories the output is saved to and the output file names
This script saves files into a folder for viewing in a wiki page. This is not necessary.
To eliminate this, one can comment out the ```WIKI_DIR``` (line 72) AND comment out the latter most part of each output statement.
For example, in the section that saves a list of all explicitly installed packages:
>\# List of all installed packages  
>echo "Creating list of all explicitly installed packages: $PAC_DIR/all_pkgs.txt"  
>FILE="$ALL"  
>pacman -Qqe | tee "$GIT_DIR/$FILE" "$PAC_DIR/$FILE" > "$WIKI_DIR/$FILE"  

change the last line to  
>pacman -Qqe | tee "$GIT_DIR/$FILE" > "$PAC_DIR/$FILE"



## TODOs
The output from pacmatic should be more readable - perhaps saved as an html file and viewed in a browser?



## License
See [LICENSE](LICENSE.md)
