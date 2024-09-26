### ![Arch](icons/arch.png) Arch based


Including: Endeavour OS, Artix, CachyOS.

Copy and paste the following commands into your terminal.

<br>

1. Add the rumpowered repository.

- If you particularly care about not adding third party repos, you could install it from another source like AUR etc. Doesn't matter.


```sh
echo '
[rumpowered]
Server = https://jc141x.github.io/rumpowered-packages/$arch ' | sudo tee -a /etc/pacman.conf
```
2. Add the multilib repo and sign keys for rumpowered.


```sh
sudo sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
sudo pacman-key --recv-keys cc7a2968b28a04b3
sudo pacman-key --lsign-key cc7a2968b28a04b3
```


3. Force refresh all packages (even if in-date) and update.


```sh
sudo pacman -Syyu
```


4. Install the required packages. (remove dwarfs from the command if you skipped step one)


```sh
# core packages
sudo pacman -S --needed dwarfs fuse-overlayfs bubblewrap wine

# optional dependencies, very likely to be needed by some games
sudo pacman -S --needed {lib32-,}{alsa-plugins,libpulse,pipewire,openal,libxcrypt-compat,gst-plugins-{good,base,base-libs},sdl2_ttf,sdl2_image} libgphoto2
```

<br>


##### AMD APU/GPUs only


```sh
sudo pacman -S --needed {lib32-,}{vulkan-radeon,vulkan-icd-loader}
```
For AMD GPUs please ensure that you do not have installed improper drivers with `sudo pacman -R amdvlk && sudo pacman -R vulkan-amdgpu-pro`. This software breaks the proper driver.


<br>


##### INTEL APU/GPUs only


```sh
sudo pacman -S --needed {lib32-,}{vulkan-intel,vulkan-icd-loader}
```


<br>


##### NVIDIA GPUs only


```sh
sudo pacman -S --needed {lib32-,}{libglvnd,nvidia-utils,vulkan-icd-loader} nvidia
```

<br>

##### Install Gamescope (**OPTIONAL**)

Prevents games from locking in the user focus, provides many more features. 

Nvidia proprietary driver needs [additional configuration to work](https://wiki.archlinux.org/title/NVIDIA#DRM_kernel_mode_setting) or use [Nouveau/NVK](https://wiki.archlinux.org/title/Nouveau) driver instead (might be disappointed for now if you play hungry games).

```sh
sudo pacman -S --needed gamescope
```