#!/bin/bash

sudo apt update
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
apt-cache policy docker-ce
sudo apt-get install -y docker-ce
sudo systemctl status docker
sudo systemctl stop docker
sudo mkfs.ext4 /dev/nvme0n1
sudo mkdir /mnt/nvme0n1
sudo mount /dev/nvme0n1 /mnt/nvme0n1
sudo mv -f /var/lib/docker /mnt/nvme0n1/
sudo ln -s /mnt/nvme0n1/docker /var/lib/
sudo systemctl start docker
sudo mv -f /home/ubuntu /mnt/nvme0n1/
echo '/dev/nvme0n1    /mnt/nvme0n1     ext4    defaults,discard    0 0' | sudo tee -a /etc/fstab
echo "Logout and log back in, then execute ./bootstrap-prepare.sh"
