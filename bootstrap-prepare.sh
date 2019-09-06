#!/bin/bash

sudo apt install unzip
sudo usermod -aG docker ubuntu
sudo systemctl restart docker
sudo docker create -v /srv --name pmm-data-2-0-0-beta6 perconalab/pmm-server:2.0.0-beta6 /bin/true
sudo docker run -d -p 80:80 -p 443:443 --volumes-from pmm-data-2-0-0-beta6 --name pmm-server-2.0.0-beta6 --restart always perconalab/pmm-server:2.0.0-beta6
git clone git@github.com/dotmanila/pmm-server-xenial.git
cd pmm-server-xenial
./packages.sh
cd
curl -sL https://deb.nodesource.com/setup_8.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh
sudo apt-get install -y nodejs
sudo npm install -g tsc
sudo npm install -g concurrently
sudo npm install -g typescript
cd pmm-server-xenial/packages/grafana-dashboards-2.0.0-beta6/pmm-app/
npm run build
cd ~/pmm-server-xenial/
./buildrun.sh
echo "Great, you can now reuse ./buildrun.sh to build the Docker image"
