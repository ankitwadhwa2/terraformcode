#!/bin/bash
sudo su
sudo apt install apache2 -y
sudo service apache2 restart
echo "this is coming from terraform" >> /var/www/html/ankit.html
echo "healthy" > /home/ubuntu/ankit.txt
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
. ~/.nvm/nvm.sh
nvm install node
node -e "console.log('Running Node.js ' + process.version)"