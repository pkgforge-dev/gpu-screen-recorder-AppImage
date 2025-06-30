#!/bin/sh

set -ex

sed -i 's/DownloadUser/#DownloadUser/g' /etc/pacman.conf
ARCH="$(uname -m)"

if [ "$ARCH" = 'x86_64' ]; then
	PKG_TYPE='x86_64.pkg.tar.zst'
else
	PKG_TYPE='aarch64.pkg.tar.xz'
fi

LLVM_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/llvm-libs-nano-$PKG_TYPE"
FFMPEG_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/ffmpeg-mini-$PKG_TYPE"
LIBXML_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/libxml2-iculess-$PKG_TYPE"
OPUS_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/opus-nano-$PKG_TYPE"
MESA_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/mesa-mini-$PKG_TYPE"

echo "Installing dependencies..."
echo "---------------------------------------------------------------"
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
	intel-media-driver      \
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

echo "Installing debloated pckages..."
echo "---------------------------------------------------------------"
wget --retry-connrefused --tries=30 "$LLVM_URL"   -O  ./llvm-libs.pkg.tar.zst
wget --retry-connrefused --tries=30 "$LIBXML_URL" -O  ./libxml2.pkg.tar.zst
wget --retry-connrefused --tries=30 "$FFMPEG_URL" -O  ./ffmpeg.pkg.tar.zst
wget --retry-connrefused --tries=30 "$OPUS_URL"   -O  ./opus.pkg.tar.zst
wget --retry-connrefused --tries=30 "$MESA_URL"   -O  ./mesa.pkg.tar.zst

pacman -U --noconfirm ./*.pkg.tar.zst
rm -f ./*.pkg.tar.zst

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
