### ![Fedora](icons/fedora.png) Fedora based support


Including Nobara and Ultramarine.


1. Enable the jc141 copr.


```sh
sudo dnf copr enable jc141/DwarFS
```


2. Install the required packages.


```sh
# core packages
sudo dnf install dwarfs wine fuse-overlayfs bubblewrap

# optional dependencies, very likely to be needed by some games
sudo dnf install {alsa-{lib,plugins-{a52,arcamav,avtp,jack,lavrate,maemo,oss,pulseaudio,samplerate,speex,upmix,usbstream,vdownmix}},pulseaudio-libs,pipewire,openal-soft,libxcrypt-compat,gstreamer1-plugins-{good,base},SDL2_{ttf,image}}{.i686,.x86_64} libgphoto2
```


<br>

##### AMD/Intel APU/GPUs only


```sh
sudo dnf install {mesa-vulkan-drivers,vulkan-loader}{.i686,.x86_64}
```


<br>


##### NVIDIA GPUs only


```sh
sudo dnf install https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```


```sh
sudo dnf config-manager --enable fedora-cisco-openh264
```


```sh
sudo dnf install akmod-nvidia {vulkan-loader,libglvnd}{.i686,.x86_64}
```

<br>

##### Install Gamescope (**OPTIONAL**)

Prevents games from locking in the user focus, provides many more features. 

Nvidia proprietary driver needs [additional configuration to work](https://wiki.archlinux.org/title/NVIDIA#DRM_kernel_mode_setting) or use [Nouveau/NVK](https://wiki.archlinux.org/title/Nouveau) driver instead (might be disappointed for now if you play hungry games).

```sh
sudo dnf install gamescope
```