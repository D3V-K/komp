#!/usr/bin/env bash

echo "[Running docker-install.sh]"

sudo apt-get update -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io -y
docker --version
sudo usermod -aG docker vagrant
newgrp docker
docker ps
systemctl status docker

# kind runs each node as a full systemd+containerd+kubelet stack in a
# container; with multiple kind clusters/nodes on one host the default
# Ubuntu inotify limits get exhausted and new nodes hang mid-boot
# (https://kind.sigs.k8s.io/docs/user/known-issues/). Raise them up front.
echo "fs.inotify.max_user_watches=524288
fs.inotify.max_user_instances=1024" | sudo tee /etc/sysctl.d/99-kind-inotify.conf
sudo sysctl --system