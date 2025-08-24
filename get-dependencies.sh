#!/bin/sh

set -ex
ARCH="$(uname -m)"
EXTRA_PACKAGES="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/get-debloated-pkgs.sh"

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
./get-debloated-pkgs.sh --add-common --prefer-nano intel-media-driver-mini

# Make the thing
echo "Building gpu-screen-recorder..."
echo "---------------------------------------------------------------"
sed -i 's|EUID == 0|EUID == 69|g' /usr/bin/makepkg
sed -i 's|-O2|-O3|; s|MAKEFLAGS=.*|MAKEFLAGS="-j$(nproc)"|; s|#MAKEFLAGS|MAKEFLAGS|' /etc/makepkg.conf
cat /etc/makepkg.conf

git clone https://aur.archlinux.org/gpu-screen-recorder.git ./gpu-screen-recorder && (
	cd ./gpu-screen-recorder
	sed -i -e "s|x86_64|$ARCH|" ./PKGBUILD
	# modify gpu-screen-recorder to build without systemd and wihtout caps
	sed -i 's|-Dsystemd=true|-Dsystemd=false -Dcapabilities=false|' ./PKGBUILD
	makepkg -fs --noconfirm
	ls -la .
	pacman --noconfirm -U ./*.pkg.tar.*
)

# now the rest
git clone https://aur.archlinux.org/gpu-screen-recorder-gtk.git ./gpu-gtk && (
	cd ./gpu-gtk
	sed -i -e "s|x86_64|$ARCH|" ./PKGBUILD
	makepkg -fs --noconfirm
	ls -la .
	pacman --noconfirm -U ./*.pkg.tar.*
)

git clone https://aur.archlinux.org/gpu-screen-recorder-notification.git ./notification && (
	cd ./notification
	sed -i -e "s|x86_64|$ARCH|" ./PKGBUILD
	makepkg -fs --noconfirm
	ls -la .
	pacman --noconfirm -U ./*.pkg.tar.*
)

git clone https://aur.archlinux.org/gpu-screen-recorder-ui.git ./gpu-ui && (
	cd ./gpu-ui
	sed -i -e "s|x86_64|$ARCH|" ./PKGBUILD
	makepkg -fs --noconfirm
	ls -la .
	pacman --noconfirm -U ./*.pkg.tar.*
)

rm -rf ./gpu-ui ./notification ./gpu-gtk ./gpu-screen-recorder

echo "All done!"
echo "---------------------------------------------------------------"
