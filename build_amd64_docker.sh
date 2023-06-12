#!/bin/bash
# Build the amd64 docker for hw_server
# This method works for all version of Vivado but requres runnig qemu on arm64.
#
# ref:
#  * https://github.com/stv0g/xilinx-hw-server-docker
#  * https://github.com/RWTH-ACS/miob/blob/main/sw/rpi/hw_server/hw_server.service
#  * https://zenn.dev/ciniml/articles/rpi_hwserver

export VIVADO_VER=2023.1
export VIVADO_PATH=/tools/Xilinx/Vivado/${VIVADO_VER}

export TARGET=build/amd64

# Clone the labtool for its tcl
git -C systemctl-labtool pull || git clone https://github.com/Xilinx/systemctl-labtool
git -C systemctl-labtool checkout 9c94bde28c95a8c8b8d5fb36ac6d56e17361d30d # actually not xlnx_rel_v2023.1..

rm -rf ${TARGET} && mkdir -p ${TARGET}
mkdir -p ${TARGET}/lib
mkdir -p ${TARGET}/bin

# hw_server
cp $VIVADO_PATH/bin/unwrapped/lnx64.o/hw_server ${TARGET}/bin/
cp $VIVADO_PATH/lib/lnx64.o/libxftdi.so \
	$VIVADO_PATH/lib/lnx64.o/libdpcomm.so.2 \
	$VIVADO_PATH/lib/lnx64.o/libjtsc.so.2 \
	$VIVADO_PATH/lib/lnx64.o/libdftd2xx.so.1 \
	$VIVADO_PATH/lib/lnx64.o/libdabs.so.2 \
	$VIVADO_PATH/lib/lnx64.o/libdmgr.so.2  \
	$VIVADO_PATH/lib/lnx64.o/libusb-1.0.so.0 \
	$VIVADO_PATH/lib/lnx64.o/libdjtg.so.2 \
	${TARGET}/lib/

# XSDB
cp $VIVADO_PATH/lib/lnx64.o/libtcl8.5.so \
	$VIVADO_PATH/lib/lnx64.o/libtcltcf.so \
	${TARGET}/lib/

cp -R $VIVADO_PATH/tps/tcl/tcl8.5 ${TARGET}/lib/
cp -R ./systemctl-labtool/usr/local/xilinx_vitis ${TARGET}/
cp $VIVADO_PATH/bin/unwrapped/lnx64.o/rdi_xsdb ${TARGET}/xilinx_vitis/

# CS_SERVER
cp $VIVADO_PATH/bin/unwrapped/lnx64.o/cs_server ${TARGET}/bin/

cp -R $VIVADO_PATH/data/xicom/cable_data/digilent/lnx64 ${TARGET}/digilent_cable

# build the docker
docker build -f Dockerfile.amd64 --tag hw_server:amd64-${VIVADO_VER} \
	--output type=docker \
	.

docker save -o hw_server.amd64-${VIVADO_VER}.tar hw_server:amd64-${VIVADO_VER}
gzip hw_server.amd64-${VIVADO_VER}.tar
