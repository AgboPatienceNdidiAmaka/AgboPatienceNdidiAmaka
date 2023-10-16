#!/bin/bash

echo "Starting Master node provisioning..."

echo "updating package list and upgrading installed packages..."
sudo apt-get update -y
sudo apt-get update -y

echo "installing net tools"
sudo apt-get install net tools

echo "Creating 'altschool' user and granting sudo priviledges"
sudo useradd -m altschool
sudo usermod -a -G sudo altschool
echo -e "1234\n1234" | sudo password altschool

echo "Generating an SSH key pair for 'altschool' user if not already done"
if [!-f/home/altschool/.ssh/id_rsa];then 
  sudo -u altshool ssh-keygen-t rsa -N"" -f/home/altschool/.ssh/id_rsa
fi

echo "Copying the SSH public Key to the Slave node..."
sshpass -p '1234' ssh-copy-id-i/home/altchool/.ssh/id_rsa.pub slave@192.168.33.10

echo "Creating /mnt/altschool directory if it doesn't exist"
if[!-d/mnt/altschool]; then
  sudo mkdir -p/mnt/altschool
fi

echo "Changing the owner of the directory to 'altschool and ensuring 'altschool' has read access to the directory"
sudo chown altschool:altschool /mnt/altschool
sudo chmod u+r /mnt/altschool

echo "Copying contents to the slave node"
sudo apt-get install rsync sshpass -y
sudo rsync -avc /mnt/altschool/altschool@192.168.33.10:/mnt/altschool/slave

echo "Displaying running processes"
ps aux

echo "installing Apache and setting it to start on boot"
sudo apt-get install apache2 -y
sudo systemctl enable apache2

echo "installing MySQL and setting root password to amaka1624"
sudo debconf-set-selections <<<'mysql-server mysql-server/ root_password password amaka1624
sudo apt-get install mysql-server -y

echo "Securing MySQL installation"
sudo mysql_secure_installation 
<<EOF
y
amaka1624
y
y
y
y
EOF

echo "Installing PHP and related modules, enabling the Apache PHP module, and restarting Apache..."
sudo apt-get install php libapache2-mod-php php-mysql -y
sudo a2enmod php7.4 #replace 7.4 with your PHP version if different
sudo systemctl restart apache2

echo "Creating a PHP test script and validating PHP functionality..."
echo "<?php phpinfo(); ?>"|sudo tee /var/www/html/index.php
echo "PHP validation: http://192.168.33.10/index.php" #Update the IP address as needed

echo "Master node Provisioning completed".





