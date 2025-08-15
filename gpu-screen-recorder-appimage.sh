#!/bin/sh

set -eux

ARCH="$(uname -m)"
URUNTIME="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/uruntime2appimage.sh"
SHARUN="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/quick-sharun.sh"

VERSION="$(pacman -Q gpu-screen-recorder | awk '{print $2; exit}')"
[ -n "$VERSION" ] && echo "$VERSION" > ~/version

export ADD_HOOKS="self-updater.bg.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export OUTNAME=gpu-screen-recorder-"$VERSION"-anylinux-"$ARCH".AppImage
export DESKTOP=/usr/share/applications/com.dec05eba.gpu_screen_recorder.desktop 
export ICON=/usr/share/icons/hicolor/128x128/apps/com.dec05eba.gpu_screen_recorder.png
export DEPLOY_OPENGL=1
export DEPLOY_PIPEWIRE=1
export PATH_MAPPING='/usr/share/gsr-ui:${SHARUN_DIR}/share/gsr-ui:/usr/share/icons/hicolor/32x32/status:${SHARUN_DIR}/share/icons/hicolor/32x32/status:/usr/share/gsr-notify:${SHARUN_DIR}/share/gsr-notify'

# ADD LIBRARIES
wget --retry-connrefused --tries=30 "$SHARUN" -O ./quick-sharun
chmod +x ./quick-sharun
./quick-sharun /usr/bin/gpu-screen-recorder* /usr/bin/gsr-*
rm -f ./AppDir/bin/gsr-global-hotkeys ./AppDir/bin/gsr-kms-server

mkdir -p ./AppDir/share/icons/hicolor/32x32
cp -rv /usr/share/icons/hicolor/32x32/status  ./AppDir/share/icons/hicolor/32x32

# hack
cp ./AppDir/sharun  ./AppDir/sharun2
cp ./AppDir/sharun  ./AppDir/sharun3

# MAKE APPIAMGE WITH URUNTIME
wget --retry-connrefused --tries=30 "$URUNTIME" -O ./uruntime2appimage
chmod +x ./uruntime2appimage
./uruntime2appimage

# make appbundle
UPINFO="$(echo "$UPINFO" | sed 's#.AppImage.zsync#*.AppBundle.zsync#g')"
wget -O ./pelf "https://github.com/xplshn/pelf/releases/latest/download/pelf_$ARCH"
chmod +x ./pelf
echo "Generating [dwfs]AppBundle..."
./pelf --add-appdir ./AppDir                  \
	--appimage-compat                         \
	--disable-use-random-workdir              \
	--add-updinfo "$UPINFO"                   \
	--compression "-C zstd:level=22 -S26 -B8" \
	--appbundle-id="com.dec05eba.gpu_screen_recorder#github.com/$GITHUB_REPOSITORY:$VERSION@$(date +%d_%m_%Y)" \
	--output-to ./gpu-screen-recorder-"$VERSION"-anylinux-"$ARCH".dwfs.AppBundle

echo "Generating zsync file..."
zsyncmake ./*.AppBundle -u ./*.AppBundle

echo "All Done!"
