# See https://xilinx.github.io/kria-apps-docs/kv260/2022.1/build/html/docs/smartcamera/docs/app_deployment.html
set -x

sudo touch /etc/cloud/cloud-init.disabled
sudo snap install xlnx-config --classic --channel=2.x

#xlnx-config.sysinit
sudo add-apt-repository ppa:xilinx-apps
sudo add-apt-repository ppa:ubuntu-xilinx/sdk
sudo apt update
sudo apt upgrade

sudo apt install xrt-dkms

# setup local datetime
sudo timedatectl set-ntp true
sudo timedatectl set-timezone America/Los_Angeles
timedatectl

# Install docker
sudo groupadd docker
sudo usermod -a -G docker  $USER
sudo apt-get update && sudo apt-get upgrade
curl -sSL https://get.docker.com | sh
sudo systemctl enable --now docker

# Enable qemu-user emulation support for running amd64 Docker images
sudo apt install qemu-user-static

# Clone PyNQ examples
git clone https://github.com/Xilinx/Kria-PYNQ
cd Kria-PYNQ && sudo bash install.sh -b KR260
