# How to setup local environment for development

## Install docker

``` sh
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io
sudo groupadd docker
sudo usermod -aG docker ubuntu
```

## Initialize swarm

``` sh
docker swarm init
docker node ls
```

## Create directories

``` sh
sudo mkdir -p /var/home/data
sudo chown ubuntu:ubuntu /var/home/data
mkdir /var/home/data/local
```

## Clone repositories

``` sh
sudo apt-get install -y git
ssh-keygen
cd /var/home/data/local
git clone ssh://git@github.com/cpv-project/cpv-cql-driver.git
git clone ssh://git@github.com/cpv-project/cpv-framework.git
git clone ssh://git@github.com/cpv-project/cpv-ops.git
```

## Configure git

``` sh
git config --global core.editor vi
git config --global gui.encoding utf-8
# git config --global user.name USERNAME
# git config --global user.email EMAIL
```

## Configure sysctl

``` sh
echo "net.core.somaxconn=65535" | sudo tee -a /etc/sysctl.conf
cat /etc/sysctl.conf
```

## Setup vim (optional)

See: https://gist.github.com/303248153/950a8c986c8ba302701ae9fa34ab656a

## Install perf (optional)

``` sh
sudo apt-get install -y linux-tools-common
# run perf and it may ask you to install other package
```

## Generate gpg key for packing deb (optional)

``` sh
sudo su
apt-get install rng-tools
gpg --full-generate-key
rngd -r /dev/urandom # in other shell
cd ~/
rm .gnupg/S.* # remove unix sockets
mkdir -p /var/home/data/local/cpv-ops/local/docker/devenv/files/home/ubuntu/
cp -r .gnupg /var/home/data/local/cpv-ops/local/docker/devenv/files/home/ubuntu/
chown -R ubuntu:ubuntu /var/home/data/local/cpv-ops/local/docker/devenv/files/home/ubuntu/.gnupg
```

