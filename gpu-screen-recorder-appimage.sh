#!/bin/sh

set -ex

ARCH="$(uname -m)"
URUNTIME="https://github.com/VHSgunzo/uruntime/releases/latest/download/uruntime-appimage-dwarfs-$ARCH"
URUNTIME_LITE="https://github.com/VHSgunzo/uruntime/releases/latest/download/uruntime-appimage-dwarfs-lite-$ARCH"
UPINFO="gh-releases-zsync|$(echo $GITHUB_REPOSITORY | tr '/' '|')|latest|*$ARCH.AppImage.zsync"
SHARUN="https://github.com/VHSgunzo/sharun/releases/latest/download/sharun-$ARCH-aio"

VERSION="$(pacman -Q gpu-screen-recorder | awk '{print $2; exit}')"
echo "$VERSION" > ~/version

# Prepare AppDir
mkdir -p ./AppDir/share/icons/hicolor/32x32 && (
	cd ./AppDir

	cp -rv /usr/share/gsr-ui                      ./share
	cp -rv /usr/share/icons/hicolor/32x32/status  ./share/icons/hicolor/32x32

	cp -v /usr/share/applications/com.dec05eba.gpu_screen_recorder.desktop           ./
	cp -v /usr/share/icons/hicolor/128x128/apps/com.dec05eba.gpu_screen_recorder.png ./
	cp -v /usr/share/icons/hicolor/128x128/apps/com.dec05eba.gpu_screen_recorder.png ./.DirIcon

	# ADD LIBRARIES
	wget --retry-connrefused --tries=30 "$SHARUN" -O ./sharun-aio
	chmod +x ./sharun-aio
	xvfb-run -a \
		./sharun-aio l -p -v -e -s -k \
		/usr/bin/gpu-screen-recorder* \
		/usr/bin/gsr-*                \
		/usr/lib/gdk-pixbuf-*/*/*/*   \
		/usr/lib/pulseaudio/*         \
		/usr/lib/pipewire-*/*         \
		/usr/lib/spa-0.2/*/*          \
		/usr/lib/libavutil.so*        \
		/usr/lib/libavformat.so*      \
		/usr/lib/lib*GL*              \
		/usr/lib/dri/*                \
		/usr/lib/vdpau/*              \
		/usr/lib/gconv/*

	rm -f ./sharun-aio ./bin/gsr-global-hotkeys ./bin/gsr-kms-server

	# hack
	cp ./sharun  ./sharun2
	cp ./sharun  ./sharun3

	# sus
	sed -i 's|/usr/share|././/share|g' ./shared/bin/*

	echo 'LIBVA_DRIVERS_PATH=${SHARUN_DIR}/shared/lib:${SHARUN_DIR}/shared/lib/dri' >> ./.env
	chmod +x ./AppRun
	./sharun -g
)

# MAKE APPIAMGE WITH URUNTIME
wget --retry-connrefused --tries=30 "$URUNTIME"      -O ./uruntime
wget --retry-connrefused --tries=30 "$URUNTIME_LITE" -O ./uruntime-lite
chmod +x ./uruntime*

# Add udpate info to runtime
echo "Adding update information \"$UPINFO\" to runtime..."
./uruntime-lite --appimage-addupdinfo "$UPINFO"

echo "Generating AppImage..."
./uruntime --appimage-mkdwarfs -f        \
	--set-owner 0 --set-group 0          \
	--no-history --no-create-timestamp   \
	--compression zstd:level=22 -S26 -B8 \
	--header uruntime-lite               \
	-i ./AppDir -o ./gpu-screen-recorder-"$VERSION"-anylinux-"$ARCH".AppImage

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
zsyncmake ./*.AppImage -u ./*.AppImage
zsyncmake ./*.AppBundle -u ./*.AppBundle

echo "All Done!"
