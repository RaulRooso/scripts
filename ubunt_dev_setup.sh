# Exit immediately if a command exits with a non-zero status
set -e

#System update
echo 'Updating system...'
sudo apt update -y
sudo apt upgrade -y

# Install VS code
echo 'Installing VS code...'
sudo snap install code --classic

#Install Bun
echo 'installing Bun...'
sudo snap install bun-js


echo 'Done! Development setup finished!'

#Check for versions
echo 'VS code version:'
code --version

echo 'Bun version:'
bun --version || echo 'Use bun-js.bun if bun is not recognized'

# use: chmod +x ubunt_dev_setup.sh to add exicutable permission