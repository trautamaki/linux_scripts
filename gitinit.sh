git config --global alias.st status
git config --global alias.chp cherry-pick
git config --global alias.hubchp '! git fetch $(echo $1 | cut -d / -f-5) && git chp $(echo $1 | cut -d / -f 7-) && :'

echo "set tabsize 4" >> ~/.nanorc
echo "set tabstospaces" >> ~/.nanorc
#echo "set autoindent" >> ~/.nanorc
echo "set tabstospaces" >> ~/.nanorc
