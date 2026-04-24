#!/bin/sh

set -eux

ARCH=$(uname -m)
VERSION=$(pacman -Q gpu-screen-recorder | awk '{print $2; exit}') # example command to get version of application here
export ARCH VERSION
export ADD_HOOKS="self-updater.bg.hook"
export OUTPATH=./dist
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export APPNAME=gpu-screen-recorder
export DESKTOP=/usr/share/applications/com.dec05eba.gpu_screen_recorder.desktop
export ICON=/usr/share/icons/hicolor/128x128/apps/com.dec05eba.gpu_screen_recorder.png
export DEPLOY_OPENGL=1
export DEPLOY_PIPEWIRE=1
export URUNTIME_PRELOAD=1

# Deploy dependencies
quick-sharun \
	/usr/bin/gpu-screen-recorder* \
	/usr/bin/gsr-*                \
	/usr/bin/getcap               \
	/usr/bin/setcap               \
	/usr/lib/libturbojpeg.so*

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the test fails due to the app
# having issues running in the CI use --simple-test instead
quick-sharun --simple-test ./dist/*.AppImage
