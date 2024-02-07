#!/bin/bash

if [[ $EUID > 0 ]]
  then echo "Please run as root."
  exit
fi

echo 'overlay' >> /etc/modules-load.d/containerd.conf
echo 'br_netfilter' >> /etc/modules-load.d/containerd.conf

modprobe overlay
modprobe br_netfilter

echo "Did overlay and br_netfilter modules."

echo 'net.bridge.bridge-nf-call-iptables = 1' >> /etc/sysctl.d/k8s.conf
echo 'net.bridge.bridge-nf-call-ip6tables = 1' >> /etc/sysctl.d/k8s.conf
echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.d/k8s.conf

sysctl --system

echo "Did iptables stuff."


sudo apt-get update && sudo apt-get install -y containerd.io

mkdir -p -m 755 /etc/containerd

containerd config default | tee /etc/containerd/config.toml

sed -i 's/disabled_plugins/#disabled_plugins/' /etc/containerd/config.toml

systemctl restart containerd

echo "Did containerd stuff, for some reason."


swapoff -a

echo "Swap off."


apt-get update && apt-get install -y ca-certificates apt-transport-https curl

echo "Installed dependencies."


mkdir -p -m 755 /etc/apt/keyrings

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

echo "Got GPG keys."


apt-get update

apt-get install -y kubelet=1.27.0-00 kubeadm=1.27.0-00 kubectl=1.27.0-00

sudo apt-mark hold kubelet kubeadm kubectl

echo "Done, I guess."
