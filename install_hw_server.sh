#!/bin/bash
export VIVADO_VER=2023.1
export ARCH=arm64 # modify to amd64 if you'd like to use qemu
set -x

# Load hw_server docker image
if [ ! -f  hw_server.${ARCH}.$VIVADO_VER.tar.gz ]
then
	echo "Please copy the generated tar.gz file from the host."
	exit 0
fi
docker load -i hw_server.${ARCH}.$VIVADO_VER.tar.gz

# Install udev rules
# There are other rules under data/xicom/cable_drivers/lin64/install_script/install_drivers/
# but Kria only need the FTDI patch
if [ ! -f /etc/udev/rules.d/52-xilinx-ftdi-usb.rules ]
then
sudo bash -c 'cat << EOF > /etc/udev/rules.d/52-xilinx-ftdi-usb.rules
ACTION=="add", ATTR{idVendor}=="0403", ATTR{manufacturer}=="Xilinx", MODE:="666"
EOF'
udevadm control --reload-rules && udevadm trigger
fi

# Setup hw_server as a service
if [ ! -f /etc/ssytemd/system/hw_server.service ]
then
sudo bash -c "cat << EOF > /etc/systemd/system/hw_server.service
[Unit]
Description=Starts xilinx hardware server
After=docker-qemu-interpreter.service
Requires=docker.service

[Service]
Type=forking
PIDFile=/run/hw_server.pid
TimeoutStartSec=infinity
Restart=always
ExecStart=/usr/bin/docker run --rm --name hw_server --privileged --platform linux/${ARCH} --volume /dev/bus/usb:/dev/bus/usb --network host --detach hw_server:arm64-${VIVADO_VER}
ExecStartPost=/bin/bash -c '/usr/bin/docker inspect -f '{{.State.Pid}}' hw_server | tee /run/hw_server.pid'
ExecStop=/usr/bin/docker stop hw_server

[Install]
WantedBy=multi-user.target
EOF"
systemctl daemon-reload
systemctl enable --now hw_server
fi

# When the JTag mode starts, the Zynq MPSoc PS hangs because CPU enter idle mode.
# This is a bug described in https://support.xilinx.com/s/article/69143?language=en_US ,
# and the solution is to add cpuidle.off=1 to the kernel bootarg
# See https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/2363129857/Getting+Started+with+Certified+Ubuntu+22.04+LTS+for+Xilinx+Devices for how to modify bootarg
sudo bash -c 'cat << EOF > /etc/default/flash-kernel
LINUX_KERNEL_CMDLINE="quiet splash cpuidle.off=1"
LINUX_KERNEL_CMDLINE_DEFAULTS=""
EOF'
sudo flash-kernel
