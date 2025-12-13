#!/bin/sh

set -eu
ARCH="$(uname -m)"
EXTRA_PACKAGES="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/get-debloated-pkgs.sh"
PACKAGE_BUILDER="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/make-aur-package.sh"

pacman -Syu --noconfirm \
	base-devel        \
	cmake             \
	curl              \
	git               \
	libx11            \
	libxrandr         \
	libxss            \
	meson             \
	pipewire-audio    \
	pulseaudio        \
	pulseaudio-alsa   \
	vulkan-headers    \
	vulkan-icd-loader \
	wget              \
	xorg-server-xvfb  \
	zlib              \
	zsync

if [ "$ARCH" = 'x86_64' ]; then
		pacman -Syu --noconfirm libva-intel-driver
fi

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
wget --retry-connrefused --tries=30 "$EXTRA_PACKAGES" -O ./get-debloated-pkgs.sh
chmod +x ./get-debloated-pkgs.sh
./get-debloated-pkgs.sh --add-common --prefer-nano intel-media-driver-mini ffmpeg-mini

# Make the thing
echo "Building gpu-screen-recorder..."
echo "---------------------------------------------------------------"
wget --retry-connrefused --tries=30 "$PACKAGE_BUILDER" -O ./make-aur-package.sh
chmod +x ./make-aur-package.sh

# modify gpu-screen-recorder to build without systemd and wihtout caps
PRE_BUILD_CMDS="sed -i 's|-Dsystemd=true|-Dsystemd=false -Dcapabilities=false|' ./PKGBUILD" \
	./make-aur-package.sh gpu-screen-recorder

# now the rest
./make-aur-package.sh gpu-screen-recorder-gtk
./make-aur-package.sh gpu-screen-recorder-notification
./make-aur-package.sh gpu-screen-recorder-ui

pacman -Q gpu-screen-recorder | awk '{print $2; exit}' > ~/version

echo "All done!"
echo "---------------------------------------------------------------"
