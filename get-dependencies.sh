#!/bin/sh

set -ex
ARCH="$(uname -m)"

pacman -Syu --noconfirm       \
	alsa-lib                \
	base-devel              \
	cairo                   \
	cmake                   \
	curl                    \
	desktop-file-utils      \
	ffmpeg                  \
	gcc-libs                \
	gdk-pixbuf2             \
	git                     \
	glib2                   \
	glibc                   \
	gtk3                    \
	hicolor-icon-theme      \
	libayatana-appindicator \
	libglvnd                \
	libpulse                \
	libx11                  \
	libxrandr               \
	libxss                  \
	mesa                    \
	meson                   \
	pango                   \
	pipewire-audio          \
	pulseaudio              \
	pulseaudio-alsa         \
	vulkan-headers          \
	vulkan-icd-loader       \
	wget                    \
	xorg-server-xvfb        \
	zlib                    \
	zsync

case "$ARCH" in
	'x86_64')
		PKG_TYPE='x86_64.pkg.tar.zst'
		pacman -Syu --noconfirm libva-intel-driver intel-media-driver
		;;
	'aarch64') PKG_TYPE='aarch64.pkg.tar.xz';;
	''|*) echo "Unknown arch: $ARCH"; exit 1;;
esac

sudo pacman -Syu --noconfirm mesa ffmpeg

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
	makepkg -f
	ls -la .
	pacman --noconfirm -U *.pkg.tar.*
)

# now the rest
git clone https://aur.archlinux.org/gpu-screen-recorder-gtk.git ./gpu-gtk && (
	cd ./gpu-gtk
	sed -i -e "s|x86_64|$ARCH|" ./PKGBUILD
	makepkg -f
	ls -la .
	pacman --noconfirm -U *.pkg.tar.*
)

git clone https://aur.archlinux.org/gpu-screen-recorder-notification.git ./notification && (
	cd ./notification
	sed -i -e "s|x86_64|$ARCH|" ./PKGBUILD
	makepkg -f
	ls -la .
	pacman --noconfirm -U *.pkg.tar.*
)

git clone https://aur.archlinux.org/gpu-screen-recorder-ui.git ./gpu-ui && (
	cd ./gpu-ui
	sed -i -e "s|x86_64|$ARCH|" ./PKGBUILD
	makepkg -f
	ls -la .
	pacman --noconfirm -U *.pkg.tar.*
)

rm -rf ./gpu-ui ./notification ./gpu-gtk ./gpu-screen-recorder

echo "All done!"
echo "---------------------------------------------------------------"
