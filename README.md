# Xilinx hw_server & xsdb Docker Image

This Docker image allows you to run Xilinx's `hw_server` as well as the Xilinx debugger `xsdb` in a Docker container.
The difference from the original repo is that
- Support both native arm64 runtime & qemu-emulated amd64 runtime
- Build from existing toolchain (not using multistage built)
- Multi-platform docker image
- Updated Vivado 2023.1 toolchain

![Setup](./docs/setup.png)

## Tested systems

- Raspberry Pi 4 with 64-bit Raspberry Pi OS (Debian Bullseye)
- KR260 (ubuntu)

## Usage

### Docker (arm64)

Please download the https://www.xilinx.com/member/forms/download/smartlynqplus2022-2-unified-eula-xef.html?filename=smartlynq-plus-app-pkg-2022-2.zip
and place it under the repo. Assume the vivado 2023.1 toolchain is installed under /tools/Xilinx/. Generate the docker image by
```bash
./build_arm64_docker.sh
```
This generates a docker image hw_server.arm64-2023.tar.gz that we can use anywhere.

Next, clone the repo on the Kria board / Raspberry Pi by
```bash
git clone https://github.com/xflash96/xilinx-hw-server-docker
```
and copy the hw_server.arm64-2023.tar.gz we generated to the board. Then run
```bash
./init_kria.sh 		# install docker & utilities (optional)
./install_hw_server.sh  # install the hw_server & services
```

### Docker (amd64)

```bash
./build_amd64_docker.sh
```
This generates a docker image hw_server.amd64-2023.tar.gz.
Next, clone the repo on the Kria board / Raspberry Pi by
```bash
git clone https://github.com/xflash96/xilinx-hw-server-docker
```
and modify the commented line in ./install_hw_server.sh (for amd64).
Copy the hw_server.amd64-2023.tar.gz we generated to the board. Then run
```bash
./init_kria.sh 		# install docker & utilities (optional)
./install_hw_server.sh  # install the hw_server & services
```
for other details, see the original repo at https://github.com/stv0g/xilinx-hw-server-docker .
