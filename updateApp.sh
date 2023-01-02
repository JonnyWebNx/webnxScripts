#!/bin/sh
cd ~/webnxVite || return;
# Pull newest changes from github
git init;
git pull;
# Build front end
npm run build;
# Switch to backend folder
cd ~/webnxAPI || return;
# Pull updates from GitHub
git init;
git pull;
npm run build;
# Move to home directory
cd ~ || return;
# Remove old site assets
rm -r ~/webnxAPI/dist/static
# Move built front end to static folder on backend
mv ~/webnxVite/dist ~/webnxAPI/dist/static
# Go back into backend folder
cd ~/webnxAPI || return;
# Clear pm2
pm2 delete all;
# Start new pm2 instances
pm2 start dist/index.js --name webnxAPI -i 16;
# exit
exit 0;