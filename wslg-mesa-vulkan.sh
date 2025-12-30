#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive
echo "deb-src http://deb.debian.org/debian trixie-backports main" >> /etc/apt/sources.list
apt-get update
apt-get install -y build-essential devscripts equivs git wget

apt-get build-dep -y mesa

mkdir build_work
cd build_work
apt-get source mesa
cd mesa-*

sed -i '/ifneq (,$(filter $(DEB_HOST_ARCH), amd64 arm64))/a \ \ \ \ GALLIUM_DRIVERS += d3d12\n\ \ \ \ VULKAN_DRIVERS += microsoft-experimental' debian/rules

echo "usr/bin/spirv2dxil" >> debian/mesa-vulkan-drivers.install
echo "usr/lib/*/libspirv_to_dxil.so" >> debian/mesa-vulkan-drivers.install

CURRENT_VER=$(dpkg-parsechangelog -S Version)
dch --newversion "1:$CURRENT_VER+wsl" "Automated build with d3d12 and microsoft-experimental enabled"
dch --release ""

dpkg-buildpackage -us -uc -b -j$(nproc)

cd ../..
mkdir -p output
mv build_work/*.deb output/
