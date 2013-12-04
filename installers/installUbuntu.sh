# Add repositories
echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/mongodb.list
sudo apt-get install -y python-software-properties python g++ make
sudo apt-get install software-properties-common
sudo add-apt-repository -y ppa:chris-lea/node.js
sudo apt-get update

# Install dependencies
sudo apt-get install mongodb-10gen

sudo apt-get install nodejs
sudo ln -s /usr/bin/nodejs /usr/bin/node

sudo npm install -g grunt-cli

# Setup the application
cd server/ && npm run-script setup
