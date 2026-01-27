<div align="center">

# gpu-screen-recorder-AppImage 🐧

[![GitHub Downloads](https://img.shields.io/github/downloads/pkgforge-dev/gpu-screen-recorder-AppImage/total?logo=github&label=GitHub%20Downloads)](https://github.com/pkgforge-dev/gpu-screen-recorder-AppImage/releases/latest)
[![CI Build Status](https://github.com//pkgforge-dev/gpu-screen-recorder-AppImage/actions/workflows/appimage.yml/badge.svg)](https://github.com/pkgforge-dev/gpu-screen-recorder-AppImage/releases/latest)
[![Latest Stable Release](https://img.shields.io/github/v/release/pkgforge-dev/gpu-screen-recorder-AppImage)](https://github.com/pkgforge-dev/gpu-screen-recorder-AppImage/releases/latest)

<p align="center">
  <img src="https://github.com/user-attachments/assets/c96f4e29-ffc8-42c1-b585-b28d82a61cd9" width="128" />
</p>


| Latest Stable Release | Upstream URL |
| :---: | :---: |
| [Click here](https://github.com/pkgforge-dev/gpu-screen-recorder-AppImage/releases/latest) | [Click here](https://git.dec05eba.com/gpu-screen-recorder/about) |

</div>

---

* The AppImage defaults to running `gpu-screen-recorder-gtk`.

* in order to launch the ui overlay you can:

```
# symlink or rename the appimage as 'gsr-ui'
ln -s ./gpu-screen-recorder-anylinux-x86_64.AppImage ./gsr-ui
./gsr-ui
```

```
# pass 'gsr-ui' as first argument to the AppImage
./gpu-screen-recorder-anylinux-x86_64.AppImage gsr-ui
```

* And so on for `gpu-screen-recorder` and all other bundled binaries.

---

AppImage made using [sharun](https://github.com/VHSgunzo/sharun) and its wrapper [quick-sharun](https://github.com/pkgforge-dev/Anylinux-AppImages/blob/main/useful-tools/quick-sharun.sh), which makes it extremely easy to turn any binary into a portable package reliably without using containers or similar tricks. 

**This AppImage bundles everything and it should work on any Linux distro, including old and musl-based ones.**

This AppImage doesn't require FUSE to run at all, thanks to the [uruntime](https://github.com/VHSgunzo/uruntime).

It is possible that this appimage may fail to work with appimagelauncher, I recommend these alternatives instead: 

* [AM](https://github.com/ivan-hc/AM) `am -i gpu-screen-recorder` or `appman -i gpu-screen-recorder`

* [dbin](https://github.com/xplshn/dbin) `dbin install gpu-screen-recorder.appimage`

* [soar](https://github.com/pkgforge/soar) `soar install gpu-screen-recorder`

This AppImage is also supplied with a self-updater by default, so any updates to this application won't be missed, you will be prompted for permission to check for updates and if agreed you will then be notified when a new update is available.

Self-updater is disabled by default if AppImage managers like [am](https://github.com/ivan-hc/AM), [soar](https://github.com/pkgforge/soar) or [dbin](https://github.com/xplshn/dbin) exist, which manage AppImage updates.

<details>
  <summary><b><i>raison d'être</i></b></summary>
    <img src="https://github.com/user-attachments/assets/d40067a6-37d2-4784-927c-2c7f7cc6104b" alt="Inspiration Image">
  </a>
</details>

---

More at: [AnyLinux-AppImages](https://pkgforge-dev.github.io/Anylinux-AppImages/)
