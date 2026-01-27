#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	cmake             \
	libx11            \
	libxrandr         \
	libxss            \
	meson             \
	pipewire-audio    \
	pipewire-jack     \
	vulkan-headers    \
	zlib

if [ "$ARCH" = 'x86_64' ]; then
		pacman -Syu --noconfirm libva-intel-driver
fi

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano intel-media-driver-mini ffmpeg-mini

# Make the thing
echo "Building gpu-screen-recorder..."
echo "---------------------------------------------------------------"
# modify gpu-screen-recorder to build without systemd and wihtout caps
PRE_BUILD_CMDS="sed -i 's|-Dsystemd=true|-Dsystemd=false -Dcapabilities=false|' ./PKGBUILD" make-aur-package gpu-screen-recorder
# now the rest
make-aur-package gpu-screen-recorder-gtk
make-aur-package gpu-screen-recorder-notification
make-aur-package gpu-screen-recorder-ui

# add zenity-rs-bin that way we always have a guaranteed GUI to ask for password to set caps
make-aur-package zenity-rs-bin
