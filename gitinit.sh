git config --global alias.st status

# Usage: git chp <hash>
git config --global alias.chp cherry-pick

# Usage: git hubchp <github commit link> <branch>
# Branch can be left empty, if commit is on default (git fetch) branch
# Example:
#   git hubchp https://github.com/trautamaki/linux_scripts/commit/c58a383a933857ed830c41c2c9e3a85e5382ed07 aplha
git config --global alias.hubchp '! git fetch $(echo $1 | cut -d / -f-5) $2 && git chp $(echo $1 | cut -d / -f 7-) && :'

# nano config
echo "set tabsize 4" >> ~/.nanorc
echo "set tabstospaces" >> ~/.nanorc
#echo "set autoindent" >> ~/.nanorc
echo "set tabstospaces" >> ~/.nanorc

echo "alias mergecommon='git fetch https://android.googlesource.com/kernel/common android-4.4-p && git merge FETCH_HEAD'" >> ~/.bashrc
