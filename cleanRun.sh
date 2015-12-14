

# this assumes you have a folder called "repo" inside your crawl installation
# and then this repo cloned into that folder. Change this based on your file layout.
# all it does it move in the functions.lua file and then kick off the game.
# run this script from the DCSS installation folder.
rm ./settings/functions.lua
cp ./repo/Crawl/functions.lua ./settings/functions.lua
./crawl.exe