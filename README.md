# gpu-screen-recorder-AppImage

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

--------------------------------------------------------------------------------

AppImage made using [sharun](https://github.com/VHSgunzo/sharun), which makes it extremely easy to turn any binary into a portable package without using containers or similar tricks.

**This AppImage bundles everything and should work on any linux distro, even on musl based ones.**

It is possible that this appimage may fail to work with appimagelauncher, I recommend these alternatives instead: 

* [AM](https://github.com/ivan-hc/AM) `am -i gpu-screen-recorder` or `appman -i gpu-screen-recorder`

* [dbin](https://github.com/xplshn/dbin) `dbin install gpu-screen-recorder.appimage`

* [soar](https://github.com/pkgforge/soar) `soar install gpu-screen-recorder`

This appimage works without fuse2 as it can use fuse3 instead, it can also work without fuse at all thanks to the [uruntime](https://github.com/VHSgunzo/uruntime)

<details>
  <summary><b><i>raison d'être</i></b></summary>
    <img src="https://github.com/user-attachments/assets/d40067a6-37d2-4784-927c-2c7f7cc6104b" alt="Inspiration Image">
  </a>
</details>

