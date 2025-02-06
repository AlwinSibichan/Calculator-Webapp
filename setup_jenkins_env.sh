#!/bin/bash

# Add jenkins user to docker group
if ! grep -q "^docker:" /etc/group; then
    sudo groupadd docker
fi
sudo usermod -aG docker jenkins

# Add sudoers entry for jenkins
echo "jenkins ALL=(ALL) NOPASSWD: /usr/sbin/groupadd, /usr/sbin/usermod, /usr/sbin/gpasswd, /usr/sbin/service" | sudo tee /etc/sudoers.d/jenkins-docker

# Set proper permissions
sudo chown -R jenkins:jenkins /var/lib/jenkins
sudo chmod -R 755 /var/lib/jenkins

# Restart Docker and Jenkins services
sudo service docker restart
sudo service jenkins restart

echo "Jenkins environment setup completed. Please restart your Jenkins instance." 