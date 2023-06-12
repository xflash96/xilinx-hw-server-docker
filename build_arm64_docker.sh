#!/bin/bash
#
# Build the arm64 docker for hw_server
# 
# Only works for Vivado version >= 2023.1
# Tested on: kr260
#
# ref: * https://support.xilinx.com/s/question/0D52E00006jD1jESAS/is-porting-hwserver-to-aarch-on-the-roadmap?language=en_US
#      * https://www.xilinx.com/member/forms/download/smartlynqplus2022-2-unified-eula-xef.html?filename=smartlynq-plus-app-pkg-2022-2.zip

set -x

export VIVADO_VER=2023.1
export VIVADO_PATH=/tools/Xilinx/Vivado/${VIVADO_VER}

if [ ! -f "./smartlynq-plus-app-pkg-2022-2.zip" ]
then
	echo "Please download the following file and place it under this directory."
	echo "https://www.xilinx.com/member/forms/download/smartlynqplus2022-2-unified-eula-xef.html?filename=smartlynq-plus-app-pkg-2022-2.zip"
	exit 0
fi

# Get the arm64 .so files
unizp -o ./smartlynq-plus-app-pkg-2022-2.zip
unzip -o -j ./installer.zip hwserver-2022.2.0.slpkg
tar xf hwserver-2022.2.0.slpkg

# Clone the labtools with arm64 debug utils
git -C systemctl-labtool pull || git clone https://github.com/Xilinx/systemctl-labtool
git -C systemctl-labtool checkout 9c94bde28c95a8c8b8d5fb36ac6d56e17361d30d # actually not xlnx_rel_v2023.1..

# copying files
export TARGET=build/arm64
rm -rf ${TARGET} && mkdir -p ${TARGET}
cp -r ./systemctl-labtool/usr/local/* ${TARGET}
cp -r ./systemctl-labtool/usr/lib/* ${TARGET}/lib
cp -r ./data/rootfs/usr/lib/* ${TARGET}/lib
mkdir -p ${TARGET}/digilent_cable
cp -r $VIVADO_PATH/data/xicom/cable_data/digilent/lnx64/* ${TARGET}/digilent_cable

# NOTE: we may also extract the so file from the digilent arm64 runtime deb 
# from https://mautic.digilentinc.com/adept-runtime-download

# docker run --privileged --rm tonistiigi/binfmt --install all
docker buildx build --platform=linux/arm64 \
	-f Dockerfile.arm64 -t hw_server:arm64-${VIVADO_VER} \
	--output type=docker \
	.

docker save -o hw_server.arm64-${VIVADO_VER}.tar hw_server:arm64-${VIVADO_VER}
gzip hw_server.arm64-${VIVADO_VER}.tar
