#!/bin/bash
backend_github_url="https://github.com/cameron-mckay/webnxAPI";
frontend_github_url="https://github.com/cameron-mckay/webnxVite";
ip_address=$(hostname -i);
user=$(logname);

# Exit if not running as super user
if [ "$(id -u)" -ne 0 ]; then echo "Please run as sudo." >&2; exit 1; fi

# start in root directory
cd /;

# Make sure gpupg is installed
apt-get install gnupg;
# Import mongodb public gpg cd
echo "Adding mongodb keys...";
wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | apt-key add -;

# Create list file for mongodb
echo "Adding mongodb repositories...";
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list;

# reload package database
echo "Updating apt...";
apt-get update;

# Install latest stable version of mongodb
echo "Installing mongodb...";
apt-get install -y mongodb-org;

# Set ulimit values to those recommended by mongodb
echo "Setting ulimits...";
ulimit -f unlimited;
ulimit -t unlimited;
ulimit -v unlimited;
ulimit -l unlimited;
ulimit -n 6400;
ulimit -m unlimited;
ulimit -u 6400;

# daemon reload to avoid service not found error
echo "Reloading daemons...";
systemctl daemon-reload;

# start mongodb
echo "Starting mongodb...";
systemctl start mongod;

# enable mongodb to automatically start after a reboot
echo "Adding mongodb as a daemon...";
systemctl enable mongod;

# bind database to ip address
echo "Binding mongodb to ip address...";
mongod --bind-ip "$ip_address";

# ADD TLS ENCRYPTION HERE

# Install node and npm
echo "Installing nodejs and npm...";
apt install nodejs
apt install npm

# Move to home directory
cd /home/"$user" || exit;

# Clone front end repository
echo "Cloning and installing front end...";
git clone "$frontend_github_url";
cd /home/"$user"/webnxVite || exit;
npm install;

# Return to home directory
cd /home/"$user" || exit;

# Clone back end repository
echo "Cloning and installing back end...";
git clone "$backend_github_url";
cd /home/"$user"/webnxAPI || exit;
npm install;

# Change ownership of all directories back to user
chown -R "$user" /home/"$user";

echo "Add the .env files to the webnxVite and webnxAPI folders and use the update script to finish setup."
echo "Nginx and TLS encryption for MongoDB will need to be configured manually."