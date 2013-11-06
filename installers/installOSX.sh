# Install dependencies from with homebrew
brew install node
brew install mongo

npm install -g grunt-cli

# Setup the application
cd server/ && npm run-script setup
