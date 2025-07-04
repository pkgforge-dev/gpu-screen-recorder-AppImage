#!/bin/sh

set -ex

export ARCH="$(uname -m)"
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
	ln ./sharun2 ./bin/gsr-global-hotkeys
	ln ./sharun3 ./bin/gsr-kms-server

	# sus
	sed -i 's|/usr/share|././/share|g' ./shared/bin/*

	# Prepare sharun
	cat > ./AppRun <<-'EOF'
	#!/bin/sh
	set -e
	APPDIR="$(cd "${0%/*}" && echo "$PWD")"
	BIN="${ARGV0:-$0}"
	BIN="${BIN#./}"
	unset ARGV0

	dependencies="getcap pkexec"
	for dep in $dependencies; do
		if ! command -v $dep 1>/dev/null; then
			>&2 echo "ERROR: Missing dependency '$dep'"
			notify-send -u critical "ERROR: Missing dependency '$dep'"
			exit 1
		fi
	done

	mkdir -p /tmp/.gsr-appimage-hack/bin

	# change working dir since we did binary patching
	cd /tmp/.gsr-appimage-hack

	# hack to get capabities working
	if [ ! -f /tmp/.gsr-appimage-hack/sharun ]; then
	        cp "$APPDIR"/sharun* ./
	        cp "$APPDIR"/.env    ./
	        ln -f ./sharun  ./bin/gpu-screen-recorder
	        ln -f ./sharun  ./bin/gpu-screen-recorder-gtk
	        ln -f ./sharun  ./bin/gsr-dbus-server
	        ln -f ./sharun  ./bin/gsr-notify
	        ln -f ./sharun  ./bin/gsr-ui
	        ln -f ./sharun  ./bin/gsr-cli
	        ln -f ./sharun2 ./bin/gsr-global-hotkeys
	        ln -f ./sharun3 ./bin/gsr-kms-server
	fi

	ln -sfn "$APPDIR"/etc     /tmp/.gsr-appimage-hack/etc
	ln -sfn "$APPDIR"/lib     /tmp/.gsr-appimage-hack/lib
	ln -sfn "$APPDIR"/share   /tmp/.gsr-appimage-hack/share
	ln -sfn "$APPDIR"/shared  /tmp/.gsr-appimage-hack/shared

	if [ -z "$(getcap /tmp/.gsr-appimage-hack/bin/*)" ]; then
	        pkexec sh -c 'setcap cap_setuid+ep /tmp/.gsr-appimage-hack/bin/gsr-global-hotkeys \
	                && setcap cap_sys_admin+ep /tmp/.gsr-appimage-hack/bin/gsr-kms-server'
	fi

	# This doesn't work because this program uses pidof internall, so when ARGV0 is
	# gsr-ui the program detects the pidof of the AppImage as the actual binary wtf
	#if [ -f ./bin/"$BIN" ]; then
	#        exec ./bin/"$BIN" "$@"

	if [ -n "$1" ] && [ -f ./bin/"$1" ]; then
	        BIN="$1"
	        shift
	        exec ./bin/"$BIN" "$@"
	else
	        exec ./bin/gpu-screen-recorder-gtk "$@"
	fi
	EOF

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
