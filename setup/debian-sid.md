### ![Debian](icons/debian.png) Debian Sid/Unstable based support

Distros this page applies for: Sparky Rolling and Siduction

Users of Debian Stable/Testing could also switch to Sid on their already existing installation. But we won't provide the steps involved here due to them involving some commands that if not done right could result in breaking the system.

However there are [tutorials](https://www.digitalocean.com/community/tutorials/upgrading-debian-to-unstable).

<br><br><br>


1. Add required repos

#### MPR for Dwarfs package
```sh
export MAKEDEB_RELEASE='makedeb'
bash -c "$(wget -qO - 'https://shlink.makedeb.org/install')"
sudo apt update
sudo apt install git

git clone https://mpr.hunterwittenborn.com/una-bin.git
cd una-bin && makedeb -si

git clone https://mpr.makedeb.org/dwarfs-bin.git && 
cd dwarfs-bin && makedeb -si
```

<br>

#### Alternative to MPR if its unavailable.

Download the [dwarfs deb package](https://github.com/patricnilackshan/jc141/blob/main/setup/dwarfs-bin_0.9.9-1_amd64.deb) and install it on your system statically.

```sh
sudo apt install ~/Downloads/dwarfs-bin_0.9.9-1_amd64.deb
```


<br>

2. Install the required packages.

<br>

```sh
# core packages
sudo apt install fuse-overlayfs wine bubblewrap

# optional dependencies, very likely to be needed by some games
sudo dpkg --add-architecture i386

sudo apt install {libva2,libopenal1,libpulse0,gstreamer1.0-plugins-{good,base}}{:i386,} giflib-tools libgphoto2-6 libxcrypt-source gstreamer1.0-{plugins-ugly,vaapi,libav} alsa-utils libsdl2-image-2.0-0 libsdl2-ttf-2.0-0
```

<br>


##### AMD and INTEL APU/GPUs only


```sh
sudo apt install libvulkan1{:i386,} vulkan-tools
```


<br>


##### NVIDIA GPUs only


```sh
sudo apt install nvidia-driver nvidia-settings nvidia-smi nvidia-opencl-icd nvidia-opencl-common libvulkan1{:i386,}
```

<br>

##### Install Gamescope (**OPTIONAL**)

Prevents games from locking in the user focus, provides many more features. 

Nvidia proprietary driver needs [additional configuration to work](https://wiki.archlinux.org/title/NVIDIA#DRM_kernel_mode_setting) or use [Nouveau/NVK](https://wiki.archlinux.org/title/Nouveau) driver instead (might be disappointed for now if you play hungry games).

```sh
sudo apt install gamescope
```