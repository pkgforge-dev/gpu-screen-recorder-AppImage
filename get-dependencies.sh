#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	cmake                   \
	libayatana-appindicator \
	libcap                  \
	libjpeg-turbo           \
	libxcursor              \
	libxdamage              \
	libxext                 \
	libxfixes               \
	libxi                   \
	libxcomposite           \
	libxrender              \
	libx11                  \
	libxrandr               \
	libxss                  \
	linux-api-headers       \
	meson                   \
	nasm                    \
	libpipewire             \
	vulkan-headers          \
	zlib

if [ "$ARCH" = 'x86_64' ]; then
	pacman -Syu --noconfirm libva-intel-driver
fi

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano intel-media-driver-mini

# build each gpu-screen-recorder binary manually
REPOS_SOURCE=https://repo.dec05eba.com

build_gsr_bin() (
	repo=$1
	shift

	echo "Building $REPOS_SOURCE/$repo..."
	echo "---------------------------------------------------------------"
	git clone "$REPOS_SOURCE"/"$repo" ./"$repo"
	cd ./"$repo"

	git fetch --tags origin
	TAG=$(git tag --sort=-v:refname | grep -vi 'rc\|alpha\|beta' | head -1)
	git checkout "$TAG"

	meson setup build --prefix=/usr --libdir=lib --buildtype=release "$@"
	meson compile -C build
	meson install -C build

	if [ "$repo" = 'gpu-screen-recorder' ]; then
		echo "$TAG" > ~/version
	fi
)

build_gsr_bin gpu-screen-recorder -Dsystemd=false -Dcapabilities=false -Dffmpeg_static=true
build_gsr_bin gpu-screen-recorder-notification
build_gsr_bin gpu-screen-recorder-ui
build_gsr_bin gpu-screen-recorder-gtk

